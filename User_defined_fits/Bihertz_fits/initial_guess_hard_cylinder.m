function [E_h,d_h,varargout] = initial_guess_hard_cylinder(x,y,perc,radius,poisson,varargin)
%% INITIAL_GUESS_HARD: makes a linear fit on the last percentage of a
%                     force curve; percentage defined in the variable perc.
%   IMPORTANT: For the fit, the indentation part of the curve has to be on
%   the negative x-axes part!!! (the percantage value has to be positive)
% 
%   [E_h,d_h] = initial_guess_hard_cylinder(x,y,perc,radius,poisson)
%   - Fits a polynome of first order
%     to the x and y dataset over the last percentage of a force curve and
%     returns the initial guess values for E_h and d_h for a subsequent
%     bihertz-model fit.
%   - Percentage value is defined in perc as a double number.
%   - In radius, the radius of the cylindrical indenter in m has to be given.
%   - In poisson, the value of the samples poisson ratio is handed.
%   
% 
%   [E_h,d_h,gof] = initial_guess_hard_cylinder(x,y,perc,radius,poisson)
%   - Fits a polynome of first order to the x and y dataset over the last
%     percentage of a force curve and returns the initial guess values for
%     E_h and d_h for a subsequent bihertz-model fit aswell as the godness
%     of fit (gof) parameters.
%   - Percentage value is defined in perc as a double number.
%   - In angle, the value of the half angle to edge of the cantilver tip.
%   - In poisson, the value of the samples poisson ratio is handed.
%   - gof is a struct containing the following fields:
%       - sse       = Sum of sqares due to error
%       - rsquare   = R-squared (coefficient of determination)
%       - dfe       = Degrees of freedom in the error
%       - adjrsqare = Degree-of-freedom in the error
%       - rmse      = Root mean squared error (standard error)
%
%   [E_h,d_h,gof] = initial_guess_hard_cylinder(...,Name,Value)
%   optional Name-Value-Pair:
%   you can add the name 'plot' followed by:
%   'off'(default) or 'on'
% 
%   when the value of plot is on a graph with the raw data, fitted linear
%   guess function and the resulting initial hertz-model is drawn.
%   Example:    [E_h,d_h,gof] = initial_guess_hard(x,y,perc,'plot','on')
% 
% Example:
%   [E_h,d_h,gof] = initial_guess_hard_cylinder(x_values, y_values, 5, 0.5e-3, 0.5, 'plot', 'on')
%                 -> results in a fit on the last 5% of the curve!
% 
%   See also FIT

%% add optional name-value-pair
p = inputParser;
paramName = 'plot';
defaultVal = 'off';
vFun = @(x) strcmp(x,'off')||strcmp(x,'on');
addParameter(p,paramName,defaultVal,vFun);


%% linear Fit on last percentage of curve

[xData, yData] = prepareCurveData(x, y);

% Set up fittype and options.
ft = fittype( 'poly1' );
x_min_val = min(x);
if x_min_val < 0
    excludedPoints = xData > x_min_val-x_min_val*perc/100;
else
    excludedPoints = xData > x_min_val+x_min_val*perc/100;
end
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Exclude = excludedPoints;

[fitresult, gof] = fit( xData, yData, ft, opts );

varargout{1} = gof;

%Save fit results to variable
m = fitresult.p1;
t = fitresult.p2;
C = (2*radius)/(1-poisson^2);
d_h = -t/m;
E_h = abs(m)/C;



% optional plot
if nargin > 5
parse(p,varargin{1},varargin{2});

if strcmp(p.Results.plot,'on')
plot(x,y);
hold on
plot(x,fitresult.p1.*x+fitresult.p2,'r-');
axis([min(x)-1e-6 max(x)+1e-6 min(y)-1e-9 max(y)+1e-9]);
mask = x < d_h;
x_par = x(mask);
y_par(~mask) = 0;
y_par(mask) = E_h*tan(17.5.*pi/180)/(2*(1-0.5.^2)).*(x_par-d_h).^2;
plot(x,y_par','g-');
legend('raw data','linear approximation','resulting hertz model','Location','northwest');
hold off
end
end

   