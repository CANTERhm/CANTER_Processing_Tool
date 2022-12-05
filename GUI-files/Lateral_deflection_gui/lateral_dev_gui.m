function varargout = lateral_dev_gui(varargin)
% LATERAL_DEV_GUI MATLAB code for lateral_dev_gui.fig
%      LATERAL_DEV_GUI, by itself, creates a new LATERAL_DEV_GUI or raises the existing
%      singleton*.
%
%      H = LATERAL_DEV_GUI returns the handle to a new LATERAL_DEV_GUI or the handle to
%      the existing singleton*.
%
%      LATERAL_DEV_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LATERAL_DEV_GUI.M with the given input arguments.
%
%      LATERAL_DEV_GUI('Property','Value',...) creates a new LATERAL_DEV_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lateral_dev_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lateral_dev_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lateral_dev_gui

% Last Modified by GUIDE v2.5 14-Aug-2018 17:35:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lateral_dev_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @lateral_dev_gui_OutputFcn, ...
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


% --- Executes just before lateral_dev_gui is made visible.
function lateral_dev_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lateral_dev_gui (see VARARGIN)

% Choose default command line output for lateral_dev_gui
handles.output = hObject;

% prelocate handle structs
handles.load_status = 0;
handles.results = struct;
handles.lines = struct;
handles.current_line = 0;
handles.cbar_factor = 2.2;
handles.peak_prom = 1.5;
handles.results = struct;
handles.results.pks = struct;
handles.results.width = struct;
handles.results.pks = [];
handles.results.width = [];

% create folder for log-file if it doesn't exist
if isdeployed
    c_path = ctfroot;
    handles.log_path = fullfile(c_path,'log_folder');
    ex_ans = exist(handles.log_path,'dir');
    if ex_ans == 0
        mkdir(handles.log_path);
        handles.log_path = fullfile(handles.log_path,'log_file.txt');
        logid = fopen(handles.log_path,'at');
        log_header = sprintf('# log_file\n# date of creation: %s\n# Type: Standalone Application\n\n\n\n',...
            datestr(datetime('now')));
        fwrite(logid,log_header);
        fclose(logid);      
    else
        handles.log_path = fullfile(handles.log_path,'log_file.txt');
    end
    
else
    c_path = pwd;
    handles.log_path = fullfile(c_path,'log-files');
    ex_ans = exist(handles.log_path,'dir');
    if ex_ans == 0
        mkdir(handles.log_path);
        handles.log_path = fullfile(handles.log_path,'log_file.txt');
        logid = fopen(handles.log_path,'at');
        log_header = sprintf('# log_file\n# date of creation: %s\n# Type: Matlab Enviroment Application\n\n\n\n',...
            datestr(datetime('now')));
        fwrite(logid,log_header);
        fclose(logid);
    else
        handles.log_path = fullfile(handles.log_path,'log_file.txt');
    end
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lateral_dev_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lateral_dev_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% delete(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
exit_button_Callback(handles.exit_button,eventdata,handles);


% --------------------------------------------------------------------
function load_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

    % preset answer
    answer = 'Yes';

    % check load status
    if handles.load_status == 1
        answer = questdlg({'Do you really want to load a new map!',...
            'All unsaved results from the current map will be lost!'},...
            'Load new map','Yes','No','Yes');
    end

    if strcmp(answer,'Yes')
        
        % delete results from previous session
        handles.results.pks = [];
        handles.results.width = [];
        
        % load x,y and z data from .xyz-file exported with gwyddion
        [x_data,y_data,z_data,map_name] = import_xyz_file();

        if ~strcmp(x_data,'canceld')
            handles.map_name = map_name;

            % ask user about fast and slow axis pixels
            prompt = {'Enter pixel number in the fast axis (x-axis)'};
            title = 'Pixel input';
            dims = [1 35];
            definput = {'512'};
            answer = inputdlg(prompt,title,dims,definput);
            x_pixel = str2double(answer{1});
            y_pixel = floor(length(z_data)/x_pixel);
            z_data = z_data(1:(x_pixel*y_pixel));


            % split x_data, y_data and z_data in a struct

            for i = y_pixel:-1:1
                a = y_pixel-i;
                x_start = x_pixel*a + 1;
                x_end = (x_start + x_pixel) - 1;
                line_num = sprintf('line%u',i);
                handles.lines.(line_num) = struct;
                handles.lines.(line_num).x_values = x_data(x_start:x_end);
                handles.lines.(line_num).y_values = y_data(x_start:x_end);
                handles.lines.(line_num).z_values = z_data(x_start:x_end);
            end
            guidata(hObject,handles);

            handles.current_line = 1;

            % plot map
            handles.number_of_lines = y_pixel;
            [X,Y] = meshgrid(handles.lines.line1.x_values,y_data(1:x_pixel:length(y_data)));
            Z = reshape(z_data,x_pixel,y_pixel);
            Z = rot90(Z,3);
            Z = flip(Z,2);
            handles.pc = pcolor(handles.map_plot_axes,X.*1e6,Y.*1e6,Z.*1e3);
            handles.pc.LineStyle = 'none';
            axes(handles.map_plot_axes)
            set_afm_gold(0.9,handles.cbar_factor);
            asp = pbaspect;
            y_asp = y_pixel/x_pixel;
            asp(1) = 1;
            asp(2) = y_asp;
            pbaspect(asp);
            xlabel('fast axis [µm]');
            ylabel('slow axis [µm]');
            guidata(hObject,handles);

            % highlight current line
            line_string = sprintf('line%u',handles.current_line);
            hold(handles.map_plot_axes,'on');
            handles.blue_line = line(handles.lines.(line_string).x_values.*1e6,handles.lines.(line_string).y_values.*1e6,'color','b');
            hold(handles.map_plot_axes,'off');
            guidata(hObject,handles);

            % draw first line
            axes(handles.line_plot_axes);
            [hObject,handles] = map_line_plot(hObject,handles);
            guidata(hObject,handles);



            % activate gui elements
            handles.peak_table.Enable = 'on';
            handles.cbar_multiplier.Enable = 'on';
            handles.peak_prom_fac.Enable = 'on';
            handles.button_next_line.Enable = 'on';
            handles.continue_line_button.Enable = 'on';

            % set satus values
            handles.load_status = 1;
            handles.save_status = 0;
            handles.save_button.Enable = 'on';
            guidata(hObject,handles);
        end % end if (~strcmp(x_data,'canceld'))
    end % end if (strcmp(answer,'Yes'))
    guidata(hObject,handles);
    
catch MException
    ME = MException;
    WriteInLogFile(handles.log_path,ME);
    rethrow(ME);
end

% --------------------------------------------------------------------
function exit_button_Callback(hObject, eventdata, handles)
% hObject    handle to exit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    answer = 'Yes';
    if handles.load_status == 1 && handles.save_status == 0
        answer = questdlg({'Do you really want to close the gui?','Alls unsaved results will be lost!'},'Close request',...
            'Yes','No','No');
    end

    if strcmp(answer,'Yes')
        delete(handles.figure1);
        run('CANTER_Processing_Toolbox.mlapp');
    end

catch MException
    ME = MException;
    WriteInLogFile(handles.log_path,ME);
    rethrow(ME);
    
end



function cbar_multiplier_Callback(hObject, eventdata, handles)
% hObject    handle to cbar_multiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cbar_multiplier as text
%        str2double(get(hObject,'String')) returns contents of cbar_multiplier as a double

try

    % get entered number
    cbar_mult = hObject.String;
    cbar_mult = strrep(cbar_mult,',','.'); 
    hObject.String = cbar_mult;
    handles.cbar_factor = str2double(cbar_mult);
    if isnan(handles.cbar_factor)
        handles.cbar_factor = 2.2;
        hObject.String = '2.2';
    end    
    
    guidata(hObject,handles)

    % set new colorbar on the map_plot_axes
    axes(handles.map_plot_axes);
    set_afm_gold(0.9,handles.cbar_factor);

catch MException
    ME = MException;
    WriteInLogFile(handles.log_path,ME);
    rethrow(ME);
    
end


% --- Executes during object creation, after setting all properties.
function cbar_multiplier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cbar_multiplier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function peak_prom_fac_Callback(hObject, eventdata, handles)
% hObject    handle to peak_prom_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of peak_prom_fac as text
%        str2double(get(hObject,'String')) returns contents of peak_prom_fac as a double

try

    % get entered number
    peak_prom = hObject.String;
    peak_prom = strrep(peak_prom,',','.'); 
    hObject.String = peak_prom;
    handles.peak_prom = str2double(peak_prom);
    if isnan(handles.cbar_factor)
        handles.peak_prom = 1.5;
        hObject.String = '1.5';
    end

    axes(handles.line_plot_axes);
    % find peak with new peak prominece value
    line_string = sprintf('line%u',handles.current_line);
    % find statistic values
    start_guess = mean(handles.lines.(line_string).z_values);
    options = fitoptions('Method','NonlinearLeastSquares','StartPoint',start_guess);
    [~,gof] = fit(handles.lines.(line_string).x_values,handles.lines.(line_string).z_values,@(c,x)c.*x.^0,options);
    noise_level = handles.peak_prom*gof.sse;

    % find peaks
    findpeaks(handles.lines.(line_string).z_values.*1e3,handles.lines.(line_string).x_values.*1e6,...
    'MinPeakProminence',noise_level*1e3,'Annotate','extents',...
        'WidthReference','halfheight');
    legend_string = sprintf('%s (y-coordinate: %g µm)',line_string,handles.lines.(line_string).y_values(1)*1e6);
    legend(legend_string,'Location','northeast');
    % get peak values
    [pks,locs,width] = findpeaks(handles.lines.(line_string).z_values.*1e3,handles.lines.(line_string).x_values.*1e6,...
    'MinPeakProminence',noise_level*1e3,'Annotate','extents',...
        'WidthReference','halfheight');
    peak_num = numel(pks);
    % label peaks
    text(locs+.05,pks+1,num2str((1:peak_num)'));

    % create cell array for table
    handles.peak_table.Data = cell(peak_num,3);
    table_data = cell(peak_num,3);
    for i=1:peak_num
        table_data{i,1} = pks(i);
        table_data{i,2} = width(i);
        table_data{i,3} = false;
    end

    % write peak values in table
    handles.peak_table.Data = table_data;

    guidata(hObject,handles);

catch MException
    ME = MException;
    WriteInLogFile(handles.log_path,ME);
    rethrow(ME);
    
end

% --- Executes during object creation, after setting all properties.
function peak_prom_fac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peak_prom_fac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_next_line.
function button_next_line_Callback(hObject, eventdata, handles)
% hObject    handle to button_next_line (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

    % activate previous line button when this button is presst on first line
    if handles.current_line == 1
        handles.button_previous_line.Enable = 'on';
    end

    %   save chosen peak values in result vectors
    %   get data cell array from uitable
        table_data = handles.peak_table.Data;

    %   extract data vectors from cell array
        pks = cell2mat(table_data(:,1));
        width = cell2mat(table_data(:,2));
        keep = cell2mat(table_data(:,3));

    %   write the user chose peak values in result vector
        line_string = sprintf('line%u',handles.current_line);
        if any(keep)
           num_keep = nnz(keep);
           handles.results.pks(end+1:end+num_keep,1) = pks(keep);
           handles.results.width(end+1:end+num_keep,1) = width(keep);
           handles.lines.(line_string).num_kept_peaks = num_keep;
        else
            handles.lines.(line_string).num_kept_peaks = 0;
        end

    % do the next part just if not the end of the map is reached
    if handles.current_line ~= handles.number_of_lines
    %   draw and evaluate next line of map
        handles.current_line = handles.current_line + 1;

    %   highlight current line
        axes(handles.map_plot_axes);
        delete(handles.blue_line);
        line_string = sprintf('line%u',handles.current_line);
    %     hold(handles.map_plot_axes,'on');
        handles.blue_line = line(handles.lines.(line_string).x_values.*1e6,handles.lines.(line_string).y_values.*1e6,'color','b');
    %     hold(handles.map_plot_axes,'off');
        guidata(hObject,handles);

        % draw line
        axes(handles.line_plot_axes);
        [hObject,handles] = map_line_plot(hObject,handles);
        guidata(hObject,handles);
    else    % ask user to save the results and deactivate next line button
        handles.button_next_line.Enable = 'off';
        answer = questdlg('Do you want to save the results?','Save results?',...
                          'Yes','No','Yes');
        if strcmp(answer,'Yes')
            save_button_Callback(handles.save_button, eventdata, handles);
        end
    end

        guidata(hObject,handles)
        
catch MException
    ME = MException;
    WriteInLogFile(handles.log_path,ME);
    rethrow(ME);
    
end



% --- Executes on button press in button_previous_line.
function button_previous_line_Callback(hObject, eventdata, handles)
% hObject    handle to button_previous_line (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

    handles.current_line = handles.current_line - 1;

    % deactivate butten when first line is reached
    if handles.current_line == 1
        hObject.Enable = 'off';
    end

    % delete results of previous line from result vectors
    line_string = sprintf('line%u',handles.current_line);
    del_num = handles.lines.(line_string).num_kept_peaks;

    if del_num ~= 0
        handles.results.pks(end-del_num+1:end) = [];
        handles.results.width(end-del_num+1:end) = [];
    end

    % draw previous line in map and find peaks in preavious line
    axes(handles.map_plot_axes);
    delete(handles.blue_line);
    line_string = sprintf('line%u',handles.current_line);
    hold(handles.map_plot_axes,'on');
    handles.blue_line = line(handles.lines.(line_string).x_values.*1e6,handles.lines.(line_string).y_values.*1e6,'color','b');
    hold(handles.map_plot_axes,'off');
    guidata(hObject,handles);

    % draw first line
    axes(handles.line_plot_axes);
    [hObject,handles] = map_line_plot(hObject,handles);
    guidata(hObject,handles);

catch MException
    ME = MException;
    WriteInLogFile(handles.log_path,ME);
    rethrow(ME);
    
end





% --- Executes when selected cell(s) is changed in peak_table.
function peak_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to peak_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when entered data in editable cell(s) in peak_table.
function peak_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to peak_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function peak_table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peak_table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Data',cell(1))


% --------------------------------------------------------------------
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try

    % sevepath
    [s_file,s_path] = uiputfile('*.tsv');
    tsv_path = fullfile(s_path,s_file);
    [~,excel_name,~] = fileparts(tsv_path);
    excel_path = fullfile(s_path,sprintf('%s.xlsx',excel_name));

    if s_path ~= 0

        wb = waitbar(0,'Creating Save Variables');

        % creating save vectors
        Peak_value_mV = handles.results.pks;
        Peak_width_um = handles.results.width;
        Map_name_string = handles.map_name;
        Map_name = string.empty;
        Line_index = string.empty;

        waitbar(0,wb,'Saving Peak Results');
        for i = 1:handles.number_of_lines
           waitbar(i/handles.number_of_lines,wb,sprintf('Saving Peak Results: line%u',i));
           line_string = sprintf('line%u',i);
           if isfield(handles.lines.(line_string),'num_kept_peaks')
               peak_num = handles.lines.(line_string).num_kept_peaks;
               if peak_num ~= 0
                  for a = 1:peak_num
                      Map_name(end+1,1) = Map_name_string;
                      Line_index(end+1,1) = line_string;
                  end % for
               end % if
           else
               break;
           end % if
        end % for

        waitbar(1,wb,'Write Files');
        % save results as tsv file
        save_table(Map_name,Line_index,Peak_value_mV,Peak_width_um,'fileFormat',...
                    'tsv','savepath',tsv_path);
        % save results as xlsx file
        save_table(Map_name,Line_index,Peak_value_mV,Peak_width_um,'fileFormat',...
                    'excel','savepath',excel_path);

        % save successfull
        delete(wb);
        msgbox('Saving was successful!','Saving completed');

        handles.save_status = 1;
        guidata(hObject,handles);
    end

catch MException
    ME = MException;
    WriteInLogFile(handles.log_path,ME);
    rethrow(ME);
    
end

% --------------------------------------------------------------------
function help_button_Callback(hObject, eventdata, handles)
% hObject    handle to help_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://github.com/CANTERhm/Canter_Matlab_Library/wiki/Lateral-deflection-processing','-browser');

    


% --------------------------------------------------------------------
function continue_line_button_Callback(hObject, eventdata, handles)
% hObject    handle to continue_line_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


try

    % get current line
    c_line = handles.current_line;
    
    % ask user from whitch line he wants to continue
    prompt = {'From whitch line do you whant to continue?'};
    title = 'Line number';
    dims = [1 35];
    definput = {'1'};
    answer = inputdlg(prompt,title,dims,definput);
    new_line_num = str2double(answer{1});
    
    % check if input is correct. If it's correct jump to this line
    if isnan(new_line_num)
        errordlg('Please enter a number!','Not a number');
    elseif new_line_num < c_line
        errordlg('Please enter a line number greater than the current number.','Lower line number');
    elseif new_line_num > handles.number_of_lines
        errordlg('Please enter a line number not greater than the maximum number of lines in the map','Too high line number');
    else  
        for i = c_line:new_line_num-1
            handles.current_line = i;
            if handles.current_line == 1
                handles.button_previous_line.Enable = 'on';
            end
            line_string = sprintf('line%u',handles.current_line);
            handles.lines.(line_string).num_kept_peaks = 0;
        end
        % draw and evaluate next line of map
        handles.current_line = handles.current_line + 1;

        % highlight current line
        axes(handles.map_plot_axes);
        delete(handles.blue_line);
        line_string = sprintf('line%u',handles.current_line);
        handles.blue_line = line(handles.lines.(line_string).x_values.*1e6,handles.lines.(line_string).y_values.*1e6,'color','b');
        guidata(hObject,handles);

        % draw line
        axes(handles.line_plot_axes);
        [hObject,handles] = map_line_plot(hObject,handles);
        guidata(hObject,handles);
    end
    
    
catch MException
    ME = MException;
    WriteInLogFile(handles.log_path,ME);
    rethrow(ME);
    
end   
