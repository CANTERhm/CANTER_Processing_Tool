function [x_corrected]=ContactPoint(x, y, baseline_edges, handles)
% ContactPoint Shifts the whole curve in reference to the contact point
% (baseline_edges(1,2). The contact point becomes (0/0).

%Get the baseline via the baselineedges
x_fit = x(baseline_edges(1,1):baseline_edges(1,2));
y_fit = y(baseline_edges(1,1):baseline_edges(1,2));

% Fit the baseline
[p, ~] = polyfit(x_fit,y_fit,1);
y_linfit = polyval(p, x);

% Check how the contact point shell be found
SelectedMode = handles.btngroup_contact.SelectedObject.String;
switch SelectedMode
    case 'via intersection'
        % Get the intersection point of the baseline and the graph
        contactpoint = find(y-y_linfit <= 0, 1, 'last');

        % Set the contactpoint as 0/0
        x_corrected = x-(x(contactpoint));
    case 'via Hertz fit'
        % Get first the intersection point of the baseline and the graph
        contactpoint = find(y-y_linfit <= 0, 1, 'last');

        % Set the preliminar contactpoint as 0/0
        x_corrected = x-(x(contactpoint));

        %Fit a Hertz_fit to find the CP via linear approximation
        perc_steps = str2double(handles.contact_percentage_hertz.String);   
        [~,d_h,gof] = initial_guess_hard(x_corrected,y,(perc_steps),17.5,0.5,'plot','off');


        % Set the new contactpoint as 0/0
        x_corrected = x_corrected-d_h;
end

end