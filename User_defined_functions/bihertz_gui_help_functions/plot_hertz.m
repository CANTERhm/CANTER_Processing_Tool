function [hObject,handles] = plot_hertz(hObject,handles)
%%  plot_hertz: a function to plot and process curves in the bihertz_gui
% 	refresh plot when parameters are changed
% 
%   [handles,plot_handle] = plot_hertz(handles,plot_handle)
%   As input parameters the HANDLES handle from the gui and the FIG_ and PLOT_HANDLE
%   from the plot is needed.
%   The output parameters are these handles for further use in the gui
% 

%% variables
curve_ind = handles.current_curve;
c_string = sprintf('curve%u',curve_ind);
fit_depth_s = handles.hertz_fit_depth.String;
fit_depth = str2double(fit_depth_s);
fit_depth = (-1)*fit_depth;
fit_start = str2double(handles.hertz_fit_start.String)*(-1);

clearvars fit_depth_s


%% drawing of corrected curve
warning off
handles.figures.main_plot.XData = handles.proc_curves.(c_string).x_values*1e6;
handles.figures.main_plot.YData = handles.proc_curves.(c_string).y_values*1e9;
warning on


% set axis borders with 10% offset
x_min = min(handles.proc_curves.(c_string).x_values*1e6);
x_max = max(handles.proc_curves.(c_string).x_values*1e6);
y_min = min(handles.proc_curves.(c_string).y_values*1e9);
y_max = max(handles.proc_curves.(c_string).y_values*1e9);
diff_x = x_max - x_min;
diff_y = y_max - y_min;

x_left = x_min - diff_x*0.1;
x_right = x_max + diff_x*0.1;
y_top = y_max + diff_y*0.1;
y_bottom = y_min - diff_y*0.1;

try
    handles.figures.main_ax.XLim = [x_left x_right];
    handles.figures.main_ax.YLim = [y_bottom y_top];
catch
    %nix%
end


%% add patches for fit depth
% define borders
depth_left = fit_depth;
depth_right = fit_start;

%% Display Contact Point and Baseline
x = handles.proc_curves.(c_string).x_values*1e6;
y = handles.proc_curves.(c_string).y_values*1e9;

%Smooth the data as it is done in the BaselineFinder
y = smoothdata(y, 'gaussian', 100);

if ~any(isnan(handles.baselineedges))
    A = [x(handles.baselineedges(1,1)) y(handles.baselineedges(1,1))];
    B = [x(handles.baselineedges(1,2)) y(handles.baselineedges(1,2))];
    C = [x(handles.baselineedges(1,3)) y(handles.baselineedges(1,3))];
else
    A = [NaN,NaN];
    B = [NaN,NaN];
    C = [NaN,NaN];
end

% slope = ((A(2)-B(2))/(A(1)-B(1)));
% xlim = get(gca,'XLim');
% y_bl_Left = slope * (xlim(1) - B(1)) + B(2);
% y_bl_Right = slope * (xlim(2) - B(1)) + B(1);
% ylim = get(gca, 'YLim');

%% add patches
try delete(handles.figures.patch_handle); catch ; end
try delete(handles.figures.baseline); catch ; end
try delete(handles.figures.baselineedges); catch ; end
try delete(handles.figures.baselineedges_2); catch ; end
try delete(handles.figures.fittedcurve); catch; end
try delete(handles.figures.contactpoint_line); catch ; end


grey = [0.4 0.4 0.4];
hold(handles.figures.main_ax,'on');
x_p = [depth_left; depth_left; depth_right; depth_right];
y_p = [y_bottom; y_top; y_top; y_bottom];
handles.figures.patch_handle = patch(handles.figures.main_ax,x_p,y_p,grey,'FaceAlpha',.3,'LineStyle','none');
handles.figures.baseline = line(handles.figures.main_ax,[x_left, x_right], [0, 0], 'Color','black','LineStyle','--');
if ~isfield(handles.fit_results,'hertz_contact_point') || isempty(handles.fit_results.hertz_contact_point)
    handles.figures.contactpoint_line = line(handles.figures.main_ax,[0, 0], [y_bottom, y_top],'Color','black','LineStyle','--');
else
    c_point = handles.fit_results.hertz_contact_point*1e6;
    handles.figures.contactpoint_line = line(handles.figures.main_ax,[c_point, c_point], [y_bottom, y_top],'Color','black','LineStyle','--');
end
handles.figures.baselineedges = scatter(handles.figures.main_ax,[A(1), B(1), C(1)], [A(2), B(2), C(2)]);
handles.figures.baselineedges_2 = scatter(handles.figures.main_ax,C(1), C(2), 'filled');
hold(handles.figures.main_ax,'off');


end
