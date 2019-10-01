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
        x_gauss1 = [];
        x_gauss2 = [];
        

    end
    
    methods
        function obj = BimodalHistogram(EModul,x_range,BinNum,plot_arg)
            %BimodalHistogram Construct an instance of this class
            
            % input check of constructor
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
            
            if ~any(ismember({'yes','no'},plot_arg))
                error('plot_arg must be either ''yes'' or ''no''!');
            end
            
            % calculate and assign property values
            obj.EModul = EModul;
            
            edges = linspace(x_range(1),x_range(2),BinNum+1);
            obj.edges = edges';
            
            hist = histogram(EModul,edges);
            obj.hist = hist;
            
            BinCenters = hist.BinEdges + hist.BinWidth/2;
            BinCenters(end) = [];
            obj.BinCenters = BinCenters;
            
            obj.BinWidth = hist.BinWidth;
            
            obj.BinCounts = hist.BinCounts;
        end
        
        function doFit(StartPoints,plot_arg)
            % doFit Summary of this method goes here
            %   Detailed explanation goes here
            
        end
    end
end

