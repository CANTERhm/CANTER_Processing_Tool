function []=WriteasJPKMap(x_data, y_data, x_data_retract, y_data_retract, curve_count, encoder ,pathname ,filename, unzipfolder)
% WriteasJPKMaps  Writes a modified map in a .jkp-force-map file which then
% can be opened with the JPK Data Processing Software
% 
% []=WriteasJPKMap(x_data, y_data, x_data_retract, y_data_retract, curve_count, encoder ,pathname ,filename, unzipfolder)
%
% The variables x_data, y_data, x_data_retract, y_data_retract should be a
% struct with the following structure: x_data.curve_count(i) = the x-values
% of the curve
%
% Instruction: 
% The most convenient is to use this function together with the ReadJPKMaps
% function, because it needs all the factors to modify the values back to
% the original order.

wbar = waitbar(0,'Please wait till the JPK ForceMap is transformed');
for i=1:length(curve_count)
   
    %% recalculating x and y values with multipliers and offsets

    % x_data
       % x_data.(curve_count{i}) = (x_data.(curve_count{i})-encoder(3))./encoder(4);
        x_data.(curve_count{i}) = (x_data.(curve_count{i})-encoder(1))./encoder(2);
        x_data.(curve_count{i}) = (x_data.(curve_count{i})-encoder(5))./encoder(6);
    
    % x_data_retract
        x_data_retract.(curve_count{i}) = (x_data_retract.(curve_count{i})-encoder(1))./encoder(2);
        x_data_retract.(curve_count{i}) = (x_data_retract.(curve_count{i})-encoder(5))./encoder(6);
        
    % y_data
    y_data.(curve_count{i}) = (y_data.(curve_count{i})-encoder(7))./encoder(8);
    
    % y_data_retract
    y_data_retract.(curve_count{i}) = (y_data_retract.(curve_count{i})-encoder(7))./encoder(8);
    
    x_data.(curve_count{i}) = flip(x_data.(curve_count{i})); %Is done in ReadJPKMaps and need to be reversed
    x_data_retract.(curve_count{i}) = flip(x_data_retract.(curve_count{i})); %Is done in ReadJPKMaps and need to be reversed
        
    %% save recalculated x and y values of the extend curve to .dat files
    n = i-1;
    n_s = num2str(n);
    movedir = [unzipfolder '/index/' n_s];
    
    % write x-data to measuredheight.dat and y-data to vDeflection.dat
    savepath = [movedir '/segments/0/channels/measuredHeight.dat'];
    fileID = fopen(savepath,'w');
    fwrite(fileID,x_data.(curve_count{i}),'short',0,'s');
    fclose(fileID);
    savepath = [movedir '/segments/0/channels/vDeflection.dat'];
    fileID = fopen(savepath,'w');
    fwrite(fileID,y_data.(curve_count{i}),'short',0,'s');
    fclose(fileID);
    
    %% save recalculated x and y values of the retract curve to .dat files
    % write x-data to measuredheight.dat and y-data to vDeflection.dat
    savepath = [movedir '/segments/1/channels/measuredHeight.dat'];
    fileID = fopen(savepath,'w');
    fwrite(fileID,x_data_retract.(curve_count{i}),'short',0,'s');
    fclose(fileID);
    savepath = [movedir '/segments/1/channels/vDeflection.dat'];
    fileID = fopen(savepath,'w');
    fwrite(fileID,y_data_retract.(curve_count{i}),'short',0,'s');
    fclose(fileID);
   %% get rid of all not anymore used variables
   fclose('all');
   
   waitbar(i/length(curve_count)); % Update the waitbar
end
 close (wbar);
%% zip all necessary files and rename .zip file to .jpk-force-map

% save all folders and files located in the Forcemap folder as a zip
% file in a selected folder
pathname_exist = exist ('pathname');
if pathname_exist == 1
    savemap = uigetdir((pathname), 'Select folder to save the .jpk-force-map');
else
    savemap = uigetdir('C:\', 'Select folder to save the .jpk-force-map');
end

%Creates a Waitpanel
figure('units','pixels','position',[500 500 200 50],'windowstyle','modal');
uicontrol('style','text','string','Saving...','units','pixels','position',[75 10 50 30]);

workingdirectory = pwd;
cd (savemap);
zip(filename,{'index','shared-data','header.properties', 'data-image.force', 'thumbnail.png'}, (unzipfolder));

% transforming .zip file in .jpk-force-map file
zipname = [filename '.zip'];
jpk_force_map_name = [filename '_modified.jpk-force-map'];
copyfile(zipname,jpk_force_map_name);

% Delete the created folders and the zipfile
rmdir (unzipfolder,'s')
delete (zipname)

%Change back to the original workingdirectory
cd(workingdirectory);

%% success message
close(gcf);
message = msgbox('Transformation Completed','Success','help');

%% get rid of all variables in storage
clear


end
