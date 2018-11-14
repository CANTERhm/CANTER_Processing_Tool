function [handles] = plot_bihertz(handles)
%% plot_bihertz: a function to plot and process curves in the bihertz_gui
% the entered parameters and refresh plot when parameters are changed
% 
%   [handles,plot_handle] = plot_bihertz(handles,plot_handle)
%   As input parameters the HANDLES handle from the gui and the FIG_ and PLOT_HANDLE
%   from the plot is needed.
%   The output parameters are these handles for further use in the gui
% 

%% variables
curve_ind = handles.current_curve;
c_string = sprintf('curve%u',curve_ind);
x = handles.proc_curves.(c_string).x_values.*1e6;
y = handles.proc_curves.(c_string).y_values.*1e9;
fit_depth_s = get(handles.fit_depth,'String');
fit_depth = str2double(fit_depth_s);
fit_depth = (-1)*fit_depth;
fit_perc_s = get(handles.fit_perc,'String');
fit_perc = str2double(fit_perc_s);
fit_perc = fit_perc/100;

clearvars fit_depth_s fit_perc_s

% delete previous fit
try
    delete(handles.figures.fit_plot)
catch
    %nix%
end


%% drawing of corrected curve
handles.figures.main_plot.XData = x;
handles.figures.main_plot.YData = y;


% set axis borders with 10% offset
x_min = min(x);
x_max = max(x);
y_min = min(y);
y_max = max(y);
diff_x = x_max - x_min;
diff_y = y_max - y_min;

x_left = x_min - diff_x*0.1;
x_right = x_max + diff_x*0.1;
y_top = y_max + diff_y*0.1;
y_bottom = y_min - diff_y*0.1;

figure(handles.figures.main_fig);
try
    axis([x_left x_right y_bottom y_top]);
catch
    %nix%
end

%% add patches for fit depth and fit percentage
% calculate borders
depth_left = fit_depth;
depth_right = 0;
perc_left = x_min;
perc_right = x_min - x_min*fit_perc;

% add patches
try
    delete(handles.figures.patch_handle);
catch
    %nix%
end
grey = [0.4 0.4 0.4];
hold(handles.figures.main_ax,'on');
x_p = [perc_left depth_left;perc_left depth_left;perc_right depth_right;perc_right depth_right];
y_p = [y_bottom y_bottom;y_top y_top;y_top y_top;y_bottom y_bottom];
handles.figures.patch_handle = patch(x_p,y_p,grey,'FaceAlpha',.3,'LineStyle','none');
drawnow;
hold(handles.figures.main_ax,'off');

end
