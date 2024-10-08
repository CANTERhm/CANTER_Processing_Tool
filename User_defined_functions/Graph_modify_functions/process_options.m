function [hObject,handles] = process_options(hObject,handles)
%%  PROCESS_OPTIONS: Function to alter the current curve by user-picked options 
%   
%   Updated infos: 
%   * Baseline: None, Offset, Offset + Tilt
%   * Processing type: automatic or curve-by-curve
% 

%% Code

c_string = sprintf('curve%u',handles.current_curve);
if strcmp(handles.options.tip_sample_correction,'yes')
    % Calculate the force from the given Calibration values and get original
    % x-values
    handles.proc_curves.(c_string).y_values = handles.curves.(c_string).y_values*handles.options.spring_const*handles.options.sensitivity*1e-9; %Save it as Newton
    handles.proc_curves.(c_string).x_values = handles.curves.(c_string).x_values;
end

% terminate processing if y_values or x_values are empty or scalar
if isscalar(handles.proc_curves.(c_string).y_values) || isscalar(handles.proc_curves.(c_string).x_values) ||...
        isempty(handles.proc_curves.(c_string).y_values) || isempty(handles.proc_curves.(c_string).x_values)

    handles.baselineedges(1,1) = NaN;
    handles.baselineedges(1,2) = NaN;
    handles.baselineedges(1,3) = NaN;
    return
end

% Correct the baseline by means of the elected option
switch handles.options.bihertz_baseline
    
    case 'none'         
        %Finds the baseline and save the edges
        [handles.baselineedges] = BaselineFinder(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values);
        
        % Adjust the Contact Point
        [handles.proc_curves.(c_string).x_values] = ContactPoint_via_intersec(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values, handles.baselineedges);
        
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
        [handles.proc_curves.(c_string).x_values] = ContactPoint_via_intersec(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values, handles.baselineedges);
        
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
        [handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).cpoint] = ContactPoint_via_intersec(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values, handles.baselineedges);
        
        % Tip Sample Separation
        if strcmp(handles.options.tip_sample_correction,'yes')
             [handles.proc_curves.(c_string).x_values] = Tip_Sample_Separation(handles.proc_curves.(c_string).x_values, handles);
        end
end

% post baseline processing can be inserted here
SelectedMode = handles.btngroup_contact.SelectedObject.String;
switch SelectedMode
    case 'via Hertz fit'
        perc_steps = str2double(handles.contact_percentage_hertz.String);
        
        [handles.proc_curves.(c_string).x_values] = ContactPoint_via_hertz(handles.proc_curves.(c_string).x_values, handles.proc_curves.(c_string).y_values, handles.baselineedges, handles,perc_steps);
end

guidata(hObject,handles);