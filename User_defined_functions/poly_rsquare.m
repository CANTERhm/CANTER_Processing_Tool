function [rsq,rsq_adj,residuals] = poly_rsquare(coeffs,x,y)
%%  POLY_RSQUARE: Is a function for calculating the rsquare and the 
%   adjusted rsquare from the coefficients calculated by polyfit and 
%   the x and y vectors to whitch polyfit found the coefficients.




%%
y_reg = polyval(coeffs,x);
y_resid = y - y_reg;
SSresid = sum(y_resid.^2);
SStotal = (length(y)-1)*var(y);
rsq = 1-SSresid/SStotal;
rsq_adj = 1-SSresid/SStotal*(length(y)-1)/(length(y)-length(coeffs));
residuals = y_resid;


end