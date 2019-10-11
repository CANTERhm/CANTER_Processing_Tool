classdef BimodalHistogram
    %BimodalHistogram: Class for the displaying of Young's modulus
    %histograms and fitting of a bimodal distribution.
    %
    % General  instructions:
    %
    %   1) Create a BimodalHistogram object (e.g. BiHist) by calling the
    %      constructor with a vector of the Young's moduli (EModul).
    %      -> For a more detailed help click on the "BimodalHistogram" link
    %         under "Constructor Summary"
    %
    %           Example:
    %           BiHist = BimodalHistogram(EModul,[0 200e3],100,'yes');
    %
    %   2) Fit a bimodal distribution on the histogram data and plot the 
    %      resulting curve, as well as the two single Gaussian
    %      distributions, the bimodal distribution consists of, to the 
    %      histogram by calling the "doFit" method of the BiHist object.
    %      -> For more details click on the "doFit" link in the "Method 
    %         Summary" section bellow.
    %    
    %           Example:
    %           BiHist = BiHist.doFit;
    %
    %   3) You can add proper axis labels and an annotation showing the
    %      two peak positions of the bimodal fit by calling the 
    %      "AddAnnotations" method of the BiHist object.
    %      -> For more details click on the "AddAnnotations" link in the
    %         "Method Summary" section below.
    %
    %           Example:
    %           BiHist = BiHist.AddAnnotations;
    %
    %   -> For any further information use the links below regarding the
    %      properties and methods of the BimodalHistogram class.
    
    
    properties
        EModul = [];        % Numeric vector containing the Young's modulus values.
        hist = [];          % The histogram handle is here available after the histogram is plotted.
        edges = [];         % Bin edges of the histogram as a numeric vector.
        BinNum = [];        % Number of histogram bins.
        BinCenters = [];    % Centers of the histogram bins as numeric vector (used as x values for the bimodal fit).
        BinWidth = [];      % Width of histogram bins.
        BinCounts = [];     % Numeric vector containing the heigths of the histogram bins (used as y values for the bimodal fit).
        gauss1 = @(a1,E1,w1,x)a1.*exp(-((x-E1)./w1).^2);	% Function handle of the first Gaussian distribution.
        gauss2 = @(a2,E2,w2,x)a2.*exp(-((x-E2)./w2).^2);	% Function handle of the secon Gaussian distribution.
        bimodal = @(a1,E1,w1,a2,E2,w2,x)a1.*exp(-((x-E1)./w1).^2)+a2.*exp(-((x-E2)./w2).^2);    % Function handle of the bimodal distribution.   
        fit_obj = [];       % The fit object is available here after the "doFit" method was executed on the BiHist object.
        parameters = struct('a1',[],'E1',[],'w1',[],'a2',[],'E2',[],'w2',[]);   % Struct containing the fittet values of the bimodal distribution are stored.
        initialGuess = struct('a1',[],'E1',[],'w1',[],'a2',[],'E2',[],'w2',[]); % Struct containing the initial guesses for the fit of the bimodal distribution.
        x_data_fit = [];    % Numeric vector of the x values used to draw the fit results.
        y_data_fit = [];    % Numeric vector of the y values used to draw the fit result of the bimodal distribution.
        y_gauss1 = [];      % Numeric vector of the y values used to draw the fit result of the first Gaussian distribution.
        y_gauss2 = [];      % Numeric vector of the y values used to draw the fit result of the second Gaussian distribution.
        annotation_obj = [];    % Handle to the annotation shown in the plot window after exectuing the "AddAnnotations" method.
        

    end
    
    methods
        function obj = BimodalHistogram(EModul,x_range,BinNum,plot_arg)
            % Constructor of the BimodalHistogram class
            % obj = BimodalHistrogram(EModul,x_range,BinNum,[plot_arg]);
            %
            % BimodalHistogram constructs an instance of this class
            %
            % Input:
            %       - EModul        -> Vector of the Young's modulus values
            %                          you want an histogram of.
            %       - x_range       -> Two element vector with the start
            %                          and the end value of the histogram-
            %                          binning range.
            %       - BinNum        -> Number of bins the x_range will be
            %                          devided in.
            %       - plot_arg      -> 'yes' (default) if you want the 
            %                          histogram to be plotted. Afterwards, 
            %                          you can use the histogram object 
            %                          saved in the property "hist".
            %                          'no' if you don't want the histogram
            %                          to be plotted. You can plot the
            %                          histogram afterward by using the
            %                          plotHist method.
            
            
            % input check of constructor
            if nargin < 3
               error('Too few input arguments!\nPlease enter at least EModul, x_range, and BinNum.\n%s',' '); 
            end
            
            if ~isnumeric(EModul)
                error('EModul must be numeric!')
            end
            
            if ~isvector(EModul)
                error('EModul must be a vector with a size of 1-by-N or N-by-1!')
            end
            
            if any(EModul<0)
                error('EModul must be only positive numbers!');
            end
            
            
            if ~isnumeric(x_range)
                error('x_range must be numeric!');
            end
            
            if ~isvector(x_range) || length(x_range) ~= 2
                error('x_range must be two element vector with a size of 1-by-2 or 2-by-1!');
            end
            
            if ~isnumeric(BinNum)
                error('BinNum must be numeric!');
            end
            
            if ~isscalar(BinNum)
                error('Too many input arguments for BinNum!\nBinNum must be a scalar.\n%s',' ');
            end
            
            if nargin < 4
                plot_arg = 'yes'; 
            end
                
            if ~any(ismember({'yes','no'},plot_arg))
                error('plot_arg must be either ''yes'' or ''no''!');
            end
            
            % calculate and assign property values
            obj.EModul = EModul(~isnan(EModul));

            edges = linspace(x_range(1),x_range(2),BinNum+1);
            obj.edges = edges';
            obj.BinNum = BinNum;
            
            switch plot_arg
                case 'yes'
                    hist = histogram(EModul,edges);
                    obj.hist = hist;

                    BinCenters = hist.BinEdges + hist.BinWidth/2;
                    BinCenters(end) = [];
                    obj.BinCenters = BinCenters;

                    obj.BinWidth = hist.BinWidth;

                    obj.BinCounts = hist.BinCounts;
                case 'no'
                    [h,h_edges] = histcounts(EModul,edges);
                    
                    BinWidth = (x_range(2)-x_range(1))/BinNum;
                    obj.BinWidth = BinWidth;
                    
                    BinCenters = h_edges + BinWidth/2;
                    BinCenters(end) = [];
                    obj.BinCenters = BinCenters';
                    
                    obj.BinCounts = h';                    
            end
        end
        
        function obj = doFit(obj,StartPoints,plot_arg)
            % Fit the bimodal distribution to the histogram data and plot the fit result.
            % 
            % Syntax:
            %   * obj = doFit(obj);
            %   * obj = obj.doFit;
            %   * obj = doFit(obj[,StartPoints,plot_arg]);
            %   * obj = obj.doFit([StartPoints,plot_arg]);
            % 
            % doFit This method calculates the bimodal fit and draws the
            % fit together with the unimodal distributions
            %
            % Input:
            %       * obj           -> BimodalHistogram object.
            %       * StartPoints   -> Start values for the fiting of the
            %                          six parameters of the bimodal
            %                          distribution [a1 E1 w1 a2 E2 w2].
            %                          If no StartPoints are defined, the
            %                          doFit method uses its own algorithm
            %                          for finding the initial guesses for
            %                          the six fitting parameters.
            %       * plot_arg      -> 'yes' (default) if you whant the
            %                          fits to be plotted.
            %                          'no' if you don't want the fits to
            %                          be plotted. You can plot the fits
            %                          anytime by using the plotFit method.
            
            
            
            % error handling for doFit method            
            if ~exist('plot_arg','var')
               plot_arg = 'yes';
            end
            
            if exist('StartPoints','var')
                
                if isvector(StartPoints)
                    error('StartPoints must be a vector with six elements!');
                end
                
                if ~length(StartPoints) == 6
                    error('StartPoints must be a six-element vector!\nIt must be constructed like this: [a1 E1 w1 a2 E2 w2].\n%s',' ');
                end
                
            end
            
            % prepare fit data
            warning off
            [x_fit,y_fit] = prepareCurveData(obj.BinCenters,obj.BinCounts);
            warning on
            
            % do bimodal fit
            if exist('StartPoints','var')
                % set initialGuess property
                obj.initialGuess.a1 = StartPoints(1);
                obj.initialGuess.E1 = StartPoints(2);
                obj.initialGuess.w1 = StartPoints(3);
                obj.initialGuess.a2 = StartPoints(4);
                obj.initialGuess.E2 = StartPoints(5);
                obj.initialGuess.w2 = StartPoints(6);
                
                % fitting
                fitobj = fit(x_fit,y_fit,'gauss2','StartPoint',StartPoints);
                obj.fit_obj = fitobj;
            else
                % Start point guessing
                [hist_max,max_ind] = max(obj.BinCounts);
                max_pos = obj.BinCenters(max_ind);
                diff = abs(max_pos - min(obj.BinCenters));
                half_diff = diff/2;
                max_width = half_diff/(2*sqrt(2*log(2)));
                max_pos_2 = max_pos + abs(max(obj.EModul)-max_pos)/2;
                [~,max_ind_2] = min(abs(obj.BinCenters-max_pos_2));
                hist_max_2 = obj.BinCounts(max_ind_2);
                diff_2 = abs(max(obj.BinCenters) - max_pos_2);
                half_diff_2 = diff_2/2;
                max_width_2 = half_diff_2/(2*sqrt(2*log(2)));
                
                % set initialGuess property
                obj.initialGuess.a1 = hist_max;
                obj.initialGuess.E1 = max_pos;
                obj.initialGuess.w1 = max_width;
                obj.initialGuess.a2 = hist_max_2;
                obj.initialGuess.E2 = max_pos_2;
                obj.initialGuess.w2 = max_width_2;
                
                % fitting
                fitobj = fit(x_fit,y_fit,'gauss2','StartPoint',[hist_max max_pos max_width hist_max_2 max_pos_2 max_width_2]);
                obj.fit_obj = fitobj;
            end
            
            % get fitted parameters
            obj.parameters.a1 = fitobj.a1;
            obj.parameters.E1 = fitobj.b1;
            obj.parameters.w1 = fitobj.c1;
            obj.parameters.a2 = fitobj.a2;
            obj.parameters.E2 = fitobj.b2;
            obj.parameters.w2 = fitobj.c2;
                        
            % calculate bimodal distribution
            obj.x_data_fit = linspace(min(obj.EModul)-obj.BinWidth*2,max(obj.EModul)+obj.BinWidth*2,400)';
            obj.y_data_fit = feval(obj.fit_obj,obj.x_data_fit);
                        
            % calculate gauss1
            param = obj.parameters;
            obj.y_gauss1 = feval(obj.gauss1,param.a1,param.E1,param.w1,obj.x_data_fit);
            
            % calculate guass2
            obj.y_gauss2 = feval(obj.gauss2,param.a2,param.E2,param.w2,obj.x_data_fit);
            
            % plot if desired
            if strcmp(plot_arg,'yes')
                hold on
                plot(obj.x_data_fit,obj.y_data_fit,'-k',obj.x_data_fit,obj.y_gauss1,'--k',obj.x_data_fit,obj.y_gauss2,'--k','LineWidth',2);
                hold off
            end
            
            
        end
        
        function obj = plotHist(obj)
            % Plot the histogram
            %
            % obj = plotHist(obj)
            %
            % plotHist: Method to plot the Histogram of the Young's modulus
            % values in the property "EModul".
            % The binning is determined by the property "edges".
            %
            % Syntax:
            %   * obj = plotHist(obj);
            %   * obj = obj.plotHist();
            %   * plotHist(obj);
            %   * obj.plotHist;
            
            obj.hist = histogram(obj.EModul,obj.edges);
        end
        
        function plotFit(obj)
            % Plot the fitted bimodal distributions together with the two Gaussian distributions.
            % 
            % Syntax:
            %   * plotFit(obj)
            %   * obj.plotFit;
            
            % error handling for plotFit method
            if isempty(obj.x_data_fit) || isempty(obj.y_data_fit) || isempty(obj.y_gauss1) || isempty(obj.y_gauss2)
                error('First you need to apply the "doFit" method on this BimodalHistogram object!');
            end
            
            hold on
            plot(obj.x_data_fit,obj.y_data_fit,'-k','LineWidth',2);
            plot(obj.x_data_fit,obj.y_gauss1,'--k','LineWidth',2);
            plot(obj.x_data_fit,obj.y_gauss2,'--k','LineWidth',2);
            hold off
            
        end
        
        function showInitialGuess(obj)
            % Draw the bimodal distribution with the initial guesses for the six fit parameters.
            %
            % obj = showInitialGuess(obj)
            %
            % showInitialGuess draws the initialGuess curve in the current
            % figure for verification
            %
            % Syntax:
            % showInitialGuess
            % obj.showInitialGuess();
            
            a1 = obj.initialGuess.a1;
            E1 = obj.initialGuess.E1;
            w1 = obj.initialGuess.w1;
            a2 = obj.initialGuess.a2;
            E2 = obj.initialGuess.E2;
            w2 = obj.initialGuess.w2;
            
            
            draw_x = linspace(min(obj.edges),max(obj.edges),400);
            draw_y = feval(obj.bimodal,a1,E1,w1,a2,E2,w2,draw_x);
            draw_y1 = feval(obj.gauss1,a1,E1,w1,draw_x);
            draw_y2 = feval(obj.gauss2,a2,E2,w2,draw_x);
            
            hold on
            plot(draw_x,draw_y,'-r','LineWidth',2);
            plot(draw_x,draw_y1,'--r','LineWidth',2);
            plot(draw_x,draw_y2,'--r','LineWidth',2);
            hold off
            
        end
        
        function obj = AddAnnotations(obj)
            % Add axis labels and annotation with the peak positions to the current axes.
            %
            % Syntax:
            %   * obj = AddAnnotations(obj);
            %   * obj = obj.AddAnnotations;
            
            % get order of magnitude of the displayed range
            max_edge = obj.edges(end);
            max_edge_ord = floor(log10(max_edge));
            
            % determine unit of x axis
            if max_edge_ord >= 9
                axis_unit = 'GPa';
                power = 9;
            elseif max_edge_ord < 9 && max_edge_ord >= 6
                axis_unit = 'MPa';
                power = 6;
            elseif max_edge_ord < 6 && max_edge_ord >=3
                axis_unit = 'kPa';
                power = 3;
            else
                axis_unit = 'Pa';
                power = 0;
            end
            
            % format x axis
            current_ax = gca;
            current_ax.XAxis.Exponent = 0;
            tick_text = string(current_ax.XTickLabel);
            tick_numbers = str2double(tick_text);
            tick_numbers_new = tick_numbers/10^power;
            current_ax.XTickLabel = num2cell(string(tick_numbers_new));
            xlabel(current_ax,sprintf('Young''s modulus [%s]',axis_unit),'FontSize',14);
            ylabel(current_ax,'Frequency','FontSize',14);
            
            % determine order of magnetude for E1 and E2 and set the
            % corresponding unit
            ord_E1 = floor(log10(obj.parameters.E1));
            ord_E2 = floor(log10(obj.parameters.E2));
            
            if ord_E1 >= 9
                E1_unit = 'GPa';
                E1_power = 9;
            elseif ord_E1 < 9 && ord_E1 >= 6
                E1_unit = 'MPa';
                E1_power = 6;
            elseif ord_E1 < 6 && ord_E1 >=3
                E1_unit = 'kPa';
                E1_power = 3;
            else
                E1_unit = 'Pa';
                E1_power = 0;
            end
            
            if ord_E2 >= 9
                E2_unit = 'GPa';
                E2_power = 9;
            elseif ord_E2 < 9 && ord_E2 >= 6
                E2_unit = 'MPa';
                E2_power = 6;
            elseif ord_E2 < 6 && ord_E2 >=3
                E2_unit = 'kPa';
                E2_power = 3;
            else
                E2_unit = 'Pa';
                E2_power = 0;
            end
            
            % prepare string for annotation
            annotation_string = sprintf('Peak values:\n1^{st} Peak: %.2f %s\n2^{nd} Peak: %.2f %s',...
                                        obj.parameters.E1/10^E1_power,...
                                        E1_unit,...
                                        obj.parameters.E2/10^E2_power,...
                                        E2_unit);
                                    
            % add annotation to figure
            annot = annotation('textbox','String',annotation_string,'FontSize',14,'Visible','off');
            annot_size = annot.Position;
            ax_pos = current_ax.Position;
            annot.Position(1) = (ax_pos(1) + ax_pos(3)) - (annot_size(3)+0.05);
            annot.Position(2) = (ax_pos(2) + ax_pos(4)) - (annot_size(4)+0.05);
            annot.Visible = 'on';
            
            obj.annotation_obj = annot;
            
            
        end
        
        function obj = GenerateTestEModul(obj)
            % Generate test distribution.
            %
            % obj = GenerateTestEModul(obj)
            %
            % GenerateTestEModul generates a EModul vector for the purpose
            % of testing this class.
            %   ATTENTION: When you apply this method on a BimodalHistogram
            %              class the "EModul" property will be overwritten!
            %
            % One possibility for testing is to first create a
            % BimodalHistogram object with a random EModul vector and a
            % x_range of [0 300e3]. For the BinNum 75 is a good guess.
            %
            %   -> h1 = BimodalHistogram(rand(5,1),[0 300e3],75);
            %
            % Then you can apply the "GenerateTestEModul" method to
            % overwrite the random EModul vector and reinitialize the
            % properties. h1 = h1.GenerateTestEModul;
            
            % genreate a bimodal distributed EModul vector
            EModul1 = 10e3*randn(5000,1)+60e3;
            EModul2 = 25e3*randn(1500,1)+110e3;
            EModul = [EModul1;EModul2]; %#ok<PROP>
            
            % overwrite "EModul" property
            obj.EModul = EModul; %#ok<PROP>
            
            % reinitialize object properties
            edges = linspace(0,300e3,obj.BinNum+1); %#ok<PROP>
            obj.edges = edges'; %#ok<PROP>
            
            hist = histogram(EModul,edges); %#ok<PROP>
            obj.hist = hist; %#ok<PROP>

            BinCenters = hist.BinEdges + hist.BinWidth/2; %#ok<PROP>
            BinCenters(end) = []; %#ok<PROP>
            obj.BinCenters = BinCenters; %#ok<PROP>

            obj.BinWidth = hist.BinWidth; %#ok<PROP>

            obj.BinCounts = hist.BinCounts; %#ok<PROP>
            
        end
    end
end

