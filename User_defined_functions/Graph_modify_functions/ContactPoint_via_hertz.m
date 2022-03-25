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
    
   % Pre-estimate the contact point via intersect
   [x_corrected,~] = ContactPoint_via_intersec(x, y, baseline_edges);
    
    % when the optional parameter is empty, perc_steps will
    % be set to the defauld value of 20
    if isempty(varargin{1})
        perc_steps = 20;
    else
        perc_steps = varargin{1};
    end
    
    switch handles.tip_shape
        case 'four_sided_pyramid'
            % approximation and calculation of contact point via liniarized
            % hertz model
            [~,d_h,~] = initial_guess_hard(x_corrected,y,perc_steps,handles.tip_angle,handles.poisson,'plot','off');
        case 'flat_cylinder'
            % get contact point via polyfit on part of the negative curve
            % section
            x_min = min(x_corrected);
            poly_mask = x_corrected < (x_min - perc_steps/100*x_min);
            p = polyfit(x_corrected(poly_mask),y(poly_mask),1);
            d_h = roots(p);
    end

    % Set the new contactpoint as 0/0
    x_corrected = x_corrected-d_h;
    
    
