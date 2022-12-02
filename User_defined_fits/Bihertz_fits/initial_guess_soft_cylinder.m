function E_s = initial_guess_soft_cylinder(x,y,d_int,radius,poisson)
%   INITIAL_GUESS_SOFT_CYLINDER Fit the soft part of a force curve for initial guess.
%   IMPORTANT: For the fit, the indentation part of the curve has to be on
%   the negative x-axes part!!! (also d_int has to be a negarive value!)
%   
% 
%   E_s = initial_guesss_soft(x,y,d_int,angle,poisson)
%   - You have to pass the following parameters to the function:
%      * x = numeric vector of force curve x values.
%      * y = numeric vector of force curve y values.
%      * d_int = positive scalar defining the maximum indentation depth that is considered for the fit.
%      * radius = radius of the cylindrical indenter in m as positive scalar.
%      * poisson = Poisson's ratio of the indented sample as scalar.
% 
% 
% Example:
%    E_s = initial_guess_soft(x_values, y_values, 2e-6, 0.5e-3, 0.5);
%
%    See also FIT (Method = LinearLeastSquares).
%   

%% Fit: initial guess.
[xData, yData] = prepareCurveData(x,y);


% Fit model to data.
fitMask = (xData <= 0) & (xData >= d_int);
p_lin = polyfit(xData(fitMask),yData(fitMask),1);
m = abs(p_lin(1));
C = (2*radius)/(1-poisson^2);
E_s = m/C;