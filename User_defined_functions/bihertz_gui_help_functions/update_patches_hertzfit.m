function [hObject,handles] = update_patches_hertzfit(hObject,handles)
%%  UPDATE_PATCHES: This function updates the grey patches in the curve plot window 
%   with the new values entered by the user  
% 
%   [hObject,handles] = update_patches(hObject,handles)
%   The function just uses the default gui handles hObject and handles.

    %% calculate required values
    ind = handles.current_curve;
    c_string = sprintf('curve%u',ind);
    
    % get fit_depth values
    fit_depth_str = handles.hertz_fit_depth.String;
    fit_depth_str = strrep(fit_depth_str,',','.'); 
    handles.hertz_fit_depth.String = fit_depth_str;
    fit_depth = str2double(fit_depth_str)*(-1);
    if isnan(fit_depth)
        warning('Please enter a valid number for Fit depth.')
        handles.hertz_fit_depth.String = '1';
    end
    
    % get fit_start values
    fit_start_str = handles.hertz_fit_start.String;
    fit_start_str = strrep(fit_start_str,',','.'); 
    handles.hertz_fit_start.String = fit_start_str;
    fit_start = str2double(fit_start_str)*(-1);
    if isnan(fit_start)
        warning('Please enter a valid number for Fit start.')
        handles.hertz_fit_start.String = '0';
    end
    
    y_bottom = handles.figures.main_ax.YLim(1);
    y_top = handles.figures.main_ax.YLim(2);
    depth_left = fit_depth;
    depth_right = fit_start;

    grey = [0.4 0.4 0.4];
    x_p = [depth_left; depth_left; depth_right; depth_right];
    y_p = [y_bottom; y_top; y_top; y_bottom];

    %% creat new handle
    delete(handles.figures.patch_handle);

    figure(handles.figures.main_fig);
    handles.figures.patch_handle = patch(x_p,y_p,grey,'FaceAlpha',.3,'LineStyle','none');
    drawnow;
    %% update gui data
    guidata(hObject,handles)
end