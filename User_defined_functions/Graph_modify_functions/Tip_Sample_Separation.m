function [x_corrected]=Tip_Sample_Separation(x,handles)
% Tip_Sample_Separation
c_string = sprintf('curve%u',handles.current_curve);

for i=1:length(x)
    if i>handles.baselineedges(1,2)
        x_corrected(i) = x(i)-(handles.curves.(c_string).y_values(i)*handles.options.sensitivity)*1e-9;
    else
        x_corrected(i) = x(i);
    end
end
x_corrected = x_corrected';
end