function [varargout] = CANTER_Auswertetool(varargin)
% CANTER_AUSWERTETOOL MATLAB code for CANTER_Auswertetool.fig
%      CANTER_AUSWERTETOOL, by itself, creates a new CANTER_AUSWERTETOOL or raises the existing
%      singleton*.
%
%      H = CANTER_AUSWERTETOOL returns the handle to a new CANTER_AUSWERTETOOL or the handle to
%      the existing singleton*.
%
%      CANTER_AUSWERTETOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CANTER_AUSWERTETOOL.M with the given input arguments.
%
%      CANTER_AUSWERTETOOL('Property','Value',...) creates a new CANTER_AUSWERTETOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CANTER_Auswertetool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CANTER_Auswertetool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CANTER_Auswertetool

% Last Modified by GUIDE v2.5 02-Jul-2018 15:23:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CANTER_Auswertetool_OpeningFcn, ...
                   'gui_OutputFcn',  @CANTER_Auswertetool_OutputFcn, ...
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


% --- Executes just before CANTER_Auswertetool is made visible.
function CANTER_Auswertetool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CANTER_Auswertetool (see VARARGIN)

% Choose default command line output for CANTER_Auswertetool
handles.output = hObject;

% Update handles structure
handles.options = struct([]);
guidata(hObject, handles);

% UIWAIT makes CANTER_Auswertetool wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CANTER_Auswertetool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.options;
delete(gcf);



% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
list_check = get(hObject,'Value');

switch list_check
    case 1
        handles.bihertz_options.Visible = 'on';
        handles.lateral_description.Visible = 'off';
    case 2
        handles.bihertz_options.Visible = 'on';
        handles.lateral_description.Visible = 'off';
    case 3
        handles.bihertz_options.Visible = 'off';
        handles.lateral_description.Visible = 'off';
    case 4
        handles.bihertz_options.Visible = 'off';
        handles.lateral_description.Visible = 'off';
    case 5
        handles.bihertz_options.Visible = 'off';
        handles.lateral_description.Visible = 'off';
    case 6
        handles.bihertz_options.Visible = 'off';
        handles.lateral_description.Visible = 'off';
    case 7
        handles.bihertz_options.Visible = 'off';
        handles.lateral_description.Visible = 'on';
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --------------------------------------------------------------------
function menu_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function help_readme_Callback(hObject, eventdata, handles)
% hObject    handle to help_readme (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in bihertz_buttongroup_processing.
function bihertz_buttongroup_processing_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in bihertz_buttongroup_processing 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch get(handles.listbox1,'Value')
    case 1
        handles.options = struct('list_object',1,'model','bihertz','bihertz_processing','','bihertz_baseline','',...
                                 'bihertz_results','','bihertz_save','');
        handles.options.bihertz_processing = 'automatic';
        handles.options.bihertz_baseline = 'offset_and_tilt';
        handles.options.bihertz_results = 'no';
        handles.options.bihertz_save = 'dont_save';
 
    case 2
        handles.options = struct('list_object',2,'model','hertz','bihertz_processing','','bihertz_baseline','',...
                                 'bihertz_results','','bihertz_save','');
        handles.options.bihertz_processing = 'automatic';
        handles.options.bihertz_baseline = 'offset_and_tilt';
        handles.options.bihertz_results = 'no';
        handles.options.bihertz_save = 'dont_save';
    case 3
        
    case 4
        
    case 5
        
    case 6
        
    case 7
        handles.options = struct('list_object',7);
end
    

guidata(hObject,handles);
uiresume(gcf);

% --- The new CloseRequestFcn
function figure1_CloseRequestFcn(hObjects,eventdata,handles)
menu_exit_Callback(handles.menu_exit, eventdata, handles)

% global bihertz_options.processing = get(handles.bihertz_buttongroup_processing,'SelectedObject');
