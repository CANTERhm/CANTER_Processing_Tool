function [hObject,handles] = process_options(hObject,handles)
%%  PROCESS_OPTIONS: Function to alter the current curve by user-picked options 
%   
%   Updated infos: 
%   * Baseline: None, Offset, Offset + Tilt
%   * Processing type: automatic or curve-by-curve
% 

% Calculate the force from the given Calibration values
c_string = sprintf('curve%u',handles.current_curve);
handles.proc_curves.(c_string).y_values = handles.curves.(c_string).y_values*handles.options.sensitivity*handles.options.spring_const;

% Correct the baseline by means of the elected option
switch handles.options.bihertz_baseline
    
    case 'none'         
        %Finds the baseline and save the edges
        [handles.baselineedges] = BaselineFinder(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values);
        
        % Adjust the Contact Point
        [handles.proc_curves.(c_string).x_values] = ContactPoint(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values, handles.baselineedges, handles);
        
        % Tip Sample Separation
        if strcmp(handles.options.tip_sample_correction,'yes')
             [handles.proc_curves.(c_string).x_values] = Tip_Sample_Separation(handles.proc_curves.(c_string).x_values, handles);
        end
        
    case 'offset'
        %Finds the baseline and save the edges
        [handles.baselineedges] = BaselineFinder(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values, 'FitWindowSize', 10);
        
        % Correct the Offset
        [handles.proc_curves.(c_string).y_values] = OffsetCorrection(handles.proc_curves.(c_string).y_values, handles.baselineedges);
        
        % Adjust the Contact Point
        [handles.proc_curves.(c_string).x_values] = ContactPoint(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values, handles.baselineedges, handles);
        
        % Tip Sample Separation
        if strcmp(handles.options.tip_sample_correction,'yes')
             [handles.proc_curves.(c_string).x_values]= Tip_Sample_Separation(handles.proc_curves.(c_string).x_values, handles);
        end
        
    case 'offset_and_tilt'
        %Finds the baseline and save the edges
        [handles.baselineedges] = BaselineFinder(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values, 'FitWindowSize', 10);
        
        %Correct the Tilt
        [handles.proc_curves.(c_string).y_values] = TiltCorrection(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values, handles.baselineedges);
        
        % Correct the Offset
        [handles.proc_curves.(c_string).y_values] = OffsetCorrection(handles.proc_curves.(c_string).y_values, handles.baselineedges);
        
        % Adjust the Contact Point
        [handles.proc_curves.(c_string).x_values] = ContactPoint(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values, handles.baselineedges, handles);
        
        % Tip Sample Separation
        if strcmp(handles.options.tip_sample_correction,'yes')
             [handles.proc_curves.(c_string).x_values] = Tip_Sample_Separation(handles.proc_curves.(c_string).x_values, handles);
        end
end

guidata(hObject,handles);