function [hObject,handles] = update_fit_results(hObject,handles)
%%  UPDATE_FIT_RESULTS: Function to update the displayed fit results in the 
%   bihertz gui.
switch handles.options.model
    case 'bihertz' 

        % get values
        E_s = handles.fit_results.fit_E_s;
        E_h = handles.fit_results.fit_E_h;
        d_h = handles.fit_results.fit_d_h;
        r_s = handles.fit_results.rsquare_fit;

        % determine order of magnitude
        ord_E_s = floor(log10(E_s));
        ord_E_h = floor(log10(E_h));
        ord_d_h = floor(log10(d_h));

        % format value and unit for E_s
        if ord_E_s < 3 || ord_E_s >= 12
            corr_E_s = E_s;
            unit_E_s = 'Pa';
        elseif ord_E_s >= 3 && ord_E_s < 6
            corr_E_s = E_s * 1e-3;
            unit_E_s = 'kPa';
        elseif ord_E_s >=6 && ord_E_s < 9
            corr_E_s = E_s * 1e-6;
            unit_E_s = 'MPa';
        elseif ord_E_s >=9 && ord_E_s < 12
            corr_E_s = E_s * 1e-9;
            unit_E_s = 'GPa';
        end
        % write value and unit of E_s to corresponding fields
        handles.result_Es.String = sprintf('%3.2f',corr_E_s);
        handles.text14.String = unit_E_s;

        % format value and unit of E_h
        if ord_E_h < 3 || ord_E_h >= 12
            corr_E_h = E_h;
            unit_E_h = 'Pa';
        elseif ord_E_h >= 3 && ord_E_h < 6
            corr_E_h = E_h * 1e-3;
            unit_E_h = 'kPa';
        elseif ord_E_h >=6 && ord_E_h < 9
            corr_E_h = E_h * 1e-6;
            unit_E_h = 'MPa';
        elseif ord_E_h >=9 && ord_E_h < 12
            corr_E_h = E_h * 1e-9;
            unit_E_h = 'GPa';
        end
        % write value and unit of E_h to corresponding fields
        handles.result_Eh.String = sprintf('%3.2f',corr_E_h);
        handles.text17.String = unit_E_h;

        % format value and unit of d_h
        if ord_d_h >= -12 && ord_d_h < -9
            corr_d_h = d_h * 1e12;
            unit_d_h = 'pm';
        elseif ord_d_h >= -9 && ord_d_h < -6
            corr_d_h = d_h * 1e9;
            unit_d_h = 'nm';
        elseif ord_d_h >= -6 && ord_d_h < -3
            corr_d_h = d_h * 1e6;
            unit_d_h = 'µm';
        elseif ord_d_h >= -3 && ord_d_h < 0
            corr_d_h = d_h * 1e3;
            unit_d_h = 'mm';
        else
            corr_d_h = d_h;
            unit_d_h = 'm';
        end
        % write value and unit of d_h to corresponding fields
        handles.result_dh.String = sprintf('%3.2f',corr_d_h);
        handles.text20.String = unit_d_h;

        % write rsquare value to edit field
        handles.result_rsquare.String = sprintf('%.4f',r_s);
                
        % if the bihertz_variant 2 is used, also the switch point value
        % has to be updated in the GUI
        if handles.options.bihertz_variant == 2
            % get value of s_p
            s_p = handles.fit_results.fit_s_p;
            
            % determine order of magnitude of s_p
            ord_s_p = floor(log10(s_p));
            
            % correct value and set unit of s_p
            if ord_s_p >= -12 && ord_s_p < -9
                corr_s_p = s_p * 1e12;
                unit_s_p = 'pm';
            elseif ord_s_p >= -9 && ord_s_p < -6
                corr_s_p = s_p * 1e9;
                unit_s_p = 'nm';
            elseif ord_s_p >= -6 && ord_s_p < -3
                corr_s_p = s_p * 1e6;
                unit_s_p = 'µm';
            elseif ord_s_p >= -3 && ord_s_p < 0
                corr_s_p = s_p * 1e3;
                unit_s_p = 'mm';
            else
                corr_s_p = s_p;
                unit_s_p = 'm';
            end
            
            % set value and unit of s_p to corresponding fields
            handles.result_switch_point.String = sprintf('%3.2f',corr_s_p);
            handles.text71.String = unit_s_p;
        end
         
    case 'hertz'
        
            % get values
            EModul = handles.fit_results.EModul;
            rsquare = handles.fit_results.gof_rsquare;
            
            % get order of magnitude of Young's modulus
            ord_EModul = floor(log10(EModul));
            
            % format value and unit for Young's modulus
            if ord_EModul < 3 || ord_EModul >= 12 || isnan(ord_EModul)
                corr_EModul = EModul;
                unit_EModul = 'Pa';
            elseif ord_EModul >= 3 && ord_EModul < 6
                corr_EModul = EModul * 1e-3;
                unit_EModul = 'kPa';
            elseif ord_EModul >=6 && ord_EModul < 9
                corr_EModul = EModul * 1e-6;
                unit_EModul = 'MPa';
            elseif ord_EModul >=9 && ord_EModul < 12
                corr_EModul = EModul * 1e-9;
                unit_EModul = 'GPa';
            end
            
            % set values
            handles.hertz_EModul.String = sprintf('%.2f',corr_EModul);
            handles.hertz_gof.String = sprintf('%.4f',rsquare);
            
            % set unit
            handles.text49.String = unit_EModul;

            % write contact point
            if strcmp(handles.tip_shape,"flat_cylinder")
                if isfield(handles.fit_results,"hertz_contact_point")
                    CP_Fit = handles.fit_results.hertz_contact_point;
                    if isnan(CP_Fit) || isinf(CP_Fit) || isempty(CP_Fit)
                       handles.ContactPointField.Value = 0.00;
                       handles.CP_unit_label.Text = "nm";
                     else
                        [CPNumber,~,CPUnit,~] = get_order_of_magnitude(handles.fit_results.hertz_contact_point,"m");
                        handles.ContactPointField.Value = CPNumber;
                        handles.CP_unit_label.Text = CPUnit;
                    end
                else
                    handles.ContactPointField.Value = 0.00;
                    handles.CP_unit_label.Text = "nm";
                end
            end
                
end

 
end
 