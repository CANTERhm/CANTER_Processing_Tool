classdef BimodalHistogram
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        EModul = [];
        hist = [];
        edges = [];
        BinCenters = [];
        BinWidth = [];
        BinCounts = [];
        gauss1 = @(a1,E1,w1,x)a1.*exp(-((x-E1)./w1).^2);
        gauss2 = @(a2,E2,w2,x)a2.*exp(-((x-E2)./w2).^2);
        bimodal = @(a1,E1,w1,a2,E2,w2,x)a1.*exp(-((x-E1)./w1).^2)+a2.*exp(-((x-E2)./w2).^2);
        fit_obj = [];
        parameters = struct('a1',[],'E1',[],'w1',[],'a2',[],'E2',[],'w2',[]);
        initialGuess = struct('a1',[],'E1',[],'w1',[],'a2',[],'E2',[],'w2',[]);
        x_data_fit = [];
        y_data_fit = [];
        y_gauss1 = [];
        y_gauss2 = [];
        

    end
    
    methods
        function obj = BimodalHistogram(EModul,x_range,BinNum,plot_arg)
            % obj = BimodalHistrogram(EModul,x_range,BinNum,plot_arg);
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
            
            if ~isvector(x_range) && length(x_range) ~= 2
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
            obj.EModul = EModul;

            edges = linspace(x_range(1),x_range(2),BinNum+1);
            obj.edges = edges';
            
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
            % obj = doFit(obj,StartPoints,plot_arg,varargin);
            % 
            % doFit This method calculates the bimodal fit and draws the
            % fit together with the unimodal distributions
            % input:
            %       - obj           -> BimodalHistogram object.
            %       - StartPoints   -> Start values for the fiting of the
            %                          six parameters of the bimodal
            %                          distribution [a1 E1 w1 a2 E2 w2].
            %       - plot_arg      -> 'yes' (default) if you whant the
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
                max_width = (max_pos - min(obj.BinCenters))/(2*sqrt(2));
                max_pos_2 = (obj.BinCenters(end)-max_pos)/2;
                [~,max_ind_2] = min(abs(obj.BinCenters-max_pos_2));
                hist_max_2 = obj.BinCounts(max_ind_2);
                max_width_2 = (max(obj.BinCenters) - max_pos_2)/(2*sqrt(2));
                
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
            obj.x_data_fit = linspace(min(obj.EModul)-obj.BinWidth*2.,max(obj.EModul)+obj.BinWidth*2)';
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
            % obj = plotHist(obj)
            %
            % plotHist: Method to plot the Histogram of the Young's modulus
            % values in the property "EModul".
            % The binning is determined by the property "edges".
            %
            % Syntax:
            % * obj = plotHist(obj);
            % * obj = obj.plotHist();
            
            obj.hist = histogram(obj.EModul,obj.edges);
        end
        
        function plotFit(obj,hold_arg)
            % error handling for plotFit method
            if isempty(obj.fit_obj)
                error('First you need to apply the "doFit" method on this BimodalHistogram object!');                
            end
            
            hold on
             plot(obj.x_data_fit,obj.y_data_fit,'-k','LineWidth',2);
             plot(obj.x_data_fit,obj.y_gauss1,'--k','LineWidth',2);
             plot(obj.x_data_fit,obj.y_gauss2,'--k','LineWidth',2);
            hold off
            
        end
        
        function obj = showInitialGuess(obj)
            % obj = showInitialGuess(obj)
            %
            % showInitialGuess draws the initialGuess curve in the current
            % figure for verification
            %
            % Syntax:
            % * obj = showInitialGuess(obj);
            % * obj = obj.ShowInitialGuess();
            
            a1 = obj.initialGuess.a1;
            E1 = obj.initialGuess.E1;
            w1 = obj.initialGuess.w1;
            a2 = obj.initialGuess.a2;
            E2 = obj.initialGuess.E2;
            w2 = obj.initialGuess.w2;
            
            
            draw_x = linspace(min(obj.edges),max(obj.edges),400);
            draw_y = feval(obj.bimodal,a1,E1,w1,a2,E2,w2,draw_x);
            
            hold on
            plot(draw_x,draw_y,'-r','LineWidth',2);
            hold off
            
        end
        
        function AddAnnotation(obj)
            
        end
    end
end

