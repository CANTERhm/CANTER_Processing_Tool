function [x_corrected]=ContactPoint_via_hertz(x, y, baseline_edges, handles,varargin)
    %%  ContactPoint_via_hertz: A function to shift the contact point of a
    %   force-indentation curve into the calculated minimum of a linear
    %   approximation of the hertz model fitted to the last percentage of
    %   the force curve.
    % 
    %   [x_corrected] = ContactPoint_via_hertz(x, y, baseline_edges, handles,perc_steps)
    %  
    %   perc_steps is a optional parameter
    %   when not set: -> default value = 10
    
    %% Code
    
    % Get the baseline via the baselineedges
    x_fit = x(baseline_edges(1,1):baseline_edges(1,2));
    y_fit = y(baseline_edges(1,1):baseline_edges(1,2));

    % Fit the baseline
    [p, ~] = polyfit(x_fit,y_fit,1);
    y_linfit = polyval(p, x);
    
    % Get first the intersection point of the baseline and the graph
    contactpoint = find(y-y_linfit <= 0, 1, 'last')+1;

    % Set the preliminar contactpoint as 0/0
    x_corrected = x-(x(contactpoint));  
    
    % when the optional parameter is empty, perc_steps will
    % be set to the defauld value of 20
    if isempty(varargin{1})
        perc_steps = 20;
    else
        perc_steps = varargin{1};
    end

    % approximation and calculation of contact point via liniarized
    % hertz model
    [~,d_h,~] = initial_guess_hard(x_corrected,y,perc_steps,handles.tip_angle,handles.poisson,'plot','off');

    % Set the new contactpoint as 0/0
    x_corrected = x_corrected-d_h;
    
    
