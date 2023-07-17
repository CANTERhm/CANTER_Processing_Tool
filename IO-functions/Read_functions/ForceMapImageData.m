function [imageFiles,varargout] = ForceMapImageData(filepath)
%%  FORCEMAPIMAGEDATA: Provides the image data of the available channels
%   of an .force or .jpk file
%   
%   UNDER CONSTRUCTION
%   -> Support for .jpk file is not jet implemented.
%   
%   
%   
%   
% 

%%
imageFiles = struct;

% create tiff file from .force or .jpk file
[path,name,ext] = fileparts(filepath);
name = strcat(name,'.tif');
filepath_tiff = fullfile(path,name);
copyfile(filepath,filepath_tiff);
warning off
T = Tiff(filepath_tiff);
info = imfinfo(filepath_tiff);

% provide the image info struct also in the varargout
varargout{1} = info;



%% if .force files

if strcmp(ext,'.force')
num_of_files = length(info);
colormap = info(1).Colormap;
colormap(256,:) = [1 1 1];

    for i = 1:num_of_files
        if i == 1
            imageFiles.thumbnail = struct;
            image_type = 'thumbnail';
            imageFiles.(image_type).channel = image_type;
            setDirectory(T,i);
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
                    setDirectory(T,i);
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
                    setDirectory(T,i);
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
                    setDirectory(T,i);
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
                    setDirectory(T,i);
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
                    setDirectory(T,i);
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
            xvector = xvector - (info(1).UnknownTags(15).Value/2);
            xvector = xvector + info(1).UnknownTags(12).Value;
            imageFiles.(image_type).XVector = xvector;
            yvector = linspace(0,info(1).UnknownTags(15).Value,info(i).Height);
            yvector = yvector - (info(1).UnknownTags(14).Value/2);
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
elseif strcmp(ext,'.jpk')
    warndlg('Reading of .jpk files is not implemented at the moment!','No Implementiation');
end
close(T);
warning on
delete(filepath_tiff);

    

