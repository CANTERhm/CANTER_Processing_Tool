function varargout = Calibration(varargin)
%% LICENSE
% 
% 
% CANTER_Auswertetool: A tool for the data processing of force-indentation curves and more ...
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
    
    
%% CALIBRATION MATLAB code for Calibration.fig
%      CALIBRATION, by itself, creates a new CALIBRATION or raises the existing
%      singleton*.
%
%      H = CALIBRATION returns the handle to a new CALIBRATION or the handle to
%      the existing singleton*.
%
%      CALIBRATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CALIBRATION.M with the given input arguments.
%
%      CALIBRATION('Property','Value',...) creates a new CALIBRATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Calibration_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Calibration_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Calibration

% Last Modified by GUIDE v2.5 04-Jul-2018 15:59:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Calibration_OpeningFcn, ...
                   'gui_OutputFcn',  @Calibration_OutputFcn, ...
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


% --- Executes just before Calibration is made visible.
function Calibration_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Calibration (see VARARGIN)

% Choose default command line output for Calibration
handles.output = hObject;
handles.options = varargin{1};
handles.options.correction = [];

% Remember last sens. and spring const. values if available
if isfield(handles.options,'sensitivity') && isfield(handles.options,'spring_const')
   handles.sensitivity_value.String = sprintf('%.2f',handles.options.sensitivity);
   handles.spring_const_value.String = sprintf('%.4f',handles.options.spring_const);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Calibration wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Calibration_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.options;

% close calibration gui
delete(gcf)



function sensitivity_value_Callback(hObject, eventdata, handles)
% hObject    handle to sensitivity_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sensitivity_value as text
%        str2double(get(hObject,'String')) returns contents of sensitivity_value as a double
test = get(hObject,'String');
test = strrep(test,',','.');
hObject.String = test;
test = str2double(test);
if test <= 0
    set(hObject,'String','28.00')
    warndlg('Sensitivity must be a positive value','Error');
end

% --- Executes during object creation, after setting all properties.
function sensitivity_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sensitivity_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spring_const_value_Callback(hObject, eventdata, handles)
% hObject    handle to spring_const_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spring_const_value as text
%        str2double(get(hObject,'String')) returns contents of spring_const_value as a double
test = get(hObject,'String');
test = strrep(test,',','.');
hObject.String = test;
test = str2double(test);
if test <= 0
    set(hObject,'String','0.1400')
    warndlg('Spring constant must be a positive value','Error');
end


% --- Executes during object creation, after setting all properties.
function spring_const_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spring_const_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_submit.
function button_submit_Callback(hObject, eventdata, handles)
% hObject    handle to button_submit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sens = get(handles.sensitivity_value,'String');
sens = strrep(sens,',','.');

cons = get(handles.spring_const_value,'String');
cons = strrep(cons,',','.');

comp = (strcmp(sens,'28.00') || strcmp(cons,'0.1400')) && (strcmp(handles.correction_group.SelectedObject.Tag,'yes')) ;

% write selection to handles
handles.options.correction = handles.correction_group.SelectedObject.Tag;

sens = str2double(sens);

if isnan(sens)
    set(handles.sensitivity_value,'String','28.00');
    warndlg('Sensitivity must be a numeric value!','Non numeric value error');
    return;
end

cons = str2double(cons);

if isnan(cons)
    set(handles.spring_const_value,'String','0.1400');
    warndlg('Spring constant must be a numeric value!','Non numeric value error');
    return;
end
 
if comp
    answer = questdlg('Would you really like to work with a default value for sensitivity or/and spring constant?',...
                      'default value question','Yes','No','No');
    if strcmp(answer,'No')
        return;
    elseif strcmp(answer,'Yes')
        handles.options(:).sensitivity = 0;
        handles.options.sensitivity = sens;

        handles.options(:).spring_const = 0;
        handles.options.spring_const = cons;
        
        switch get(handles.correction_group.SelectedObject,'Tag')
        case 'yes'
            handles.options(:).tip_sample_correction = '';
            handles.options.tip_sample_correction = 'yes';
            
        case 'no'
            handles.options(:).tip_sample_correction = '';
            handles.options.tip_sample_correction = 'no';
        end
        guidata(hObject,handles);
        uiresume(handles.figure1);
    end
else
    handles.options(:).sensitivity = 0;
    if strcmp(handles.correction_group.SelectedObject.Tag,'yes')
        handles.options.sensitivity = sens;
    end

    handles.options(:).spring_const = 0;
    if strcmp(handles.correction_group.SelectedObject.Tag,'yes')
        handles.options.spring_const = cons;
    end
    
    switch get(handles.correction_group.SelectedObject,'Tag')
        case 'yes'           
            handles.options(:).tip_sample_correction = '';
            handles.options.tip_sample_correction = 'yes';
            
        case 'no'
            handles.options(:).tip_sample_correction = '';  
            handles.options.tip_sample_correction = 'no';
    end
    guidata(hObject,handles);
    uiresume(handles.figure1);
end


% --- Executes on key press with focus on button_submit and none of its controls.
function button_submit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to button_submit (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
button_submit_Callback(handles.button_submit, eventdata, handles)


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
c = get(hObject, 'CurrentCharacter');
switch c
    case 29
        set(handles.no,'Value',1);
        set(handles.yes,'Value',0);
    case 28
        set(handles.no,'Value',0);
        set(handles.yes,'Value',1);
end


% --- Executes on key press with focus on yes and none of its controls.
function yes_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to yes (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
            figure1_KeyPressFcn(handles.figure1,eventdata,handles)


% --- Executes on key press with focus on no and none of its controls.
function no_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to no (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
figure1_KeyPressFcn(handles.figure1,eventdata,handles)