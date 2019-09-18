function [mach_data,segment_headers] = ReadMachTextFile(varargin)
    %%   ReadMachTextFile:
    %   This function reads text files created from the Mach-1 indenter
    %   system from Biomomentum.
    %   
    %   [mach_data,segment_infos] = ReadMachTextFile();
    %   After calling this function you are asked to select a Mach-1 text
    %   file (.txt). As output you get a data and a header struct.
    %   The first one contains all numeric data from each segment in the
    %   text file. The second conatins the header information of each segment.
    %
    %   [mach_data,segment_infos] = ReadMachTextFile(filepath);
    %   Optionally, you can also give the function the filepath of the text
    %   file you want to read as a string.
    %       
    %   If an empty MACH-1 file is loaded, this function shows an error
    %   dialog and the function returns -1 for both, mach_data and
    %   segment_headers.
    %     
    
    
    %% Code
    
    %% Check input
    if isempty(varargin)
        [file,path] = uigetfile('*.txt');
        ext = split(file,'.',2);
        ext = ext{2};
        if ~strcmp(ext,'txt')
            error('FileTypeError\nYou have to select a Mach-1 text file!%s\n',' ');
        end
        fullpath = fullfile(path,file);
    else 
        [path,file,ext] = fileparts(varargin{1});
        fullpath = fullfile(path,[file ext]);
        exist_output = exist(fullpath,'file');
        if ~strcmp(ext,'.txt')
            error('FileTypeError\nYou have to parse a valid path to a Mach-1 text file!%s\n',' ');
        elseif exist_output ~= 2
            error('InvalidFilePath\nWrong file type or path to nonexistent file!\nPlease parse a valid path to a Mach-1 text file.%s\n',' ');
        end
    end
    
    %% Open and read file
    
    % Open file, read first line, and check if the loaded file is indeed a
    % Mach-1 text file.
    file_id = fopen(fullpath,'rt');
    if file_id == -1
        error('ReadError\nSomething went wrong while opening the text file!\nMaybe the file access is restricted.%s\n',' ');
    end
    
    first_line = fgetl(file_id);
    if ~strcmp(first_line,'<Mach-1 File>')
        error('FileTypeError\nYou must select a <a href="">Mach-1</a> text file!%s\n',' ')
    end
    
    % Read file into a cell array
    file_cell = textscan(file_id,'%s','Delimiter','\n');
    file_cell = file_cell{:};
    % Close file ID
    fclose(file_id);
    
    % throw an error if the loaded MACH-1 file is empty
    if isempty(file_cell)
       errordlg(sprintf('You can not load an empty MACH-1 file!\nPlease select a MACH-1 file with content.%s',' '),'Empty file error');
       mach_data = -1;
       segment_headers = -1;
       return;
    end
    
    % Get indices of segment start (header + data)
    match_segment_start_cell = cellfun(@(x) strcmp(x,'<INFO>'),file_cell,'UniformOutput',false);
    match_segment_start = cell2mat(match_segment_start_cell);
    
    segment_start_ind = find(match_segment_start);
    
    % Get indices of segment data start and end and info end
    match_data_start_cell = cellfun(@(x) strcmp(x,'<DATA>'),file_cell,'UniformOutput',false);
    match_data_end_cell = cellfun(@(x) strcmp(x,'<END DATA>'),file_cell,'UniformOutput',false);
    match_data_start = cell2mat(match_data_start_cell);
    match_data_end = cell2mat(match_data_end_cell);
    
    data_start_ind = find(match_data_start);
    data_end_ind = find(match_data_end);
    
    % count number of segments in Mach-1 text file
    segment_count = sum(match_segment_start);
    
    % preallocate data and header struct
    data_struct = struct();
    header_struct = struct();
    for i = 1:segment_count
        seg_name = sprintf('segment%d',i);
        data_struct.(seg_name) = [];
        header_struct.(seg_name) = [];
    end
    
    % Create waitbar
    wb = waitbar(0,'Please wait ... read header information');
    
    % Read and organize general header information and segment information
    for i =1:segment_count
       % get varaible with the current segment number
       seg_name = sprintf('segment%d',i);
       
       % write header in seg_header and find the separator index for
       % general and channel information
       seg_header = file_cell(segment_start_ind(i)+1:data_start_ind(i)-1,1);
       header_separator_cell = cellfun(@(x) strcmp(x,'<END INFO>'),seg_header);

       header_separator_ind = find(header_separator_cell);
       
       % split the header in general and channel header
       general_header = seg_header(3:header_separator_ind-1);
       channel_header = [seg_header(header_separator_ind+1);seg_header(1:2);seg_header(header_separator_ind+2:end)];
       
       % different formating of the cahnnel name
       channel_string = channel_header{1};
       % get rid of < and >
       channel_string = channel_string(2:end-1);
       % Add string 'Segment Name'
       channel_string = sprintf('Segment Name:\t%s',channel_string);
       % write channel_string in channel_header
       channel_header{1} = channel_string;
       
       % devide name-value pairs
       general_header = cellfun(@(x) split(x,':	',2),general_header,'UniformOutput',false);
       [general_header(:,1) general_header(:,2)] = cellfun(@(x) x{:},general_header,'UniformOutput',false);
       channel_header = cellfun(@(x) split(x,':	',2),channel_header,'UniformOutput',false);
       [channel_header(:,1) channel_header(:,2)] = cellfun(@(x) x{:},channel_header,'UniformOutput',false);
       
       % formating of date and time value
       segment_date = channel_header{2,2};
       segment_date = split(segment_date,',',2);
       segment_date{2} = strrep(strip(segment_date{2}),' ','.');
       segment_date = [segment_date{2} ',' strip(segment_date{3})];
       segment_date = datestr(segment_date,1);
       
       segment_time = channel_header{3,2};
       segment_time = datestr(segment_time,14);
       
       % rewrite to channel_header
       channel_header{2,2} = segment_date;
       channel_header{3,2} = segment_time;
       
       % Arrange final header cell array an write it in the output struct
       final_segment_header = [{'General Information'},{''};general_header;{''},{''};{'Segment Information'},{''};channel_header];
       header_struct.(seg_name) = final_segment_header;
       
       % update waitbar
       waitbar(i/(2*segment_count),wb);
    end
    
    % rename waitbar text
    waitbar(i/(2*segment_count),wb,'Please wait ... read data channels');
    
    % Read and organize measured data
    for i=1:segment_count
       % get name of current segment
       seg_name = sprintf('segment%d',i);
       
       % get data section of current segment
       data_cell = file_cell(data_start_ind(i)+1:data_end_ind(i)-1);
       
       % get column names and separate quantity and unit
       column_names = data_cell{1};
       split_column_names = split(column_names,'	',2)';
       split_column_names = cellfun(@(x) split(x,', ',2),split_column_names,'UniformOutput',false);
       [split_column_names(:,1),split_column_names(:,2)] = cellfun(@(x) x{1,:},split_column_names,'UniformOutput',false);
       split_column_names(:,2) = cellfun(@(x) strrep(x,'-','/'),split_column_names(:,2),'UniformOutput',false);
       split_column_names(:,1) = cellfun(@(x) replace(x,{'(';')';' '},{'';'';'_'}),split_column_names(:,1),'UniformOutput',false);
       
       % get values
       column_split = cellfun(@(x) split(x,'	',2),data_cell(2:end),'UniformOutput',false);
       column_cell = cellfun(@(x) str2double(x),column_split,'UniformOutput',false);
       column_values = cell2mat(column_cell);
       
       % Add units and values of each column to output data struct
       empty = cell([size(split_column_names,1),1]);
       struct_element = cell2struct(empty,split_column_names(:,1),1);
       for j=1:size(split_column_names,1)
          switch split_column_names{j,2}
              case 'mm'
                  struct_element.(split_column_names{j,1}).Unit = 'm';
                  struct_element.(split_column_names{j,1}).Values = column_values(:,j)'.*1e-3;
              case 'N/mm'
                  struct_element.(split_column_names{j,1}).Unit = 'N/m';
                  struct_element.(split_column_names{j,1}).Values = column_values(:,j)'.*1e3;
              otherwise
                struct_element.(split_column_names{j,1}).Unit = split_column_names{j,2};
                struct_element.(split_column_names{j,1}).Values = column_values(:,j)';
          end
          
       end 
       data_struct.(seg_name) = struct_element;
       
       % update waitbar
        waitbar((i+segment_count)/(2*segment_count),wb);
    end
    
    % delete waitbar
    close(wb);
    
    
    
    
    
    
    
    % set output
    mach_data = data_struct;
    segment_headers = header_struct;
end

