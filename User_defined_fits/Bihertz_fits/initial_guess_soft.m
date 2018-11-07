function [E_s,varargout] = initial_guess_soft(x,y,d_int,angle,poisson)
%   INITIAL_GUESS_SOFT Fit the soft part of a force curve for initial guess.
%   IMPORTANT: For the fit, the indentation part of the curve has to be on
%   the negative x-axes part!!! (also d_int has to be a negarive value!)
%   
%   [E_s] = initial_guess_soft(x,y)
%   - Fits the single Hertz-Model over the dataset specified by x and y.
%
%   [E_s] = initial_guess_soft(x,y,d_int)
%   - Fits the single Hertz-Model to a indentation depth specified in d_int
%     and returns E_s (soft Young's Modulus).
%
%   [E_s,gof] = initial_guess_soft(x,y,d_int)
%   - Fits the single Hertz-Model to a indentation depth specified in d_int
%     and returns E_s (soft Young's Modulus) and the struct gof (gondness of fit)
% 
%   [E_s,gof] = initial_guesss_soft(x,y,d_int,angle,poisson)
%   - you can optionally also provite the half angle to edge of the cantilever
%     (in degrees, i.e. 17.5) and the poisson ratio of the indented sample.
% 
% 
% Example:
%   [E_s,gof] = initial_guess_soft(x_values, y_values, 2e-6,17.5,0.5);
%
%    See also FIT (Method = LinearLeastSquares).
%   

%% Fit: initial guess.
[xData, yData] = prepareCurveData(x,y);

if nargin < 3
    d_int = max(x);
end
if nargin < 4
    angle = 17.5;
end
if nargin < 5
    poisson = 0.5;
end


func_string = sprintf('(tan(%f.*pi/180)/(2*(1-%f.^2)).*x.^2)',angle,poisson);

% Set up fittype and options.
ft = fittype( {func_string}, 'independent', 'x', 'dependent', 'y', 'coefficients', {'E_s'} );
excludedPoints = ((xData < d_int) | (xData > 0));
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

E_s = fitresult.E_s;
varargout{1} = gof;
