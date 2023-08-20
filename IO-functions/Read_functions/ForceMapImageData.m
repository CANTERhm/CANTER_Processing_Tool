function [imageFiles,varargout] = ForceMapImageData(filepath)
%%  FORCEMAPIMAGEDATA: Provides the image data of the available channels
%   of an .force or .jpk-qi-image file
%   
%   General function calls:
%     Example 1: imageFiles = ForceMapImageData(filepath)
%     Example 2: [imageFiles, imageInfo] = ForceMapImageData(filepath)
%   
%   Input Parameter:
%       - filepath: String of the full path of the image file (.force or .jpk-qi-image).
%
%   Outpur Parameter:
%       - imageFiles: Struct containing the loaded channels (e.g., slope, measuredHeight, adhesion) as fields which are structs themselve.
%                     Each channel struct has to contain the following fields in any order:
%                     (examples given for measuredHeight channel of a 3x3 µm map containing 25x25 force curves)
%                     * channel: character variable containing the channel name (example: 'measuredHeigt')
%                     * data_unit: SI unit of the image channel data as string (example: "m")
%                     * measuredHeight_data: double array (dim: XPixel x YPixel) containing the channel image data (example: 25x25 double array for 25x25 force map)
%                                            Note: the field name has to be the name of the channel followed by "_data" (example: measuredHeight_data)
%                     * Colormap: colormap of the map image given as a 256 x 3 double array
%                                 rows: 256 grey scale values & columns: one for R, G, and B values.
%                     * XPixel: integer of the number of pixels recorded on the map's fast axis of the map. (example: 25)
%                     * YPixel: integer of the number of pixels recorded on the map's slow axis of the map. (example: 25)
%                     * BitDepth: integer of the number of image bits. (example: 32)
%                     * Grid_Angle: integer of the angle the force map grid was recorded with. (example: 0)
%                     * XOffset: double scalar of the x offset of the force map in the scanner region in meters. (example: -2.1765e-5)
%                     * YOffset: double scalar of the y offset of the force map in the scanner region in meters. (example: -7.4124e-6)
%                     * XLength: double scalar containing the length of the map's fast axis in meters. (example: 3.0e-6);
%                     * YLength: double scalar containing the length of the map's slow axis in meters. (example: 3.0e-6);
%                     * XVector: double row vector (dim: 1 x XPixel) containing the x coordinate of the map grid. (example: 1x25 double)
%                                Can be created from the previous fields: "XVector = linspace(0,XLength,XPixel) - XLength/2 + XOffset/2"
%                     * YVector: double column vector (dim: YPixel x 1) containing the x coordinate of the map grid. (example: 25x1 double)
%                                Can be created from the previous fields: "YVector = flip((linspace(0,YLength,YPixel) - YLength/2 + YOffset/2)',1)"
%                     * XGrid: double array (dim: YPixel x XPixel) containing the grid of the x values for the image interpolation (e.g., 25x25 double)
%                              Can be created using the code: "[XGrid,YGrid] = meshgrid(XVector,YVector)"
%                     * YGrid: double array (dim: YPixel x XPixel) containing the grid of the y values for the image interpolation (e.g., 25x25 double)
%                              Can be created using the code: "[XGrid,YGrid] = meshgrid(XVector,YVector)"
%                     * XGrid_interpol: double array containing the x grid positions for the interpolated image (e.g. 500x500 double)
%                                       Here, an increase in image pixels of 20 is used (25 * 20 = 500)
%                                       Code to generate: 
%                                       XVector_interpol = linspace(0,XLength,XPixel*20) - XLength/2 + XOffset/2
%                                       YVector = flip((linspace(0,YLength,YPixel*20) - YLength/2 + YOffset/2)',1)
%                                       [XGrid_interpol,YGrid_interpol] = meshgrid(XVector_interpol,YVector_interpol)
%                     * YGrid_interpol: double array containing the y grid positions for the interpolated image (e.g. 500x500 double)
%                                       Here, an increase in image pixels of 20 is used (25 * 20 = 500)
%                                       Code example for how to generate this array, see "XGrid_interpol" above.
%                     * measuredHeight_data_linear_interpolation: interpolated image data using a "linear" interpolation in x and y (e.g. 500x500 double)
%                                                                 Note: the field name has to be the name of the channel followed by "_data_linear_interpolation" (example: measuredHeight_data_linear_interpolation)
%                                                                 Code to generate (for the measuredHeight channel):
%                                                                 F = griddedInterpolant({YVector,XVector},measuredHeight_data)
%                                                                 F.Method = 'linear';
%                                                                 linear_interpol = F({YGrid_interpol(:,1),XGrid_interpol(1,:)});
%                                                                 measuredHeight_data_linear_interpolation = flip(linear_interpol,1);
%                     * measuredHeight_data_bicubic_interpolation: interpolated image data using a "cubic" interpolation in x and y (e.g. 500x500 double)
%                                                                  Note: the field name has to be the name of the channel followed by "_data_bicubic_interpolation" (example: measuredHeight_data_bicubic_interpolation)
%                                                                  Code to generate (for the measuredHeight channel):
%                                                                  F = griddedInterpolant({YVector,XVector},measuredHeight_data)
%                                                                  F.Method = 'cubic';
%                                                                  bicubic_interpol = F({YGrid_interpol(:,1),XGrid_interpol(1,:)});
%                                                                  measuredHeight_data_bicubic_interpolation = flip(bicubic_interpol,1);
% 
%                     -> For more information about the image interpolation see MATLAB's griddedInterpolant function.
% 
% 
%       - imageFiles: (optional) This optional output parameters contains the info struct returned by the imfinfo MATLAB function which is used to get
%                                information like the bit depth of the image file.
%
% See also: GRIDDEDINTERPOLANT | IMFINFO

%%
imageFiles = struct;

% create tiff file from .force or .jpk file
% [path,name,ext] = fileparts(filepath);
[~,~,ext] = fileparts(filepath);
% name = strcat(name,'.tif');
% filepath_tiff = fullfile(path,name);
% copyfile(filepath,filepath_tiff);
warning off
% T = Tiff(filepath_tiff);
T = Tiff(filepath);
warning on
info = imfinfo(filepath);

% provide the image info struct also in the varargout
varargout{1} = info;



%% if .force files

switch ext
    case ".force"
        num_of_files = length(info);
        colormap = info(1).Colormap;
        colormap(256,:) = [1 1 1];
        
            for i = 1:num_of_files
                if i == 1
                    imageFiles.thumbnail = struct;
                    image_type = 'thumbnail';
                    imageFiles.(image_type).channel = image_type;
                    warning off
                    setDirectory(T,i);
                    warning off
                    [RGB,~] = readRGBAImage(T);
                    imageFiles.(image_type).thumbnail_image = RGB;
                    imageFiles.(image_type).image_type = 'RGB_image';
                else
                    channel_name = info(i).UnknownTags(1).Value;
                    switch channel_name
                        case 'adhesion'
                            imageFiles.adhesion = struct;
                            image_type = 'adhesion';
                            imageFiles.(image_type).channel = image_type;
                            imageFiles.(image_type).data_unit = 'Volts';
                            warning off
                            setDirectory(T,i);
                            warning on
                            im_data_int = read(T);
                            im_data_int = flip(im_data_int,1);
                            % real value calculation for adhesion                    
                            im_data = double(im_data_int);
                            % find location of multiplier and offset
                            for b=1:length(info(i).UnknownTags)
                                find_var = info(i).UnknownTags(b).Value;
                                if strcmp(find_var,'LinearScaling')
                                    break
                                end
                            end
                            mult_num = b+1;
                            off_num = b+2;
                            % caltulation
                            im_data = (im_data.*info(i).UnknownTags(mult_num).Value)+info(i).UnknownTags(off_num).Value;
                            imageFiles.(image_type).adhesion_data = im_data;
                        case 'slope'
                            imageFiles.slope = struct;
                            image_type = 'slope';
                            imageFiles.(image_type).channel = image_type;
                            imageFiles.(image_type).data_unit = 'V/m';
                            warning off
                            setDirectory(T,i);
                            warning on
                            im_data_int = read(T);
                            im_data_int = flip(im_data_int,1);
                            % real value calculation for slope
                            im_data = double(im_data_int);
                            % find location of multiplier and offset
                            for b=1:length(info(i).UnknownTags)
                                find_var = info(i).UnknownTags(b).Value;
                                if strcmp(find_var,'LinearScaling')
                                    break
                                end
                            end
                            mult_num = b+1;
                            off_num = b+2;
                            % caltulation
                            im_data = (im_data.*info(i).UnknownTags(mult_num).Value)+info(i).UnknownTags(off_num).Value;
                            imageFiles.(image_type).slope_data = im_data;
                        case 'measuredHeight'
                            imageFiles.height_measured = struct;
                            image_type = 'height_measured';
                            imageFiles.(image_type).channel = image_type;
                            imageFiles.(image_type).data_unit_absolute = 'm';
                            warning off
                            setDirectory(T,i);
                            warning on
                            im_data_int = read(T);
                            im_data_int = flip(im_data_int,1);
                            % real value claculation for absolute height
                            im_data = double(im_data_int);
                            % find location of multiplier and offset
                            for b=1:length(info(i).UnknownTags)
                                find_var = info(i).UnknownTags(b).Value;
                                if strcmp(find_var,'Absolute height')
                                    break
                                end
                            end
                            mult_num_a = b+4;
                            off_num_a = b+5;
                            % caltulation
                            im_data = (im_data.*info(i).UnknownTags(mult_num_a).Value)+info(i).UnknownTags(off_num_a).Value;
                            imageFiles.(image_type).absolute_height_data = im_data;
                            imageFiles.(image_type).data_unit_nominal = 'm';
                            % real value claculation for absolute height
                            im_data = double(im_data_int);
                            % find location of multiplier and offset
                            for b=1:length(info(i).UnknownTags)
                                find_var = info(i).UnknownTags(b).Value;
                                if strcmp(find_var,'Nominal height')
                                    break
                                end
                            end
                            mult_num_n = b+4;
                            off_num_n = b+5;
                            % caltulation
                            im_data = (im_data.*info(i).UnknownTags(mult_num_n).Value)+info(i).UnknownTags(off_num_n).Value;
                            imageFiles.(image_type).nominal_height_data = im_data;                
                        case 'vDeflection'
                            imageFiles.vDeflection = struct;
                            image_type = 'vDeflection';
                            imageFiles.(image_type).channel = image_type;
                            imageFiles.(image_type).data_unit = 'Volts';
                            warning off
                            setDirectory(T,i);
                            warning on
                            im_data_int = read(T);
                            im_data_int = flip(im_data_int,1);
                            % real value claculation for vDeflection
                            im_data = double(im_data_int);
                            % find location of multiplier and offset
                            for b=1:length(info(i).UnknownTags)
                                find_var = info(i).UnknownTags(b).Value;
                                if strcmp(find_var,'LinearScaling')
                                    break
                                end
                            end
                            mult_num = b+1;
                            off_num = b+2;
                            % caltulation
                            im_data = (im_data.*info(i).UnknownTags(mult_num).Value)+info(i).UnknownTags(off_num).Value;
                            imageFiles.(image_type).vDeflection_data = im_data;
                        otherwise
                            imageFiles.(channel_name) = struct;
                            image_type = channel_name;
                            info_table = struct2table(info(i).UnknownTags);
                            imageFiles.(image_type).channel = info_table.Value{info_table.ID==32850};
                            imageFiles.(image_type).data_unit = info_table.Value{info_table.ID==32978};
                            warning off
                            setDirectory(T,i);
                            warning on
                            im_data_int = read(T);
                            im_data_int = flip(im_data_int,1);
                            % real value calculation for slope
                            im_data = double(im_data_int);
                            % find location of multiplier and offset
                            for b=1:length(info(i).UnknownTags)
                                find_var = info(i).UnknownTags(b).Value;
                                if strcmp(find_var,'LinearScaling')
                                    break
                                end
                            end
                            mult_num = b+1;
                            off_num = b+2;
                            % caltulation
                            im_data = (im_data.*info(i).UnknownTags(mult_num).Value)+info(i).UnknownTags(off_num).Value;
                            imageFiles.(image_type).(sprintf('%s_data',image_type)) = im_data;
                    end
        
                    % write general information similar for all channels
                    imageFiles.(image_type).Colormap = colormap;
                    imageFiles.(image_type).XPixel = info(i).Width;
                    imageFiles.(image_type).YPixel = info(i).Height;
                    imageFiles.(image_type).BitDepth = info(i).BitDepth;
                    imageFiles.(image_type).Grid_Angle = info(1).UnknownTags(16).Value;
                    imageFiles.(image_type).XOffset = info(1).UnknownTags(12).Value;
                    imageFiles.(image_type).YOffset = info(1).UnknownTags(13).Value;
                    imageFiles.(image_type).XLength = info(1).UnknownTags(14).Value;
                    imageFiles.(image_type).YLength = info(1).UnknownTags(15).Value;
                    xvector = linspace(0,info(1).UnknownTags(14).Value,info(i).Width);
                    xvector = xvector - (info(1).UnknownTags(14).Value/2);
                    xvector = xvector + info(1).UnknownTags(12).Value;
                    imageFiles.(image_type).XVector = xvector;
                    yvector = linspace(0,info(1).UnknownTags(15).Value,info(i).Height);
                    yvector = yvector - (info(1).UnknownTags(15).Value/2);
                    yvector = yvector + info(1).UnknownTags(13).Value;
                    imageFiles.(image_type).YVector = flip(yvector',1);
                    [XG,YG] = meshgrid(xvector,yvector);
                    imageFiles.(image_type).XGrid = XG;
                    imageFiles.(image_type).YGrid = YG;
                    % at the moment no rotation of the Grid is programmed
        
                    % interpolated image data
                    if strcmp(image_type,'height_measured')
                        F_absolute = griddedInterpolant({yvector,xvector},imageFiles.height_measured.absolute_height_data);
                        F_nominal = griddedInterpolant({yvector,xvector},imageFiles.height_measured.nominal_height_data);
                        % refined grid (20 times finer)
                        x_interp = linspace(min(xvector),max(xvector),info(i).Width*20);
                        y_interp = linspace(min(yvector),max(yvector),info(i).Height*20);
                        y_interp = flip(y_interp',1);
                        [XGrid_interpol,YGrid_interpol] = meshgrid(x_interp,y_interp);
                        imageFiles.height_measured.XGrid_interpol = XGrid_interpol;
                        imageFiles.height_measured.YGrid_interpol = YGrid_interpol;
                        % linear interpolation
                        F_absolute.Method = 'linear';
                        F_nominal.Method = 'linear';
                        absolute_height_interpol = F_absolute({y_interp,x_interp});
                        absolute_height_interpol = flip(absolute_height_interpol,1);
                        imageFiles.height_measured.absolute_height_data_linear_interpolation = absolute_height_interpol;
                        nominal_height_interpol = F_nominal({y_interp,x_interp});
                        nominal_height_interpol = flip(nominal_height_interpol,1);
                        imageFiles.height_measured.nominal_height_data_linear_interpolation = nominal_height_interpol;
                        % bicubic interpolation
                        F_absolute.Method = 'cubic';
                        F_nominal.Method = 'cubic';
                        absolute_height_interpol = F_absolute({y_interp,x_interp});
                        absolute_height_interpol = flip(absolute_height_interpol,1);
                        imageFiles.height_measured.absolute_height_data_bicubic_interpolation = absolute_height_interpol;
                        nominal_height_interpol = F_nominal({y_interp,x_interp});
                        nominal_height_interpol = flip(nominal_height_interpol,1);
                        imageFiles.height_measured.nominal_height_data_bicubic_interpolation = nominal_height_interpol;
                    else
                        data_type = sprintf('%s_data',image_type);
                        F = griddedInterpolant({yvector,xvector},imageFiles.(image_type).(data_type));
                        % refined grid (20 times finer)
                        x_interp = linspace(min(xvector),max(xvector),info(i).Width*20);
                        y_interp = linspace(min(yvector),max(yvector),info(i).Height*20);
                        y_interp = flip(y_interp',1);
                        [XGrid_interpol,YGrid_interpol] = meshgrid(x_interp,y_interp);
                        imageFiles.(image_type).XGrid_interpol = XGrid_interpol;
                        imageFiles.(image_type).YGrid_interpol = YGrid_interpol;
                        % linear interpolation
                        F.Method = 'linear';
                        linear_interpol = F({y_interp,x_interp});
                        linear_interpol = flip(linear_interpol,1);
                        imageFiles.(image_type).(sprintf('%s_linear_interpolation',data_type)) = linear_interpol;
                        % bicubic interpolation
                        F.Method = 'cubic';
                        bicubic_interpol = F({y_interp,x_interp});
                        bicubic_interpol = flip(bicubic_interpol,1);
                        imageFiles.(image_type).(sprintf('%s_bicubic_interpolation',data_type)) = bicubic_interpol;
                    end
                end
            end
    case ".jpk-qi-image"
        num_of_files = length(info);
        colormap = info(1).Colormap;
        colormap(256,:) = [1 1 1];


        for i = 1:num_of_files
            warning off
            setDirectory(T,i);
            warning on
            TableUnknownTags = struct2table(info(i).UnknownTags);
            if ~any(TableUnknownTags.ID == 32978)
                image_type = 'thumbnail';
                imageFiles.(image_type) = struct;
                imageFiles.(image_type).channel = image_type;
                [RGB,~] = readRGBAImage(T);
                imageFiles.(image_type).thumbnail_image = RGB;
                imageFiles.(image_type).image_type = 'RGB_image';
            else
                image_type = info(i).UnknownTags(1).Value;
                imageFiles.(image_type) = struct;
                imageFiles.(image_type).channel = image_type;
                UnitIndex = find(TableUnknownTags.ID == 32978,1);
                imageFiles.(image_type).data_unit = string(TableUnknownTags.Value(UnitIndex));
                im_data_int = read(T);
                im_data_int = flip(im_data_int,1);
                im_data = double(im_data_int);
                Multiplier = TableUnknownTags.Value{UnitIndex+2};
                Offset = TableUnknownTags.Value{UnitIndex+3};
                % caltulation
                im_data = im_data.*Multiplier + Offset;
                FieldName = sprintf("%s_data",image_type);
                imageFiles.(image_type).(FieldName) = im_data;
            end

            % General information
            imageFiles.(image_type).Colormap = colormap;
            imageFiles.(image_type).XPixel = info(i).Width;
            imageFiles.(image_type).YPixel = info(i).Height;
            imageFiles.(image_type).BitDepth = info(i).BitDepth;
            GeneralInfoTable = struct2table(info(1).UnknownTags);
            imageFiles.(image_type).Grid_Angle = GeneralInfoTable.Value{GeneralInfoTable.ID == 32836};
            imageFiles.(image_type).XOffset = GeneralInfoTable.Value{GeneralInfoTable.ID == 32832};
            imageFiles.(image_type).YOffset = GeneralInfoTable.Value{GeneralInfoTable.ID == 32833};
            imageFiles.(image_type).XLength = GeneralInfoTable.Value{GeneralInfoTable.ID == 32834};
            imageFiles.(image_type).YLength = GeneralInfoTable.Value{GeneralInfoTable.ID == 32835};
            xvector = linspace(0,GeneralInfoTable.Value{GeneralInfoTable.ID == 32834},info(i).Width);
            xvector = xvector - (GeneralInfoTable.Value{GeneralInfoTable.ID == 32834}/2) + GeneralInfoTable.Value{GeneralInfoTable.ID == 32832};
            imageFiles.(image_type).XVector = xvector;
            yvector = linspace(0,GeneralInfoTable.Value{GeneralInfoTable.ID == 32835},info(i).Height);
            yvector = yvector + (GeneralInfoTable.Value{GeneralInfoTable.ID == 32835}/2) + GeneralInfoTable.Value{GeneralInfoTable.ID == 32833};
            imageFiles.(image_type).YVector = flip(yvector',1);
            [XG,YG] = meshgrid(xvector,imageFiles.(image_type).YVector);
            imageFiles.(image_type).XGrid = XG;
            imageFiles.(image_type).YGrid = YG;
        

            % interpolated image data
            if ~strcmp(image_type,'thumbnail')
                data_type = sprintf('%s_data',image_type);
                F = griddedInterpolant({yvector,xvector},imageFiles.(image_type).(data_type));
                % refined grid (20 times finer)
                x_interp = linspace(min(xvector),max(xvector),info(i).Width*20);
                y_interp = linspace(min(yvector),max(yvector),info(i).Height*20);
                y_interp = flip(y_interp',1);
                [XGrid_interpol,YGrid_interpol] = meshgrid(x_interp,y_interp);
                imageFiles.(image_type).XGrid_interpol = XGrid_interpol;
                imageFiles.(image_type).YGrid_interpol = YGrid_interpol;
                % linear interpolation
                F.Method = 'linear';
                linear_interpol = F({y_interp,x_interp});
                linear_interpol = flip(linear_interpol,1);
                imageFiles.(image_type).(sprintf('%s_linear_interpolation',data_type)) = linear_interpol;
                % bicubic interpolation
                F.Method = 'cubic';
                bicubic_interpol = F({y_interp,x_interp});
                bicubic_interpol = flip(bicubic_interpol,1);
                imageFiles.(image_type).(sprintf('%s_bicubic_interpolation',data_type)) = bicubic_interpol;
            end
        end
end
close(T);
% warning on
% delete(filepath_tiff);

    

