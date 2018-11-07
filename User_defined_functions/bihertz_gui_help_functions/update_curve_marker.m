function handles = update_curve_marker(handles)
%%  UPDATE_CURVE_MARKER: Function to update the marker of the current 
%                        processed force curve on the map image.
% 
%   EXAMPLE:
%   handles = update_curve_marker(handles)
% 
%
% 

%%
%   Code starts here
% make map axes active
axes(handles.map_axes);
% draw new marker on the position of the current curve
curve_num = handles.current_curve;

% delete existing marker
delete(handles.figures.proc_point);
delete(handles.figures.proc_text);

% make the map_axes hold all graphs
hold(handles.map_axes,'on');


handles.figures.proc_point = plot(handles.map_info.processing_grid(curve_num,1),...
    handles.map_info.processing_grid(curve_num,2),'.w','MarkerSize',15);

% x position for the text
if handles.map_info.processing_grid(curve_num,1) < handles.map_info.x_pixel/2
    x_pos = handles.map_info.processing_grid(curve_num,1)+0.5;
    alignment = 'left';
else
    x_pos = handles.map_info.processing_grid(curve_num,1)-0.5;
    alignment = 'right';
end

% y position of the text
if handles.map_info.processing_grid(curve_num,2)<handles.map_info.y_pixel/2
    y_pos = handles.map_info.processing_grid(curve_num,2)+0.5;
else
    y_pos = handles.map_info.processing_grid(curve_num,2)-0.5;
end
    
handles.figures.proc_text = text(x_pos,y_pos,...
    sprintf('%g',curve_num),'Color','w','FontWeight','bold',...
    'HorizontalAlignment',alignment);
% switch hold satus to off
hold(handles.map_axes,'off');

end