function [baseline_edges]=BaselineFinder(x,y,varargin)
% BaselineFinder  Finds the Baseline of a given curve
%
% [baseline_edges]=BaselineFinder(x, y, varargin)
%
% Instruction: 
% The function needs x and y as double vectors.
%
% In the output variable you find the edges of the baseline stored in a row vector. 
% 
%   Optional input:
%   Name-value pair: 'FitWindowSize',double    -> default = 20
%   Example:    [edges] = BaselineFinder(x,y,'FitWindowSize',25)
% 
% Output: 
%
% baseline_edges(1, 1) = edge minimum (right);
% baseline_edges(1, 2) = edge maximum (left, closest to contact point);
% 
% 

%%
p = inputParser;

% input parameter for x values
addRequired(p,'x',@(x)assert(isnumeric(x)&&isvector(x),'BaselineFinder:invalidInput',...
    'Input for x value is not a one dimensional numerical vector!'));
% input parameter for y values
addRequired(p,'y',@(x)assert(isnumeric(x)&&isvector(x),'BaselineFinder:invalidInput',...
    'Input for y value is not a one dimensional numerical vector!'));
% optional name-value pair for the size of the fit window
addParameter(p,'FitWindowSize',20,@(x)assert(isnumeric(x)&&isreal(x)&&isscalar(x),'BaselineFinder:InvalidInput',...
    'The FitWindowSize must be a numeric real scalar'));

parse(p,x,y,varargin{:});

x = p.Results.x;
y = p.Results.y;
windowlength = p.Results.FitWindowSize;

%% Search for the best window 
%Create a 20% fit Window
onepercent_length = floor(length(x)/100);
interval_max = uint64(onepercent_length*windowlength);
interval_min = uint64(1);

slope = zeros([3 (100-windowlength)]);
% Shift the window in 1% steps over the curve to find the lowest slope 
for window=1:100-windowlength
    x_fit = x(interval_min:interval_max,1);
    y_fit = y(interval_min:interval_max,1);
    % X_fit matrix
    X_fit = [ones(length(x_fit),1) x_fit];

    %Fit the Linear fit to the given window and save the slope of the
    %linear fit
    % instead of polyfit(x,y,1) we use here the matrix operation X\y to
    % improve code performance
    p = X_fit\y_fit;
    slope(1,window) = p(2);
    slope(2,window) = interval_min;
    slope(3,window) = interval_max;

    interval_min = uint64(interval_min + onepercent_length);
    interval_max = uint64(interval_max + onepercent_length);
    if interval_max > length(y)
        interval_max = uint64(length(y));
    end
end


slope = abs(slope);
% % Auskommentiert von Bastian
% % minimum = min(slope);
% % toleranceslope = minimum*1.25; % This is just a value which gave good results

toleranceslope = median(slope(1,:));
minimalslope = find(slope(1,:) <= toleranceslope); %Gives back the window number
if length(minimalslope)>20
    interval_min = slope(2,minimalslope(4));
    interval_max = slope(3,minimalslope(end-4));
else
    interval_min = slope(2,minimalslope(2));
    interval_max = slope(3,minimalslope(end-2));
end
interval_min_original = interval_min;
% % 
% % % Auskommentiert von Bastian
% % % Make sure to use at least one window length
% % if max(minimalslope)-min(minimalslope)<=windowlength
% %     interval_max = (onepercent_length*minimalslope(end))+(onepercent_length*(windowlength-(max(minimalslope)-min(minimalslope))));
% % else
% %     interval_max = onepercent_length*minimalslope(end);
% % end

%% refinement of baseline edges with the deflection points
% finding best fitting polynom from polynoms of the order three to fifty
rsq = zeros(50,1);
rsq_adj = zeros(50,1);
warning off
for i=3:50
   [coeffs] = polyfit(x,y,i);
   % calculation of R^2 and adjusted R^2
   [rsq(i),rsq_adj(i),~] = poly_rsquare(coeffs,x,y);
end
warning on
% find index with maximal rsq_adj
[~,poly_deg] = max(rsq_adj);

% calculate first and second derivative of polynome
warning off
coeffs = polyfit(x,y,poly_deg);
warning on

coeffs_1 = polyder(coeffs);
coeffs_2 = polyder(coeffs_1);
root_deg2 = real(roots(coeffs_2)); % Deflection points of the 2nd derivative
root_y = polyval(coeffs,root_deg2);


if ~isempty(root_y)
    % keep deflection points within the baseline edges
    x_edges = x([interval_min;interval_max]);
    root_mask = root_deg2<x_edges(1) & root_deg2>x_edges(2);
    root_deg2 = root_deg2(root_mask);
    root_deg1_y = polyval(coeffs_1,root_deg2);
    
    
    % use first derivative to identify outliers
    first_order_median = median(root_deg1_y);
    first_order_std = std(root_deg1_y);
    root_mask = root_deg1_y>first_order_median-first_order_std & root_deg1_y<first_order_median+first_order_std;
    root_deg2 = root_deg2(root_mask);

    if ~isempty(root_deg2)
        % set baseline max to minimal deflection point (= point closest to contact point)
        min_root = min(root_deg2);
        if x(interval_max) > min_root
            [~,id] = min(abs(x-min_root));
            interval_max = id;
        end
    end
end


%% Update the interval_min and the baseline 
% till the last point is definitely under the baseline
x_fit = x(interval_min:interval_max);
y_fit = y(interval_min:interval_max);

y_fit = smoothdata(y_fit, 'gaussian', 100);

% Fit the linear fit regression line of the actual window
[p, ~] = polyfit(x_fit,y_fit,1);
y_linfit = polyval(p, x);

if interval_min >= onepercent_length
    while y(1)-y_linfit(1) >= std(y)/4 %If the last point of the curve is not in the baseline range 
        interval_min = interval_min - 5;
        x_fit = x(interval_min:interval_max);
        y_fit = y(interval_min:interval_max);

        y_fit = smoothdata(y_fit, 'gaussian', 100);

        % Fit the linear fit regression line
        [p, ~] = polyfit(x_fit,y_fit,1);
        y_linfit = polyval(p, x);

        if interval_min <= 6
            break
        end
    end
end
    
%% Check if the function is uplifted over the baseline
while y(interval_min)-y_linfit(interval_min) < 0
    interval_min = interval_min + 5;
    x_fit = x(interval_min:interval_max);
    y_fit = y(interval_min:interval_max);

    % Fit the linear fit regression line
    [p, ~] = polyfit(x_fit,y_fit,1);
    y_linfit = polyval(p, x);
end

%% Update final Interval_max
    
% y_fit = smoothdata(y_fit, 'gaussian', 100);
% std_tolerance = std(y_fit); 
% edgecounter = 0;
% coefficients = polyfit([x(interval_min), x(interval_max)], [y(interval_min), y(interval_max)], 1);
% y_baseline = coefficients(1)*x_fit+coefficients(2);
% baseline_diff = abs(y_fit-y_baseline);
% 
% maximal = max(baseline_diff);
% interval_max = interval_min + find(maximal == baseline_diff);


%% Save the edges in an array
if interval_max < interval_min
    baseline_edges(1, 1) = interval_max;
    baseline_edges(1, 2) = interval_min;
else
    baseline_edges(1, 1) = interval_min;
    baseline_edges(1, 2) = interval_max;
end
 baseline_edges(1, 3) = interval_min_original; %zum algorithmus testen
   
end