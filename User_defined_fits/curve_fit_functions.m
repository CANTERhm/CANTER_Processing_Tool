function [hObject,handles] = curve_fit_functions(hObject,handles, varargin)
%%  CURVE_FIT_FUNCTIONS: Function to process the fit choosen by the user
% 
%   Example:
%   [hObject,handles] = curve_fit_functions(hObject,handles)
%
%   *BIHERTZ_FIT* : Function for the bihertz gui to do the bihertz fit on
%   the processed data, plot the fit-curve on the main plot window and
%   provide the fit results in the struct handles.fitResults.
% 
%   All fit Results are provided in the handles handle in the struct 'fit_results'
%   It contains:
%   * initial_E_s -> initial guess for E_s
%   * gof_soft -> goodness of initial soft guess fit (for mor information see: 'Evaluate a Curve Fit')
%   * initial_E_h -> initial guess fot E_h
%   * initial_d_h -> initial guess fot d_h
%   * gof_hard -> goodness of initial hard guess fit (for mor information see: 'Evaluate a Curve Fit')
%   * fit_E_s -> fitresult for E_s
%   * fit_E_h -> fitresult for E_h
%   * fit_d_h -> fitresult for d_h
%   * rsqare_fit -> R^2 of bihertz fit
%   And in case of the bihertz_split_heavyside fit model also:
%   * initial_s_p
%   * fit_s_p
%
%   *HERTZ_FIT* : Function for the bihertz gui to do the Hertz fit on
%   the processed data, plot the fit-curve on the main plot window and
%   provide the fit results in the struct handles.fitResults.
%
%   *   EModul --> fitresult of the Hertzfit
%   *   gof_rsquare --> shows the goodness of fit as rsquare 
% 

%%

% warning off;

% error handling for fit functions - please enter error handling procedure
% in the catch block of the try error handling when a new fit function was
% added.

try

    item = handles.options.model;
    switch item

        % BiHertz_Fit
        case 'bihertz'
            if strcmp(handles.tip_shape,'four_sided_pyramid')
                % variables and structs
                options = handles.options;
                curve_ind = handles.current_curve;
                curves = handles.curves;

                c_string = sprintf('curve%u',curve_ind);
                x_fit = handles.proc_curves.(c_string).x_values;
                y_fit = handles.proc_curves.(c_string).y_values;
                d_ind = str2double(handles.fit_depth.String)*(-1)*1e-6;
                fit_perc = str2double(handles.fit_perc.String);
                angle = handles.tip_angle;
                poisson = handles.poisson;

                %initial soft guess
                [E_s,gof_soft] = initial_guess_soft(x_fit,y_fit,d_ind,angle,poisson);
                % initial hard guess
                [E_h,d_h,gof_hard] = initial_guess_hard(x_fit,y_fit,fit_perc,angle,poisson,'plot','off');
                % bihertz fit with initial guesses
                par0(1) = E_s;
                par0(2) = E_h;
                par0(3) = d_h;

                % get user answer regarding displaying fits
                answer_display = [];
                if nargin == 3
                    answer_display = varargin{1};
                end


                switch handles.options.bihertz_variant
                    case 1
                        [fit,~,~,~,~,Rs] = bihertz_sum_heaviside(x_fit,y_fit,par0,angle,poisson,'plot','off');
                        % add fit to main plot window
                        if strcmp(answer_display, 'Yes') || isempty(answer_display)
                            figure(handles.figures.main_fig)
                            hold(handles.figures.main_ax,'on');
                            func = @(par,d)tan(angle.*pi/180)/(2*(1-poisson.^2))*par(1).*d.^2+tan(angle.*pi/180)/(2.*(1-poisson^2)).*((heaviside(d-par(3))-1)*(-1)).*par(2).*(d-par(3)).^2;
                            mask = x_fit < 0;
                            y_plot(length(x_fit)) = 0;
                            x_draw = x_fit(mask);
                            y_plot(mask) = func(fit,x_draw);
                            try
                                delete(handles.figures.fit_plot)
                            catch 
                                %nix%
                            end
                            handles.figures.fit_plot = plot(x_fit.*1e6,y_plot.*1e9','r-');
                            drawnow;
                            hold(handles.figures.main_ax,'off');

                        end

                        % saving fit results in handles
                        handles.fit_results = struct('initial_E_s',E_s,'gof_soft',gof_soft,...
                            'initial_E_h',E_h,'initial_d_h',d_h,'gof_hard',gof_hard,...
                            'fit_E_s',fit(1),'fit_E_h',fit(2),'fit_d_h',fit(3),'rsquare_fit',Rs);
                        guidata(hObject,handles);

                    case 2
                        [fit,~,~,~,~,Rs,init_s_p] = bihertz_split_heaviside(x_fit,y_fit,par0,angle,poisson,'plot','off');
                        % add fit to main plot window
                        if strcmp(answer_display, 'Yes') || isempty(answer_display)
                            figure(handles.figures.main_fig)
                            hold(handles.figures.main_ax,'on');
                            func = @(par,d)tan(angle.*pi/180)/(2.*(1-poisson^2)).*heaviside(d-par(4)).*par(1).*d.^2 ...
                                          +tan(angle.*pi/180)/(2.*(1-poisson^2)).*(heaviside(d-par(4))-1).*(-1).*par(2).*(d-par(3)).^2;
                            mask = x_fit < 0;
                            y_plot(length(x_fit)) = 0;
                            x_draw = x_fit(mask);
                            y_plot(mask) = func(fit,x_draw);
                            try
                                delete(handles.figures.fit_plot)
                            catch 
                                %nix%
                            end
                            handles.figures.fit_plot = plot(x_fit.*1e6,y_plot.*1e9','r-');
                            drawnow;
                            hold(handles.figures.main_ax,'off');
                        end

                        % saving fit results in handles
                        handles.fit_results = struct('initial_E_s',E_s,'gof_soft',gof_soft,...
                            'initial_E_h',E_h,'initial_d_h',d_h,'initial_s_p',init_s_p,'gof_hard',gof_hard,...
                            'fit_E_s',fit(1),'fit_E_h',fit(2),'fit_d_h',fit(3),'fit_s_p',fit(4),'rsquare_fit',Rs);
                        guidata(hObject,handles);
                end
            end




        % Hertz_Fit
        case 'hertz'
            % variables and structs
            curve_ind = handles.current_curve;

            c_string = sprintf('curve%u',curve_ind);
            x_fit = handles.proc_curves.(c_string).x_values;
            y_fit = handles.proc_curves.(c_string).y_values;
            d_ind = str2double(handles.hertz_fit_depth.String)*(-1)*1e-6;
            fit_start = str2double(handles.hertz_fit_start.String)*(-1)*1e-6;
            switch handles.tip_shape
                case 'four_sided_pyramid'
                    indenter_value = handles.tip_angle;
                case 'flat_cylinder'
                    indenter_value = handles.cylinder_radius;
            end
            poisson = handles.poisson;

            % Hertz fit
            [EModul,gof,x_fit, y_plot,handles.fit_results.hertz_contact_point] = HertzFit(x_fit,y_fit,fit_start,d_ind,handles.tip_shape,indenter_value,poisson);

            %Save fitresults in handles
            handles.fit_results.EModul = EModul;
            handles.fit_results.gof_rsquare = gof.rsquare;

            %Fit is always shown only when in "keep and apply to all" it is
            %denied
            answer_display = 'Yes';
            if nargin == 3
                answer_display = varargin{1};
            end

            if strcmp(answer_display, 'Yes')
                % add fit to main plot window
                hold(handles.figures.main_ax,'on');
                try
                    delete(handles.figures.fit_plot)
                catch 
                    %nix%
                end
                handles.figures.fit_plot = plot(handles.figures.main_ax,x_fit*1e6,y_plot*1e9,'r-');
                [hObject,handles] = plot_hertz(hObject,handles);
                hold(handles.figures.main_ax,'off');
            else
            end

    end

    warning on;
    
catch ME
    % error handling in case of fit errors (e.g. when to few points are handed to a fit function)
    switch handles.options.model
        case 'bihertz'
            switch handles.options.bihertz_variant
                case 1
                    handles.fit_results = struct('initial_E_s',NaN,'gof_soft',NaN,...
                            'initial_E_h',NaN,'initial_d_h',NaN,'gof_hard',NaN,...
                            'fit_E_s',NaN,'fit_E_h',NaN,'fit_d_h',NaN,'rsquare_fit',NaN);
                    warning('No fit was possible on curve %d.\nAll fit results are NaN for this curve!',handles.current_curve);
                    guidata(hObject,handles);
                case 2
                    handles.fit_results = struct('initial_E_s',NaN,'gof_soft',NaN,...
                            'initial_E_h',NaN,'initial_d_h',NaN,'initial_s_p',NaN,'gof_hard',NaN,...
                            'fit_E_s',NaN,'fit_E_h',NaN,'fit_d_h',NaN,'fit_s_p',NaN,'rsquare_fit',NaN);
                    warning('No fit was possible on curve %d.\nAll fit results are NaN for this curve!',handles.current_curve);
                    guidata(hObject,handles);
            end
        case 'hertz'
            handles.fit_results.EModul = NaN;
            handles.fit_results.gof_rsquare = NaN;
            warning('No fit was possible on curve %d.\nAll fit results are NaN for this curve!',handles.current_curve);
        otherwise
            errordlg(sprintf('Please implement a fit-error handling for this fit-function in ''curve_fit_functions.m''\nError in line %d\n%s\n%s',ME.stack.line,ME.identifier,ME.message));
    end
end

guidata(hObject,handles);
