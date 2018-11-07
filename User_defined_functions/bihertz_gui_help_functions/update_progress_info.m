function [hObject,handles] = update_progress_info(hObject,handles)
%%  UPDATE_PROGRESS_INFO: Function to update the provided info text for the 
%   progress of the data processing.
%   
%   handles = update_progress_info(handles)
%   Updated infos: 
%   * Number of unprocessed curves
%   * Number of processed curves
%   * Number of discarded curves
% 

%%
set(handles.text27,'String',sprintf('unprocessed: %u',...
                    handles.progress.num_unprocessed));
                
set(handles.text28,'String',sprintf('processed: %u',...
                    handles.progress.num_processed));

set(handles.text29,'String',sprintf('discarded: %u',...
                    handles.progress.num_discarded));
                
guidata(hObject,handles);