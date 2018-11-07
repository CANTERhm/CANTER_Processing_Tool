function [EModul,varargout] = HertzFit(x,y,d_int, angle, poisson, handles)
% HertzFit Fits the Hertz Model on a given graph
% 
% Syntax: [EModul,varargout] = HertzFit(x,y,baseline_edges, varargin)
% varargout{1} = gof; goodness of fit = rsquare
% varargout{2} = fittedcurve_x; X data of the fitted curve
% varargout{3} = fittedcurve_y; Y data of the fitted curve
%   

%% Fit: initial guess.
[xData, yData] = prepareCurveData(x,y);

%func_string = sprintf('(tan(%f.*pi/180)/(2*(1-%f.^2)).*(x-%f).^2)',angle,poisson, xData(handles.baselineedges(1,2)));
func_string = sprintf('(tan(%f.*pi/180)/(2*(1-%f.^2)).*x.^2)',angle,poisson);

% Set all the values into um so the calculation is easier
d_int=d_int*1e6;
xData=xData*1e6;


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
%Values need to be in m and N for the formula
xData = xData*1e-6;
[fitresult, gof] = fit( xData, yData, ft, opts );

EModul = fitresult.EModul;

for i = 1:length(xData)
fittedcurve_x(i) = xData(i);
    if xData(i)< 0
        fittedcurve_y(i) = EModul*((tan(angle.*pi/180)/(2*(1-poisson.^2)).*(xData(i).^2)));
    else
        fittedcurve_y (i) = 0;
    end
end

% Reconvert the Data into um or nN to show them
fittedcurve_x = (fittedcurve_x/1e-6)';
fittedcurve_y = (fittedcurve_y/1e-9)';
varargout{1} = gof;
varargout{2} = fittedcurve_x;
varargout{3} = fittedcurve_y;
end
