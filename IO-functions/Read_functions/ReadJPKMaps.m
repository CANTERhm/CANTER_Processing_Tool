function [x_data,y_data, x_data_retract, y_data_retract, Forcecurve_count, varargout]=ReadJPKMaps(varargin)
% ReadJPKMaps  Reads .jkp-force-map files and returns the x and y values of
% the extend and retract curves
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
    filename = [name ext];
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
    path_parts = split(pwd,filesep);
    unzip(fullfile(path_parts{1:end-2},'7-Zip.zip'),fullfile(path_parts{1:end-2}));
    zip_prog_path = fullfile(path_parts{1:end-2},'7-Zip','7z.exe');
    zip_command = 'x';
    switches = ['-bso0' ' ' '-r' ' ' '-y' ' ' '-o' '"' unzipfolder '"' ];
    status = system(['"' zip_prog_path '"' ' ' zip_command  ' ' '"' zippath '"' ' ' switches]);
    rmdir(fullfile(path_parts{1:end-2},'7-Zip'),'s');
catch
    warning('7zip wasn''found; matlabs unzip function was used instead!');
    unzip(zippath, unzipfolder);
end

if status ~= 0
    warning('7zip wasn''t successful in unziping. Matlabs unuip function was used instead!');
    unzip(zippath, unzipfolder);
end
    

Indexfolder = fullfile(unzipfolder,'index');
folder = dir(Indexfolder); % get the information of all files in the chosen folder
files = {folder.name}; % get names(amount of curves) of all files
files = files(3:length(files)); % get rid of the first two lines with no suitable information
for i=1:length(files)
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
map_images = ForceMapImageData(force_path);
varargout{4} = map_images;

x_data_raw = struct; %Height Extend 
y_data_raw = struct; %vDeflection Extend
x_data_raw_retract = struct; %Height Retract
y_data_raw_retract = struct; %vDeflection Retract

% Read all extend curves and save them as x and y values (Height & vDeflection)
    for i = 1:length(files)
    n = i-1;
    n_s = num2str(n);
    movedir = [Indexfolder '/' n_s];
    Heightpath = [movedir '/segments/0/channels/measuredHeight.dat'];
    Deflectionpath = [movedir '/segments/0/channels/vDeflection.dat'];
    fileHeight = fopen(Heightpath);
    fileDeflection = fopen(Deflectionpath);
    x_data_raw.(Forcecurve_count{i}) = fread(fileHeight,inf,'short','s');
    y_data_raw.(Forcecurve_count{i}) = fread(fileDeflection,inf, 'short','s');
    fclose('all');
    
    waitbar(i/length(files)); % Update the waitbar
    
    end
    
% Read all retract curves and save them as x and y values (Height & vDeflection)
    for i = 1:length(files)
    n = i-1;
    n_s = num2str(n);
    movedir = [Indexfolder '/' n_s];
    Heightpath = [movedir '/segments/1/channels/measuredHeight.dat'];
    Deflectionpath = [movedir '/segments/1/channels/vDeflection.dat'];
    fileHeight = fopen(Heightpath);
    fileDeflection = fopen(Deflectionpath);
    x_data_raw_retract.(Forcecurve_count{i}) = fread(fileHeight,inf,'short','s');
    y_data_raw_retract.(Forcecurve_count{i}) = fread(fileDeflection,inf, 'short','s');
    fclose('all');
    
    waitbar(i/length(files)); % Update the waitbar
    
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
for i=1:length(files)
    x_data.(Forcecurve_count{i})=x_data_raw.(Forcecurve_count{i}).*encoder(6)+encoder(5);
    x_data.(Forcecurve_count{i})=x_data.(Forcecurve_count{i}).*encoder(2)+encoder(1);
    % x_data.(Forcecurve_count{i})=(x_data.(Forcecurve_count{i})*multiplier_cali_height)+offset_cali_height;
    % Formula is only needed if  Height is used
    % (lcd.info0) instead of measured height (lcd.info4)
    x_data.(Forcecurve_count{i}) = flip(x_data.(Forcecurve_count{i})); %JPK PreProcessing does present it like that, this is necessary to get all the calculations for the next functions
end
waitbar(0.25,wbar);
%Decode the height for the retract part
for i=1:length(files)
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
for i=1:length(files)
    y_data.(Forcecurve_count{i})=(y_data_raw.(Forcecurve_count{i})*encoder(8))+encoder(7);
end
waitbar(0.75,wbar);
% Decode the vDeflection for the retract part
for i=1:length(files)
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


