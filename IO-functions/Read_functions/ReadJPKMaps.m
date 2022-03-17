function [x_data,y_data, x_data_retract, y_data_retract, Forcecurve_count, varargout]=ReadJPKMaps(varargin)
% ReadJPKMaps  Reads .jkp-force-map files and returns the x and y values of
% the extend and retract curves
%
% Function call:
% [x_data,y_data, x_data_retract, y_data_retract, Forcecurve_count, varargout] = ReadJPKMaps(varargin)
% 
% Instruction: 
% If the function is called you need to choose the .jpk-force-map and it
% will give you the x and y values back as the structure variables x_data and y_data 
%
% Get the data of a single force curve in a map:
%    Curves are starting with an Index of 0
%
%    Example: x_data.curve0, y_data.curve0
%           or you use --> x_data_raw.(Forcecurve_count{i})    
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
% encoder:
% (1)= offset_scaling_height;
% (2)= multiplier_scaling_height;
% (3)= offset_cali_height;
% (4)= multiplier_cali_height;
% (5) = offset_encoder_height;
% (6) = multiplier_encoder_height;
% (7) = offset_encoder_vdef;
% (8) = multiplier_encoder_vdef;

% Get the direction/the file and convert it into a .zip file
if nargin == 1
    [pathname, name, ext] = fileparts(varargin{1});
    filename = string(name)+string(ext);
else
    [filename, pathname] = uigetfile('*.jpk-force-map','Select a jpk-force-map file');
end

wbar = waitbar(0,'Please wait till the jpk-force-map is unpacked');
zipname = split(filename,'.jpk-force-map');
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
    
% get general information about laoded map
info_array = get_map_info(unzipfolder);

% laod the force curves
Indexfolder = fullfile(unzipfolder,'index');
folder = dir(Indexfolder); % get the information of all files in the chosen folder
files = {folder.name}; % get names(amount of curves) of all files
files = files(3:end); % get rid of the first two lines with no suitable information
num_files = length(files); % get the number of containing force curves
for i=1:num_files
    filenumber(i)= str2double(files{i});
end
filenumber = filenumber';
filenumber = sort(filenumber,1);
Forcecurve_count = strcat('curve',num2str(filenumber));
Forcecurve_count = cellstr(Forcecurve_count);
Forcecurve_count = Forcecurve_count';
Forcecurve_count = regexprep(Forcecurve_count, '\s+', ''); % Get rid of the empty space

% provide images of map channels
force_path = fullfile(unzipfolder,'data-image.force');
[map_images,all_info] = ForceMapImageData(force_path);
varargout{4} = map_images;
varargout{5} = all_info;
varargout{6} = info_array;

x_data_raw = struct; %Height Extend 
y_data_raw = struct; %vDeflection Extend
x_data_raw_retract = struct; %Height Retract
y_data_raw_retract = struct; %vDeflection Retract

% devide the Waitbar to speed up code
dividerWaitbar = 10^(floor(log10(num_files))-1);

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
    x_data_raw.(Forcecurve_count{i}) = fread(fileHeight,inf,'short','s');
    y_data_raw.(Forcecurve_count{i}) = fread(fileDeflection,inf, 'short','s');
    fclose('all');
    
    if round(i/dividerWaitbar) == i/dividerWaitbar
        waitbar(i/num_files,wbar); % Update the waitbar
    end
        
    end
    
% Read all retract curves and save them as x and y values (Height & vDeflection)
    for i = 1:num_files
    n = i-1;
    n_s = string(num2str(n));
    movedir = fullfile(Indexfolder,n_s);
    channels_path = fullfile(movedir,"segments","0","channels");
    Heightpath = fullfile(channels_path,"measuredHeight.dat");
    Deflectionpath = fullfile(channels_path,"vDeflection.dat");
    fileHeight = fopen(Heightpath);
    fileDeflection = fopen(Deflectionpath);
    x_data_raw_retract.(Forcecurve_count{i}) = fread(fileHeight,inf,'short','s');
    y_data_raw_retract.(Forcecurve_count{i}) = fread(fileDeflection,inf, 'short','s');
    fclose('all');
    
    if round(i/dividerWaitbar) == i/dividerWaitbar
        waitbar(i/num_files,wbar); % Update the waitbar
    end
    
    end
close(wbar);    

segmentheader = fullfile(unzipfolder, '/shared-data/header.properties');

wbar = waitbar(0,'Encoder values for height are read from header file');
% Read the Encoder's for the measuredHeight 
fid = fopen(segmentheader,'r');
tline = fgetl(fid);
% Find channel number of measured Heigth
while ischar(tline)
    match = contains(tline,'channel.name=measuredHeight');
    if match == 1
        line_string = split(tline,'.');
        channelnum_measuredHeight = str2double(line_string(2));
    end
    tline = fgetl(fid);
end
fclose(fid);
% Read the Encoder's for the measuredHeight 
fid = fopen(segmentheader,'r');
tline = fgetl(fid);
while ischar(tline)
       
       matches1 = strfind(tline, sprintf('lcd-info.%u.conversion-set.conversion.nominal.scaling.offset',channelnum_measuredHeight));
       matches2 = strfind(tline, sprintf('lcd-info.%u.conversion-set.conversion.nominal.scaling.multiplier',channelnum_measuredHeight));
       matches3 = strfind(tline, sprintf('lcd-info.%u.conversion-set.conversion.calibrated.scaling.offset',channelnum_measuredHeight));
       matches4 = strfind(tline, sprintf('lcd-info.%u.conversion-set.conversion.calibrated.scaling.multiplier',channelnum_measuredHeight));
       matches5 = strfind(tline, sprintf('lcd-info.%u.encoder.scaling.offset',channelnum_measuredHeight));
       matches6 = strfind(tline, sprintf('lcd-info.%u.encoder.scaling.multiplier',channelnum_measuredHeight));
        
       if matches1==1
           h1=textscan(tline,'%s %f' ,'Delimiter','=');
           encoder(1)=h1{1,2}; % offset_scaling_height
       end
       if matches2 ==1
           h2=textscan(tline,'%s %f' ,'Delimiter','=');
           encoder(2)=h2{1,2}; %multiplier_scaling_height
       end
       if matches3 ==1
           h3=textscan(tline,'%s %f' ,'Delimiter','=');
           encoder(3)=h3{1,2}; %offset_cali_height
       end
       if matches4 ==1
           h4=textscan(tline,'%s %f' ,'Delimiter','=');
           encoder(4)=h4{1,2}; %multiplier_cali_height
       end
       if matches5 ==1
           h5=textscan(tline,'%s %f' ,'Delimiter','=');
           encoder(5)=h5{1,2}; %offset_encoder_height
       end
       if matches6 ==1
           h6=textscan(tline,'%s %f' ,'Delimiter','=');
           encoder(6)=h6{1,2}; %multiplier_encoder_height
       end
         tline = fgetl(fid);
 end
        clearvars('h1','h2','h3','h4','h5','h6');
fclose(fid);

waitbar(0.5,wbar,'Encoder values for vDeflection are read from header file');

% Get channel number of vDeflection
fid = fopen(segmentheader,'r');
tline = fgetl(fid);
while ischar(tline)
    match = contains(tline,'channel.name=vDeflection');
    if match == 1
        line_string = split(tline,'.');
        channelnum_vDeflection = str2double(line_string(2));
    end
    tline = fgetl(fid);
end
fclose(fid);

% Read the Encoder's for the vDeflection
fid = fopen(segmentheader,'r');
tline = fgetl(fid);
while ischar(tline)
       
       matches1 = strfind(tline, sprintf('lcd-info.%u.encoder.scaling.offset',channelnum_vDeflection));
       matches2 = strfind(tline, sprintf('lcd-info.%u.encoder.scaling.multiplier',channelnum_vDeflection));
   
         if matches1 ==1
             h1=textscan(tline,'%s %f' ,'Delimiter','=');
             encoder(7)=h1{1,2}; % offset_encoder_vdef
             
         end
         if matches2 ==1
             h2=textscan(tline,'%s %f' ,'Delimiter','=');
             encoder(8)=h2{1,2}; % multiplier_encoder_vdef
             
         end
         tline = fgetl(fid);
end
        clearvars('h1','h2');
fclose(fid);
waitbar(1,wbar,'Got all encoders')
close(wbar);


%Create variables for the decoded data

x_data = struct; % Height Extend 
y_data = struct; % vDeflection Extend
x_data_retract = struct; % Height Extend
y_data_retract = struct; % vDeflection Extend

wbar = waitbar(0,'Decoding all channels');
% Decode measuredHeight
%Decode the height for the extend part
for i=1:num_files
    x_data.(Forcecurve_count{i})=x_data_raw.(Forcecurve_count{i}).*encoder(6)+encoder(5);
    x_data.(Forcecurve_count{i})=x_data.(Forcecurve_count{i}).*encoder(2)+encoder(1);
    % x_data.(Forcecurve_count{i})=(x_data.(Forcecurve_count{i})*multiplier_cali_height)+offset_cali_height;
    % Formula is only needed if  Height is used
    % (lcd.info0) instead of measured height (lcd.info4)
    x_data.(Forcecurve_count{i}) = flip(x_data.(Forcecurve_count{i})); %JPK PreProcessing does present it like that, this is necessary to get all the calculations for the next functions
end
waitbar(0.25,wbar);
%Decode the height for the retract part
for i=1:num_files
    x_data_retract.(Forcecurve_count{i})=(x_data_raw_retract.(Forcecurve_count{i})*encoder(6))+encoder(5);
    x_data_retract.(Forcecurve_count{i})=(x_data_retract.(Forcecurve_count{i})*encoder(2))+encoder(1);
    % x_data.(Forcecurve_count{i})=(x_data.(Forcecurve_count{i})*multiplier_cali_height)+offset_cali_height;
    % Formula is only needed if  Height is used
    % (lcd.info0) instead of measured height (lcd.info4)
    x_data_retract.(Forcecurve_count{i}) = flip(x_data_retract.(Forcecurve_count{i})); %JPK PreProcessing does present it like that, this is necessary to get all the calculations for the next functions
end
waitbar(0.5,wbar);
% Decode vDeflection
% Decode the vDeflection for the extend part
for i=1:num_files
    y_data.(Forcecurve_count{i})=(y_data_raw.(Forcecurve_count{i})*encoder(8))+encoder(7);
end
waitbar(0.75,wbar);
% Decode the vDeflection for the retract part
for i=1:num_files
    y_data_retract.(Forcecurve_count{i})=(y_data_raw_retract.(Forcecurve_count{i})*encoder(8))+encoder(7);
end
waitbar(1,wbar);
varargout{1} = encoder;
varargout{2} = pathname;
varargout{3} = zipname;

[status,msg,msgID] = rmdir(unzipfolder,'s');
delete(zippath);

close(wbar);
end

% help function to get all important information about the force-map
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
    match_strings = {'force-scan-map.description.source-software';...
                     'force-scan-map.start-time';...
                     'force-scan-map.feedback-mode.name';...
                     'force-scan-map.settings.force-settings.closed-loop';...
                     'force-scan-map.description.user-name';...
                     'force-scan-map.environment.xy-scanner-position-map.xy-scanner.tip-scanner.xy-scanner.description';...
                     'force-scan-map.environment.z-scanner-map.z-scanner.internal-z-scanner.z-scanner-environment.z-scanner.fancy-name';...
                     'force-scan-map.environment.z-scanner-map.z-scanner.internal-z-scanner.z-scanner-environment.z-range.fancyname';...
                     'force-scan-map.position-pattern.grid.ulength';...
                     'force-scan-map.position-pattern.grid.vlength';...
                     'force-scan-map.position-pattern.grid.ilength';...
                     'force-scan-map.position-pattern.grid.jlength';...
                     'force-scan-map.settings.force-settings.type';...
                     'force-scan-map.settings.force-settings.relative-setpoint';...
                     'force-scan-map.settings.force-settings.relative-z-start';...
                     'force-scan-map.settings.force-settings.relative-z-end';...
                     'force-scan-map.settings.force-settings.extend-scan-time';...
                     'force-scan-map.settings.force-settings.extend-k-length'};
    
    % find indices of all match_strings in names_cell
    Match = cellfun(@(x) ismember(x, match_strings), names_cell, 'UniformOutput', 0);
    match_ind = find(cell2mat(Match));
    
    % write values from values_cell to the right array fields using the
    % matched indices
    for i = 1:length(match_ind)
        indx = match_ind(i);
        switch names_cell{indx}
            
            case 'force-scan-map.description.source-software'     
                info_array(1,2) = values_cell(indx);    % write software version to corresponding array field
                
            case 'force-scan-map.start-time'
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
                
            case 'force-scan-map.feedback-mode.name'
                info_array(4,2) = values_cell(indx);
                
            case 'force-scan-map.settings.force-settings.closed-loop'
                info_array(5,2) = values_cell(indx);    % write closed loop status to corresponding array field
                
            case 'force-scan-map.description.user-name'
                info_array(6,2) = values_cell(indx);    % write user name to corresponding array field
                
            case 'force-scan-map.environment.xy-scanner-position-map.xy-scanner.tip-scanner.xy-scanner.description'
                info_array(7,2) = values_cell(indx);    % write xy scanner dexcription to corresponding array field
                
            case 'force-scan-map.environment.z-scanner-map.z-scanner.internal-z-scanner.z-scanner-environment.z-scanner.fancy-name'
                info_array(8,2) = values_cell(indx);    % write z scanner name to corresponding array field
                
            case 'force-scan-map.environment.z-scanner-map.z-scanner.internal-z-scanner.z-scanner-environment.z-range.fancyname'
                z_scanner_name = values_cell{indx};                             % get z scanner name
                info_array{9,2} = sprintf(strrep(z_scanner_name,'\u','\x'));    % replace \u with \x for correct unicode interpretation and write z scanner name to array field
                
            case 'force-scan-map.position-pattern.grid.ulength'
                ulength = str2double(values_cell{indx});    % write ulength to variable for later calculation
                
            case 'force-scan-map.position-pattern.grid.vlength'
                vlength = str2double(values_cell{indx});    % write vlength to variable for later colculation
                
            case 'force-scan-map.position-pattern.grid.ilength'
                ilength = values_cell{indx};    % write string of ilength to variable for later concatenation
                
            case 'force-scan-map.position-pattern.grid.jlength'
                jlength = values_cell{indx};    % write string of jlength to variable for later concatenation
                
            case 'force-scan-map.settings.force-settings.type'
                info_array(12,2) = values_cell(indx);   % write type of force settings to corresponding array field
                
            case 'force-scan-map.settings.force-settings.relative-setpoint'
                setpoint = str2double(values_cell{indx});   % get value of setpoint
                if setpoint < 1 % decide with is the suitable unit and write it to corresponding array field
                   info_array{13,2} = sprintf('%.0f mV',setpoint*1e3);
                else
                   info_array{13,2} = [values_cell{indx} ' V']; 
                end     
                
            case 'force-scan-map.settings.force-settings.relative-z-start'
                z_start = str2double(values_cell{indx});    % write z start value to variable for later calculation
                
            case 'force-scan-map.settings.force-settings.relative-z-end'
                z_end = str2double(values_cell{indx});      % write z end value to variable for later calculation
                
            case 'force-scan-map.settings.force-settings.extend-scan-time'
                extend_time = str2double(values_cell{indx});    % convert extend time to double
                if extend_time < 1                              % determine if it's smaller then 1 and write the time with correct unit to corresponding array field
                    info_array{15,2} = [sprintf('%.2f ms',extend_time*1e3)];
                else
                    info_array{15,2} = [sprintf('%.3f s',extend_time) ' s'];
                end
                
            case 'force-scan-map.settings.force-settings.extend-k-length'
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

