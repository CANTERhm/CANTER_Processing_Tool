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
    
    % read detailed Map information
    [info_cell,additional_parameters] = read_WaveNotes(data);
    dataUnits = data.waveHeader.dataUnits;
    InvOLS = additional_parameters.InvOLS;
    SpringConst = additional_parameters.SpringConstant;
    

    x_data_raw = data.y(:,1).*(-1); % write x values from IBW file to x_data
    switch dataUnits
        case 'V'    % Deflection in Volts can be written directly to output.
            y_data_raw = data.y(:,2);
        case 'm'    % Deflection in meter has to be converted to Volts by Deviding with the "inverted optical lever sensitivity (InvOLS)".
            y_data_raw = data.y(:,2)./InvOLS; 
        case 'N'    % The applied force in Newton has to be converted by Dividing with the InvOLS and the spring constant.
            y_data_raw = data.y(:,2)./(InvOLS*SpringConst);
        otherwise
            y_data_raw = data.y(:,2); % Otherwise just write data to output, but warn the user about the unknown data unit.
            warning('Unknown data unit!\ny-channel is likely to be in the wrong unit!!!!%s',' ');
    end
            
    % last index of extend part
    extend_end_ind = additional_parameters.Indexes(2);
    
    % separate the retract part and the extend part
    x_data.(Forcecurve_count{i}) = x_data_raw(1:extend_end_ind,1); % keep the extend part
    y_data.(Forcecurve_count{i}) = y_data_raw(1:extend_end_ind,1); % keep the extend part
    x_data_retract.(Forcecurve_count{i}) = x_data_raw(extend_end_ind+1:end,1); % keep the retract part
    y_data_retract.(Forcecurve_count{i}) = y_data_raw(extend_end_ind+1:end,1); % keep the retract part
    
    
    %% updating the wait bar
    waitbar(i/(length(files)));

 end

% write the output variable mfpmapdata
mfpmapdata{1} = info_cell;
mfpmapdata{2} = additional_parameters;
 
%% close the wait bar
close(wbar)

end
