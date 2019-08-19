function varargout = canti_sample_gui(varargin)
%% LICENSE
% 
% 
% CANTER_Auswertetool: A tool for the data processing of force-indentation curves and more ...
%     Copyright (C) 2018-2019  Bastian Hartmann and Lutz Fleischhauer
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
    
%% CANTI_SAMPLE_GUI MATLAB code for canti_sample_gui.fig
%      CANTI_SAMPLE_GUI, by itself, creates a new CANTI_SAMPLE_GUI or raises the existing
%      singleton*.
%
%      H = CANTI_SAMPLE_GUI returns the handle to a new CANTI_SAMPLE_GUI or the handle to
%      the existing singleton*.
%
%      CANTI_SAMPLE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANTI_SAMPLE_GUI.M with the given input arguments.
%
%      CANTI_SAMPLE_GUI('Property','Value',...) creates a new CANTI_SAMPLE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before canti_sample_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to canti_sample_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help canti_sample_gui

% Last Modified by GUIDE v2.5 09-Aug-2019 13:35:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @canti_sample_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @canti_sample_gui_OutputFcn, ...
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


% --- Executes just before canti_sample_gui is made visible.
function canti_sample_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to canti_sample_gui (see VARARGIN)

% Choose default command line output for canti_sample_gui
handles.output = hObject;

% get options as input parameter
handles.options = varargin{1};

% Update handles structure
guidata(hObject, handles);

% set gui images
axes(handles.axes_cantilever)
canti_ima = imread('cantilever_tip.png');
canti_ima(:,:,2) = canti_ima(:,:,1);
canti_ima(:,:,3) = canti_ima(:,:,1);
image(canti_ima);
axis off
axis image

% UIWAIT makes canti_sample_gui wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = canti_sample_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.options;
delete(handles.figure1);


% --- Executes during object creation, after setting all properties.
function axes_cantilever_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_cantilever (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_cantilever


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
content_cell = hObject.String;
content_str = content_cell{hObject.Value};

switch content_str
    case 'Four sided pyramid'
        handles.diameter_panel.Visible = false;
        % display suitable image
        axes(handles.axes_cantilever)
        canti_ima = imread('cantilever_tip.png');
        canti_ima(:,:,2) = canti_ima(:,:,1);
        canti_ima(:,:,3) = canti_ima(:,:,1);
        image(canti_ima);
        axis off
        axis image
    case 'Flat cylinder'
        handles.diameter_panel.Visible = true;
        % display suitable image
        axes(handles.axes_cantilever)
        canti_ima = imread('flat_cylinder.png');
        canti_ima(:,:,2) = canti_ima(:,:,1);
        canti_ima(:,:,3) = canti_ima(:,:,1);
        image(canti_ima);
        axis off
        axis image
        
end


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
angle = get(hObject,'String');
angle = strrep(angle,',','.');
hObject.String = angle;
angle = str2double(angle);
if angle <= 0
    set(hObject,'String','17.5')
    warndlg('Angle must be a positive value','Error');
end

if isnan(angle)
    handles.edit1.String = '17.5';
    warndlg('Angle must be a numeric value!','Non numeric value error');
    return;
end


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pois_str = handles.edit5.String;
pois = str2double(pois_str);

switch handles.popupmenu1.Value
    case 1
        handles.options.tip_shape = 'four_sided_pyramid';
        switch handles.uibuttongroup1.SelectedObject.Tag 
            case 'angle_edge'
                angle = handles.edit1.String;
                angle = str2double(angle);
            case 'angle_face'
                angle = handles.edit1.String;
                angle = str2double(angle)*sqrt(2);
        end
        handles.options.tip_angle = angle;
        handles.options.cylinder_radius = NaN;
    case 2
        handles.options.tip_shape = 'flat_cylinder';
        radius_str = handles.diameter_flat_value.String;
        radius = str2double(radius_str);
        radius_cell = handles.diameter_flat_unit.String;
        radius_unit = radius_cell{handles.diameter_flat_unit.Value};
        switch radius_unit
            case 'm'
                handles.options.cylinder_radius = radius;
            case 'cm'
                handles.options.cylinder_radius = radius*1e-2;
            case 'mm'
                handles.options.cylinder_radius = radius*1e-3;
            case 'µm'
                handles.options.cylinder_radius = radius*1e-6;
            case 'nm'
                handles.options.cylinder_radius = radius*1e-9;
        end
        handles.options.tip_angle = NaN;
end


handles.options.poisson = pois;

guidata(hObject,handles);
uiresume(handles.figure1);




function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
pois = get(hObject,'String');
pois = strrep(pois,',','.');
hObject.String = pois;
pois = str2double(pois);

if isnan(pois)
    handles.edit5.String = 0.5;
    warndlg('Poisson ratio must be a numeric value!','Non numeric value error');
    return;
end




% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diameter_flat_value_Callback(hObject, eventdata, handles)
% hObject    handle to diameter_flat_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diameter_flat_value as text
%        str2double(get(hObject,'String')) returns contents of diameter_flat_value as a double

value_string = hObject.String;
value_string = strrep(value_string,',','.');
hObject.String = value_string;
value = str2double(value_string);
if isnan(value)
    hObject.String = '1.0';
end


% --- Executes during object creation, after setting all properties.
function diameter_flat_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diameter_flat_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in diameter_flat_unit.
function diameter_flat_unit_Callback(hObject, eventdata, handles)
% hObject    handle to diameter_flat_unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns diameter_flat_unit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from diameter_flat_unit


% --- Executes during object creation, after setting all properties.
function diameter_flat_unit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diameter_flat_unit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
