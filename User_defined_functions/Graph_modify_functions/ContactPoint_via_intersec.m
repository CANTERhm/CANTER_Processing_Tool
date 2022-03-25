function [x_corrected, real_contactpoint]=ContactPoint_via_intersec(x, y, baseline_edges)
%% ContactPoint Shifts the whole curve in reference to the contact point
% (baseline_edges(1,2). The contact point becomes (0/0).
% 
% 


%% Code

%Get the baseline via the baselineedges
x_fit = x(baseline_edges(1,1):baseline_edges(1,2));
y_fit = y(baseline_edges(1,1):baseline_edges(1,2));

% Fit the baseline
[p, ~] = polyfit(x_fit,y_fit,1);
y_linfit = polyval(p, x);

% Get the last index where curve is under the baseline
last_index = find(y<y_linfit, 1, 'last');
% Get index left of the last_index
next_index = last_index + 1;
% Interpolate between the curve values betwee the two indices
warning off
try
    [p_inter,~] = polyfit(x([next_index,last_index]),[y([next_index,last_index])],1);
catch ME
    [p_inter,~] = polyfit(x([last_index-1,last_index]),[y([last_index-1,last_index])],1);
end
warning on
% Calculate intersection point (x-value) of the baseline and the interpolation polynome
real_contactpoint = (p_inter(2)-p(2))/(p(1)-p_inter(1)); % x_intersect = (t2-t1)/(m1-m2)
% Set the contact point to 0
x_corrected = x-real_contactpoint;

end