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

% save absolut maximum of baseline variations
variation_max = max(abs(y_fit)-mean(y_linfit));

% Get the intersection point of the baseline and the graph
contactpoint = find(y-y_linfit <= variation_max, 1, 'last');
real_contactpoint = x(contactpoint-1);
% Set the contactpoint as 0/0
x_corrected = x-(x(contactpoint-1));

end