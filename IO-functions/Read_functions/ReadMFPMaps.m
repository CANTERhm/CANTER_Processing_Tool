function [x_data, y_data, x_data_retract, y_data_retract, Forcecurve_count, file_name, mfpmapdata]=ReadMFPMaps(pathname)
% ************************************************************************%
%                                                                         %
%   * Read the forcemap of the MFP-3D                                     %
%                                                                         %
% ************************************************************************%
    
folder = dir(strcat(pathname)); % get the information of all files in the chosen folder
files = {folder.name}'; % get names of all files in folder
files = files(3:length(files)); % get rid of the first two lines with no suitable information
[~,file_name,~] = fileparts(pathname); % save the name of the folder

% defining the illustraiting wait bar
wbar = waitbar(0,'Please wait while the force map is read');

x_data = struct;
y_data = struct;
x_data_retract = struct;
y_data_retract = struct;
count = (1:length(files));

for i=1:length(count)
    Forcecurve_count(i) = cellstr(['curve' num2str(count(i))]);
end
Forcecurve_count = Forcecurve_count';

% read all .ibw force-curves
for i = 1:length(files)
    
    root = [pathname '\' files(i)]; % part for the actual IBW file
    fileroot = cell2mat(root); % transforming cell array to string
    data = IBWread(fileroot); % import the actual IBW file
    x_data_raw = data.y(:,1).*(-1); % write x values from IBW file to x_data
    y_data_raw = data.y(:,2)*1e7; % write y values from IBW file to y_data

    % find maximum of force curve do get rid of the retract part and just
    % keep the extend part
    [~,I] = max(y_data_raw); % find maximum (M) and index of Maximum (I) of y_data
    x_data.(Forcecurve_count{i}) = x_data_raw(1:I,1); % keep the extend part
    y_data.(Forcecurve_count{i}) = y_data_raw(1:I,1); % keep the extend part
    x_data_retract.(Forcecurve_count{i}) = x_data_raw(I+1:end,1); % keep the retract part
    y_data_retract.(Forcecurve_count{i}) = y_data_raw(I+1:end,1); % keep the retract part
    
    
%Test to read additional map data
    if i == 1
        mfpmapdata = data.WaveNotes;
%         scanpt_loc = strfind(data.WaveNotes, 'FMapScanPoints');
%         scanpt = str2num(data.WaveNotes((scanpt_loc)+16:(scanpt_loc)+17));
%         scanl_loc = strfind(data.WaveNotes, 'FMapScanLines');
%         scanl = str2num(data.WaveNotes((scanl_loc)+15:(scanl_loc)+17));
    end
    
    %% updating the wait bar
    waitbar(i/(length(files)));
    
    clearvars x_data_raw y_data_raw root fileroot data I
    fclose('all');

end

%% close the wait bar
close(wbar)

end
