function [EModul,varargout] = HertzFit(x,y,fit_start,d_int,tip_shape,indenter_value, poisson)
% HertzFit Fits the Hertz Model on a given graph
% 
% Syntax: [EModul,varargout] = HertzFit(x,y,fit_start,d_ind,tip_shape,indenter_value,poisson)
% varargout{1} = gof; goodness of fit = rsquare
% varargout{2} = fittedcurve_x; X data of the fitted curve
% varargout{3} = fittedcurve_y; Y data of the fitted curve
% varargout{4} = contact point; JUST AVAILABLE WHEN THE TIP_SHAPE IS
%                               FLAT_CYLINDER

%% Code

% Fit: initial guess.
[xData, yData] = prepareCurveData(x,y);

switch tip_shape
    case 'four_sided_pyramid'
        angle = indenter_value;
        func_string = sprintf('(tan(%f.*pi/180)/(2*(1-%f.^2)).*x.^2)',angle,poisson);
        ft = fittype( {func_string}, 'independent', 'x', 'dependent', 'y', 'coefficients', {'EModul'} );
        opts = fitoptions( 'Method', 'LinearLeastSquares' );
    case 'flat_cylinder'
        radius = indenter_value;
        ft = fittype("poly1");
        opts = fitoptions(ft);
end

    
% Set up fittype and options. Contactpoint is (0/0) or (fit_start/0)
if d_int<min(xData)
    excludedPoints = (xData > fit_start);
else
    excludedPoints = (xData <= (d_int) | (xData > fit_start));
end
        
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );


switch tip_shape
    case 'four_sided_pyramid'
        baseline_mask = xData<0;
        EModul = fitresult.EModul;
    case 'flat_cylinder'
        m = fitresult.p1;
        t = fitresult.p2;
        contact_point = -1*(t/m);
        baseline_mask = xData<contact_point;
        EModul = (m*(1-poisson^2))/(2*radius);
end
fittedcurve_y = zeros(length(xData),1);
switch tip_shape
    case 'four_sided_pyramid'
        fittedcurve_y(baseline_mask) = EModul*((tan(angle.*pi/180)/(2*(1-poisson.^2)).*(xData(baseline_mask).^2)));
    case 'flat_cylinder'
        fittedcurve_y(baseline_mask) = EModul*(2*radius./(1-poisson.^2)).*(xData(baseline_mask)-contact_point);
end

EModul = abs(EModul);
varargout{1} = gof;
varargout{2} = xData;
varargout{3} = fittedcurve_y;
varargout{4} = [];
if strcmp(tip_shape,'flat_cylinder')
    varargout{4} = contact_point;
end
