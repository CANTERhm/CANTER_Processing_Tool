function [info_cell_array,varargout] = read_WaveNotes(data)
%%
% 
%  PREFORMATTED
%  TEXT
% 


%% code

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
               additional_struct.InvOLS = 'Invalid value!'; 
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
                additional_struct.Indexes(isnan(indexes)') = 'Invalid value!'; 
                warning('One or more invalid values for indexes!');
            else
                additional_struct.Indexes = indexes'+1; % +1 because Igor counts starting with 0 and MATLAB counts starting with 1
            end
            used_indices(i) = true;
            if_count = if_count + 1;
        case 'SpringConstant'
            springconstant = str2double(split_pairs{list_comparison(i),2});
            if isnan(springconstant)
               additional_struct.SpringConstant = 'Invalid value!'; 
               warning('Invalid value for SpringConstant!');
            else
                additional_struct.SpringConstant = springconstant;
            end
            used_indices(i) = true;
            if_count = if_count + 1;
        case 'KappaFactor'
            kappa = str2double(split_pairs{list_comparison(i),2});
            if isnan(kappa)
               additional_struct.KappaFactor = 'Invalid value!'; 
               warning('Invalid value for KappaFactor!');
            else
                additional_struct.KappaFactor = kappa;
            end
            used_indices(i) = true;
            if_count = if_count + 1;
        case 'Velocity'
            velocity = str2double(split_pairs{list_comparison(i),2});
            if isnan(velocity)
               additional_struct.Velocity = 'Invalid value!'; 
               warning('Invalid value for Velocity (Vert. Tip Speed)!');
            else
                additional_struct.Velocity = velocity;
            end
            used_indices(i) = true;
            if_count = if_count + 1;
        case 'ForceDist'
            forcedist = str2double(split_pairs{list_comparison(i),2});
            if isnan(forcedist)
               additional_struct.ForceDist = 'Invalid value!'; 
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
           additional_struct.FMapScanPoints = str2double(split_pairs{list_comparison(i),2});
           if isnan(additional_struct.FMapScanPoints)
               additional_struct.FMapScanPoints = 'Invalid value!';
               warning('Invalid value in FMapScanPoints')
           end
           
       case 'FMapScanLines'
           additional_struct.FMapScanLines = str2double(split_pairs{list_comparison(i),2});
           if isnan(additional_struct.FMapScanLines)
               additional_struct.FMapScanLines = 'Invalid value!';
               warning('Invalid value in FMapScanLines');
           end
           
       case 'TriggerType'
           triggertype = str2double(split_pairs{list_comparison(i),2});
           if isnan(triggertype)
              info_cell_array{13,2} = 'Invalid value!';
              warning('Invalid value in TriggerType');
           else
              if triggertype == 0
                 info_cell_array{13,2} = 'Relative'; 
              else
                  info_cell_array{13,2} = 'Absolute';
              end
           end
           
       case 'UseVelocity'
           usevelocity = split_pairs{list_comparison(i),2};
           usevelocity = strip(usevelocity);
           switch usevelocity
               case '1'
                   info_cell_array{14,2} = 'true';
               case '0'
                   info_cell_array{14,2} = 'false';
               otherwise
                   info_cell_array{14,2} = usevelocity;
           end
           
           
       case 'TriggerPoint'
           triggerpoint = str2double(split_pairs{list_comparison(i),2});
           if isnan(triggerpoint)
              additional_struct.TriggerPoint = 'Invalid value!';
              warning('Invalid value in TriggerPoint');
           else
               additional_struct.TriggerPoint = triggerpoint;
           end
           
       case 'NumPtsPerSec'
           samplerate = str2double(split_pairs{list_comparison(i),2});
           if isnan(samplerate)
               info_cell_array{20,2} = 'Invalid value!';
               warning('Invalid value in NumPtsPerSec');
           else
               samplerate_string = sprintf('%.0f Hz',samplerate);
               info_cell_array{19,2} = samplerate_string;
           end
   end
end
                  
% write date and time information in info_cell_array and calculate missing
% fields of info_cell_array

% 1. Write date and time information
info_cell_array{4,2} = datestr(data.creationDate,1);
info_cell_array{5,2} = datestr(data.creationDate,14);

% 2. Write Map Size to info_cell_array
fast = additional_struct.FastScanSize;
slow = additional_struct.SlowScanSize;
if strcmp(fast,'Invalid value!') || strcmp(slow,'Invalid value!')
    info_cell_array{11,2} = 'Invalid value!';
    warning('Invalid value in Map Size!\nEither FastScanSize or/and SlowScanSize have an invalid value!%s',' ');
else
 info_cell_array{11,2} = sprintf('%.2g x %.2g µm',fast*1e6,slow*1e6); 
end

% 3. Write Pixels information to info_cell_array
fast_p = additional_struct.FMapScanPoints;
slow_p = additional_struct.FMapScanLines;
if strcmp(fast_p,'Invalid value!') || strcmp(slow_p,'Invalid value!')
    info_cell_array{12,2} = 'Invalid value!';
    warning('Invalid value in Pixels\nEither FMapScanPoints or/and FMapScanLines have an invalid value!%s',' ');
else
    info_cell_array{12,2} = sprintf('%d x %d',fast_p,slow_p);
end
                       
% 4. Write Vert. Tip Speed to info_cell_array
velocity = additional_struct.Velocity;
if strcmp(velocity,'Invalid value!')
   info_cell_array{17,2} = 'Invalid value!'; 
else
    info_cell_array{17,2} = sprintf('%.2g µm/s',velocity*1e6);
end

% 5. Write Extend Time to info_cell_array
zlength = additional_struct.ZLength;
velocity = additional_struct.Velocity;
if strcmp(zlength,'Invalid value!') || strcmp(velocity,'Invalid value!')
    info_cell_array{18,2} = 'Invalid value!';
    warning('Invalid value in Extend Time\nEither ZLength or/and Velocity have an invalid value!%s',' ')
else
    info_cell_array{18,2} = sprintf('%.3g s',zlength/velocity);
end
                       
% 6.Write Triggerpoint value to info_cell_array
triggerpoint = additional_struct.TriggerPoint;
triggerchannel = info_cell_array{7,2};
if strcmp(triggerpoint,'Invalid value!')
   info_cell_array{15,2} = 'Invalid value!';
else
    switch triggerchannel
        case 'DeflVolts'
            info_cell_array{15,2} = sprintf('%.2g V',triggerpoint);
        case 'Deflection'
            info_cell_array{15,2} = sprintf('%.2g nm',triggerpoint*1e9);
        case 'Force'
            info_cell_array{15,2} = sprintf('%.2g nN',triggerpoint*1e9);
        otherwise
            info_cell_array{15,2} = sprintf('%g (no Unit)',triggerpoint);
    end
end

% 7. Write ZLength to info_cell_array
info_cell_array{16,2} = sprintf('%.2g µm',additional_struct.ZLength*1e6);

% set additional_struct as optional output
varargout{1} = additional_struct;

