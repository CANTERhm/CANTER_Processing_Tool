function [info_cell_array,varargout] = read_WaveNotes(data)
%%
% 
%  PREFORMATTED
%  TEXT
% 


%% code
% preallocate the function output info_cell_array
info_cell_array = [];

% split data to local variables
ibwread_notes = data.WaveNotes;
ibw_bin_header = data.binHeader;
ibw_wave_header = data.waveHeader;

split_char = split(ibwread_notes,char(13));
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


% get the important map information and write them into the output cell
% array and the additional_struct

% preallocate info_cell_array
info_cell_array = {'Microscope Model','';...
                   'Software Version','';...
                   'Igor File Version','';...
                   'Start Date','';...
                   'Start Time','';...
                   'Feedback Mode','';...
                   'Trigger Channel','';...
                   'Force Mode','';...
                   'Max. Scan Size','';...
                   'Max. Z Range','';...
                   'Map Size','';...
                   'Pixels','';...
                   'Trigger Type','';...
                   'Const. Tip Speed','';...
                   'Trigger Point','';...
                   'Z Length','';...
                   'Vert. Tip Speed','';...
                   'Extend Time','';...
                   'Extend Length','';...
                   'Sample Rate',''};

% preallocate additional_struct
additional_struct = struct('InvOLS',[],...
                           'Indexes',[],...
                           'SpringConstant',[],...
                           'KappaFactor',[],...
                           'Velocity',[],...
                           'ZLength',[]);
                       
% find infomation positions in WaveNotes
comp_list = {'MicroscopeModel';
             'Version';
             'IgorFileVersion';
             'ImagingMode';
             'TriggerChannel';
             'ForceMode';
             'ExtendZ';
             'FastScanSize';
             'SlowScanSize';
             'MaxScanSize';
             'FMapScanPoints';
             'FMapScanLines';
             'TriggerType';
             'ForceDist';
             'UseVelocity';
             'TriggerPoint';
             'Velocity';
             'Indexes';
             'NumPtsPerSec';
             'InvOLS';
             'SpringConstant';
             'KappaFactor'};
         
% find indices of comp_list items in the first column of split_pairs
Match = cellfun(@(x) ismember(x, comp_list), split_pairs(:,1), 'UniformOutput', 0);
list_comparison = find(cell2mat(Match));

% go through indices and write first the parameters for further
% calculations in the additional_struct
if_count = 0;
used_indices(length(list_comparison),1) = false;
    
for i=1:length(list_comparison)     
    switch split_pairs{list_comparison(i),1}
        case 'InvOLS'
            invols = str2double(split_pairs{list_comparison(i),2});
            if isnan(invols)
               additional_struct.InvOLS = 'invalid value!'; 
               warning('Invalid value for InvOLS!');
            else
                additional_struct.InvOLS = invols;
            end
            used_indices(i) = true;
            if_count = if_count + 1;
        case 'Indexes'
            indexes_split = split(split_pairs{list_comparison(i),2},',');
            indexes_comp = cellfun(@(x) ~isempty(x),indexes_split);
            indexes_split = indexes_split(indexes_comp);
            indexes = cellfun(@(x) str2double(x),indexes_split);
            if any(isnan(indexes))
                additional_struct.Indexes = indexes'+1; % +1 because Igor counts starting with 0 and MATLAB counts starting with 1
                additional_struct.Indexes(isnan(indexes)') = 'invalid value!'; 
                warning('One or more invalid values for indexes!');
            else
                additional_struct.Indexes = indexes'+1; % +1 because Igor counts starting with 0 and MATLAB counts starting with 1
            end
            used_indices(i) = true;
            if_count = if_count + 1;
        case 'SpringConstant'
            springconstant = str2double(split_pairs{list_comparison(i),2});
            if isnan(springconstant)
               additional_struct.SpringConstant = 'invalid value!'; 
               warning('Invalid value for SpringConstant!');
            else
                additional_struct.SpringConstant = springconstant;
            end
            used_indices(i) = true;
            if_count = if_count + 1;
        case 'KappaFactor'
            kappa = str2double(split_pairs{list_comparison(i),2});
            if isnan(kappa)
               additional_struct.KappaFactor = 'invalid value!'; 
               warning('Invalid value for KappaFactor!');
            else
                additional_struct.KappaFactor = kappa;
            end
            used_indices(i) = true;
            if_count = if_count + 1;
        case 'Velocity'
            velocity = str2double(split_pairs{list_comparison(i),2});
            if isnan(velocity)
               additional_struct.Velocity = 'invalid value!'; 
               warning('Invalid value for Velocity!');
            else
                additional_struct.Velocity = velocity;
            end
            used_indices(i) = true;
            if_count = if_count + 1;
        case 'ForceDist'
            forcedist = str2double(split_pairs{list_comparison(i),2});
            if isnan(forcedist)
               additional_struct.ForceDist = 'invalid value!'; 
               warning('Invalid value for ForceDist!');
            else
                additional_struct.ZLength = forcedist;
            end
            used_indices(i) = true;
            if_count = if_count + 1;
    end     % switch split_pairs{list_comparison(i),1}
    if if_count >= 6
        break
    end
end     % for i=1:length(list_comparison)

% delete used indices from list_comparison
list_comparison = list_comparison(~used_indices);

% write some values of additionnal_struct in info_cell_array
info_cell_array{15,2} = additional_struct.ZLength;
info_cell_array{16,2} = additional_struct.Velocity;
info_cell_array{18,2} = additional_struct.Indexes(2);

% write all remaining values to info_cell_array
for i = 1:length(list_comparison)
   switch split_pairs{list_comparison(i),1}
       case 'MicroscopeModel'
           info_cell_array(1,2) = split_pairs(list_comparison(i),2);
           
       case 'Version'
           info_cell_array(2,2) = split_pairs(list_comparison(i),2);
           
       case 'IgorFileVersion'
           info_cell_array(3,2) = split_pairs(list_comparison(i),2);
           
       case 'ImagingMode'
           info_cell_array(6,2) = split_pairs(list_comparison(i),2);
           
       case 'TriggerChannel'
           info_cell_array(7,2) = split_pairs(list_comparison(i),2);
           
       case 'ForceMode'
           info_cell_array(8,2) = split_pairs(list_comparison(i),2);
           
       case 'ExtendZ'
           extendz = str2double(split_pairs(list_comparison(i),2));
           if isnan(extendz)
               info_cell_array(10,2) = 'Invalid value!';
               additional_struct.ExtendZ = NaN;
               warning('Invalid value in ExtendZ for Max. Z Range!');
           else
               extendz_string = sprintf('%.2f µm',extendz*1e6);
               additional_struct.ExtendZ = extendz;
               info_cell_array{10,2} = extendz_string;
           end
           
       case 'FastScanSize'
           additional_struct.FastScanSize = str2double(split_pairs{list_comparison(i),2});
           if isnan(additional_struct.FastScanSize)
               additional_struct.FastScanSize = 'Invalid value!';
               warning('Invalid value in FastScanSize!');
           end
           
       case 'SlowScanSize'
           additional_struct.SlowScanSize = str2double(split_pairs{list_comparison(i),2});
           if isnan(additional_struct.SlowScanSize)
               additional_struct.SlowScanSize = 'Invalid value!';
               warning('Invalid value in SlowScanSize!');
           end
           
       case 'MaxScanSize'
           maxscansize = str2double(split_pairs{list_comparison(i),2});
           if isnan(maxscansize)
               info_cell_array{9,2} = 'Invalid value!';
               warning('Invalid value in MaxScanSize!');
           else
               info_cell_array{9,2} = sprintf('%.0f x %.0f µm',maxscansize*1e6,maxscansize*1e6);
           end
           
       case 'FMapScanPoints'
           
           
       case 'FMapScanLines'
           
           
       case 'TriggerType'
           
           
       case 'UseVelocity'
           
           
       case 'TriggerPoint'
           
           
       case 'NumPtsPerSec'
           
           
   end
end


disp(info_cell_array)                  
% write date and time information in info_cell_array

                       
                       
                       
                       
                       
                       
varargout{1} = additional_struct;

