function outcell = read_JPK_text_header(incell)
%%  read_JPK_text_header:
%   This function transforms the cell array (incell), which contains the
%   lines of the header part of the text file in a cell array.
% 
%   In the output cell array (outcell) the header information is split in
%   two columns of the first 7 lines from the in cell. 
%   The column contains the info name while the second column
%   contains the matching values.
%   This output cell array can for example directly written to an uitable
%   object to display the containing information in a GUI.
% 
% 


%% Code
    header_cell = incell(1:7,1);
    split_name_value = cellfun(@(x) split(x,': ',2),header_cell,'UniformOutput',false);
    [split_name,values] = cellfun(@(x) x{:},split_name_value,'UniformOutput',false);
    % separate name from split_name
    split_name = cellfun(@(x) split(x,'.',2),split_name,'UniformOutput',false);
    names = cellfun(@(x)x{1,end},split_name,'UniformOutput',false);
    outcell = [{'File Type','text file'};names,values];
        
end