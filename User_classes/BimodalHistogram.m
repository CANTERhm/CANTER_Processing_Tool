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
        fit_obj = [];
        parameters = struct('a1',[],'E1',[],'w1',[],'a2',[],'E2',[],'w2',[]);
        x_data_fit = [];
        y_data_fit = [];
        y_gauss1 = [];
        y_gauss2 = [];
        

    end
    
    methods
        function obj = BimodalHistogram(EModul,x_range,BinNum,plot_arg)
            %BimodalHistogram Construct an instance of this class
            
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
                    obj.BinCenters = BinCenters;
                    
                    obj.BinCounts = h;                    
            end
        end
        
        function obj = doFit(obj,StartPoints,plot_arg)
            % doFit This method calculates the bimodal fit and draws the
            % fit together with the unimodal distributions
            
            % error handling for doFit method            
            if nargin < 2
               plot_arg = 'yes'; 
            end
            
            % do bimodal fit
            if nargin < 1
                fitobj = fit(obj.BinCenters,obj.BinCounts,'gauss2');
                obj.fit_obj = fitobj;
            else
               fitobj = fit(obj.BinCenters,obj.BinCounts,'gauss2','StartPoints',StartPoints);
               obj.fit_obj = fitobj;
            end
            
            % get fitted parameters
            obj.parameters.a1 = fitobj.a1;
            obj.parameters.E1 = fitobj.b1;
            obj.parameters.w1 = fitobj.c1;
            obj.parameters.a2 = fitobj.a2;
            obj.parameters.E1 = fitobj.b2;
            obj.parameters.w2 = fitobj.c2;
                        
            % calculate bimodal distribution
            obj.x_data_fit = linspace(min(obj.EModul)-obj.parameters.w1,max(obj.EModul)+obj.parameters.w2);
            obj.y_data_fit = feval(obj.fit_obj,obj.x_data_fit);
            
            % calculate gauss1
            param = obj.parameters;
            obj.y_gauss1 = feval(obj.gauss1,param.a1,param.E1,param.w1,obj.x_data_fit);
            
            % calculate guass2
            
            
            % plot if desired
            if strcmp(plot_arg,'yes')
                
            end
            
            
        end
        
        function plotHist(obj,hold_arg)
            
        end
        
        function plotFit(obj,hold_arg)
            
        end
    end
end

