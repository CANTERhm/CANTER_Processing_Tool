function [x_corrected]=Tip_Sample_Separation(x,handles)
% Tip_Sample_Separation
c_string = sprintf('curve%u',handles.current_curve);

x_corrected = x+handles.proc_curves.(c_string).y_values./handles.options.spring_const;

end