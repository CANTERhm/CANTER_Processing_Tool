function WriteInLogFile(log_path,ME)
%%  WRITEINLOGFILE: File to write the error contained in the ME object to
%   the log file, whos location is specified in log_path as a string.
%   The error is also dispayed in an info dialog.
% 
%   EXAMPLE:
%   WriteInLogFile('C:\User\Desktop\Log_file.txt',ME_object)
%   
%   
%   

%%
Error_string = sprintf('%s\nError in: %s Line: %u\n%s\n%s\n\n\n\n',...
                           datestr(datetime('now')),...
                           ME.stack(1).name,...
                           ME.stack(1).line,...
                           ME.identifier,...
                           ME.message);
logid = fopen(log_path,'at');
fwrite(logid,Error_string);
fclose(logid);

error_dlg_cell = {sprintf('%s',datestr(datetime('now')));...
                  sprintf('Error in: %s Line: %u',ME.stack(1).name,ME.stack(1).line);...
                  sprintf('%s',ME.identifier);...
                  sprintf('%s',ME.message)};
errordlg(error_dlg_cell,'Error in Application');

end