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
if strcmp(SelectedMode, 'via intersection')
    % Get the intersection point of the baseline and the graph
    contactpoint = find(y-y_linfit <= 0, 1, 'last');
    
    % Set the contactpoint as 0/0
    x_corrected = x-(x(contactpoint));
else
    % Get first the intersection point of the baseline and the graph
    contactpoint = find(y-y_linfit <= 0, 1, 'last');
    
    % Set the contactpoint as 0/0
    x_corrected = x-(x(contactpoint));
    
    %Fit a Hertz_fit to find the CP via Hertz Fit
    perc_steps = 5;
    for i=1:19
        [E_h,d_h,gof] = initial_guess_hard(x_corrected,y,(perc_steps*i),17.5,0.5,'plot','off');
        error(i) = gof.rsquare;
        Distanz(i) = d_h/1e-6;
        x_corrected = x_corrected+d_h;

        d_ind = str2double(handles.hertz_fit_depth.String)*(-1)*1e-6;
        angle = handles.tip_angle;
        poisson = handles.poisson;
        % Hertz fit
        [EModul,gof_hertz,~,~] = HertzFit(x_corrected,y,d_ind,angle,poisson,handles);
        error_hertz(i) = gof_hertz.rsquare;
    end
    best_perc = perc_steps*find(max(error) == error);
    best_perc_hertz = perc_steps*find(max(error_hertz) == error_hertz);
    %%% Attention 
    test_figure_2 = figure;   %%%% this creates a new figure window for testing
    figure(test_figure_2);    %%%% and will be removed when everything is working properly!!!!!!!
    %%%% Attention
    [E_h,d_h,gof] = initial_guess_hard(x_corrected,y, best_perc,17.5,0.5,'plot','on');
    title('TEST-PLOT WILL BE REMOVED');
    msgbox(sprintf('Fitlength initial guess hard: %d%% Fitlength Hertz Fit: %d', best_perc, best_perc_hertz));
    % Set the new contactpoint as 0/0
    x_corrected = x_corrected+d_h;
end

end