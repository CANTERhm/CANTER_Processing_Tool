function [EModul,varargout] = HertzFit(x,y,d_int,tip_shape,indenter_value, poisson)
% HertzFit Fits the Hertz Model on a given graph
% 
% Syntax: [EModul,varargout] = HertzFit(x,y,baseline_edges, varargin)
% varargout{1} = gof; goodness of fit = rsquare
% varargout{2} = fittedcurve_x; X data of the fitted curve
% varargout{3} = fittedcurve_y; Y data of the fitted curve
%   

%% Code

% Fit: initial guess.
[xData, yData] = prepareCurveData(x,y);

switch tip_shape
    case 'four_sided_pyramid'
        angle = indenter_value;
        func_string = sprintf('(tan(%f.*pi/180)/(2*(1-%f.^2)).*x.^2)',angle,poisson);
    case 'flat_cylinder'
        radius = indenter_value;
        magnitude = floor(log(radius)/log(10));
        func_string = sprintf('(2*%fe%d./(1-%f.^2)).*x',radius/10^magnitude,magnitude,poisson);
end


ft = fittype( {func_string}, 'independent', 'x', 'dependent', 'y', 'coefficients', {'EModul'} );
    
% Set up fittype and options. Contactpoint is (0/0)
if d_int<min(xData)
    excludedPoints = (xData > 0);
else
    excludedPoints = (xData <= (d_int) | (xData > 0));
end
        
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

EModul = fitresult.EModul;

baseline_mask = xData<0;
fittedcurve_y = zeros(length(xData),1);
switch tip_shape
    case 'four_sided_pyramid'
        fittedcurve_y(baseline_mask) = EModul*((tan(angle.*pi/180)/(2*(1-poisson.^2)).*(xData(baseline_mask).^2)));
    case 'flat_cylinder'
        fittedcurve_y(baseline_mask) = EModul*(2*radius./(1-poisson.^2)).*(xData(baseline_mask));
end

EModul = abs(EModul);
varargout{1} = gof;
varargout{2} = xData;
varargout{3} = fittedcurve_y;
end
