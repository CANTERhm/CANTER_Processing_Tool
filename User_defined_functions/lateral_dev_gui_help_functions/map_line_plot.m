function [hObject,handles] = map_line_plot(hObject,handles)
%%  MAP_LINE_PLOT: Function to create and update the line plot of a lateral 
%   deflection map in the lateral defelction gui.
%   
%   
%   
%   
%   
%   

%%  draw current line in current axes

line_string = sprintf('line%u',handles.current_line);
handles.line_plot = plot(handles.lines.(line_string).x_values.*1e6,handles.lines.(line_string).z_values.*1e3);
legend_string = sprintf('%s (y-coordinate: %g µm)',line_string,handles.lines.(line_string).y_values(1)*1e6);
legend(legend_string);

% find statistic values
start_guess = mean(handles.lines.(line_string).z_values);
options = fitoptions('Method','NonlinearLeastSquares','StartPoint',start_guess);
[~,gof] = fit(handles.lines.(line_string).x_values,handles.lines.(line_string).z_values,@(c,x)c.*x.^0,options);
noise_level = handles.peak_prom*gof.sse;

% find peaks
findpeaks(handles.lines.(line_string).z_values.*1e3,handles.lines.(line_string).x_values.*1e6,...
'MinPeakProminence',noise_level*1e3,'Annotate','extents',...
    'WidthReference','halfheight');
legend(legend_string,'Location','northeast');
xlabel('fast axis [µm]');
ylabel('lateral deflection [mV]');

% get peak values
[pks,locs,width] = findpeaks(handles.lines.(line_string).z_values.*1e3,handles.lines.(line_string).x_values.*1e6,...
'MinPeakProminence',noise_level*1e3,'Annotate','extents',...
    'WidthReference','halfheight');
peak_num = numel(pks);
% label peaks
text(locs+.05,pks+1,num2str((1:peak_num)'));

% create cell array for table
handles.peak_table.Data = cell(peak_num,3);
table_data = cell(peak_num,3);
for i=1:peak_num
    table_data{i,1} = pks(i);
    table_data{i,2} = width(i);
    table_data{i,3} = false;
end

% write peak values in table
handles.peak_table.Data = table_data;

end