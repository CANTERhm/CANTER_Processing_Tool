function [hObject,handles] = update_patches_hertzfit(hObject,handles)
%%  UPDATE_PATCHES: This function updates the grey patches in the curve plot window 
%   with the new values entered by the user  
% 
%   [hObject,handles] = update_patches(hObject,handles)
%   The function just uses the default gui handles hObject and handles.

    %% calculate required values
    ind = handles.current_curve;
    c_string = sprintf('curve%u',ind);
    x = handles.proc_curves.(c_string).x_values.*1e6;
    
    
    fit_d = get(handles.hertz_fit_depth,'String');
    fit_d = strrep(fit_d,',','.'); 
    set(handles.hertz_fit_depth,'String',fit_d);
    fit_depth = str2double(fit_d)*(-1);

    x_min = min(x);
    y_bottom = handles.figures.main_ax.YLim(1);
    y_top = handles.figures.main_ax.YLim(2);
    depth_left = fit_depth;
    depth_right = 0;

    grey = [0.4 0.4 0.4];
    x_p = [depth_left; depth_left; depth_right; depth_right];
    y_p = [y_bottom; y_top; y_top; y_bottom];

    %% creat new figure
    delete(handles.figures.patch_handle);

    figure(handles.figures.main_fig);
    handles.figures.patch_handle = patch(x_p,y_p,grey,'FaceAlpha',.3,'LineStyle','none');
    drawnow;
    %% update gui data
    guidata(hObject,handles)
end