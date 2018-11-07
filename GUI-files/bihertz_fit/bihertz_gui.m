function varargout = bihertz_gui(varargin)
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

% Last Modified by GUIDE v2.5 02-Oct-2018 10:56:11
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
handles.curves = struct([]);
handles.figures = struct('main_fig',[]);
handles.load_status = 0;
handles.save_status = 1;
handles.interpolation_type = 'bicubic';

guidata(hObject, handles);


% set gui appearance depending on chosen model
handles.fit_model_popup.Enable = 'on';
switch handles.options.model
    case 'bihertz'
        % in this case it is good as it is ;)
    case 'hertz'
        handles.fit_model_popup.Value = 2;
        handles.uipanel5.Visible = 'off';
        handles.uipanel10.Visible = 'off';
        handles.hertz_fit_panel.Visible = 'on';
        axes(handles.map_axes);
        axis off
end



% UIWAIT makes bihertz_gui wait for user response (see UIRESUME)
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
function listbox1_Callback(hObject, ~, ~)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
text = get(hObject,'Value');
fprintf('Left click on list-value %g\n',text);



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
function listbox1_ButtonDownFcn(hObject, ~, ~)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
test = get(hObject,'Value');
fprintf('Right click on list-value %g\n',test)



function edit_filepath_Callback(~, ~, ~)
% hObject    handle to edit_filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filepath as text
%        str2double(get(hObject,'String')) returns contents of edit_filepath as a double


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
[file,path,indx] = uigetfile({'*.jpk-force-map','JPK-Force-map (*.jpk-force-map)';...
    '*.tsv','Single tsv-file (*.tsv)'},'Select a File');

if ~isequal(file,0)
    set(handles.edit_filepath,'String',fullfile(path,file))
    handles.filefilter = indx;
    handles.loadtype = 'file';
    guidata(hObject,handles)
end

% --- Executes on button press in button_load_data.
function button_load_data_Callback(hObject, ~, handles)
% hObject    handle to button_load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
answer = 0;
if handles.load_status == 1
    answer = questdlg({'There is loaded data!',...
        'If you load new data all unsaved results will be lost!',...
        'Do you really want to load new data?'},...
        'Loaded data warning','Yes','No','No');
end

if strcmp(answer,'No')
    return;
elseif strcmp(answer,'Yes')  || answer == 0
    path = get(handles.edit_filepath,'String');
    if strcmp(path,'    filepath')
        errordlg('No file or folder selected','No selection found');
    else
        handles.options = Calibration(handles.options);
        guidata(hObject,handles);
        handles.options = canti_sample_gui(handles.options);
        guidata(hObject,handles);
        
        handles.tip_angle = handles.options.tip_angle;
        handles.poisson = handles.options.poisson;
        handles.tip_shape = handles.options.tip_shape;



        % provide processing infos
        str = sprintf('Sensitivity: %.2f nm/V',handles.options.sensitivity);
        set(handles.text_sensitivity,'String',str);
        str = sprintf('Spring constant: %.4f N/m',handles.options.spring_const);
        set(handles.text_spring_const,'String',str);

        switch handles.loadtype
            case 'file'
                if handles.filefilter == 1
                   [x_data,y_data, ~, ~, Forcecurve_label,~,~,name_of_file,~,map_images] = ReadJPKMaps(handles.edit_filepath.String);
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
                       end
                   end
                   
                   % display first processing grid point and text
                   axes(handles.map_axes);
                   hold(handles.map_axes,'on');
                   handles.figures.proc_point = plot(1,1,'.w','MarkerSize',15);
                   handles.figures.proc_text = text(1.5,1.5,'1','Color','w','FontWeight','bold');
                   hold(handles.map_axes,'off');
                   guidata(hObject,handles);
                   
                elseif handles.filefilter == 2
                    % look for filefilter in handles and choose right load function
                    % UNDER CONSTRUCTION
                    warndlg('The option to load a single txt or tsv file is not yet implemented!',...
                        'UNDER CONSTRUCTION!');
                end
                num_files = length(Forcecurve_label);
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
                % prelocate listbox cell
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
                    curves.(c_string).x_values = x_data.(Forcecurve_label{i}).*1e-6;
                    curves.(c_string).y_values = y_data.(Forcecurve_label{i}).*1e-9;
                    % add listbox element                  
                    it = handles.listbox1.String;
                    it{i,1} = sprintf('curve %3u  ->  unprocessed',i);
                    handles.listbox1.String = it;
                    % update waitbar
                    wb_num = i/num_files;
                    waitbar(wb_num,wb,sprintf('Loading progress: %.f%%',wb_num*100))
                end
                
            case 'folder'
                folderpath = get(handles.edit_filepath,'String');       % get folder location
                listing = dir(folderpath);                              % information of files in folder
                filetype = strsplit(listing(3).name, '.');
                
                % Check if the folder contains .ibw files from the MFP-3D
                if strcmp(filetype(1,2), 'ibw') == 1
                    handles.ibw = true;
                    [x_data,y_data,~,~, Forcecurve_label, name_of_file] = ReadMFPMaps(folderpath);
                    Forcecurve_label = Forcecurve_label';
                    curves_in_map = strcat(name_of_file,'.',Forcecurve_label);
                    handles.file_names = curves_in_map;
                    num_files = length(Forcecurve_label);
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
                    % prelocate listbox cell
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
                        curves.(c_string).x_values = x_data.(Forcecurve_label{i});
                        curves.(c_string).y_values = y_data.(Forcecurve_label{i}).*1e-9;
                        % add listbox element                  
                        it = handles.listbox1.String;
                        it{i,1} = sprintf('curve %3u  ->  unprocessed',i);
                        handles.listbox1.String = it;
                        % update waitbar
                        wb_num = i/num_files;
                        waitbar(wb_num,wb,sprintf('Loading progress: %.f%%',wb_num*100))
                    end
                else
                    T_files_in_folder = struct2table(listing);
                    files_in_folder = table2array(T_files_in_folder(:,1));
                    files_in_folder(1:2) = [];                              % cell array with all file names
                    handles.file_names = files_in_folder;                   % save the filenames
                    num_files = length(files_in_folder);                    % number of files in folder

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
                    % prelocate listbox cell
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
                        count = 1;
                        while ischar(line)
                            line = fgetl(testid);
                            line_sep = split(line,' ');
                            if ~strcmp(line_sep{1},'#') && ~isempty(line_sep{1})
                                break
                            end
                            count = count + 1;
                        end       
                        count = count + 1;
                        fclose(testid);         
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
                        waitbar(wb_num,wb,sprintf('Loading progress: %.f%%',wb_num*100))
                    end
                end

        end
        
        handles.listbox1.Value = 1;         % highlight listbox item number one
        handles.curves = curves;            % write curves struct to handles
        handles.current_curve = 1;          % set the current curve to first
        handles.load_status = 1;            % set load status tag to 1
        handles.save_status = 0;            % set save status tag to 0
        handles.save_status_led.BackgroundColor = [1 0 0];
        delete(wb)                          % delete loading waitbar
        if i == num_files
            handles.num_files = num_files;  % provide max curve number in handles
        else
            num_files = i-1;                % number of fully loaded curves
            handles.num_files = i-1;        % provide max curve number in handles                    
        end

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
        catch
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
        xlabel('Vertical tip position [�m]');
        ylabel({'Force [nN]';''});
        guidata(hObject,handles);
        %Plot the data as Bihertz or as Hertz
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

        % prelocate result table
        switch handles.options.model
            case 'bihertz'
                varTypes =  {'string','uint64','double','double','double',...
                             'double','double','double','double'};
                varNames = {'File_name','Index','initial_E_s_Pa','initial_E_h_Pa',...
                            'initial_d_h_m','fit_E_s_Pa','fit_E_h_Pa','fit_d_h_m','rsquare_fit'};
                handles.T_result = table('size',[handles.num_files 9],'VariableTypes',varTypes,'VariableNames',varNames);
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
function button_save_path_Callback(hObject, ~, ~)
% hObject    handle to button_save_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uiputfile({'*.tsv;*.xlsx','Save files (*.tsv,*.xlsx)';...
                '*.*','All Files (*.*)'});
savepath = fullfile(path,file);
hObject.String = savepath;

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
function button_keep_highlighted_Callback(~, ~, handles)
% hObject    handle to button_keep_highlighted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_undo_highlighted.
function button_undo_highlighted_Callback(hObject, eventdata, handles)
% hObject    handle to button_undo_highlighted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_discard_highlighted.
function button_discard_highlighted_Callback(hObject, eventdata, handles)
% hObject    handle to button_discard_highlighted (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in button_keep.
function button_keep_Callback(hObject, ~, handles)
% hObject    handle to button_keep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.fit_model_popup.Enable = 'off';

% save fit results
curve_index = handles.current_curve;
discarded = handles.progress.num_discarded;

switch handles.options.model
    case 'bihertz'
        handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                           uint64(curve_index),...
                           handles.fit_results.initial_E_s,...
                           handles.fit_results.initial_E_h,...
                           handles.fit_results.initial_d_h,...
                           handles.fit_results.fit_E_s,...
                           handles.fit_results.fit_E_h,...
                           handles.fit_results.fit_d_h,...
                           handles.fit_results.rsquare_fit};

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
else
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
                '*.*','All Files (*.*)'});
            if path ~= 0
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
    
    % write process info
    [hObject,handles] = update_progress_info(hObject,handles);
    guidata(hObject,handles);
    
    % activate undo button when first time pushed
    if curve_index == 1
        handles.button_undo.Enable = 'on';
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

                
% change listbox element                  
it = handles.listbox1.String;
it{curve_index,1} = sprintf('curve %3u  ->  discarded',curve_index);
handles.listbox1.String = it;


% add 1 to the current_curve value
handles.current_curve = curve_index +1;
new_curve_index = curve_index + 1;
guidata(hObject,handles);

if handles.ibw == true
else
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
                '*.*','All Files (*.*)'});
            if path ~= 0
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
    handles.progress.num_discarded = handles.progress.num_discarded +1;
    guidata(hObject,handles);
    
    % write process info
    [hObject,handles] = update_progress_info(hObject,handles);
    guidata(hObject,handles);
    
    % activate undo button when first time pushed
    if curve_index == 1
        handles.button_undo.Enable = 'on';
    end
    
end
guidata(hObject,handles);


% --- Executes on button press in button_undo.
function button_undo_Callback(hObject, ~, handles)
% hObject    handle to button_undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set save status to 0
handles.save_status = 0;
handles.save_status_led.BackgroundColor = [0 1 0];


% Subtract 1 from the current curve value
curve_index = handles.current_curve-1;

% undo previous fit results
if curve_index == 1
    switch handles.options.model
        case 'bihertz'
            varTypes = {'string','uint64','double','double','double',...
                        'double','double','double','double'};
            varNames = {'File_name','Index','initial_E_s_Pa','initial_E_h_Pa',...
                        'initial_d_h_m','fit_E_s_Pa','fit_E_h_Pa','fit_d_h_m','rsquare_fit'};
            handles.T_result = table('Size',[handles.num_files 9],'VariableTypes',varTypes,'VariableNames',varNames);
        case 'hertz'
            varTypes =  {'string','uint64','double','double'};
            varNames = {'File_name','Index','EModul','rsquare_fit'};
            handles.T_result = table('size',[handles.num_files 4],'VariableTypes',varTypes,'VariableNames',varNames);
    end
else
    if curve_index ~= handles.num_files
        switch handles.options.model
            case 'bihertz'
                handles.T_result(end+1,:) = {missing,...
                                           uint64(0),...
                                           0,...
                                           0,...
                                           0,...
                                           0,...
                                           0,...
                                           0,...
                                           0};
            case 'hertz'
                handles.T_result(end+1,:) = {missing,uint64(0), 0, 0};
        end
    end
end
                
% change listbox element and save previous string                  
it = handles.listbox1.String;
prev_string = it{curve_index,1};
it{curve_index,1} = sprintf('curve %3u  ->  unprocessed',curve_index);
handles.listbox1.String = it;


% Save the new current_curve value
handles.current_curve = curve_index;
new_curve_index = curve_index;
guidata(hObject,handles);

if handles.ibw == true
else
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
prev_string = split(prev_string,'  ->  ');
prev_string = prev_string{2};
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

% when first curve reached disable undo button
if new_curve_index == 1
    handles.button_undo.Enable = 'off';
    handles.fit_model_popup.Enable = 'on';
end

% if pushed after reaching the last curve keep and discard buttons are
% enabled again
if new_curve_index == handles.num_files-1
    handles.button_keep.Enable = 'on';
    handles.button_discard.Enable = 'on';
    handles.button_keep_all.Enable = 'on';
    handles.fit_model_popup.Enable = 'off';
end
guidata(hObject,handles);
    




% --- Executes on button press in button_keep_all.
function button_keep_all_Callback(hObject, ~, handles)
% hObject    handle to button_keep_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % disable buttons during processing
    handles.button_keep.Enable = 'off';
    handles.button_discard.Enable = 'off';
    handles.button_keep_all.Enable = 'off';
    handles.button_undo.Enable = 'off';

curve_index = handles.current_curve;

% loop iterations
loop_it = (handles.num_files - curve_index);

% initialise waitbar with cancel button
wb = waitbar(0,sprintf('curve %3u of %3u',curve_index,handles.num_files),...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(wb,'canceling',0);

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
        handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                           uint64(curve_index),...
                           handles.fit_results.initial_E_s,...
                           handles.fit_results.initial_E_h,...
                           handles.fit_results.initial_d_h,...
                           handles.fit_results.fit_E_s,...
                           handles.fit_results.fit_E_h,...
                           handles.fit_results.fit_d_h,...
                           handles.fit_results.rsquare_fit};

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
    else
        % update current curve marker on map axes
        handles = update_curve_marker(handles);
    end

    % highlight next list item
    handles.listbox1.Value = new_curve_index;
    guidata(hObject,handles);
    
    % update waitbar and message
    waitbar(a/loop_it,wb,sprintf('curve %3u of %3u',new_curve_index,handles.num_files));

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

    % write process info
    [hObject,handles] = update_progress_info(hObject,handles);
    guidata(hObject,handles);

end

% reable buttons after processing
handles.button_keep.Enable = 'on';
handles.button_discard.Enable = 'on';
handles.button_keep_all.Enable = 'on';
handles.button_undo.Enable = 'on';

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
        handles.T_result(curve_index-discarded,:) = {handles.file_names(curve_index),...
                           uint64(curve_index),...
                           handles.fit_results.initial_E_s,...
                           handles.fit_results.initial_E_h,...
                           handles.fit_results.initial_d_h,...
                           handles.fit_results.fit_E_s,...
                           handles.fit_results.fit_E_h,...
                           handles.fit_results.fit_d_h,...
                           handles.fit_results.rsquare_fit};

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
        if strcmp(handles.edit_savepath.String,'     savepath')
            [file,path] = uiputfile({'*.tsv;*.xlsx','Save files (*.tsv,*.xlsx)';...
                '*.*','All Files (*.*)'});
            if path ~= 0
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
        handles.uipanel5.Visible = 'on';
        handles.uipanel10.Visible = 'on';
        handles.hertz_fit_panel.Visible = 'off';
        handles.map_axes.Visible = 'off';
        handles.options.model = 'bihertz';
        % recreate T_results if exists
        if isfield(handles,'T_result')
        varTypes =  {'string','uint64','double','double','double',...
                             'double','double','double','double'};
        varNames = {'File_name','Index','initial_E_s_Pa','initial_E_h_Pa',...
                    'initial_d_h_m','fit_E_s_Pa','fit_E_h_Pa','fit_d_h_m','rsquare_fit'};
        handles.T_result = table('size',[handles.num_files 9],'VariableTypes',varTypes,'VariableNames',varNames);
        end
    case 2
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
end

try     % if curves are loaded
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
[path] = uigetdir([],'Select folder with curve-files');

if ~isequal(path,0)
    set(handles.edit_filepath,'String',path);
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
[hObject,handles] = update_patches_hertzfit(hObject,handles);
[hObject,handles] = curve_fit_functions(hObject,handles);
[hObject,handles] = update_fit_results(hObject,handles);
guidata(hObject,handles);

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
guidata(hObject,handles);


% --- Executes on selection change in image_channels_popup.
function image_channels_popup_Callback(hObject, ~, handles)
% hObject    handle to image_channels_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns image_channels_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from image_channels_popup
[hObject,handles] = checker_helpf(hObject,handles);
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
else
    channel_image = handles.map_images.(channel_string).(sprintf('%s_data%s',...
        channel_string,interpolation_string));
end
axes(handles.map_axes);
imshow(flip(channel_image,1),[],'InitialMagnification','fit','XData',[1 handles.map_info.x_pixel],'YData',[1 handles.map_info.y_pixel]);
handles.map_axes.YDir = 'normal';
handles = update_curve_marker(handles);
hline = findall(gca,'Type','image');
set(hline(1),'uicontextmenu',handles.map_axes_context);
set_afm_gold;
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
handles = update_curve_marker(handles);
hline = findall(gca,'Type','image');
set(hline(1),'uicontextmenu',handles.map_axes_context);
set_afm_gold;
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
handles = update_curve_marker(handles);
hline = findall(gca,'Type','image');
set(hline(1),'uicontextmenu',handles.map_axes_context);
set_afm_gold;
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
handles = update_curve_marker(handles);
hline = findall(gca,'Type','image');
set(hline(1),'uicontextmenu',handles.map_axes_context);
set_afm_gold;
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
function btngroup_contact_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in btngroup_contact 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Curve is redrawn with a different Contactpoint finding model. This is
%checked in the contact point function during the process_options

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
guidata(hObject,handles);
