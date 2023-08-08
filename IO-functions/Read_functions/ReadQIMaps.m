function [x_data,y_data, x_data_retract, y_data_retract, Forcecurve_count, varargout]=ReadQIMaps(varargin)
% ReadQIMaps  Reads .jpk-qi-data files and returns the x and y values of
% the extend and retract curves.
%
% Function call:
% [x_data,y_data, x_data_retract, y_data_retract, Forcecurve_count, varargout] = ReadQIMaps(varargin)
% 
% Instruction: 
% If the function is called you need to choose the .jpk-qi-data and it
% will give you the x and y values back as the structure variables x_data and y_data 
%
% Get the data of a single force curve in a map:
%    Curves are starting with an Index of 0
%
%    Example: x_data.curve0, y_data.curve0
%           or use --> x_data_raw.(Forcecurve_count{i})    
%
% 
%
% varargout:
% varargout{1} = encoder;
% varargout{2} = pathname;
% varargout{3} = filename;
% varargout{4} = map_images;
% varargout{5} = map_info;      -> A struct containing all availlable information about the loaded map images in raw format.
% varargout{6} = info_array;    -> Contains all information about the laoded map as a cell array (first column: names, second column: values)
% 
% encoder: (1-4 for measuredHeight; 5-6 for verticalDef)
% (1)= nominal.scaling.offset;          %channel: measuredHeight
% (2)= nominal.scaling.multiplier;      %channel: measuredHeight
% (3) = encoder.scaling.offset;         %channel: measuredHeight
% (4) = encoder.scaling.multiplier;     %channel: measuredHeight
% (5) = encoder.scaling.offset;         %channel: verticalDeflection
% (6) = encoder.scaling.multiplier;     %channel: verticalDeflection


    % Get the direction/the file and convert it into a .zip file
    if nargin >= 1
        [pathname, name, ext] = fileparts(varargin{1});
        filename = string(name)+string(ext);
    else
        [filename, pathname] = uigetfile('*.jpk-qi-data','Select a jpk-qi-data file');
        if pathname == 0
            x_data = [];
            y_data = [];
            x_data_retract = [];
            y_data_retract = [];
            Forcecurve_count = [];
            varargout{1} = [];
            varargout{2} = [];
            varargout{3} = [];
            varargout{4} = [];
            varargout{5} = [];
            varargout{6} = [];
            return;
        end
    end

    zipname = split(filename,'.jpk-qi-data');
    zipname = cell2mat(zipname);
    zipfile = strcat(zipname,'.zip');
    mappath = fullfile(pathname, filename);
    zippath = fullfile(pathname, zipfile);
    copyfile (mappath, zippath);
    
    unzipfolder = fullfile(pathname, 'Forcemap');
    
    % unzip file eather with 7zip or unzip
    try
        file_n = mfilename('fullpath');
        path_parts = split(file_n,filesep);
        unzip(fullfile(path_parts{1:end-3},'7-Zip.zip'),fullfile(path_parts{1:end-3}));
        zip_prog_path = fullfile(path_parts{1:end-3},'7-Zip','7z.exe');
        zip_command = 'x';
        switches = ['-bso0' ' ' '-r' ' ' '-y' ' ' '-o' '"' char(unzipfolder) '"' ];
        status = system(['"' char(zip_prog_path) '"' ' ' char(zip_command)  ' ' '"' char(zippath) '"' ' ' switches]);
        rmdir(fullfile(path_parts{1:end-3},'7-Zip'),'s');
    catch
        warning('7zip wasn''t found; matlabs unzip function was used instead!');
        unzip(zippath, unzipfolder);
        status = 0;
    end
    
    if status ~= 0
        warning('7zip wasn''t successful in unziping. Matlabs unzip function was used instead!');
        unzip(zippath, unzipfolder);
    end

    % Get map information
    info_array = get_map_info(unzipfolder);

    % Read Image Data
    ImageFileLocatrion = fullfile(unzipfolder,"data-image.jpk-qi-image");
    [map_images,all_info] = ForceMapImageData(ImageFileLocatrion);

    % Read Force Curves
    Indexfolder = fullfile(unzipfolder,'index');
    folder = dir(Indexfolder); % get the information of all files in the chosen folder
    files = {folder.name}; % get names(amount of curves) of all files
    files = files(3:end); % get rid of the first two lines with no suitable information
    num_files = length(files); % get the number of containing force curves
    filenumber = zeros(num_files,1);
    for i=1:num_files
        filenumber(i)= str2double(files{i});
    end
    filenumber = sort(filenumber,1);
    Forcecurve_count = strcat('curve',num2str(filenumber));
    Forcecurve_count = cellstr(Forcecurve_count);
    % Forcecurve_count = Forcecurve_count';
    Forcecurve_count = regexprep(Forcecurve_count, '\s+', ''); % Get rid of the empty space
    
    % Create structs for force curve data
    x_data_raw = struct; %Height Extend 
    y_data_raw = struct; %vDeflection Extend
    x_data_raw_retract = struct; %Height Retract
    y_data_raw_retract = struct; %vDeflection Retract
    
    % Read all extend curves and save them as x and y values (Height & vDeflection)
    for i = 1:num_files
        n = i-1;
        n_s = string(num2str(n));
        movedir = fullfile(Indexfolder,n_s);
        channels_path = fullfile(movedir,"segments","0","channels");
        Heightpath = fullfile(channels_path,"measuredHeight.dat");
        Deflectionpath = fullfile(channels_path,"vDeflection.dat");
        fileHeight = fopen(Heightpath);
        fileDeflection = fopen(Deflectionpath);
        x_data_raw.(Forcecurve_count{i}) = fread(fileHeight,inf,'long','s');
        y_data_raw.(Forcecurve_count{i}) = fread(fileDeflection,inf, 'long','s');
        fclose('all');
    end
    
    % Read all retract curves and save them as x and y values (Height & vDeflection)
    for i = 1:num_files
        n = i-1;
        n_s = string(num2str(n));
        movedir = fullfile(Indexfolder,n_s);
        channels_path = fullfile(movedir,"segments","1","channels");
        Heightpath = fullfile(channels_path,"measuredHeight.dat");
        Deflectionpath = fullfile(channels_path,"vDeflection.dat");
        fileHeight = fopen(Heightpath);
        fileDeflection = fopen(Deflectionpath);
        x_data_raw_retract.(Forcecurve_count{i}) = fread(fileHeight,inf,'long','s');
        y_data_raw_retract.(Forcecurve_count{i}) = fread(fileDeflection,inf, 'long','s');
        fclose('all');
    end
    
    segmentheader = fullfile(unzipfolder, '/shared-data/header.properties');
    
    % Get header.properties
    HeaderProperties = readtable(segmentheader,"CommentStyle","#","Delimiter","=","FileType","text","TextType","string");
    
    % Find measuredHeight channel number
    mHeightInd = find(strcmp(HeaderProperties.Var2,"measuredHeight") & contains(HeaderProperties.Var1,"lcd-info"),1);
    ChannelString = HeaderProperties.Var1(mHeightInd);
    ChannelString = split(ChannelString,".",2);
    mHeightNum = str2double(ChannelString(2));
    
    % Read the Encoders for measuredHeight
    % Encoder 1
    EncoderString = sprintf("lcd-info.%u.conversion-set.conversion.nominal.scaling.offset",mHeightNum);
    EncoderLine = find(strcmp(HeaderProperties.Var1,EncoderString),1);
    encoder(1) = str2double(HeaderProperties.Var2(EncoderLine));
    % Encoder 2
    EncoderString = sprintf("lcd-info.%u.conversion-set.conversion.nominal.scaling.multiplier",mHeightNum);
    EncoderLine = find(strcmp(HeaderProperties.Var1,EncoderString),1);
    encoder(2) = str2double(HeaderProperties.Var2(EncoderLine));
    % Encoder 3
    EncoderString = sprintf("lcd-info.%u.encoder.scaling.offset",mHeightNum);
    EncoderLine = find(strcmp(HeaderProperties.Var1,EncoderString),1);
    encoder(3) = str2double(HeaderProperties.Var2(EncoderLine));
    % Encoder 4
    EncoderString = sprintf("lcd-info.%u.encoder.scaling.multiplier",mHeightNum);
    EncoderLine = find(strcmp(HeaderProperties.Var1,EncoderString),1);
    encoder(4) = str2double(HeaderProperties.Var2(EncoderLine));
    
    % Get channel number of vDeflection
    vDefInd = find(strcmp(HeaderProperties.Var2,"vDeflection") & contains(HeaderProperties.Var1,"lcd-info"),1);
    ChannelString = HeaderProperties.Var1(vDefInd);
    ChannelString = split(ChannelString,".",2);
    vDefIndNum = str2double(ChannelString(2));
    
    % Read the Encoders for vDeflection
    % Encoder 5
    EncoderString = sprintf("lcd-info.%u.encoder.scaling.offset",vDefIndNum);
    EncoderLine = find(strcmp(HeaderProperties.Var1,EncoderString),1);
    encoder(5) = str2double(HeaderProperties.Var2(EncoderLine));
    % Encoder 6
    EncoderString = sprintf("lcd-info.%u.encoder.scaling.multiplier",vDefIndNum);
    EncoderLine = find(strcmp(HeaderProperties.Var1,EncoderString),1);
    encoder(6) = str2double(HeaderProperties.Var2(EncoderLine));
    
    %Create variables for the decoded data
    
    x_data = struct; % Height Extend 
    y_data = struct; % vDeflection Extend
    x_data_retract = struct; % Height Extend
    y_data_retract = struct; % vDeflection Extend
    
    %Decode the height for the extend part
    for i=1:num_files
        x_data.(Forcecurve_count{i})=x_data_raw.(Forcecurve_count{i}).*encoder(4)+encoder(3); % decoding into meter
        x_data.(Forcecurve_count{i})=x_data.(Forcecurve_count{i}).*encoder(2)+encoder(1); % nominal scaling
    end
    
    %Decode the height for the retract part
    for i=1:num_files
        x_data_retract.(Forcecurve_count{i})=(x_data_raw_retract.(Forcecurve_count{i}).*encoder(4))+encoder(3); % decoding into Volts
        x_data_retract.(Forcecurve_count{i})=(x_data_retract.(Forcecurve_count{i})*encoder(2))+encoder(1); % nominal scaling
        % x_data_retract.(Forcecurve_count{i}) = flip(x_data_retract.(Forcecurve_count{i})); %JPK PreProcessing does present it like that, this is necessary to get all the calculations for the next functions
    end
    
    % Decode vDeflection
    % Decode the vDeflection for the extend part
    for i=1:num_files
        y_data.(Forcecurve_count{i})=(y_data_raw.(Forcecurve_count{i})*encoder(6))+encoder(5);
    end
    % Decode the vDeflection for the retract part
    for i=1:num_files
        y_data_retract.(Forcecurve_count{i})=(y_data_raw_retract.(Forcecurve_count{i})*encoder(6))+encoder(5);
    end

    % Define varargout
    varargout{1} = encoder;
    varargout{2} = pathname;
    varargout{3} = zipname;
    varargout{4} = map_images;
    varargout{5} = all_info;
    varargout{6} = info_array;
    
    % Delete map folder and zip file
    [status,msg,msgID] = rmdir(unzipfolder,'s');
    delete(zippath);

end

% Help Functions
function info_array = get_map_info(map_folder_path)

    % initialize output cell array
    info_array = {'SPM Version',[];...
                  'Start Date',[];...
                  'Start Time',[];...
                  'Feedback Mode',[];...
                  'Closed Loop',[];...
                  'Account',[];...
                  'XY Scanner',[];...
                  'Z Scanner',[];...
                  'Z Range',[];...
                  'Size',[];...
                  'Pixels',[];...
                  'Force Settings',[];...
                  'Setpoint',[];...
                  'Z Length',[];...
                  'Extend Time',[];...
                  'Tip Speed',[];...
                  'Pixel Num',[];...
                  'Sample Rate',[]};
    
    % get file id of header.properties file
    header_file_path = fullfile(map_folder_path,'header.properties');
    header_file_id = fopen(header_file_path,'rt');
    if header_file_id == -1
        error('Function: ReadJPKMaps -> Helpfunction: get_map_info: header.properties file wasn''t found');
    end
    
    % read text file fields in cell array
    file_output = textscan(header_file_id,['%s' '%s'],'HeaderLines',1,'Delimiter','=');
    
    % separate names and values
    names_cell = file_output{1,1};
    values_cell = file_output{1,2};
    
    % define all strings that has to be searched for
    match_strings = {'quantitative-imaging-map.description.source-software';...
                     'quantitative-imaging-map.start-time';...
                     'quantitative-imaging-map.feedback-mode.name';...
                     'quantitative-imaging-map.settings.force-settings.control-settings.closed-loop';...
                     'quantitative-imaging-map.description.user-name';...
                     'quantitative-imaging-map.environment.xy-scanner-position-map.xy-scanner.tip-scanner.xy-scanner.description';...
                     'quantitative-imaging-map.environment.z-scanner-map.z-scanner.internal-z-scanner.z-scanner-environment.z-scanner.fancy-name';...
                     'quantitative-imaging-map.environment.z-scanner-map.z-scanner.internal-z-scanner.z-scanner-environment.z-range.fancyname';...
                     'quantitative-imaging-map.position-pattern.grid.ulength';...
                     'quantitative-imaging-map.position-pattern.grid.vlength';...
                     'quantitative-imaging-map.position-pattern.grid.ilength';...
                     'quantitative-imaging-map.position-pattern.grid.jlength';...
                     'quantitative-imaging-map.settings.force-settings.type';...
                     'quantitative-imaging-map.settings.force-settings.relative-setpoint';...
                     'quantitative-imaging-map.settings.force-settings.extend.z-start';...
                     'quantitative-imaging-map.settings.force-settings.extend.z-end';...
                     'quantitative-imaging-map.settings.force-settings.extend.duration';...
                     'quantitative-imaging-map.settings.force-settings.extend.num-points'};
    
    % find indices of all match_strings in names_cell
    Match = cellfun(@(x) ismember(x, match_strings), names_cell, 'UniformOutput', 0);
    match_ind = find(cell2mat(Match));
    validateString = string([18 1]);

    % write values from values_cell to the right array fields using the
    % matched indices
    for i = 1:length(match_ind)
        indx = match_ind(i);
        validateString(i,1) = string(names_cell{indx});
        switch names_cell{indx}
            
            case 'quantitative-imaging-map.description.source-software'     
                info_array(1,2) = values_cell(indx);    % write software version to corresponding array field
                
            case 'quantitative-imaging-map.start-time'
                d_t_value = values_cell{indx};
                d_t_sep = split(d_t_value);     % split string to separate date and time
                info_array{2,2} = d_t_sep{1};   % write date value to corresponding array field
                
                if strcmp(d_t_sep{3},'+0200')   % if matching do replacement
                   d_t_sep{3} = 'CEST';
                end
                if strcmp(d_t_sep{3},'+0100')   % if matching do replacement
                   d_t_sep{3} = 'CET';
                end
                
                t_z_string = [d_t_sep{2} ' ' d_t_sep{3}];   % insert space between time and time-zone
                t_z_string = replace(t_z_string,'\','');      % get rid of backspaces
                
                info_array{3,2} = t_z_string;   % write time&zone value to corresponding array field
                
            case 'quantitative-imaging-map.feedback-mode.name'
                info_array(4,2) = values_cell(indx);
                
            case 'quantitative-imaging-map.settings.force-settings.control-settings.closed-loop'
                info_array(5,2) = values_cell(indx);    % write closed loop status to corresponding array field
                
            case 'quantitative-imaging-map.description.user-name'
                info_array(6,2) = values_cell(indx);    % write user name to corresponding array field
                
            case 'quantitative-imaging-map.environment.xy-scanner-position-map.xy-scanner.tip-scanner.xy-scanner.description'
                info_array(7,2) = values_cell(indx);    % write xy scanner dexcription to corresponding array field
                
            case 'quantitative-imaging-map.environment.z-scanner-map.z-scanner.internal-z-scanner.z-scanner-environment.z-scanner.fancy-name'
                info_array(8,2) = values_cell(indx);    % write z scanner name to corresponding array field
                
            case 'quantitative-imaging-map.environment.z-scanner-map.z-scanner.internal-z-scanner.z-scanner-environment.z-range.fancyname'
                z_scanner_name = values_cell{indx};                             % get z scanner name
                info_array{9,2} = sprintf(strrep(z_scanner_name,'\u','\x'));    % replace \u with \x for correct unicode interpretation and write z scanner name to array field
                
            case 'quantitative-imaging-map.position-pattern.grid.ulength'
                ulength = str2double(values_cell{indx});    % write ulength to variable for later calculation
                
            case 'quantitative-imaging-map.position-pattern.grid.vlength'
                vlength = str2double(values_cell{indx});    % write vlength to variable for later colculation
                
            case 'quantitative-imaging-map.position-pattern.grid.ilength'
                ilength = values_cell{indx};    % write string of ilength to variable for later concatenation
                
            case 'quantitative-imaging-map.position-pattern.grid.jlength'
                jlength = values_cell{indx};    % write string of jlength to variable for later concatenation
                
            case 'quantitative-imaging-map.settings.force-settings.type'
                info_array(12,2) = values_cell(indx);   % write type of force settings to corresponding array field
                
            case 'quantitative-imaging-map.settings.force-settings.relative-setpoint'
                setpoint = str2double(values_cell{indx});   % get value of setpoint
                if setpoint < 1 % decide with is the suitable unit and write it to corresponding array field
                   info_array{13,2} = sprintf('%.0f mV',setpoint*1e3);
                else
                   info_array{13,2} = [values_cell{indx} ' V']; 
                end     
                
            case 'quantitative-imaging-map.settings.force-settings.extend.z-start'
                z_start = str2double(values_cell{indx});    % write z start value to variable for later calculation
                
            case 'quantitative-imaging-map.settings.force-settings.extend.z-end'
                z_end = str2double(values_cell{indx});      % write z end value to variable for later calculation
                
            case 'quantitative-imaging-map.settings.force-settings.extend.duration'
                extend_time = str2double(values_cell{indx});    % convert extend time to double
                if extend_time < 1                              % determine if it's smaller then 1 and write the time with correct unit to corresponding array field
                    info_array{15,2} = [sprintf('%.2f ms',extend_time*1e3)];
                else
                    info_array{15,2} = [sprintf('%.3f s',extend_time) ' s'];
                end
                
            case 'quantitative-imaging-map.settings.force-settings.extend.num-points'
                pixel_num = str2double(values_cell{indx});  % write pixel number to varaible for later calculation
                info_array{17,2} = pixel_num;   % write pixerl number in corresponding array field
                
        end
        
    end
    
    
    % write map size to info_array
    info_array{10,2} = sprintf('%.4g x %.4g µm',ulength*1e6,vlength*1e6);

    % write pixels to info_array
    info_array{11,2} = sprintf('%s x %s',ilength,jlength);
  
    % calculate z length and write value to corresponding array field
    z_len = abs(z_start - z_end);
    info_array{14,2} = sprintf('%.2f µm',z_len*1e6);

    % calculate vertical tip speed and write value to correxponding array
    % field
    tip_speed = z_len / extend_time;
    info_array{16,2} = sprintf('%.2f µm/s',tip_speed*1e6);

    % calculate sample rate and write value to corresponding array field
    sample_rate = pixel_num / extend_time;
    info_array{18,2} = sprintf('%g Hz',sample_rate);
    
    % kill file id
    fclose(header_file_id);
end