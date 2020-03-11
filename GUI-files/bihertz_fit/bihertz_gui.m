function varargout = bihertz_gui(varargin)
%% LICENSE
% 
% 
% CANTER Processing Tool: A tool for the data processing of force-indentation curves and more ...
%     Copyright (C) 2018-present  Bastian Hartmann and Lutz Fleischhauer
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
%     
%   
% 
%    
%%    
% BIHERTZ_GUI MATLAB code for bihertz_gui.fig
%      BIHERTZ_GUI, by itself, creates a new BIHERTZ_GUI or raises the existing
%      singleton*.
%
%      H = BIHERTZ_GUI returns the handle to a new BIHERTZ_GUI or the handle to
%      the existing singleton*.
%
%      BIHERTZ_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIHERTZ_GUI.M with the given input arguments.
%
%      BIHERTZ_GUI('Property','Value',...) creates a new BIHERTZ_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bihertz_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bihertz_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bihertz_gui

% Last Modified by GUIDE v2.5 26-Sep-2019 11:03:57
    warning off
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bihertz_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @bihertz_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});

end

    warning on
% End initialization code - DO NOT EDIT


% --- Executes just before bihertz_gui is made visible.
function bihertz_gui_OpeningFcn(hObject, ~, handles, varargin)
    
    
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bihertz_gui (see VARARGIN)
warning off
% Choose default command line output for bihertz_gui
handles.output = hObject;

% get default window size and save led width
handles.def_wind_width = handles.figure1.Position(3);
handles.def_wind_height = handles.figure1.Position(4);
handles.def_led_width = handles.save_status_led.Position(3);
handles.def_led_x = handles.save_status_led.Position(1);
handles.def_led_y = handles.save_status_led.Position(2);

% Update handles structure
handles.options = varargin{1};
handles.curves = struct();
handles.figures = struct('main_fig',[]);
handles.load_status = 0;
handles.loaded_file_type = 'none';
handles.save_status = [];
handles.interpolation_type = 'bicubic';
handles.ibw = false;
handles.options.bihertz_variant = 1;
handles.last_load_path = [];
handles.last_save_path = [];

guidata(hObject, handles);


% set gui appearance depending on chosen model
handles.fit_model_popup.Enable = 'on';
switch handles.options.model
    case 'bihertz'
        handles.fit_model_popup.Value = 2;
    case 'hertz'
        handles.fit_model_popup.Value = 1;
        handles.uipanel5.Visible = 'off';
        handles.uipanel10.Visible = 'off';
        handles.hertz_fit_panel.Visible = 'on';
        axes(handles.map_axes);
        axis off

guidata(hObject,handles);
end

handles = grid_creation_function(handles);

warning on
guidata(hObject,handles);




% UIWAIT makes bihertz_gui wait for user response (see UIRESUME)
% Not needed anymore!!!
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bihertz_gui_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.options;
varargout{2} = handles;

% maximise window
handles.figure1.WindowState = 'maximized';


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, ~, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1

% differ between single and double click on listbox item
figure_hand = gcf;
if strcmp(figure_hand.SelectionType,'open')
    try
        delete(handles.figures.single_curve_fig);
    catch
        % ME if you can
    end
    handles.figures.single_curve_fig = figure;
    handles.figures.single_curve_ax = axes;
    
    % get number of double clicked_curve
    curve_index = hObject.Value;
    
    % make a copy of handles
    handles_copy = handles;
    % set the curve index as current curve in handles copy
    handles_copy.current_curve = curve_index;
    % process the choosen curve with the handles copy
    [hObject,handles_copy] = process_options(hObject,handles_copy);
    guidata(hObject,handles);

    % make the single_curve_fig the main_fig in handles copy aswell as the
    % axes and overwrite fit_handle
    handles_copy.figures.main_fig = handles.figures.single_curve_fig;
    handles_copy.figures.main_ax = handles.figures.single_curve_ax;
    handles_copy.figures.fit_plot = [];
    
    % plot unprocessed curve as dummy in main_plot
    figure(handles_copy.figures.main_fig);
    c_string = sprintf('curve%u',curve_index);
    handles_copy.figures.main_plot = ...
        plot(handles_copy.proc_curves.(c_string).x_values,handles_copy.proc_curves.(c_string).y_values);
    
    % draw choosen curve
    switch handles.options.model
        case 'bihertz'
            [handles_copy] = plot_bihertz(handles_copy);
            guidata(hObject,handles);
        case 'hertz'
            [hObject,handles_copy] = plot_hertz(hObject,handles_copy);
            guidata(hObject,handles);
    end
    
    % fit model to choosen curve and display fitresult in single_curve_fig
    warning off
    [hObject,handles_copy] = curve_fit_functions(hObject,handles_copy);
    warning on
    guidata(hObject,handles);
    
    % add annotation to single_curve_fig
    figure(handles.figures.single_curve_fig);
    switch handles.options.model
        case 'bihertz'
            plot_str = {c_string,...
                sprintf('Young''s Modulus soft: %.2f kPa',handles_copy.fit_results.fit_E_s/1e3),...
                sprintf('Young''s Modulus hard: %.2f kPa',handles_copy.fit_results.fit_E_h/1e3),...
                sprintf('Soft layer thickness: %.2f µm',handles_copy.fit_results.fit_d_h*1e6),...
                sprintf('R^2: %1.5f',handles_copy.fit_results.rsquare_fit)};
            hold(handles.figures.single_curve_ax,'on')
            h1 = line(nan,nan,'Color','none');
            h2 = line(nan,nan,'Color','none');
            h3 = line(nan,nan,'Color','none');
            h4 = line(nan,nan,'Color','none');
            h5 = line(nan,nan,'Color','none');
            warning off
            [~,leg_icons] = legend([h1 h2 h3 h4 h5],plot_str,'Location','northeast');
            warning on
            icon_hnd = findobj(leg_icons,'type','text');
            icon_hnd(1).Position(1) = .08;
            icon_hnd(2).Position(1) = .08;
            icon_hnd(3).Position(1) = .08;
            icon_hnd(4).Position(1) = .08;
            icon_hnd(5).Position(1) = .08;
        case 'hertz'
            plot_str = {c_string,...
                sprintf('Young''s Modulus: %.2f kPa',handles_copy.fit_results.EModul/1e3),...
                sprintf('R^2: %1.5f',handles_copy.fit_results.gof_rsquare)};
            h1 = line(nan,nan,'Color','none');
            h2 = line(nan,nan,'Color','none');
            h3 = line(nan,nan,'Color','none');
            warning off
            [~,leg_icons] = legend([h1 h2 h3],plot_str,'Location','northeast');
            warning on
            icon_hnd = findobj(leg_icons,'type','text');
            icon_hnd(1).Position(1) = .08;
            icon_hnd(2).Position(1) = .08;
            icon_hnd(3).Position(1) = .08;
    end
    
    
    
else
    % the following code will be executed after single-click
    selection_num = hObject.Value;

    if selection_num == handles.current_curve
        % deaktivate all list buttons
        handles.button_keep_highlighted.Enable = 'off';
        handles.button_undo_highlighted.Enable = 'off';
        handles.button_discard_highlighted.Enable = 'off';
    elseif selection_num < handles.current_curve
        % aktivate undo list button and deaktivate the other list buttons
        handles.button_keep_highlighted.Enable = 'off';
        handles.button_undo_highlighted.Enable = 'on';
        handles.button_discard_highlighted.Enable = 'off';
    elseif selection_num > handles.current_curve
        % deaktivate undo list button and aktivate the other list buttons
        handles.button_keep_highlighted.Enable = 'on';
        handles.button_undo_highlighted.Enable = 'off';
        handles.button_discard_highlighted.Enable = 'on';
    end
end




% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, ~, ~)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over listbox1.
function listbox1_ButtonDownFcn(~, ~, ~)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function edit_filepath_Callback(hObject, ~, ~)
% hObject    handle to edit_filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filepath as text
%        str2double(get(hObject,'String')) returns contents of edit_filepath as a double

tooltip_string = hObject.Tooltip;
hObject.String = tooltip_string;


% --- Executes during object creation, after setting all properties.
function edit_filepath_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_file.
function button_file_Callback(hObject, ~, handles)
% hObject    handle to button_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path,ext] = uigetfile({'*.jpk-force-map','JPK-Force-map (*.jpk-force-map)';...
    '*.txt','Mach-1 text-file (*.txt)'},'Select a File',handles.last_load_path);

if ~isequal(file,0)
    % save last load path for next invoke of uigetfile
    handles.last_load_path = path;
    fullpathtofile = fullfile(path,file);
    handles.edit_filepath.HorizontalAlignment = 'right';
    handles.edit_filepath.Enable = 'on';
    handles.edit_filepath.String = fullpathtofile;
    handles.edit_filepath.Tooltip = fullpathtofile;
    handles.filefilter = ext;
    handles.loadtype = 'file';
    guidata(hObject,handles)
end

% --- Executes on button press in button_load_data.
function button_load_data_Callback(hObject, ~, handles)
% hObject    handle to button_load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = 'NaN';
if handles.save_status == 1
    answer = questdlg({'There is loaded data!',...
        'If you load new data all unsaved results will be lost!',...
        'Do you really want to load new data?'},...
        'Loaded data warning','Yes','No','No');
end

if strcmp(answer,'No')
    return;
elseif strcmp(answer,'Yes')  || strcmp(answer, 'NaN')
    
    % initialise fit results struct or reset previous fit results
    handles.fit_results = struct();
    
    path = get(handles.edit_filepath,'String');
    if strcmp(path,'    filepath')
        errordlg('No file or folder selected','No selection found');
    else
        handles.options = Calibration(handles.options);
        guidata(hObject,handles);
        
        handles.options = canti_sample_gui(handles.options);
        guidata(hObject,handles);
        
        % get indenter options and poisson ration in dependency of the choosen
        % indenter shape
        handles = get_indenter_parameter(handles);
                
        % reset invalid_data_type controle parameter
        handles.invalid_data_type = false;
        


        % provide processing infos
        str = sprintf('Sensitivity: %.2f nm/V',handles.options.sensitivity);
        set(handles.text_sensitivity,'String',str);
        str = sprintf('Spring constant: %.4f N/m',handles.options.spring_const);
        set(handles.text_spring_const,'String',str);
        
        % set the prefered load path also as prefered save path if save
        % path is empty
        if isempty(handles.last_save_path)
            handles.last_save_path = handles.last_load_path;
        end

        switch handles.loadtype
            case 'file'
                if handles.filefilter == 1
                   handles.loaded_file_type = 'jpk-force-map';
                   % if a jpk-force-map is loaded reset the fit start and
                   % fit depth values
                   handles.hertz_fit_depth.String = '1';
                   handles.hertz_fit_start.String = '0';
                   [x_data,y_data, ~, ~, Forcecurve_label,~,~,name_of_file,map_images,~,handles.map_info_array] = ReadJPKMaps(handles.edit_filepath.String);
                   % create filename array
                   Forcecurve_label = Forcecurve_label';
                   curves_in_map = strcat(name_of_file,'.',Forcecurve_label);
                   handles.file_names = curves_in_map;
                   Forcecurve_label = Forcecurve_label';
                   % save map image in handles and display in axes
                   handles.map_images = map_images;
                   guidata(hObject,handles);
                   axes(handles.map_axes);
                   % get image channels
                   handles.channel_names = fieldnames(handles.map_images);
                   if strcmp(handles.channel_names{1},'thumbnail')
                       handles.channel_names(1) = [];
                   end
                   handles.image_channels_popup.String = handles.channel_names;
                   
                   % create processing grid for visual curve feedback
                   map_tags = fieldnames(handles.map_images);
                   if strcmp(map_tags{1},'thumbnail')
                       map_tags(1) = [];
                   end
                   handles.map_info = struct('x_pixel',0,'y_pixel',0,'processing_grid',[0,0]);
                   handles.map_info.x_pixel = handles.map_images.(map_tags{1}).XPixel;
                   handles.map_info.y_pixel = handles.map_images.(map_tags{1}).YPixel;
                   handles.map_info.processing_grid = zeros(handles.map_info.x_pixel*handles.map_info.y_pixel,2);
                   grid_index = 0;
                   for i=1:(handles.map_info.y_pixel)
                       for j = 1:(handles.map_info.x_pixel)
                           grid_index = grid_index + 1;
                           handles.map_info.processing_grid(grid_index,1) = j;
                           handles.map_info.processing_grid(grid_index,2) = i;
                       end
                       % flip every second line of the processing_grid
                       % because the jpk NanoWizard records a force map on
                       % a snakelia line.
                       if ~mod(i,2)
                           run_ind = i*handles.map_info.x_pixel;
                           last_vec = handles.map_info.processing_grid((run_ind)-handles.map_info.x_pixel+1:run_ind,1);
                           flip_vec = flipud(last_vec);
                           handles.map_info.processing_grid((run_ind)-handles.map_info.x_pixel+1:run_ind,1) = flip_vec;
                       end
                   end                           
                   
                   % write image channels in popup
                   handles.image_channels_popup.Enable = 'on';
                   for i=1:length(handles.channel_names)
                       if strcmp(handles.channel_names{i},'height')
                           handles.image_channels_popup.Value = i;
                           channel_image = handles.map_images.height.absolute_height_data_bicubic_interpolation;
                           imshow(flip(channel_image,1),[],'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel]);
                           handles.map_axes.YDir = 'normal';
                           hline = findall(gca,'Type','image');
                           set(hline(1),'uicontextmenu',handles.map_axes_context);
                           set_afm_gold;
                           handles = colorbar_helpf(handles.map_axes,handles);
                           break
                       elseif i==length(handles.channel_names) && ~strcmp(handles.channel_names{i},'height')
                           handles.image_channels_popup.Value = 1;
                           channel_image = handles.map_images.(handles.channel_names{i}).(sprintf('%s_data_bicubic_interpolation',...
                                handles.channel_names{i}));
                           imshow(flip(channel_image,1),[],'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel]);
                           handles.map_axes.YDir = 'normal';
                           hline = findall(gca,'Type','image');
                           set(hline(1),'uicontextmenu',handles.map_axes_context);
                           set_afm_gold;
                           handles = colorbar_helpf(handles.map_axes,handles);
                       end
                   end
                   
                   % display first processing grid point and text
                   axes(handles.map_axes);
                   hold(handles.map_axes,'on');
                   handles.figures.proc_point = plot(1,1,'.w','MarkerSize',15);
                   handles.figures.proc_text = text(1.5,1.5,'1','Color','w','FontWeight','bold');
                   hold(handles.map_axes,'off');
                   guidata(hObject,handles);
                   
                   num_files = length(Forcecurve_label);
                    % preallocate curve struct
                    for i=1:num_files
                        c_string = sprintf('curve%u',i);
                        curves.(c_string) = struct('x_values',[],'y_values',[]);                    
                    end
                   
                   % create waitbar for load process with cancel button
                    wb_num = 0;
                    wb = waitbar(0,sprintf('Loading progress: %.g%%',wb_num*100),'Name',...
                        'Loading ...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
                    setappdata(wb,'canceling',0);
                    % preallocate listbox cell
                    it(1:num_files,1) = {''};
                    handles.listbox1.String = it;
                    guidata(hObject,handles);

                    % load x and y values from file in struct elements
                    for i=1:num_files
                        % Check for clicked cancel button
                        if getappdata(wb,'canceling')
                            break
                        end
                        % load x and y values of each force curve
                        c_string = sprintf('curve%u',i);
                        curves.(c_string).x_values = x_data.(Forcecurve_label{i}).*1e-6; %Save data as meter[m]
                        curves.(c_string).y_values = y_data.(Forcecurve_label{i}); %Save data as Volt[V]
                        % add listbox element                  
                        it = handles.listbox1.String;
                        it{i,1} = sprintf('curve %3u  ->  unprocessed',i);
                        handles.listbox1.String = it;
                        % update waitbar
                        wb_num = i/num_files;
                        waitbar(wb_num,wb,sprintf('Loading progress: %.f%%',wb_num*100))
                    end
                   
                   
                elseif handles.filefilter == 2
                    [mach_data,mach_info] = ReadMachTextFile(handles.edit_filepath.String);
                    
                    % interrupt callback when an empty MACH-1 file is
                    % loaded
                    if (isnumeric(mach_data) && mach_data == -1) || (isnumeric(mach_info) && mach_info == -1)
                       return; 
                    end
                    
                    handles.mach_info_struct = mach_info;
                    % if loading of file was successful, set the loaded
                    % file type to mach-txt and set fit-depth to  500 µm
                    handles.loaded_file_type = 'mach-txt';
                    % set fit-depth to 500 µm just in case the value is 1 µm
                    % which is the AFM default value for the fit-depth
                    if strcmp(handles.hertz_fit_depth.String,'1')
                        handles.hertz_fit_depth.String = '500';
                    end
                    
                    % set channel_names empty
                    handles.channel_names = 'no loaded channels';
                    
                    % create segment_labels and determine number of
                    % segments
                    segment_labels = fieldnames(mach_data);
                    handles.file_names = segment_labels;
                    seg_num = length(segment_labels);
                    
                    % preallocate listbox cell
                    it(1:seg_num,1) = {''};
                    handles.listbox1.String = it;
                    guidata(hObject,handles);
                    
                    % create watibar
                    wb_num = 0;
                    wb = waitbar(0,sprintf('Loading progress: %.g%%',wb_num*100),'Name',...
                        'Loading ...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
                    setappdata(wb,'canceling',0);
                    
                    % create main data struct with x and y values and write
                    % strings in listbox
                    for i = 1:seg_num
                        % Check for clicked cancel button
                        if getappdata(wb,'canceling')
                            break
                        end
                        % load x and y values of each force curve
                        c_string = sprintf('curve%u',i);
                        current_label = segment_labels{i};
                        % load x values in dependency of unit
                        % (The multiplication by (-1) is due to the different sign convention of the positive distance direction of the MACH-1 sytem)
                        switch mach_data.(current_label).Position_z.Unit
                            case 'm'
                                curves.(c_string).x_values = mach_data.(current_label).Position_z.Values.*(-1);   % get x values in meter
                            case 'cm'
                                curves.(c_string).x_values = mach_data.(current_label).Position_z.Values.*(-1).*1e-2;   % get x values in meter
                            case 'mm'
                                curves.(c_string).x_values = mach_data.(current_label).Position_z.Values.*(-1).*1e-3;   % get x values in meter
                            case 'µm'
                                curves.(c_string).x_values = mach_data.(current_label).Position_z.Values.*(-1).*1e-6;   % get x values in meter
                            otherwise
                                curves.(c_string).x_values = mach_data.(current_label).Position_z.Values.*(-1);   % get x values in any unit
                                warning on
                                warning('Unknown unit for Position_z\nValues may be laoded in a different unit than meter!%s\n',' ');
                        end
                        % load y values in dependency of unit
                        % (The multiplication by (-1) is due to the different sign convention of the positive force direction of the MACH-1 sytem)
                        switch mach_data.(current_label).Fz.Unit
                            case 'N'
                                curves.(c_string).y_values = mach_data.(current_label).Fz.Values.*(-1);   % get y values in newton
                            case 'mN'
                                curves.(c_string).y_values = mach_data.(current_label).Fz.Values.*(-1).*1e-3;   % get y values in newton
                            case 'µN'
                                curves.(c_string).y_values = mach_data.(current_label).Fz.Values.*(-1).*1e-6;   % get y values in newton
                            case 'nN'
                                curves.(c_string).y_values = mach_data.(current_label).Fz.Values.*(-1).*1e-9;   % get y values in newton
                            otherwise
                                curves.(c_string).y_values = mach_data.(current_label).Fz.Values.*(-1);   % get y values in any unit
                                warning on
                                warning('Unknown unit for Fz\nValues may be laoded in a different unit than newton!%s\n',' ');
                        end
                            
                        % add listbox element                  
                        it = handles.listbox1.String;
                        it{i,1} = sprintf('curve %3u  ->  unprocessed',i);
                        handles.listbox1.String = it;
                        % update waitbar
                        wb_num = i/seg_num;
                        waitbar(wb_num,wb,sprintf('Loading progress: %.f%%',wb_num*100))
                    end
                      
                end
                                                
            case 'folder'
                folderpath = get(handles.edit_filepath,'String');       % get folder location
                listing = [dir(fullfile(folderpath,'*.ibw'));dir(fullfile(folderpath,'*.txt'))];    % information of files in folder
                [~,~,filetype] = fileparts(listing(1).name);
                
                % Check if the folder contains .ibw files from the MFP-3D
                if strcmp(filetype, '.ibw')
                    handles.loaded_file_type = 'ibw';
                    handles.ibw = true;
                    % if a ibw-file is loaded reset the fit start and
                    % fit depth values
                    handles.hertz_fit_depth.String = '1';
                    handles.hertz_fit_start.String = '0';
                    [x_data,y_data,~,~, Forcecurve_label, name_of_file, mfpmapdata] = ReadMFPMaps(folderpath);
                    Forcecurve_label = Forcecurve_label';
                    curves_in_map = strcat(name_of_file,'.',Forcecurve_label);
                    handles.file_names = curves_in_map;
                    num_files = length(Forcecurve_label);
                    handles.mfpmapdata = mfpmapdata;
                    % preinitialise curve struct
                    for i=1:num_files
                        c_string = sprintf('curve%u',i);
                        curves.(c_string) = struct('x_values',[],'y_values',[]);                    
                    end

                    % create waitbar for load process with cancel button
                    wb_num = 0;
                    wb = waitbar(0,sprintf('Loading progress: %.g%%',wb_num*100),'Name',...
                        'Loading ...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
                    setappdata(wb,'canceling',0);
                    % preallocate listbox cell
                    it(1:num_files,1) = {''};
                    handles.listbox1.String = it;
                    guidata(hObject,handles);
                    
                    % Get the size of the forcemap
                    map_parameters = mfpmapdata{2};
                    scanpt = map_parameters.FMapScanPoints;
                    scanl = map_parameters.FMapScanLines;
                    handles.MFP_height_matrix = zeros(scanl,scanpt);
                    handles.MFP_mslope_matrix = zeros(scanl,scanpt);
                    handles.MFP_fmap_num_line = scanl;    %Number of lines in the forcemap
                    handles.MFP_fmap_num_points = scanpt; %Number of points in the forcemap

                    % load x and y values from file in struct elements
                    for i=1:num_files
                        % Check for clicked cancel button
                        if getappdata(wb,'canceling')
                            break
                        end
                        % load x and y values of each force curve
                        c_string = sprintf('curve%u',i);
                        curves.(c_string).x_values = x_data.(Forcecurve_label{i}); %x_data are stored as meter[m]
                        curves.(c_string).y_values = y_data.(Forcecurve_label{i}); %y_data are stored as Volt[V]
                        if i == 1
                            pt_count = 1;
                            line_count = scanl;
                        end
                        %Get the height value of each curve
                        handles.MFP_height_matrix(line_count,pt_count) = min(x_data.(Forcecurve_label{i}));
                        
                        %Get the measured slope value of each curve
                        y_data_singlecurve = y_data.(Forcecurve_label{i});
                        x_data_singlecurve = x_data.(Forcecurve_label{i});
                        y_data_fit = y_data_singlecurve((length(y_data_singlecurve)-round(0.02*length(y_data_singlecurve))):end);
                        x_data_fit = x_data_singlecurve((length(x_data_singlecurve)-round(0.02*length(x_data_singlecurve))):end);
                        [p] = polyfit(x_data_fit, y_data_fit, 1);
                        handles.MFP_mslope_matrix(line_count,pt_count) = p(1);
                        
                        if pt_count == scanpt
                            pt_count = 0;
                            line_count = line_count - 1;
                        end
                        pt_count = pt_count +1;
                        % add listbox element                  
                        it = handles.listbox1.String;
                        it{i,1} = sprintf('curve %3u  ->  unprocessed',i);
                        handles.listbox1.String = it;
                        % update waitbar
                        wb_num = i/num_files;
                        waitbar(wb_num,wb,sprintf('Loading progress: %.f%%',wb_num*100))
                    end
                    %Subtract the minimum value of the height matrix to get
                    %the real height
                    lowest_point = min(min(handles.MFP_height_matrix));
                    handles.MFP_height_matrix = handles.MFP_height_matrix-lowest_point;
                    
                    %Replace all the left zeros by the minimal/maximal value to get
                    %still a good image
                    mslope_matrix = handles.MFP_mslope_matrix;
                    mslope_matrix(mslope_matrix==0) = [];
                    handles.MFP_mslope_matrix(handles.MFP_mslope_matrix==0) = (min(min(mslope_matrix))); %Calling min twice is a trick to get the minimum value of a whole matrix
                 
                    height_matrix = handles.MFP_height_matrix;
                    height_matrix(height_matrix==0) = [];
                    handles.MFP_height_matrix(handles.MFP_height_matrix ==0) = (min(min(height_matrix))); %Calling min twice is a trick to get the minimum value of a whole matrix                
                    
                    %Create interpolation images of height and slope matrix
                    [handles.MFP_mslope_matrix_linear_interpolation, handles.MFP_mslope_matrix_cubic_interpolation] = ImageInterpolationMFP(map_parameters.FMapScanPoints,map_parameters.FMapScanLines,handles.MFP_mslope_matrix);
                    [handles.MFP_height_matrix_linear_interpolation, handles.MFP_height_matrix_cubic_interpolation] = ImageInterpolationMFP(map_parameters.FMapScanPoints,map_parameters.FMapScanLines,handles.MFP_height_matrix);
                    
                    % Get the color gradient for each matrix
                    handles.colorgrad_height = flipud(linspace(min(min(handles.MFP_height_matrix)), max(max(handles.MFP_height_matrix)), 100))';
                    handles.colorgrad_slope = flipud(linspace(min(min(handles.MFP_mslope_matrix)), max(max(handles.MFP_mslope_matrix)), 100))';
                    
                    %Enable the Image Channel popup menu
                    handles.channel_names = {'height', 'slope'}';
                    handles.image_channels_popup.String = handles.channel_names;
                    handles.image_channels_popup.Enable = 'on';
                    
                    % plot an channel image and the given color gradient
                    handles.map_axes.Visible = 'on';
                    handles.image_channels_popup.Value = 1;
                    axes(handles.map_axes);
                    %Bicubic interpolation is set as default
                    imshow(handles.MFP_height_matrix_cubic_interpolation, 'InitialMagnification', 'fit', 'XData', [1 handles.MFP_fmap_num_points], 'YData', [1 handles.MFP_fmap_num_line], 'DisplayRange', []);
                    set_afm_gold();
                    handles = colorbar_helpf(handles.map_axes,handles);
                    hline = findall(gca,'Type','image');
                    set(hline(1),'uicontextmenu',handles.map_axes_context);
                    
                    % create processing grid for visual curve feedback
                    handles.map_info = struct('x_pixel',0,'y_pixel',0,'processing_grid',[0,0]);
                    handles.map_info.x_pixel = map_parameters.FMapScanPoints;
                    handles.map_info.y_pixel = map_parameters.FMapScanLines;
                    handles.map_info.processing_grid = zeros(handles.map_info.x_pixel*handles.map_info.y_pixel,2);
                    grid_index = 0;
                    for i=1:(handles.map_info.y_pixel)
                        for j = 1:(handles.map_info.x_pixel)
                            grid_index = grid_index + 1;
                            handles.map_info.processing_grid(grid_index,1) = j;
                            handles.map_info.processing_grid(grid_index,2) = i;
                        end
                    end
                    handles.map_info.processing_grid(:,2) = flip(handles.map_info.processing_grid(:,2));
 
                    % display first processing grid point and text
                    axes(handles.map_axes);
                    hold(handles.map_axes,'on');
                    handles.figures.proc_point = plot(1,map_parameters.FMapScanLines,'.w','MarkerSize',15);
                    handles.figures.proc_text = text(1.5,map_parameters.FMapScanLines-0.5,'1','Color','w','FontWeight','bold');
                    hold(handles.map_axes,'off');
                    guidata(hObject,handles);

               elseif strcmp(filetype, '.txt')
			
                    handles.loaded_file_type = 'txt';
                    T_files_in_folder = struct2table(listing);
                    files_in_folder = table2array(T_files_in_folder(:,1));  % cell array with all file names
                    handles.file_names = files_in_folder;                   % save the filenames
                    num_files = length(files_in_folder);                    % number of files in folder

                    % preallocate curve struct
                    for i=1:num_files
                        c_string = sprintf('curve%u',i);
                        curves.(c_string) = struct('x_values',[],'y_values',[]);                    
                    end

                    % create waitbar for load process with cancel button
                    wb_num = 0;
                    wb = waitbar(0,sprintf('Loading progress: %.g%%',wb_num*100),'Name',...
                        'Loading ...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
                    setappdata(wb,'canceling',0);
                    % preallocate listbox cell
                    it(1:num_files,1) = {''};
                    handles.listbox1.String = it;
                    guidata(hObject,handles);

                    % load x and y values from file in struct elements
                    for i=1:num_files
                        % Check for clicked cancel button
                        if getappdata(wb,'canceling')
                            break
                        end
                        % load x and y values of next file in folder
                        filepath = fullfile(path,files_in_folder{i});
                        % get first line with number
                        testid = fopen(filepath);
                        line = fgetl(testid);
                        
                        if i == 1
                            % preallocate info_cell_array
                            info_cell_array = {};
                        end
                        
                        count = 1;
                        while ischar(line)
                            line = fgetl(testid);
                            line_sep = split(line,' ');
                            if ~strcmp(line_sep{1},'#') && ~isempty(line_sep{1})
                                break
                            end
                            if i == 1
                                info_cell_array(end+1,1) = {line};
                            end
                            count = count + 1;
                        end       
                        count = count + 1;
                        fclose(testid); 
                        handles.text_file_info = read_JPK_text_header(info_cell_array);
                        coordinates = import_force_curve_txt_file_fast(filepath,count);
                        c_string = sprintf('curve%u',i);
                        curves.(c_string).x_values = coordinates.x_values;
                        curves.(c_string).y_values = coordinates.y_values;
                        % add listbox element                  
                        it = handles.listbox1.String;
                        it{i,1} = sprintf('curve %3u  ->  unprocessed',i);
                        handles.listbox1.String = it;
                        % update waitbar
                        wb_num = i/num_files;
                        waitbar(wb_num,wb,sprintf('Loading progress: %.f%%',wb_num*100));
                    end
                    
                    % plot an channel image dummy
                    axes(handles.map_axes);
                    imshow('no_image_dummy.jpg');
                else
                    warndlg('No readable datatype is contained in the choosen folder!');
                    handles.invalid_data_type = true;
                end  
        end
        
        if ~handles.invalid_data_type
        
            handles.listbox1.Value = 1;         % highlight listbox item number one
            handles.curves = curves;            % write curves struct to handles
            handles.current_curve = 1;          % set the current curve to first
            handles.load_status = 1;            % set load status tag to 1
            handles.save_status = 0;            % set save status tag to 0
            handles.save_status_led.BackgroundColor = [1 0 0];
            delete(wb)                          % delete loading waitbar
            if strcmp(handles.loaded_file_type,'mach-txt')
                num_files = seg_num;
            end
            if length(fieldnames(curves)) == num_files
                handles.num_files = num_files;  % provide max curve number in handles
            else
            num_files = length(fieldnames(curves))-1;                % number of fully loaded curves
            handles.num_files = length(fieldnames(curves))-1;        % provide max curve number in handles                    
            end

            % provide file information in the info panel
            handles = info_panel_helpf(handles);        

            % write progress values
            % needed variables
            handles.progress = struct('num_unprocessed',num_files,...
                                      'num_processed',0,...
                                      'num_discarded',0);
            % write process
            [hObject,handles] = update_progress_info(hObject,handles);

            % create struct for processed data
            handles.proc_curves = curves;

            %% Curve processing function V
            % function for the processing of current curve depending on user
            % options.
            try
            [hObject,handles] = process_options(hObject,handles);
            catch % ME
                % if you can
            end
            %%

            % create main plot window for displaying processed curves
            if ~isempty(handles.figures.main_fig)
                delete(handles.figures.main_fig);
                handles.figures.main_fig = [];
            end

            handles.figures.main_fig = figure('NumberTitle','off','Name','Main plot window');
            figure(handles.figures.main_fig);
            handles.figures.main_fig.CloseRequestFcn = {@main_plot_CloseRequest,handles};
            handles.figures.main_ax = axes;
            handles.figures.main_ax.FontSize = 16;
            hold(handles.figures.main_ax,'on');
            handles.figures.main_plot = plot(nan,nan);
            handles.figures.patch_handle = patch(nan,nan,nan);
            hold(handles.figures.main_ax,'off');
            xlabel('Vertical tip position [µm]');
            ylabel({'Force [nN]';''});
            guidata(hObject,handles);
            
            % fit data to processed curve and display fitresult
            [hObject,handles] = curve_fit_functions(hObject,handles);
            guidata(hObject,handles);
            
            %Plot the data with chosen model
            switch handles.options.model
                case 'bihertz'
                    [handles] = plot_bihertz(handles);
                    guidata(hObject,handles);
                case 'hertz'
                    [hObject,handles] = plot_hertz(hObject,handles);
                    guidata(hObject,handles);
            end

            % preallocate result table
            switch handles.options.model
                case 'bihertz'
                    if handles.options.bihertz_variant == 1
                        varTypes =  {'string','uint64','double','double','double',...
                                     'double','double','double','double'};
                        varNames = {'File_name','Index','initial_E_s_Pa','initial_E_h_Pa',...
                                    'initial_d_h_m','fit_E_s_Pa','fit_E_h_Pa','fit_d_h_m','rsquare_fit'};
                        handles.T_result = table('size',[handles.num_files 9],'VariableTypes',varTypes,'VariableNames',varNames);
                    elseif handles.options.bihertz_variant == 2
                        varTypes =  {'string','uint64','double','double','double','double',...
                                     'double','double','double','double','double'};
                        varNames = {'File_name','Index','initial_E_s_Pa','initial_E_h_Pa',...
                                    'initial_d_h_m','initial_s_p_m','fit_E_s_Pa','fit_E_h_Pa','fit_d_h_m','fit_s_p_m','rsquare_fit'};
                        handles.T_result = table('size',[handles.num_files 11],'VariableTypes',varTypes,'VariableNames',varNames);
                    end

                case 'hertz'
                    varTypes =  {'string','uint64','double','double'};
                    varNames = {'File_name','Index','EModul','rsquare_fit'};
                    handles.T_result = table('size',[num_files 4],'VariableTypes',varTypes,'VariableNames',varNames);
            end


            % update gui fit results
            [hObject,handles] = update_fit_results(hObject,handles);

            % activate the gui buttons
            handles.button_keep.Enable = 'on';
            handles.button_discard.Enable = 'on';
            handles.button_keep_all.Enable = 'on';
            handles.fit_model_popup.Enable = 'on';
            


        end
    end
end

%If button is pressed again without reopening app, update interpolation
handles.interpolation_type = 'bicubic';
handles.none.Checked = 'off';
handles.linear.Checked  = 'off';
handles.bicubic.Checked = 'on';


guidata(hObject,handles);





function edit_savepath_Callback(~, ~, ~) %#ok<*DEFNU>
% hObject    handle to edit_savepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_savepath as text
%        str2double(get(hObject,'String')) returns contents of edit_savepath as a double


% --- Executes during object creation, after setting all properties.
function edit_savepath_CreateFcn(hObject, ~, ~)
% hObject    handle to edit_savepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_save_path.
function button_save_path_Callback(hObject, ~, handles)
% hObject    handle to button_save_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path,~] = uiputfile({'*.tsv;*.xlsx','Save files (*.tsv,*.xlsx)';...
        '*.*','All Files (*.*)'},'Save results',handles.last_save_path);

if path ~= 0
    % save path for later revokes of uiputfile
    handles.last_save_path = path;
    
    if ~isempty(handles.T_result) && isfield(handles,'T_result')
        savepath = fullfile(path,file);
        save_table(handles.T_result,'fileFormat','tsv','savepath',savepath);
        save_diffract = split(savepath,'.tsv');
        savepath_cell = strcat(save_diffract(1),'.xlsx');
        savepath = savepath_cell{1};
        if exist(savepath,'file') == 2
            delete(savepath)
        end
        save_table(handles.T_result,'fileFormat','excel','savepath',savepath);
        handles.save_status = 1;
        handles.save_status_led.BackgroundColor = [0 1 0];
    end

end
guidata(hObject,handles);

% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(~, ~, ~)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit2_Callback(~, ~, ~)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, ~, ~)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(~, ~, ~)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(~, ~, ~)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function fit_depth_Callback(hObject, ~, handles)
% hObject    handle to fit_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fit_depth as text
%        str2double(get(hObject,'String')) returns contents of fit_depth as a double


[hObject,handles] = update_patches(hObject,handles);

% fit data to processed curve and display fitresult
[hObject,handles] = curve_fit_functions(hObject,handles);
guidata(hObject,handles);

% update gui fit results
[hObject,handles] = update_fit_results(hObject,handles);


guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function fit_depth_CreateFcn(hObject, ~, ~)
% hObject    handle to fit_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fit_perc_Callback(hObject, ~, handles)
% hObject    handle to fit_perc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fit_perc as text
%        str2double(get(hObject,'String')) returns contents of fit_perc as a double


[hObject,handles] = update_patches(hObject,handles);

% fit data to processed curve and display fitresult
[hObject,handles] = curve_fit_functions(hObject,handles);
guidata(hObject,handles);

% update gui fit results
[hObject,handles] = update_fit_results(hObject,handles);


guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function fit_perc_CreateFcn(hObject, ~, ~)
% hObject    handle to fit_perc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_keep_highlighted.
function button_keep_highlighted_Callback(hObject, ~, handles)
% hObject    handle to button_keep_highlighted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curve_index_old = handles.current_curve;
selection_num = handles.listbox1.Value;
selection_diff = selection_num - handles.current_curve;
for i=1:selection_diff
    button_keep_Callback(handles.button_keep,[],handles)
    drawnow limitrate nocallbacks;
    handles = guidata(handles.button_keep);
end
% switch all buttons to off after processing
handles.button_keep_highlighted.Enable = 'off';
handles.button_undo_highlighted.Enable = 'off';
handles.button_discard_highlighted.Enable = 'off';

% when last curve is reached
if selection_num == handles.num_files
    handles.button_keep.Enable = 'off';
    handles.button_discard.Enable = 'off';
    handles.button_keep_all.Enable = 'off';
    handles.button_undo.Enable = 'on';
    handles.fit_model_popup.Enable = 'off';
end
guidata(hObject,handles)

% --- Executes on button press in button_undo_highlighted.
function button_undo_highlighted_Callback(hObject, ~, handles)
% hObject    handle to button_undo_highlighted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection_num = handles.listbox1.Value;
selection_diff = handles.current_curve - selection_num;

% set save status to 1
handles.save_status = 1;
handles.save_status_led.BackgroundColor = [1 0 0];

% if pushed after reaching the last curve keep and discard buttons are
% enabled again
new_curve_index = handles.current_curve;
if new_curve_index == handles.num_files
    handles.button_keep.Enable = 'on';
    handles.button_discard.Enable = 'on';
    handles.button_keep_all.Enable = 'on';
    handles.fit_model_popup.Enable = 'off';
end
guidata(hObject,handles);

if new_curve_index == handles.num_files
   handles.current_curve = handles.current_curve+1;
   selection_diff = selection_diff+1;
end


for i=1:selection_diff
    
    % Subtract 1 from the current curve value
    curve_index = handles.current_curve-1;

    % change listbox element and save previous string                  
    it = handles.listbox1.String;
    prev_string = it{curve_index,1};
    it{curve_index,1} = sprintf('curve %3u  ->  unprocessed',curve_index);
    handles.listbox1.String = it;
    prev_string = split(prev_string,'  ->  ');
    prev_string = prev_string{2};

    % undo previous fit results
    if curve_index == 1
        switch handles.options.model
            case 'bihertz'
                if handles.options.bihertz_variant == 1
                    varTypes = {'string','uint64','double','double','double',...
                                'double','double','double','double'};
                    varNames = {'File_name','Index','initial_E_s_Pa','initial_E_h_Pa',...
                                'initial_d_h_m','fit_E_s_Pa','fit_E_h_Pa','fit_d_h_m','rsquare_fit'};
                    handles.T_result = table('Size',[handles.num_files 9],'VariableTypes',varTypes,'VariableNames',varNames);
                elseif handles.options.bihertz_variant == 2
                    varTypes =  {'string','uint64','double','double','double','double',...
                                     'double','double','double','double','double'};
                    varNames = {'File_name','Index','initial_E_s_Pa','initial_E_h_Pa',...
                                'initial_d_h_m','initial_s_p_m','fit_E_s_Pa','fit_E_h_Pa','fit_d_h_m','fit_s_p_m','rsquare_fit'};
                    handles.T_result = table('size',[handles.num_files 11],'VariableTypes',varTypes,'VariableNames',varNames);
                end
            case 'hertz'
                varTypes =  {'string','uint64','double','double'};
                varNames = {'File_name','Index','EModul','rsquare_fit'};
                handles.T_result = table('size',[handles.num_files 4],'VariableTypes',varTypes,'VariableNames',varNames);
        end
    else
        discarded = handles.progress.num_discarded;
        if curve_index ~= handles.num_files

            if strcmp(prev_string,'processed')
                T_indx = curve_index-discarded;
            else
                T_indx = size(handles.T_result,1)+1;
            end

            switch handles.options.model
                case 'bihertz'
                    if handles.options.bihertz_variant == 1
                        handles.T_result(T_indx,:) = {missing,...
                                                   uint64(0),...
                                                   0,...
                                                   0,...
                                                   0,...
                                                   0,...
                                                   0,...
                                                   0,...
                                                   0};
                    elseif handles.options.bihertz_variant == 2
                        handles.T_result(T_indx,:) = {missing,...
                                               uint64(0),...
                                               0,...
                                               0,...
                                               0,...
                                               0,...
                                               0,...
                                               0,...
                                               0,...
                                               0,...
                                               0};
                    end
                case 'hertz'
                    handles.T_result(T_indx,:) = {missing,uint64(0), 0, 0};
            end
        end
    end
    
    % Save the new current_curve value
    handles.current_curve = curve_index;
    new_curve_index = curve_index;
    guidata(hObject,handles);
    
    % update progress values
    switch prev_string
        case 'processed'
            handles.progress.num_unprocessed = handles.progress.num_unprocessed +1;
            handles.progress.num_processed = handles.progress.num_processed -1; 
        case 'discarded'
            handles.progress.num_unprocessed = handles.progress.num_unprocessed +1;
            handles.progress.num_discarded = handles.progress.num_discarded -1;
    end
    guidata(hObject,handles);
    
    % write process info
    [hObject,handles] = update_progress_info(hObject,handles);
    guidata(hObject,handles);
    
    % if a MACH-1 text file is laoded update the info panel
    if strcmp(handles.loaded_file_type,'mach-txt')
        handles = info_panel_helpf(handles);
    end
    
end

if handles.ibw == true
    % update current curve marker on map axes
    handles = update_curve_marker(handles);
elseif strcmp(handles.loadtype,'file') && handles.ibw == false && ~strcmp(handles.loaded_file_type,'mach-txt')
    % update current curve marker on map axes
    handles = update_curve_marker(handles);
end

% highlight next list item
handles.listbox1.Value = new_curve_index;
guidata(hObject,handles);


% Process new curve
[hObject,handles] = process_options(hObject,handles);
    
% Draw new curve
switch handles.options.model
    case 'bihertz'
        [handles] = plot_bihertz(handles);
        guidata(hObject,handles);
    case 'hertz'
        [hObject,handles] = plot_hertz(hObject,handles);
        guidata(hObject,handles);
end
% fit data to processed curve and display fitresult
[hObject,handles] = curve_fit_functions(hObject,handles);
guidata(hObject,handles);

% update gui fit results
[hObject,handles] = update_fit_results(hObject,handles);
guidata(hObject,handles);

% when first curve reached disable undo button and Youngs Modulus image
if new_curve_index == 1
    handles.button_undo.Enable = 'off';
    handles.fit_model_popup.Enable = 'on';
    handles.btn_histogram.Enable = 'off';
    handles.btn_gof.Enable = 'off';
    channel_find = cellfun(@(x)strcmp(x,'Youngs Modulus'),handles.channel_names);
    if any(channel_find)
        handles.channel_names = handles.channel_names(~channel_find);
        handles.image_channels_popup.Value = length(handles.channel_names);
        handles.image_channels_popup.String = handles.channel_names;
    end
    if handles.ibw == true
        channel_find_contact = cellfun(@(x)strcmp(x,'Contactpoint'),handles.channel_names);
        if any(channel_find_contact)
            handles.channel_names = handles.channel_names(~channel_find_contact);
            handles.image_channels_popup.Value = length(handles.channel_names);
            handles.image_channels_popup.String = handles.channel_names;
        end
    end
end

guidata(hObject,handles);








% --- Executes on button press in button_discard_highlighted.
function button_discard_highlighted_Callback(hObject, ~, handles)
% hObject    handle to button_discard_highlighted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection_num = handles.listbox1.Value;
selection_diff = selection_num - handles.current_curve;



for i=1:selection_diff
    % Don't write fit results
    curve_index = handles.current_curve;
    discarded = handles.progress.num_discarded;
    handles.T_result(curve_index-discarded,:) = [];
    handles.save_status = 1;
    
    % change listbox element                  
    it = handles.listbox1.String;
    it{curve_index,1} = sprintf('curve %3u  ->  discarded',curve_index);
    handles.listbox1.String = it;

    if handles.ibw == true
        % update current curve marker on map axes
        handles = update_curve_marker(handles);
    elseif strcmp(handles.loadtype,'file') && handles.ibw == false && ~strcmp(handles.loaded_file_type,'mach-txt')
        % update current curve marker on map axes
        handles = update_curve_marker(handles);
    end
    
    % add 1 to the current_curve value
    handles.current_curve = curve_index +1;
    new_curve_index = curve_index + 1;
    guidata(hObject,handles);

    if new_curve_index == handles.num_files+1

        % disable buttons during processing
        handles.button_keep.Enable = 'off';
        handles.button_discard.Enable = 'off';
        handles.button_keep_all.Enable = 'off';

        % update progress values
        handles.progress.num_unprocessed = handles.progress.num_unprocessed -1;
        handles.progress.num_discarded = handles.progress.num_discarded +1; 

        % write process info
        [hObject,handles] = update_progress_info(hObject,handles);
        guidata(hObject,handles);

        % save dialog
        answer = questdlg({'Curve processing completed!',...
            'Do you want to save the results?'},...
            'Processing completed!','Yes','No','Yes');

        if strcmp(answer,'Yes')
            if strcmp(handles.edit_savepath.String,'     savepath')
                [file,path] = uiputfile({'*.tsv;*.xlsx','Save files (*.tsv,*.xlsx)';...
                    '*.*','All Files (*.*)'},'Save results',handles.last_save_path);


                if path ~= 0
                    % save path for later revokes of uiputfile
                    handles.last_save_path = path;

                    savepath = fullfile(path,file);
                    save_table(handles.T_result,'fileFormat','tsv','savepath',savepath);
                    save_diffract = split(savepath,'.tsv');
                    savepath_cell = strcat(save_diffract(1),'.xlsx');
                    savepath = savepath_cell{1};
                    if exist(savepath,'file') == 2
                        delete(savepath)
                    end
                    save_table(handles.T_result,'fileFormat','excel','savepath',savepath);
                    handles.save_status = 1;
                    handles.save_status_led.BackgroundColor = [0 1 0];
                end
            else 
                savepath = handles.edit_savepath.String;
                save_table(handles.T_result,'fileFormat','tsv','savepath',savepath);
                save_diffract = split(savepath,'.tsv');
                savepath = strcat(save_diffract,'.xlsx');
                if exist(savepath,'file') == 2
                        delete(savepath)
                end
                save_table(handles.T_result,'fileFormat','excel','savepath',savepath);
                handles.save_status = 0;
                handles.save_status_led.BackgroundColor = [0 1 0];
            end
        end

    else

        % highlight next list item
        handles.listbox1.Value = new_curve_index;
        guidata(hObject,handles);

        % update progress values
        handles.progress.num_unprocessed = handles.progress.num_unprocessed -1;
        handles.progress.num_discarded = handles.progress.num_discarded +1;
        guidata(hObject,handles);

        % write process info
        [hObject,handles] = update_progress_info(hObject,handles);
        guidata(hObject,handles);

        % activate undo button when first time pushed
        if curve_index == 1
            handles.button_undo.Enable = 'on';
            handles.btn_histogram.Enable = 'on';
            handles.btn_gof.Enable = 'on';
        end

    end
        
    
       
end

%Process new curve
[hObject,handles] = process_options(hObject,handles);

% draw new curve
switch handles.options.model
    case 'bihertz'
        [handles] = plot_bihertz(handles);
        guidata(hObject,handles);
    case 'hertz'
        [hObject,handles] = plot_hertz(hObject,handles);
        guidata(hObject,handles);
end

if handles.ibw == true
    % update current curve marker on map axes
    handles = update_curve_marker(handles);
elseif strcmp(handles.loadtype,'file') && handles.ibw == false && ~strcmp(handles.loaded_file_type,'mach-txt')
    % update current curve marker on map axes
    handles = update_curve_marker(handles);
end

% fit data to processed curve and display fitresult
[hObject,handles] = curve_fit_functions(hObject,handles);
guidata(hObject,handles);

% update gui fit results
[hObject,handles] = update_fit_results(hObject,handles);
guidata(hObject,handles);

% if a MACH-1 text file is laoded update the info panel
if strcmp(handles.loaded_file_type,'mach-txt')
    handles = info_panel_helpf(handles);
end


% switch all buttons to off after processing
handles.button_keep_highlighted.Enable = 'off';
handles.button_undo_highlighted.Enable = 'off';
handles.button_discard_highlighted.Enable = 'off';
guidata(hObject,handles)


% --- Executes on button press in button_keep.
function button_keep_Callback(hObject, ~, handles)
% hObject    handle to button_keep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.fit_model_popup.Enable = 'off';
handles.save_status = 1;    %always keep it on 1 if there is still unsaved data

% save fit results
curve_index = handles.current_curve;
discarded = handles.progress.num_discarded;

switch handles.options.model
    case 'bihertz'
        if handles.options.bihertz_variant == 1
            handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                               uint64(curve_index),...
                               handles.fit_results.initial_E_s,...
                               handles.fit_results.initial_E_h,...
                               handles.fit_results.initial_d_h,...
                               handles.fit_results.fit_E_s,...
                               handles.fit_results.fit_E_h,...
                               handles.fit_results.fit_d_h,...
                               handles.fit_results.rsquare_fit};
        elseif handles.options.bihertz_variant == 2
            handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                               uint64(curve_index),...
                               handles.fit_results.initial_E_s,...
                               handles.fit_results.initial_E_h,...
                               handles.fit_results.initial_d_h,...
                               handles.fit_results.initial_s_p,...
                               handles.fit_results.fit_E_s,...
                               handles.fit_results.fit_E_h,...
                               handles.fit_results.fit_d_h,...
                               handles.fit_results.fit_s_p,...
                               handles.fit_results.rsquare_fit};
        end

    case 'hertz'
        handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                           uint64(curve_index),...
                           handles.fit_results.EModul,...
                           handles.fit_results.gof_rsquare};
end


% change listbox element                  
it = handles.listbox1.String;
it{curve_index,1} = sprintf('curve %3u  ->  processed',curve_index);
handles.listbox1.String = it;


% add 1 to the current_curve value
handles.current_curve = curve_index +1;
new_curve_index = curve_index + 1;
guidata(hObject,handles);

if handles.ibw == true
    % update current curve marker on map axes
    handles = update_curve_marker(handles);
elseif strcmp(handles.loadtype,'file') && handles.ibw == false && ~strcmp(handles.loaded_file_type,'mach-txt')
    % update current curve marker on map axes
    handles = update_curve_marker(handles);
end
%Check if the last force curve is reached
if new_curve_index == handles.num_files+1

        
    % disable buttons during processing
    handles.button_keep.Enable = 'off';
    handles.button_discard.Enable = 'off';
    handles.button_keep_all.Enable = 'off';
    
    % update progress values
    handles.progress.num_unprocessed = handles.progress.num_unprocessed -1;
    handles.progress.num_processed = handles.progress.num_processed +1; 
    
    % write progess info
    [hObject,handles] = update_progress_info(hObject,handles);
    guidata(hObject,handles);
    
    % save dialog
    answer = questdlg({'Curve processing completed!',...
        'Do you want to save the results?'},...
        'Processing completed!','Yes','No','Yes');

    if strcmp(answer,'Yes')
        
        if strcmp(handles.edit_savepath.String,'     savepath')
            [file,path] = uiputfile({'*.tsv;*.xlsx','Save files (*.tsv,*.xlsx)';...
                '*.*','All Files (*.*)'},'Save results',handles.last_save_path);
            
                        
            if path ~= 0
                % save path for later revokes of uiputfile
                handles.last_save_path = path;
                
                savepath = fullfile(path,file);
                save_table(handles.T_result,'fileFormat','tsv','savepath',savepath);
                save_diffract = split(savepath,'.tsv');
                savepath_cell = strcat(save_diffract(1),'.xlsx');
                savepath = savepath_cell{1};
                if exist(savepath,'file') == 2
                    delete(savepath)
                end
                save_table(handles.T_result,'fileFormat','excel','savepath',savepath);
                handles.save_status = 1;
                handles.save_status_led.BackgroundColor = [0 1 0];
            end
        else 
            savepath = handles.edit_savepath.String;
            save_table(handles.T_result,'fileFormat','tsv','savepath',savepath);
            save_diffract = split(savepath,'.tsv');
            savepath = strcat(save_diffract,'.xlsx');
            save_table(handles.T_result,'fileFormat','excel','savepath',savepath);
            handles.save_status = 1;
            handles.save_status_led.BackgroundColor = [0 1 0];
        end
    end
    
else

    % highlight next list item
    handles.listbox1.Value = new_curve_index;
    guidata(hObject,handles);
    
    %Process new curve
    [hObject,handles] = process_options(hObject,handles);
    
    % draw new curve
    switch handles.options.model
        case 'bihertz'
            [handles] = plot_bihertz(handles);
            guidata(hObject,handles);
        case 'hertz'
            [hObject,handles] = plot_hertz(hObject,handles);
            guidata(hObject,handles);
    end
    
        % fit data to processed curve and display fitresult
        [hObject,handles] = curve_fit_functions(hObject,handles);
        guidata(hObject,handles);

        % update gui fit results
        [hObject,handles] = update_fit_results(hObject,handles);
        guidata(hObject,handles);
    
    % update progress values
    handles.progress.num_unprocessed = handles.progress.num_unprocessed -1;
    handles.progress.num_processed = handles.progress.num_processed +1;
    
    % if a MACH-1 text file is laoded update the info panel
    if strcmp(handles.loaded_file_type,'mach-txt')
        handles = info_panel_helpf(handles);
    end
    
    % write process info
    [hObject,handles] = update_progress_info(hObject,handles);
    guidata(hObject,handles);
    
    % activate undo & histogram button & youngs modulus image when first time pushed
    if curve_index == 1
        handles.button_undo.Enable = 'on';
        handles.btn_histogram.Enable = 'on';
        handles.btn_gof.Enable = 'on';
    end
    if (curve_index == 1 || handles.progress.num_processed == 1)
        if handles.ibw == true
            handles.channel_names = [handles.channel_names(:,1);{'Youngs Modulus'};{'Contactpoint'}];
        else 
            handles.channel_names = [handles.channel_names(:,1);{'Youngs Modulus'}];
        end
        handles.image_channels_popup.String = handles.channel_names;
    end
    

end
guidata(hObject,handles);





% --- Executes on button press in button_discard.
function button_discard_Callback(hObject, ~, handles)
% hObject    handle to button_discard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.fit_model_popup.Enable = 'off';

% Don't write fit results
curve_index = handles.current_curve;
discarded = handles.progress.num_discarded;
handles.T_result(curve_index-discarded,:) = [];
handles.save_status = 1;
      
% change listbox element                  
it = handles.listbox1.String;
it{curve_index,1} = sprintf('curve %3u  ->  discarded',curve_index);
handles.listbox1.String = it;


% add 1 to the current_curve value
handles.current_curve = curve_index +1;
new_curve_index = curve_index + 1;
guidata(hObject,handles);

if handles.ibw == true
    % update current curve marker on map axes
    handles = update_curve_marker(handles);
elseif strcmp(handles.loadtype,'file') && handles.ibw == false && ~strcmp(handles.loaded_file_type,'mach-txt')
    % update current curve marker on map axes
    handles = update_curve_marker(handles);
end

if new_curve_index == handles.num_files+1
    
    % disable buttons during processing
    handles.button_keep.Enable = 'off';
    handles.button_discard.Enable = 'off';
    handles.button_keep_all.Enable = 'off';
    
    % update progress values
    handles.progress.num_unprocessed = handles.progress.num_unprocessed -1;
    handles.progress.num_discarded = handles.progress.num_discarded +1; 
    
    % write process info
    [hObject,handles] = update_progress_info(hObject,handles);
    guidata(hObject,handles);
    
    % save dialog
    answer = questdlg({'Curve processing completed!',...
        'Do you want to save the results?'},...
        'Processing completed!','Yes','No','Yes');
    
    if strcmp(answer,'Yes')
        if strcmp(handles.edit_savepath.String,'     savepath')
            [file,path] = uiputfile({'*.tsv;*.xlsx','Save files (*.tsv,*.xlsx)';...
                '*.*','All Files (*.*)'},'Save results',handles.last_save_path);
            
                        
            if path ~= 0
                % save path for later revokes of uiputfile
                handles.last_save_path = path;
                
                savepath = fullfile(path,file);
                save_table(handles.T_result,'fileFormat','tsv','savepath',savepath);
                save_diffract = split(savepath,'.tsv');
                savepath_cell = strcat(save_diffract(1),'.xlsx');
                savepath = savepath_cell{1};
                if exist(savepath,'file') == 2
                    delete(savepath)
                end
                save_table(handles.T_result,'fileFormat','excel','savepath',savepath);
                handles.save_status = 1;
                handles.save_status_led.BackgroundColor = [0 1 0];
            end
        else 
            savepath = handles.edit_savepath.String;
            save_table(handles.T_result,'fileFormat','tsv','savepath',savepath);
            save_diffract = split(savepath,'.tsv');
            savepath = strcat(save_diffract,'.xlsx');
            if exist(savepath,'file') == 2
                    delete(savepath)
            end
            save_table(handles.T_result,'fileFormat','excel','savepath',savepath);
            handles.save_status = 0;
            handles.save_status_led.BackgroundColor = [0 1 0];
        end
    end
    
else

    % highlight next list item
    handles.listbox1.Value = new_curve_index;
    guidata(hObject,handles);
    
    %Process new curve
    [hObject,handles] = process_options(hObject,handles);
    
    % draw new curve
    switch handles.options.model
        case 'bihertz'
            [handles] = plot_bihertz(handles);
            guidata(hObject,handles);
        case 'hertz'
            [hObject,handles] = plot_hertz(hObject,handles);
            guidata(hObject,handles);
    end

    % fit data to processed curve and display fitresult
    [hObject,handles] = curve_fit_functions(hObject,handles);
    guidata(hObject,handles);

    % update gui fit results
    [hObject,handles] = update_fit_results(hObject,handles);
    guidata(hObject,handles);
    
    % update progress values
    handles.progress.num_unprocessed = handles.progress.num_unprocessed -1;
    handles.progress.num_discarded = handles.progress.num_discarded +1;
    guidata(hObject,handles);
    
    % write process info
    [hObject,handles] = update_progress_info(hObject,handles);
    guidata(hObject,handles);
    
    % if a MACH-1 text file is laoded update the info panel
    if strcmp(handles.loaded_file_type,'mach-txt')
        handles = info_panel_helpf(handles);
    end
    
    % activate undo button when first time pushed
    if curve_index == 1
        handles.button_undo.Enable = 'on';
        handles.btn_histogram.Enable = 'on';
        handles.btn_gof.Enable = 'on';
    end
    
end
guidata(hObject,handles);


% --- Executes on button press in button_undo.
function button_undo_Callback(hObject, ~, handles)
% hObject    handle to button_undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set save status to 1
handles.save_status = 1;
handles.save_status_led.BackgroundColor = [1 0 0];

% if undo button is pushed after reaching last curve reactivate buttons and
% adjust current curve
if handles.current_curve == handles.num_files
   handles.current_curve = handles.current_curve+1;
   
   handles.button_keep.Enable = 'on';
    handles.button_discard.Enable = 'on';
    handles.button_keep_all.Enable = 'on';
    handles.fit_model_popup.Enable = 'off';
end

% Subtract 1 from the current curve value
curve_index = handles.current_curve-1;

% change listbox element and save previous string                  
it = handles.listbox1.String;
prev_string = it{curve_index,1};
it{curve_index,1} = sprintf('curve %3u  ->  unprocessed',curve_index);
handles.listbox1.String = it;
prev_string = split(prev_string,'  ->  ');
prev_string = prev_string{2};

% do the string correction again, if the selection was on the last element
% which is an unprocessed one with adjusted curve_index
if strcmp(prev_string,'unprocessed')
    curve_index = curve_index - 1;
    it = handles.listbox1.String;
    prev_string = it{curve_index,1};
    it{curve_index,1} = sprintf('curve %3u  ->  unprocessed',curve_index);
    handles.listbox1.String = it;
    prev_string = split(prev_string,'  ->  ');
    prev_string = prev_string{2};
end

% undo previous fit results
if curve_index == 1
    switch handles.options.model
        case 'bihertz'
            if handles.options.bihertz_variant == 1
                varTypes = {'string','uint64','double','double','double',...
                            'double','double','double','double'};
                varNames = {'File_name','Index','initial_E_s_Pa','initial_E_h_Pa',...
                            'initial_d_h_m','fit_E_s_Pa','fit_E_h_Pa','fit_d_h_m','rsquare_fit'};
                handles.T_result = table('Size',[handles.num_files 9],'VariableTypes',varTypes,'VariableNames',varNames);
            elseif handles.options.bihertz_variant == 2
                varTypes =  {'string','uint64','double','double','double','double',...
                                 'double','double','double','double','double'};
                varNames = {'File_name','Index','initial_E_s_Pa','initial_E_h_Pa',...
                            'initial_d_h_m','initial_s_p_m','fit_E_s_Pa','fit_E_h_Pa','fit_d_h_m','fit_s_p_m','rsquare_fit'};
                handles.T_result = table('size',[handles.num_files 11],'VariableTypes',varTypes,'VariableNames',varNames);
            end
        case 'hertz'
            varTypes =  {'string','uint64','double','double'};
            varNames = {'File_name','Index','EModul','rsquare_fit'};
            handles.T_result = table('size',[handles.num_files 4],'VariableTypes',varTypes,'VariableNames',varNames);
    end
else
    discarded = handles.progress.num_discarded;
    if curve_index ~= handles.num_files
        
        if strcmp(prev_string,'processed')
            T_indx = curve_index-discarded;
        else
            T_indx = size(handles.T_result,1)+1;
        end
        
        switch handles.options.model
            case 'bihertz'
                if handles.options.bihertz_variant == 1
                    handles.T_result(T_indx,:) = {missing,...
                                               uint64(0),...
                                               0,...
                                               0,...
                                               0,...
                                               0,...
                                               0,...
                                               0,...
                                               0};
                elseif handles.options.bihertz_variant == 2
                    handles.T_result(T_indx,:) = {missing,...
                                           uint64(0),...
                                           0,...
                                           0,...
                                           0,...
                                           0,...
                                           0,...
                                           0,...
                                           0,...
                                           0,...
                                           0};
                end
            case 'hertz'
                handles.T_result(T_indx,:) = {missing,uint64(0), 0, 0};
        end
    end
end
                


% Save the new current_curve value
handles.current_curve = curve_index;
new_curve_index = curve_index;
guidata(hObject,handles);

if handles.ibw == true
    % update current curve marker on map axes
    handles = update_curve_marker(handles);
elseif strcmp(handles.loadtype,'file') && handles.ibw == false && ~strcmp(handles.loaded_file_type,'mach-txt')
    % update current curve marker on map axes
    handles = update_curve_marker(handles);
end

% highlight next list item
handles.listbox1.Value = new_curve_index;
guidata(hObject,handles);

% Process new curve
[hObject,handles] = process_options(hObject,handles);
    
% Draw new curve
switch handles.options.model
    case 'bihertz'
        [handles] = plot_bihertz(handles);
        guidata(hObject,handles);
    case 'hertz'
        [hObject,handles] = plot_hertz(hObject,handles);
        guidata(hObject,handles);
end
% fit data to processed curve and display fitresult
[hObject,handles] = curve_fit_functions(hObject,handles);
guidata(hObject,handles);

% update gui fit results
[hObject,handles] = update_fit_results(hObject,handles);
guidata(hObject,handles);

% update progress values
switch prev_string
    case 'processed'
        handles.progress.num_unprocessed = handles.progress.num_unprocessed +1;
        handles.progress.num_processed = handles.progress.num_processed -1; 
    case 'discarded'
        handles.progress.num_unprocessed = handles.progress.num_unprocessed +1;
        handles.progress.num_discarded = handles.progress.num_discarded -1;
end
guidata(hObject,handles);

% write process info
[hObject,handles] = update_progress_info(hObject,handles);
guidata(hObject,handles);

% if a MACH-1 text file is laoded update the info panel
if strcmp(handles.loaded_file_type,'mach-txt')
    handles = info_panel_helpf(handles);
end

% when first curve reached disable undo button, Youngs Modulus and Contactpoint image
if new_curve_index == 1
    handles.button_undo.Enable = 'off';
    handles.fit_model_popup.Enable = 'on';
    handles.btn_histogram.Enable = 'off';
    handles.btn_gof.Enable = 'off';
    channel_find = cellfun(@(x)strcmp(x,'Youngs Modulus'),handles.channel_names);
    if any(channel_find)
        handles.channel_names = handles.channel_names(~channel_find);
        handles.image_channels_popup.Value = length(handles.channel_names);
        handles.image_channels_popup.String = handles.channel_names;
    end
    if handles.ibw == true
        channel_find_contact = cellfun(@(x)strcmp(x,'Contactpoint'),handles.channel_names);
        if any(channel_find)
            handles.channel_names = handles.channel_names(~channel_find_contact);
            handles.image_channels_popup.Value = length(handles.channel_names);
            handles.image_channels_popup.String = handles.channel_names;
        end
    end
end


guidata(hObject,handles);
    




% --- Executes on button press in button_keep_all.
function button_keep_all_Callback(hObject, ~, handles)
% hObject    handle to button_keep_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% disable fit model popup
handles.fit_model_popup.Enable = 'off';

% disable buttons during processing
handles.button_keep.Enable = 'off';
handles.button_discard.Enable = 'off';
handles.button_keep_all.Enable = 'off';
handles.button_undo.Enable = 'off';

% disable histogram buttons
handles.btn_histogram.Enable = 'off';
handles.btn_gof.Enable = 'off';

% Enable Youngs Modulus/Contactpoint image
if (handles.current_curve == 1 || handles.progress.num_processed == 0)
    channels = handles.image_channels_popup.String;
    if handles.ibw == true
        handles.channel_names = [channels;{'Youngs Modulus'};{'Contactpoint'}];
    else
        handles.channel_names = [channels;{'Youngs Modulus'}];
    end
    handles.image_channels_popup.String = handles.channel_names;
end

curve_index = handles.current_curve;

handles.save_status = 1; %Always keep it on 1 if there is still unsaved data

% loop iterations
loop_it = (handles.num_files - curve_index);

% initialise waitbar with cancel button
wb = waitbar(0,sprintf('curve %3u of %3u',curve_index,handles.num_files),...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)','WindowStyle','modal');
setappdata(wb,'canceling',0);

% Do the keep and apply function with or without graphical presentation
answer_display = questdlg('Do you want every graph/fit to be displayed?',...
    'Graphical Presentation','Yes','No','Yes');

% Devider for the waitbar to speed up the code performance of
% keep_all_callback

for a = 1:loop_it
    
    % check for clicked cancel button
    if getappdata(wb,'canceling')
        break
    end
    
    
    % save fit results
    curve_index = handles.current_curve;
    discarded = handles.progress.num_discarded;
    switch handles.options.model
    case 'bihertz'
        if handles.options.bihertz_variant == 1
            handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                               uint64(curve_index),...
                               handles.fit_results.initial_E_s,...
                               handles.fit_results.initial_E_h,...
                               handles.fit_results.initial_d_h,...
                               handles.fit_results.fit_E_s,...
                               handles.fit_results.fit_E_h,...
                               handles.fit_results.fit_d_h,...
                               handles.fit_results.rsquare_fit};
        elseif handles.options.bihertz_variant == 2
            handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                               uint64(curve_index),...
                               handles.fit_results.initial_E_s,...
                               handles.fit_results.initial_E_h,...
                               handles.fit_results.initial_d_h,...
                               handles.fit_results.initial_s_p,...
                               handles.fit_results.fit_E_s,...
                               handles.fit_results.fit_E_h,...
                               handles.fit_results.fit_d_h,...
                               handles.fit_results.fit_s_p,...
                               handles.fit_results.rsquare_fit};
        end

    case 'hertz'
        handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                           uint64(curve_index),...
                           handles.fit_results.EModul,...
                           handles.fit_results.gof_rsquare};
    end

    % change listbox element                  
    it = handles.listbox1.String;
    it{curve_index,1} = sprintf('curve %3u  ->  processed',curve_index);
    handles.listbox1.String = it;


    % add 1 to the current_curve value
    handles.current_curve = curve_index +1;
    new_curve_index = curve_index + 1;
    guidata(hObject,handles);
    
    if strcmp(handles.loaded_file_type,'ibw') || strcmp(handles.loaded_file_type,'jpk-force-map')
        % update current curve marker on map axes
        handles = update_curve_marker(handles);
    end

    % highlight next list item
    handles.listbox1.Value = new_curve_index;
    guidata(hObject,handles);
    
    % update waitbar and message
    waitbar(a/loop_it,wb,sprintf('curve %3u of %3u',new_curve_index,handles.num_files));


    % Process new curve
    [hObject,handles] = process_options(hObject,handles);
    
    % Only show the curve when the user want to see it
    if isempty(answer_display) || strcmp(answer_display, 'Yes')
        % draw new curve
        switch handles.options.model
            case 'bihertz'
                [handles] = plot_bihertz(handles);
                guidata(hObject,handles);
            case 'hertz'
                [hObject,handles] = plot_hertz(hObject,handles);
                guidata(hObject,handles);
        end
    end
    
    % fit data to processed curve and display fitresult
    [hObject,handles] = curve_fit_functions(hObject,handles, answer_display);
    guidata(hObject,handles);


    % update gui fit results
    [hObject,handles] = update_fit_results(hObject,handles);
    guidata(hObject,handles);

    % update progress values
    handles.progress.num_unprocessed = handles.progress.num_unprocessed -1;
    handles.progress.num_processed = handles.progress.num_processed +1; 

    % write process info
    [hObject,handles] = update_progress_info(hObject,handles);
    guidata(hObject,handles);
    
    % update the changed GUI elements
    drawnow limitrate nocallbacks
    
end
% reset user answer for displaying curves
handles.answer_display = [];

% reable buttons after processing
handles.button_keep.Enable = 'on';
handles.button_discard.Enable = 'on';
handles.button_keep_all.Enable = 'on';
handles.button_undo.Enable = 'on';
handles.btn_histogram.Enable = 'on';
handles.btn_gof.Enable = 'on';

if ~getappdata(wb,'canceling')
    
    % reable buttons after processing
    handles.button_keep.Enable = 'off';
    handles.button_discard.Enable = 'off';
    handles.button_keep_all.Enable = 'off';

    % save results of last curve
    curve_index = handles.current_curve;
    discarded = handles.progress.num_discarded;
    switch handles.options.model
    case 'bihertz'
        if handles.options.bihertz_variant == 1
            handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                               uint64(curve_index),...
                               handles.fit_results.initial_E_s,...
                               handles.fit_results.initial_E_h,...
                               handles.fit_results.initial_d_h,...
                               handles.fit_results.fit_E_s,...
                               handles.fit_results.fit_E_h,...
                               handles.fit_results.fit_d_h,...
                               handles.fit_results.rsquare_fit};
        elseif handles.options.bihertz_variant == 2
            handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                               uint64(curve_index),...
                               handles.fit_results.initial_E_s,...
                               handles.fit_results.initial_E_h,...
                               handles.fit_results.initial_d_h,...
                               handles.fit_results.initial_s_p,...
                               handles.fit_results.fit_E_s,...
                               handles.fit_results.fit_E_h,...
                               handles.fit_results.fit_d_h,...
                               handles.fit_results.fit_s_p,...
                               handles.fit_results.rsquare_fit};
        end

    case 'hertz'
        handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                           uint64(curve_index),...
                           handles.fit_results.EModul,...
                           handles.fit_results.gof_rsquare};
    end

    % change last listbox element                  
    it = handles.listbox1.String;
    it{curve_index,1} = sprintf('curve %3u  ->  processed',curve_index);
    handles.listbox1.String = it;
    
    % add one to current curve
    handles.current_curve = curve_index + 1;
    guidata(hObject,handles);
    
    % update progress values
    handles.progress.num_unprocessed = handles.progress.num_unprocessed -1;
    handles.progress.num_processed = handles.progress.num_processed +1;
    
    % if a MACH-1 text file is laoded update the info panel
    if strcmp(handles.loaded_file_type,'mach-txt') && handles.current_curve <= handles.num_files
        handles = info_panel_helpf(handles);
    end

    % write process info
    [hObject,handles] = update_progress_info(hObject,handles);
    guidata(hObject,handles);
    
    % set current curve back to index of last curve
    handles.current_curve = handles.num_files;
                               
    % save dialog
    answer = questdlg({'Curve processing completed!',...
        'Do you want to save the results?'},...
        'Processing completed!','Yes','No','Yes');

    if strcmp(answer,'Yes')
        [file,path] = uiputfile({'*.tsv;*.xlsx','Save files (*.tsv,*.xlsx)';...
                '*.*','All Files (*.*)'},'Save results',handles.last_save_path);
           
            
            if path ~= 0
                % save path for later revokes of uiputfile
                handles.last_save_path = path;
               
                savepath = fullfile(path,file);
                save_table(handles.T_result,'fileFormat','tsv','savepath',savepath);
                save_diffract = split(savepath,'.tsv');
                savepath_cell = strcat(save_diffract(1),'.xlsx');
                savepath = savepath_cell{1};
                if exist(savepath,'file') == 2
                    delete(savepath)
                end
                save_table(handles.T_result,'fileFormat','excel','savepath',savepath);
                handles.save_status = 0;
                handles.save_status_led.BackgroundColor = [0 1 0];
            end
    end
end
delete(wb)
guidata(hObject,handles)


% --------------------------------------------------------------------
function map_axes_context_Callback(~, ~, ~)
% hObject    handle to map_axes_context (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in fit_model_popup.
function fit_model_popup_Callback(hObject, ~, handles)
% hObject    handle to fit_model_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fit_model_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fit_model_popup

% switch panels
switch hObject.Value
    case 1
        handles.uipanel5.Visible = 'off';
        handles.uipanel10.Visible = 'off';
        handles.hertz_fit_panel.Visible = 'on';
        handles.map_axes.Visible = 'on';
        handles.options.model = 'hertz';
        % recreate T_results if exists
        if isfield(handles,'T_result')
            varTypes =  {'string','uint64','double','double'};
            varNames = {'File_name','Index','EModul','rsquare_fit'};
            handles.T_result = table('size',[handles.num_files 4],'VariableTypes',varTypes,'VariableNames',varNames);
        end
                
    case 2
        handles.uipanel5.Visible = 'on';
        handles.uipanel10.Visible = 'on';
        handles.hertz_fit_panel.Visible = 'off';
        handles.map_axes.Visible = 'off';
        handles.options.model = 'bihertz';
        handles.options.bihertz_variant = 1;
        handles = grid_creation_function(handles);
        % recreate T_results if exists
        if isfield(handles,'T_result')
            varTypes =  {'string','uint64','double','double','double',...
                                 'double','double','double','double'};
            varNames = {'File_name','Index','initial_E_s_Pa','initial_E_h_Pa',...
                        'initial_d_h_m','fit_E_s_Pa','fit_E_h_Pa','fit_d_h_m','rsquare_fit'};
            handles.T_result = table('size',[handles.num_files 9],'VariableTypes',varTypes,'VariableNames',varNames);
        end
        
    case 3
        handles.uipanel5.Visible = 'on';
        handles.uipanel10.Visible = 'on';
        handles.hertz_fit_panel.Visible = 'off';
        handles.map_axes.Visible = 'off';
        handles.options.model = 'bihertz';
        handles.options.bihertz_variant = 2;
        handles = grid_creation_function(handles);
        % recreate T_results if exists
        if isfield(handles,'T_result')
            varTypes =  {'string','uint64','double','double','double','double',...
                                 'double','double','double','double','double'};
            varNames = {'File_name','Index','initial_E_s_Pa','initial_E_h_Pa',...
                        'initial_d_h_m','initial_s_p_m','fit_E_s_Pa','fit_E_h_Pa','fit_d_h_m','fit_s_p_m','rsquare_fit'};
            handles.T_result = table('size',[handles.num_files 11],'VariableTypes',varTypes,'VariableNames',varNames);
        end
        
end

try delete(handles.figures.patch_handle); catch;  end
try delete(handles.figures.baseline); catch; end
try delete(handles.figures.baselineedges); catch; end
try delete(handles.figures.baselineedges_2); catch; end
try delete(handles.figures.fittedcurve); catch; end
try delete(handles.figures.contactpoint_line); catch; end

try  % draw new curve
    switch handles.options.model
        case 'bihertz'
            [handles] = plot_bihertz(handles);
            guidata(hObject,handles);
        case 'hertz'
            [hObject,handles] = plot_hertz(hObject,handles);
            guidata(hObject,handles);
    end

    % fit data to processed curve and display fitresult
    [hObject,handles] = curve_fit_functions(hObject,handles);
    guidata(hObject,handles);

    % update gui fit results
    [hObject,handles] = update_fit_results(hObject,handles);
catch
   % if no curve is loaded don't do anything 
end
guidata(hObject,handles);



% --- Executes during object creation, after setting all properties.
function fit_model_popup_CreateFcn(hObject, ~, ~)
% hObject    handle to fit_model_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function exit_Callback(~, ~, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = 'Yes';
if handles.save_status == 0
    answer = questdlg({'There are unsaved results.','Do you really want to exit the window?'},...
        'Exit request','Yes','No','No');
end

if strcmp(answer,'Yes')
        % Delete created folder and .zip of the ReadJPKMaps function
    if isfield(handles, 'loadtype') == 1
        if strcmp(handles.loadtype,'file')
            [filepath, name, ~] = fileparts(handles.edit_filepath.String);
            zipname = strcat(filepath, '\', name, '.zip');
            unzipfolder = strcat(filepath, '\', 'Forcemap');
            if exist(zipname, 'file') == 2
                delete (zipname)
            end
            if exist(unzipfolder, 'dir') == 7
                rmdir(unzipfolder, 's')
            end
        end
    end

    try
        delete(handles.figures.main_fig);
    catch 
        % nix
    end
    warning on
    delete(handles.figure1);
    delete(allchild(groot));
    run('Auswertetool_exe.m');
end

% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(~, ~, ~)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_folder.
function button_folder_Callback(hObject, ~, handles)
% hObject    handle to button_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[path] = uigetdir(handles.last_load_path,'Select folder with curve-files');


if ~isequal(path,0)
    % remember last path for the next invoke of uigetdir or uigetfile
    parts = strsplit(path,filesep);
    path_short = fullfile(parts{1:end-1});
    handles.last_load_path = path_short;
    
    handles.edit_filepath.String = path;
    handles.edit_filepath.Enable = 'on';
    handles.edit_filepath.HorizontalAlignment = 'right';
    handles.edit_filepath.Tooltip = path;
    handles.loadtype = 'folder';
    guidata(hObject,handles)
end

% --- Close function for main_plot window.
function main_plot_CloseRequest(~,~,~)
   warndlg({'You are not allowed to close the main plot window this way!';...
       'The main plot window will be closed together with the processing window!'})


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(~, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
exit_Callback(handles.exit,eventdata,handles);


% --- Executes on key press with focus on fit_depth and none of its controls.
function fit_depth_KeyPressFcn(~, ~, ~)
% hObject    handle to fit_depth (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on button_keep and none of its controls.
function button_keep_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to button_keep (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
button_keep_Callback(hObject, eventdata, handles);



function hertz_fit_depth_Callback(hObject, ~, handles)
% hObject    handle to hertz_fit_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fit_d_string = hObject.String;
fit_d_string = strrep(fit_d_string,',','.');
hObject.String = fit_d_string;

fit_d_num_check = str2double(fit_d_string);

if ~isnan(fit_d_num_check)
    try
        [hObject,handles] = curve_fit_functions(hObject,handles);
        [hObject,handles] = update_patches_hertzfit(hObject,handles);
        [hObject,handles] = update_fit_results(hObject,handles);
        guidata(hObject,handles);
    catch %ME
        % if you can    
    end
else
    hObject.String = '1.0';
end

function hertz_fit_depth_DeleteFcn(~, ~, ~)
% hObject    handle to hertz_fit_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% Hints: get(hObject,'String') returns contents of hertz_fit_depth as text
%        str2double(get(hObject,'String')) returns contents of hertz_fit_depth as a double


% --- Executes during object creation, after setting all properties.
function hertz_fit_depth_CreateFcn(hObject, ~, ~)
% hObject    handle to hertz_fit_depth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in baseline_btngroup.
function baseline_btngroup_SelectionChangedFcn(hObject, ~, handles)
% hObject    handle to the selected object in baseline_btngroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SelectedMode = handles.baseline_btngroup.SelectedObject.String;
if strcmp(SelectedMode, 'none')
    handles.options.bihertz_baseline = 'none';
elseif strcmp(SelectedMode, 'Offset')
    handles.options.bihertz_baseline = 'offset';
else
    handles.options.bihertz_baseline = 'offset_and_tilt';
end

if isfield(handles, 'curves')
    
    %Update the graph with the new fit options
    [hObject,handles] = process_options(hObject,handles);
    %Plot the data as Bihertz or as Hertz
    switch handles.options.model
        case 'bihertz'
            [handles] = plot_bihertz(handles);
            guidata(hObject,handles);
        case 'hertz'
            [hObject,handles] = plot_hertz(hObject,handles);
            guidata(hObject,handles);
    end
    
    if strcmp(SelectedMode, 'none')
        curve_str = sprintf('curve%u',handles.current_curve);
        handles.proc_curves.(curve_str) = handles.curves.(curve_str);
    end
    
    % fit data to processed curve and display fitresult
    [hObject,handles] = curve_fit_functions(hObject,handles);
    guidata(hObject,handles);

    % update gui fit results
    [hObject,handles] = update_fit_results(hObject,handles);
        
else
    %Nothing
end
guidata(hObject,handles)
    


% --- Executes during object creation, after setting all properties.
function baseline_btngroup_CreateFcn(~, ~, handles)
% hObject    handle to baseline_btngroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.baseline_btngroup.SelectedObject.Tag = 'offset_and_tilt';



function save_status_led_Callback(~, ~, ~)
% hObject    handle to save_status_led (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_status_led as text
%        str2double(get(hObject,'String')) returns contents of save_status_led as a double


% --- Executes during object creation, after setting all properties.
function save_status_led_CreateFcn(hObject, ~, ~)
% hObject    handle to save_status_led (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, ~, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% make save status led square
window_width = handles.figure1.Position(3);
led_width = (window_width*handles.def_led_width)/handles.def_wind_width;
handles.save_status_led.Position(3) = led_width;
handles.save_status_led.Position(4) = led_width;    % square led shape

% correct led x-y-Position
window_height = handles.figure1.Position(4);
x_led = (window_width*handles.def_led_x)/handles.def_wind_width;
y_led = (window_height*handles.def_led_y)/handles.def_wind_height;
handles.save_status_led.Position(1) = x_led;
handles.save_status_led.Position(2) = y_led;

% change info panel column width
handles.info_table.Units = 'pixel';
table_width = handles.info_table.Position(3);
handles.info_table.ColumnWidth = {table_width/2-1,table_width/2-1};
handles.info_table.Units = 'normalized';


guidata(hObject,handles);




% --- Executes on selection change in image_channels_popup.
function image_channels_popup_Callback(hObject, ~, handles)
% hObject    handle to image_channels_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns image_channels_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from image_channels_popup
[hObject,handles] = checker_helpf(hObject,handles);
if (handles.ibw == true)
    channel_interpolation = handles.interpolation_type;
    channel_string = hObject.String(hObject.Value);
    if strcmp(channel_string,'height')
        axes(handles.map_axes);
        if strcmp (channel_interpolation, 'linear')
            imshow(handles.MFP_height_matrix_linear_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        elseif strcmp (channel_interpolation, 'bicubic')
            imshow(handles.MFP_height_matrix_cubic_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        else
            imshow(handles.MFP_height_matrix, 'InitialMagnification', 'fit', 'XData', [1 handles.MFP_fmap_num_points], 'YData', [1 handles.MFP_fmap_num_line], 'DisplayRange', []);
        end
        set_afm_gold();
        handles = colorbar_helpf(handles.map_axes,handles);
        hline = findall(gca,'Type','image');
        set(hline(1),'uicontextmenu',handles.map_axes_context);
        
    elseif strcmp(channel_string, 'slope')
        axes(handles.map_axes);
        if strcmp (channel_interpolation, 'linear')
            imshow(handles.MFP_mslope_matrix_linear_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        elseif strcmp(channel_interpolation, 'bicubic')
            imshow(handles.MFP_mslope_matrix_cubic_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        else
            imshow(handles.MFP_mslope_matrix, 'InitialMagnification', 'fit', 'XData', [1 handles.MFP_fmap_num_points], 'YData', [1 handles.MFP_fmap_num_line], 'DisplayRange', []);
        end
        set_afm_gold();
        handles = colorbar_helpf(handles.map_axes,handles);
        hline = findall(gca,'Type','image');
        set(hline(1),'uicontextmenu',handles.map_axes_context);
        
    elseif strcmp(channel_string, 'Youngs Modulus')
        
        current_curve = handles.current_curve;
        curve_index = 1;    %only processed curves are saved in the handles.T_result table
        handles.MFP_Ymodulus_matrix = zeros(handles.MFP_fmap_num_line,handles.MFP_fmap_num_points);
        
        for i=1:current_curve
            if i == 1
                pt_count = 1;
                line_count = handles.MFP_fmap_num_line;
            end
            if handles.T_result{curve_index,2} == i 
                handles.MFP_Ymodulus_matrix(line_count,pt_count)= handles.T_result{curve_index,3};
                curve_index = curve_index+1;
            else
                handles.MFP_Ymodulus_matrix(line_count,pt_count) = pi; % A way to fill in empty spaces
            end
            if pt_count == handles.MFP_fmap_num_points
                pt_count = 0;
                line_count = line_count - 1;
            end
            pt_count = pt_count +1;
        end
        Ymodulus_matrix = handles.MFP_Ymodulus_matrix;
        Ymodulus_matrix(Ymodulus_matrix == 0 | Ymodulus_matrix == pi) = [];
        handles.MFP_Ymodulus_matrix(handles.MFP_Ymodulus_matrix == 0 | handles.MFP_Ymodulus_matrix == pi) = min(min(Ymodulus_matrix));
        handles.colorgrad_Ymodulus = flipud(linspace(min(min(handles.MFP_Ymodulus_matrix)), max(max(handles.MFP_Ymodulus_matrix)), 100))';
        
        % Get interpolation maps
        [handles.MFP_Ymodulus_matrix_linear_interpolation, handles.MFP_Ymodulus_matrix_cubic_interpolation] = ImageInterpolationMFP(handles.MFP_fmap_num_points,handles.MFP_fmap_num_line,handles.MFP_Ymodulus_matrix);
        
        %Display the Youngs Modulus matrix
        axes(handles.map_axes);
        if strcmp (channel_interpolation, 'linear')
            imshow(handles.MFP_Ymodulus_matrix_linear_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        elseif strcmp(channel_interpolation, 'bicubic')
            imshow(handles.MFP_Ymodulus_matrix_cubic_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        else
            imshow(handles.MFP_Ymodulus_matrix, 'InitialMagnification', 'fit', 'XData', [1 handles.MFP_fmap_num_points], 'YData', [1 handles.MFP_fmap_num_line], 'DisplayRange', []);
        end
        set_afm_gold();
        handles = colorbar_helpf(handles.map_axes,handles);
        hline = findall(gca,'Type','image');
        set(hline(1),'uicontextmenu',handles.map_axes_context);
        
    elseif strcmp(channel_string, 'Contactpoint')
        
        for i=1:handles.current_curve
            string = strcat('curve', num2str(i));
            cpoint(i) = handles.proc_curves.(string).cpoint;
        end
        
        cpoint_matrix = zeros(handles.MFP_fmap_num_line, handles.MFP_fmap_num_points);
        for i=1:handles.MFP_fmap_num_line
            for j=1:handles.MFP_fmap_num_points
                if (i-1)*handles.MFP_fmap_num_points+j >= size(cpoint, 2)
                    cpoint_matrix(i,j) = 0;
                else
                    cpoint_matrix(i,j) = cpoint((i-1)*handles.MFP_fmap_num_points+j);
                end
            end
        end
        
        cpoint_matrix(cpoint_matrix == 0) = min(cpoint);
        cpoint_matrix = flip(cpoint_matrix);
        handles.MFP_cpoint_matrix = cpoint_matrix;
        
        % Get interpolation maps
        [handles.MFP_cpoint_matrix_linear_interpolation, handles.MFP_cpoint_matrix_cubic_interpolation] = ImageInterpolationMFP(handles.MFP_fmap_num_points,handles.MFP_fmap_num_line,handles.MFP_cpoint_matrix);
        
        axes(handles.map_axes);
        if strcmp (channel_interpolation, 'linear')
            imshow(handles.MFP_cpoint_matrix_linear_interpolation, 'InitialMagnification', 'fit', 'XData', [1 handles.MFP_fmap_num_points], 'YData', [1 handles.MFP_fmap_num_line], 'DisplayRange', []);
        elseif strcmp(channel_interpolation, 'bicubic')
            imshow(handles.MFP_cpoint_matrix_cubic_interpolation, 'InitialMagnification', 'fit', 'XData', [1 handles.MFP_fmap_num_points], 'YData', [1 handles.MFP_fmap_num_line], 'DisplayRange', []);
        else
            imshow(cpoint_matrix, 'InitialMagnification', 'fit', 'XData', [1 handles.MFP_fmap_num_points], 'YData', [1 handles.MFP_fmap_num_line], 'DisplayRange', []);
        end
        set_afm_gold();
        handles = colorbar_helpf(handles.map_axes,handles);
        hline = findall(gca,'Type','image');
        set(hline(1),'uicontextmenu',handles.map_axes_context);

    end
else
    channel_num = hObject.Value;
    channel_string = handles.channel_names{channel_num};
    channel_interpolation = handles.interpolation_type;
    if ~strcmp(channel_interpolation,'none')
        interpolation_string = sprintf('_%s_interpolation',channel_interpolation);
    else
        interpolation_string = '';
    end
    if strcmp(channel_string,'height')
        channel_image = handles.map_images.height.(sprintf('absolute_%s_data%s',...
        channel_string,interpolation_string));
    elseif isfield(handles.map_images,channel_string)  
        channel_image = handles.map_images.(channel_string).(sprintf('%s_data%s',...
        channel_string,interpolation_string));
    end
    if isfield(handles.map_images,channel_string)
        axes(handles.map_axes);
        imshow(flip(channel_image,1),[],'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel]);
        handles.map_axes.YDir = 'normal';
        handles = update_curve_marker(handles);
        hline = findall(gca,'Type','image');
        set(hline(1),'uicontextmenu',handles.map_axes_context);
        set_afm_gold;
        handles = colorbar_helpf(handles.map_axes,handles);
    end
    if strcmp(channel_string, 'Youngs Modulus')
        EModul_matrix = zeros(handles.map_info.y_pixel, handles.map_info.x_pixel);
        for i=1:handles.map_info.y_pixel
            for j=1:handles.map_info.x_pixel
                if (i-1)*handles.map_info.x_pixel+j > length(handles.T_result.EModul)
                    EModul_matrix(i,j) = 0;
                else
                    EModul_matrix(i,j) = handles.T_result.EModul((i-1)*handles.map_info.x_pixel+j);
                end
            end
        end
        
        EModul_matrix(EModul_matrix == 0) = min(handles.T_result.EModul);
        EModul_matrix = flip(EModul_matrix);
        handles.EModul_matrix = EModul_matrix;
        
        % Get interpolation maps
        [handles.EModul_matrix_linear_interpolation, handles.EModul_matrix_cubic_interpolation] = ImageInterpolationMFP(handles.map_info.x_pixel,handles.map_info.y_pixel,handles.EModul_matrix);
        
        axes(handles.map_axes);
        if strcmp (channel_interpolation, 'linear')
            imshow(handles.EModul_matrix_linear_interpolation, 'InitialMagnification', 'fit', 'XData', [1 handles.map_info.x_pixel], 'YData', [1 handles.map_info.y_pixel], 'DisplayRange', []);
        elseif strcmp(channel_interpolation, 'bicubic')
            imshow(handles.EModul_matrix_cubic_interpolation, 'InitialMagnification', 'fit', 'XData', [1 handles.map_info.x_pixel], 'YData', [1 handles.map_info.y_pixel], 'DisplayRange', []);
        else
            imshow(handles.EModul_matrix, 'InitialMagnification', 'fit', 'XData', [1 handles.map_info.x_pixel], 'YData', [1 handles.map_info.y_pixel], 'DisplayRange', []);
        end
        set_afm_gold();
        handles = colorbar_helpf(handles.map_axes,handles);
        hline = findall(gca,'Type','image');
        set(hline(1),'uicontextmenu',handles.map_axes_context);
    end
    
end

% update current curve marker on map axes
handles = update_curve_marker(handles);

guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function image_channels_popup_CreateFcn(hObject, ~, ~)
% hObject    handle to image_channels_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function interpolation_type_Callback(~, ~, ~)
% hObject    handle to interpolation_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function none_Callback(hObject, ~, handles)
% hObject    handle to none (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles] = checker_helpf(hObject,handles);
handles.interpolation_type = 'none';
channel_num = handles.image_channels_popup.Value;
channel_string = handles.channel_names{channel_num};
channel_interpolation = handles.interpolation_type;
if handles.ibw == false
    if ~strcmp(channel_interpolation,'none')
        interpolation_string = sprintf('_%s_interpolation',channel_interpolation);
    else
        interpolation_string = '';
    end

    if strcmp(channel_string,'height')
        channel_image = handles.map_images.height.(sprintf('absolute_%s_data%s',...
        channel_string,interpolation_string));
    else
        channel_image = handles.map_images.(channel_string).(sprintf('%s_data%s',...
            channel_string,interpolation_string));
    end

    axes(handles.map_axes);
    imshow(flip(channel_image,1),[],'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel]);
    handles.map_axes.YDir = 'normal';
else
    if strcmp(channel_string,'height')
        axes(handles.map_axes);
        imshow(handles.MFP_height_matrix,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        
    elseif strcmp(channel_string, 'slope')
        axes(handles.map_axes);
        imshow(handles.MFP_mslope_matrix,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        
    elseif strcmp(channel_string, 'Contactpoint')
        axes(handles.map_axes);
        imshow(handles.MFP_cpoint_matrix,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        
    elseif strcmp(channel_string, 'Youngs Modulus')
        axes(handles.map_axes);
        imshow(handles.MFP_Ymodulus_matrix,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
    end
end
    
handles = update_curve_marker(handles);
hline = findall(gca,'Type','image');
set(hline(1),'uicontextmenu',handles.map_axes_context);
set_afm_gold;
handles = colorbar_helpf(handles.map_axes,handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function linear_Callback(hObject, ~, handles)
% hObject    handle to linear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles] = checker_helpf(hObject,handles);
handles.interpolation_type = 'linear';
channel_num = handles.image_channels_popup.Value;
channel_string = handles.channel_names{channel_num};
channel_interpolation = handles.interpolation_type;
if handles.ibw == false
    if ~strcmp(channel_interpolation,'none')
        interpolation_string = sprintf('_%s_interpolation',channel_interpolation);
    else
        interpolation_string = '';
    end
    if strcmp(channel_string,'height')
        channel_image = handles.map_images.height.(sprintf('absolute_%s_data%s',...
        channel_string,interpolation_string));
    else
        channel_image = handles.map_images.(channel_string).(sprintf('%s_data%s',...
            channel_string,interpolation_string));
    end
    axes(handles.map_axes);
    imshow(flip(channel_image,1),[],'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel]);
    handles.map_axes.YDir = 'normal';
    
else
    if strcmp(channel_string,'height')
        axes(handles.map_axes);
        imshow(handles.MFP_height_matrix_linear_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        
    elseif strcmp(channel_string, 'slope')
        axes(handles.map_axes);
        imshow(handles.MFP_mslope_matrix_linear_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        
    elseif strcmp(channel_string, 'Contactpoint')
        axes(handles.map_axes);
        imshow(handles.MFP_cpoint_matrix_linear_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        
    else strcmp(channel_string, 'Youngs Modulus')
        axes(handles.map_axes);
        imshow(handles.MFP_Ymodulus_matrix_linear_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
    end
end
handles = update_curve_marker(handles);
hline = findall(gca,'Type','image');
set(hline(1),'uicontextmenu',handles.map_axes_context);
set_afm_gold;
handles = colorbar_helpf(handles.map_axes,handles);
guidata(hObject,handles);


% --------------------------------------------------------------------
function bicubic_Callback(hObject, ~, handles)
% hObject    handle to bicubic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hObject,handles] = checker_helpf(hObject,handles);
handles.interpolation_type = 'bicubic';
channel_num = handles.image_channels_popup.Value;
channel_string = handles.channel_names{channel_num};
channel_interpolation = handles.interpolation_type;
if handles.ibw == false
    if ~strcmp(channel_interpolation,'none')
        interpolation_string = sprintf('_%s_interpolation',channel_interpolation);
    else
        interpolation_string = '';
    end
    if strcmp(channel_string,'height')
        channel_image = handles.map_images.height.(sprintf('absolute_%s_data%s',...
        channel_string,interpolation_string));
    else
        channel_image = handles.map_images.(channel_string).(sprintf('%s_data%s',...
            channel_string,interpolation_string));
    end
    axes(handles.map_axes);
    imshow(flip(channel_image,1),[],'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel]);
    handles.map_axes.YDir = 'normal';
else
    if strcmp(channel_string,'height')
        axes(handles.map_axes);
        imshow(handles.MFP_height_matrix_cubic_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        
    elseif strcmp(channel_string, 'slope')
        axes(handles.map_axes);
        imshow(handles.MFP_mslope_matrix_cubic_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        
    elseif strcmp(channel_string, 'Contactpoint')
        axes(handles.map_axes);
        imshow(handles.MFP_cpoint_matrix_cubic_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
        
    else strcmp(channel_string, 'Youngs Modulus')
        axes(handles.map_axes);
        imshow(handles.MFP_Ymodulus_matrix_cubic_interpolation,'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel], 'DisplayRange', []);
    end
end
handles = update_curve_marker(handles);
hline = findall(gca,'Type','image');
set(hline(1),'uicontextmenu',handles.map_axes_context);
set_afm_gold;
handles = colorbar_helpf(handles.map_axes,handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function map_axes_CreateFcn(~, ~, ~)
% hObject    handle to map_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate map_axes






% ---- checker_helper function ------
function [hObject,handles] = checker_helpf(hObject,handles)
    button_tag = hObject.Tag;
    switch button_tag
        case 'none'
            handles.none.Checked = 'on';
            handles.linear.Checked  = 'off';
            handles.bicubic.Checked = 'off';
        case 'linear'
            handles.none.Checked = 'off';
            handles.linear.Checked  = 'on';
            handles.bicubic.Checked = 'off';
        case 'bicubic'
            handles.none.Checked = 'off';
            handles.linear.Checked  = 'off';
            handles.bicubic.Checked = 'on';
    end
guidata(hObject,handles);
    
    
% -------- bihertz_channel_helpf -----------


% --- Executes when selected object is changed in btngroup_contact.
function btngroup_contact_SelectionChangedFcn(hObject, ~, handles)
% hObject    handle to the selected object in btngroup_contact 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Curve is redrawn with a different Contactpoint finding model. This is
%checked in the contact point function during the process_options

sel_obj = handles.btngroup_contact.SelectedObject;


if strcmp(sel_obj.String,'via Hertz fit')
    set(handles.contact_percentage_hertz,'Enable','on');
else
    set(handles.contact_percentage_hertz,'Enable','off');
end

if handles.load_status ~=0
    %Process curve
    [hObject,handles] = process_options(hObject,handles);

    % draw new curve
    switch handles.options.model
        case 'bihertz'
            [handles] = plot_bihertz(handles);
            guidata(hObject,handles);
        case 'hertz'
            [hObject,handles] = plot_hertz(hObject,handles);
            guidata(hObject,handles);
    end
    
    % fit data to processed curve and display fitresult
    [hObject,handles] = curve_fit_functions(hObject,handles);
    guidata(hObject,handles);

    % update gui fit results
    [hObject,handles] = update_fit_results(hObject,handles);
end

guidata(hObject,handles);
    
    



% --- Executes on button press in btn_histogram.
function btn_histogram_Callback(hObject, ~, handles)
% hObject    handle to btn_histogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    close(handles.EModulFig)
    handles = rmfield(handles, 'EModulFig');
catch
end
if isempty(findobj('Name', 'Histogram: Goodness of Fit'))
    try
        handles = rmfield(handles, 'GoFFig');
    catch
    end
end
EModul = handles.T_result.EModul;
if any(EModul)
    handles.EModulFig = figure('Name','Histogram: Youngs Modulus','Units', 'normalized', 'NumberTitle','off', 'Color', 'white');
    EModul(EModul == 0)=[];
    EModul(isnan(EModul)) = [];
    EModul = EModul/1000;
    [~,~] = histogram_fits(EModul, 'gauss', 100);
%     h.Histogram_handle.FaceColor = [1 0.72 0.73];     -> The face color is now set directly in the histogram_fits function when the histogram is created.
%     h.Histogram_handle.EdgeColor = [0.77 0.32 0.34];  -> The Edge color is now set directly in the histogram_fits function when the histogram is created.
    title('Youngs Modulus');
    xlabel('Youngs Modulus [kPa]');
    ylabel('Frequency');

    %Present both histograms in a good way if both are opened
    if isfield(handles, 'GoFFig') == 1
        handles.EModulFig.Position = [0.1 0.3 0.4 0.5];
        handles.GoFFig.Position = [0.5 0.3 0.4 0.5];
        figure(handles.EModulFig);
        figure(handles.GoFFig);
    else
        handles.EModulFig.Position = [0.1 0.3 0.4 0.5];
        figure(handles.EModulFig);
    end
else
    warning('No results are available at the moment!')
end

guidata(hObject,handles);


% --- Executes on button press in btn_gof.
function btn_gof_Callback(hObject, ~, handles)
% hObject    handle to btn_gof (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    close(handles.GoFFig)
    handles = rmfield(handles, 'GoFFig');
catch
end
if isempty(findobj('Name', 'Histogram: Youngs Modulus'))
    try
        handles = rmfield(handles, 'EModulFig');
    catch
    end
end
rsquare = handles.T_result.rsquare_fit;
if any(rsquare)
    handles.GoFFig = figure('Name','Histogram: Goodness of Fit','Units', 'normalized', 'NumberTitle','off', 'Color', 'white');
    rsquare(rsquare <= 0)=[];
    rsquare(isnan(rsquare)) = [];
    [h] = histogram_fits(rsquare, 'none', 50);
    h.Histogram_handle.FaceColor = [1 0.72 0.73];
    h.Histogram_handle.EdgeColor = [0.77 0.32 0.34];
    xlim([0 1])
    xticks([0 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1])
    xticklabels({0, [], 0.1, [], 0.2, [], 0.3, [], 0.4, [], 0.5, [], 0.6, [], 0.7, [], 0.8, [], 0.9, [], 1})
    title('Goodness of Fit')
    xlabel('Goodness of Fit[rsquare]')
    ylabel('Frequency')

    %Present both histograms in a good way if both are opened
    if isfield(handles, 'EModulFig') == 1
        handles.EModulFig.Position = [0.1 0.3 0.4 0.5];
        handles.GoFFig.Position = [0.5 0.3 0.4 0.5];
        figure(handles.EModulFig);
        figure(handles.GoFFig);
    else
        handles.GoFFig.Position = [0.1 0.3 0.4 0.5];
        figure(handles.GoFFig);
    end
else
    warning('No results are available at the moment!')
end
guidata(hObject,handles);



function contact_percentage_hertz_Callback(hObject, ~, handles)
% hObject    handle to contact_percentage_hertz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contact_percentage_hertz as text
%        str2double(get(hObject,'String')) returns contents of contact_percentage_hertz as a double

perc_str = get(hObject,'String');
perc_str = strrep(perc_str,',','.');
perc = str2double(perc_str);

if isnan(perc)
   set(hObject,'String','20');
else
    set(hObject,'String',sprintf('%g',perc));
end

btngroup_contact_SelectionChangedFcn(handles.btngroup_contact,[], handles);






% --- Executes during object creation, after setting all properties.
function contact_percentage_hertz_CreateFcn(hObject, ~, ~)
% hObject    handle to contact_percentage_hertz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function uipanel10_CreateFcn(~, ~, ~)
% hObject    handle to uipanel10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function result_switch_point_Callback(~, ~, ~)
% hObject    handle to result_switch_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of result_switch_point as text
%        str2double(get(hObject,'String')) returns contents of result_switch_point as a double


% --- Executes during object creation, after setting all properties.
function result_switch_point_CreateFcn(hObject, ~, ~)
% hObject    handle to result_switch_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Colorbar helper function to display the colorbar properly.
function handles = colorbar_helpf(ax_handle,handles)
    axes(ax_handle);
    cbar = colorbar(ax_handle);
    cbar.Ruler.Exponent = 0;
    image_handle = findobj(ax_handle,'Type','image');
    if isempty(image_handle)
        warning('No image object was found in the given axes object');
        return;
    end
    map_type = handles.loaded_file_type;
    channels = handles.image_channels_popup.String;
    channel_indx = handles.image_channels_popup.Value;
    channel = channels{channel_indx};
    
    if strcmp(map_type,'jpk-force-map') || strcmp(map_type,'ibw')
        % the following is the colorbar correction for jpk-force-maps
        switch channel
            case 'height' 
                % find min and max of CData
                c_min = min(min(image_handle.CData));
                c_max = max(max(image_handle.CData));
                % determine if the maximum dimension is nm or µm and
                % correct the tick lables of the colorbar
                check = abs(c_max) < 1e-6 && abs(c_min) < 1e-6;
                labels = cbar.Ticks;
                if check
                    labels = strcat(string(labels*1e9), ' nm');
                    max_label = sprintf('max: %.f nm',c_max*1e9);
                    min_label = sprintf('min: %.f nm',c_min*1e9);                           
                else
                    labels = strcat(string(labels*1e6), ' µm');
                    max_label = sprintf('max: %.2f µm',c_max*1e6);
                    min_label = sprintf('min: %.2f µm',c_min*1e6);  
                end
                cbar.TickLabels = labels;
                % provide min and max information of shown data
                title(ax_handle,{'Full data range:';max_label;min_label},'FontSize',9);
            case 'slope'
                % find min and max of CData
                c_min = min(min(image_handle.CData));
                c_max = max(max(image_handle.CData));
                % determine if the maximum dimension is nm or µm and
                % correct the tick lables of the colorbar
                check = abs(c_max) < 1e6 && abs(c_min) < 1e6;
                labels = cbar.TickLabels;
                for i = 1:length(labels)
                   label_char = labels{i};
                   label_num = str2double(label_char);
                   if isnan(label_num)
                       split_cell = strsplit(label_char,'\\times10^{');
                       new_string = sprintf('%se%s',split_cell{1},split_cell{2}(1:end-1));
                       label_num = str2double(new_string);
                   end
                   if check
                       label_num = label_num*1e-3;
                       labels(i) = {sprintf('%3.0f mV/µm',label_num)};
                       max_label = sprintf('max: %.2g mV/µm',c_max*1e-3);
                       min_label = sprintf('min: %.2g mV/µm',c_min*1e-3);
                   else
                       label_num = label_num*1e-6;
                       labels(i) = {sprintf('%.1f V/µm',label_num)};
                       max_label = sprintf('max: %.2g V/µm',c_max*1e-6);
                       min_label = sprintf('min: %.2g V/µm',c_min*1e-6);
                   end
                end
                cbar.TickLabels = labels;
                % provide min and max information of shown data
                title(ax_handle,{'Full data range:';max_label;min_label},'FontSize',9);
            case 'adhesion'
                % find min and max of CData
                c_min = min(min(image_handle.CData));
                c_max = max(max(image_handle.CData));
                % determine if the maximum dimension is nm or µm and
                % correct the tick lables of the colorbar
                check = abs(c_max) < 1 && abs(c_min) < 1;
                labels = cbar.TickLabels;
                for i = 1:length(labels)
                   lable_char = labels{i};
                   label_num = str2double(lable_char);
                   if check
                       label_num = label_num*1e3;
                       labels(i) = {sprintf('%3.0f mV',label_num)};
                       max_label = sprintf('max: %.2g mV',c_max*1e3);
                       min_label = sprintf('min: %.2g mV',c_min*1e3);
                   else
                       labels(i) = {sprintf('%1.1f V',label_num)};
                       max_label = sprintf('max: %.2g V',c_max);
                       min_label = sprintf('min: %.2g V',c_min);
                   end
                end
                cbar.TickLabels = labels;
                % provide min and max information of shown data
                title(ax_handle,{'Full data range:';max_label;min_label},'FontSize',9);
            case 'vDeflection'
                % find min and max of CData
                c_min = min(min(image_handle.CData));
                c_max = max(max(image_handle.CData));
                % determine if the maximum dimension is nm or µm and
                % correct the tick lables of the colorbar
                check = abs(c_max) < 1 && abs(c_min) < 1;
                labels = cbar.TickLabels;
                for i = 1:length(labels)
                   lable_char = labels{i};
                   label_num = str2double(lable_char);
                   if check
                       label_num = label_num*1e3;
                       labels(i) = {sprintf('%3.0f mV',label_num)};
                       max_label = sprintf('max: %.2g mV',c_max*1e3);
                       min_label = sprintf('min: %.2g mV',c_min*1e3);
                   else
                       labels(i) = {sprintf('%1.1f V',label_num)};
                       max_label = sprintf('max: %.2g V',c_max);
                       min_label = sprintf('min: %.2g V',c_min);
                   end
                end
                cbar.TickLabels = labels;
                % provide min and max information of shown data
                title(ax_handle,{'Full data range:';max_label;min_label},'FontSize',9);
            case 'hDeflection'
                % find min and max of CData
                c_min = min(min(image_handle.CData));
                c_max = max(max(image_handle.CData));
                % determine if the maximum dimension is nm or µm and
                % correct the tick lables of the colorbar
                check = abs(c_max) < 1 && abs(c_min) < 1;
                labels = cbar.TickLabels;
                for i = 1:length(labels)
                   lable_char = labels{i};
                   label_num = str2double(lable_char);
                   if check
                       label_num = label_num*1e3;
                       labels(i) = {sprintf('%3.0f mV',label_num)};
                       max_label = sprintf('max: %.2g mV',c_max*1e3);
                       min_label = sprintf('min: %.2g mV',c_min*1e3);
                   else
                       labels(i) = {sprintf('%1.1f V',label_num)};
                       max_label = sprintf('max: %.2g V',c_max);
                       min_label = sprintf('min: %.2g V',c_min);
                   end
                end
                cbar.TickLabels = labels;
                % provide min and max information of shown data
                title(ax_handle,{'Full data range:';max_label;min_label},'FontSize',9);
            case 'Youngs Modulus'
                % find min and max of CData
                c_min = min(min(image_handle.CData));
                c_max = max(max(image_handle.CData));
                % determine the order of magnetude and
                % correct the tick lables of the colorbar
                order_max = floor(log(abs(c_max))./log(10));
                order_min = floor(log(abs(c_min))./log(10));
                max_order = max([order_max order_min]);
                labels = cbar.TickLabels;
                for i = 1:length(labels)
                   lable_char = labels{i};
                   label_num = str2double(lable_char);
                   if max_order < 3
                       labels(i) = {sprintf('%3.0f Pa',label_num)};
                       max_label = sprintf('max: %f Pa',c_max);
                       min_label = sprintf('min: %f Pa',c_min);
                   elseif max_order >= 3 && max_order < 6
                       label_num = label_num*1e-3;
                       labels(i) = {sprintf('%.2f kPa',label_num)};
                       max_label = sprintf('max: %.2f kPa',c_max*1e-3);
                       min_label = sprintf('min: %.2f kPa',c_min*1e-3);
                   else
                       label_num = label_num*1e-6;
                       labels(i) = {sprintf('%.2f MPa',label_num)};
                       max_label = sprintf('max: %.2f MPa',c_max*1e-6);
                       min_label = sprintf('min: %.2f MPa',c_min*1e-6);
                   end
                end
                cbar.TickLabels = labels;
                % provide min and max information of shown data
                title(ax_handle,{'Full data range:';max_label;min_label},'FontSize',9);
            case 'Contactpoint'
                % find min and max of CData
                c_min = min(min(image_handle.CData));
                c_max = max(max(image_handle.CData));
                % determine the order of magnetude and
                % correct the tick lables of the colorbar
                order_max = floor(log(abs(c_max))./log(10));
                order_min = floor(log(abs(c_min))./log(10));
                max_order = max([order_max order_min]);
                labels = cbar.TickLabels;
                for i = 1:length(labels)
                   lable_char = labels{i};
                   label_num = str2double(lable_char);
                   if max_order <= -9
                       label_num = label_num*1e9;
                       labels(i) = {sprintf('%3.0f nm',label_num)};
                       max_label = sprintf('max: %.2g nm',c_max*1e9);
                       min_label = sprintf('min: %.2g nm',c_min*1e9);
                   else
                       label_num = label_num*1e6;
                       labels(i) = {sprintf('%.2f µm',label_num)};
                       max_label = sprintf('max: %.2g µm',c_max*1e6);
                       min_label = sprintf('min: %.2g µm',c_min*1e6);
                   end
                end
                cbar.TickLabels = labels;
                % provide min and max information of shown data
                title(ax_handle,{'Full data range:';max_label;min_label},'FontSize',9);
            otherwise
                warning('No colorbar processing is available for the choosen map channel');
        end
    else
        warning('No matching filetype for the color bar processing is loaded!')
        return;
    end
    
% --- Colorbar helper function to display the colorbar properly.
function handles = info_panel_helpf(handles)
    %     Function to read file information and display them in the info panel
    loaded_file = handles.loaded_file_type;
    
    % Check if a jpk-force-map was loaded
    if strcmp(loaded_file,'jpk-force-map')         
        handles.info_table.Data = handles.map_info_array;                
    % Check if ibw files were loaded
    elseif strcmp(loaded_file,'ibw') 
        handles.info_table.Data = handles.mfpmapdata{1};        
    % Check if txt files were loaded
    elseif strcmp(loaded_file,'txt')
        handles.info_table.Data = handles.text_file_info;
    elseif strcmp(loaded_file,'mach-txt')
        seg_num = handles.current_curve;
        seg = sprintf('segment%d',seg_num);
        handles.info_table.Data = handles.mach_info_struct.(seg);
    end
    
    
% --------------------------------------------------------------------
function help_menu_Callback(~, ~, ~)
% hObject    handle to help_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function help_wiki_Callback(~, ~, ~)
% hObject    handle to help_wiki (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if clicked, open the help wiki on our github site
web('https://github.com/CANTERhm/Canter_Matlab_Library/wiki/2a.-Force-indentation-processing','-browser');

%--------------------------------------------------------------------
function handles = get_indenter_parameter(handles)
% help function to get the indetner geometry parameter and the poisson ration from the options struct    
handles.tip_angle = handles.options.tip_angle;
handles.poisson = handles.options.poisson;
handles.tip_shape = handles.options.tip_shape;
handles.cylinder_radius = handles.options.cylinder_radius;

   



function hertz_fit_start_Callback(hObject, ~, handles)
% hObject    handle to hertz_fit_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hertz_fit_start as text
%        str2double(get(hObject,'String')) returns contents of hertz_fit_start as a double
fit_s_string = hObject.String;
fit_s_string = strrep(fit_s_string,',','.');
hObject.String = fit_s_string;

fit_s_num_check = str2double(fit_s_string);

if ~isnan(fit_s_num_check)
    try
        [hObject,handles] = curve_fit_functions(hObject,handles);
        [hObject,handles] = update_patches_hertzfit(hObject,handles);
        [hObject,handles] = update_fit_results(hObject,handles);
        guidata(hObject,handles);
    catch %ME
        % if you can    
    end
else
    hObject.String = '0.0';
end


% --- Executes during object creation, after setting all properties.
function hertz_fit_start_CreateFcn(hObject, ~, ~)
% hObject    handle to hertz_fit_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function save_image_Callback(~, ~, handles)
% hObject    handle to save_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
path = handles.edit_filepath.String;
[filepath,filename,~] = fileparts(path);

if ~exist(filepath, 'dir')
  mkdir(filepath);
end

channels = handles.image_channels_popup.String;
channel_indx = handles.image_channels_popup.Value;
channel = channels{channel_indx};

baseFileName =  sprintf('%s_%s_%s.jpg',filename,channel, handles.interpolation_type);
fullFileName = fullfile(filepath, baseFileName); 
image = getframe(handles.map_axes);
if exist(fullFileName, 'file')
    answer = questdlg({'File already exists!',...
            'Do you want to overwrite the existing file?'},...
            'Warning!','Yes','No','Yes');
        if strcmp(answer,'Yes')
            imwrite(image.cdata, fullFileName); % img respresents input image.
        else
        end
else
    imwrite(image.cdata, fullFileName); % img respresents input image.
end


% --------------------------------------------------------------------
function bug_report_menu_Callback(hObject, eventdata, handles)
% hObject    handle to bug_report_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function report_a_bug_submenu_Callback(hObject, eventdata, handles)
% hObject    handle to report_a_bug_submenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/CANTERhm/Canter_Matlab_Library/issues','-browser');


% --------------------------------------------------------------------
function how_to_report_submenu_Callback(hObject, eventdata, handles)
% hObject    handle to how_to_report_submenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/CANTERhm/Canter_Matlab_Library/wiki/How-to-report-an-issue','-browser');
