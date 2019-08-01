function [info_cell_array] = read_WaveNotes(iwbread_notes)
%%
% 
%  PREFORMATTED
%  TEXT
% 


%% code
split_char = split(iwbread_notes,char(13));
split_pairs = cell(length(split_char),2);
for i=1:length(split_char)
    split_line = split(split_char{i},':');
    split_pairs(i,1) = split_line(1);
    if length(split_line) > 2
        string = cell(1,length(split_line)-1);
        for j = 1:length(split_line)-2
            string{j} = [split_line{j+1} ':'];
        end
        string(end) = split_line(end);
        split_pairs{i,2} = [string{1:end}];
    elseif length(split_line) < 2
        split_pairs{i,2} = '';
    else
        split_pairs(i,2) = split_line(2);
    end
end
disp(iwbread_notes);

disp('hallo');

