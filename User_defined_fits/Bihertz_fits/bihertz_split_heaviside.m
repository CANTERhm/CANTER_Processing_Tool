function [fit,varargout] = bihertz_split_heaviside(x,y,par0,angle,poisson,varargin)
%%  BIHERTZ_SUM_HEAVISIDE: Fit the 'bihertz split heaviside' model using the function:
%   @(par,d) tan(17.5.*pi/180)/(2*(1-0.5.^2)).*heaviside(d-par(3)).*par(1).*d.^2+...
%            tan(angle.*pi/180)/(2.*(1-poisson^2)).*((heaviside(d-par(3)*1e-6)-1)*(-1)).*par(2).*(d-par(3)*1e-6).^2;
% 
%   IMPORTANT: For the fit, the indentation part of the curve has to be on
%   the negative x-axes part!!! (also d_int has to be a negarive value!)
% 
%   [fit] = bihertz_sum_heaviside(x,y,par0,angle,poisson)
%   - Fits the single 'bihertz sum heaviside' model
%     using the initial values in par0 over the the x-y-dataset.
%   -> par0 has to be given as a vector containing the initial value for E_s on the first,
%      for E_h on the second and for d_h on the third position.
%   - angle is the half angle to edge for the cantilever tip given in
%     degree (i.e. 17.5).
%   - poisson is the poisson ratio of the indented sample (i.e. 0.5)
%   - It returns the fittet parameters in the vector fit (same order as in par0).
%
%   dataset is specified by x and y.
%
%   [fit,r,J,CovB,MSE,Rs] = bihertz_sum_heaviside(x,y,par0,angle,poisson)
%   - Fits the single 'bihertz sum heaviside' model
%     using the initial values in par0 over the the x-y-dataset. par0 has to
%     be given as a vector containing the initial value for E_s on the first,
%     for E_h on the second and for d_h on the third position.
%     It returns the fittet parameters in the vector fit (same order as in par0)
%     and the residuals (r), the Jacobian-Matrix (J), the variance-covariance
%     matrix (CovB), the mean squared error (MSE) and the Coefficiant of
%     determination 'R square'(Rs).
% 
%   [...] = bihertz_sum_heaviside(...,Name,Value)
%   optional Name-Value-Pair:
%   you can add the name 'plot' followed by:
%   'off'(default) or 'on'
% 
%   when the value of plot is on a graph with the raw data, fittet linear
%   guess function and the resulting initial hertz-model is drawn.
%   Example:    [fit,r,J,CovB,MSE,Rs] = bihertz_sum_heaviside(x,y,par0,'plot','on')
% 
% 
%
% Example:
%   [fit,res,Jac,CovB,MSE,R_square] = bihertz_sum_heaviside(x_values,y_values,initial_guesses);
%
%    See also NLINFIT.
%   


%% inputParser
p = inputParser;
paramName = 'plot';
dafaultVal = 'off';
valFun = @(x) strcmp('off',x) || strcmp('on',x);
addParameter(p,paramName,dafaultVal,valFun);
parse(p,varargin{:});


%% create function handle:


%   par(1) = E_s
%   par(2) = E_h
%   par(3) = d_h
func = @(par,d)tan(angle.*pi/180)/(2.*(1-poisson^2)).*heaviside(d-par(3)).*par(1).*d.^2+tan(angle.*pi/180)/(2.*(1-poisson^2)).*((heaviside(d-par(3)*1e-6)-1)*(-1)).*par(2).*(d-par(3)*1e-6).^2;
par0(3) = par0(3)*1e6;

% data masking
mask = x < 0;
x_fit = x(mask);
y_fit = y(mask);

% fit bihertz-sum-heaviside model with nlinfit
[fit,residual,Jac_fit,CovB,MSE] = nlinfit(x_fit,y_fit,func,par0);
varargout{1} = residual;
varargout{2} = Jac_fit;
varargout{3} = CovB;
varargout{4} = MSE;

% calculation of R^2
y_mean = mean(y_fit);
y_fitfun = func(fit,x_fit);
RSS_diff = y_fit - y_fitfun;
RSS_diff_square = RSS_diff.^2;
RSS = sum(RSS_diff_square);
TSS_diff = y_fit - y_mean;
TSS_diff_square = TSS_diff.^2;
TSS = sum(TSS_diff_square);

R_s = 1 - RSS/TSS;

fit(3) = fit(3)*1e-6;
varargout{5} = R_s;

% optional plot
if strcmp(p.Results.plot,'on')
    plot(x,y);
    hold on
    y_plot(length(x)) = 0;
    y_plot(mask) = func(fit,x_fit);
    plot(x,y_plot,'g-');
    axis([min(x)-1e-6 max(x)+1e-6 min(y)-1e-9 max(y)+1e-9]);
    legend('raw data','fittet curve','location','northwest');
    hold off
end
