function [x_data, y_data, x_data_retract, y_data_retract, Forcecurve_count, file_name, mfpmapdata]=ReadMFPMaps(pathname)
% ************************************************************************%
%                                                                         %
%   * Read the forcemap of the MFP-3D                                     %
%                                                                         %
% ************************************************************************%
    
folder = dir(fullfile(strcat(pathname),'*.ibw')); % get the information of all files in the chosen folder
files = {folder.name}'; % get names of all files in folder
[~,file_name,~] = fileparts(pathname); % save the name of the folder as file_name

% defining the illustraiting wait bar
wbar = waitbar(0,'Please wait while the force map is read');

x_data = struct;
y_data = struct;
x_data_retract = struct;
y_data_retract = struct;

% preallocate Forcecurve_count
Forcecurve_count(1:length(files),1) = string(missing);
% write curve counts in Forcecurve_count
for i=1:length(files)
    Forcecurve_count(i,1) = ['curve' num2str(i)];
end


% read all .ibw force-curves
 for i = 1:length(files)
    
    fileroot = fullfile(pathname,files{i}); % part for the actual IBW file
    data = IBWread(fileroot); % import the actual IBW file
    [info_cell,additional_parameters] = read_WaveNotes(data);
    x_data_raw = data.y(:,1).*(-1); % write x values from IBW file to x_data
    
    %% replace 1e7 with corresponding value from WaveNotes!!!!!!!!!!!!!!!!
    y_data_raw = data.y(:,2)*1e7; % write y values from IBW file to y_data
    
    
    % find maximum of force curve to separate the retract part and the extend part
    %% replace max(y_data_raw) and I with index from WaveNotes!!!!!!!!!!!!!!!!
    [~,I] = max(y_data_raw); % find maximum (M) and index of Maximum (I) of y_data
    x_data.(Forcecurve_count{i}) = x_data_raw(1:I,1); % keep the extend part
    y_data.(Forcecurve_count{i}) = y_data_raw(1:I,1); % keep the extend part
    x_data_retract.(Forcecurve_count{i}) = x_data_raw(I+1:end,1); % keep the retract part
    y_data_retract.(Forcecurve_count{i}) = y_data_raw(I+1:end,1); % keep the retract part
    
    
    %% updating the wait bar
    waitbar(i/(length(files)));

 end
% write the output variable mfpmapdata
mfpmapdata{1} = info_cell;
mfpmapdata{2} = additional_parameters;
 
%% close the wait bar
close(wbar)

end
