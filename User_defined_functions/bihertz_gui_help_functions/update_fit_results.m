function [hObject,handles] = update_fit_results(hObject,handles)
%%  UPDATE_FIT_RESULTS: Function to update the displayed fit results in the 
%   bihertz gui.
switch handles.options.model
    case 'bihertz' 
        if handles.options.bihertz_variant == 1
             % variables
             E_s = handles.fit_results.fit_E_s*1e-3;
             E_h = handles.fit_results.fit_E_h*1e-3;
             d_h = handles.fit_results.fit_d_h*1e6;
             r_s = handles.fit_results.rsquare_fit;

             % write values to field
             handles.result_Es.String = sprintf('%3.2f',E_s);
             handles.result_Eh.String = sprintf('%3.2f',E_h);
             handles.result_dh.String = sprintf('%3.2f',d_h);
             handles.result_rsquare.String = sprintf('%1.4f',r_s);
             
        elseif handles.options.bihertz_variant == 2
             % variables
             E_s = handles.fit_results.fit_E_s*1e-3;
             E_h = handles.fit_results.fit_E_h*1e-3;
             d_h = handles.fit_results.fit_d_h*1e6;
             s_p = handles.fit_results.fit_s_p*1e6;
             r_s = handles.fit_results.rsquare_fit;

             % write values to field
             handles.result_Es.String = sprintf('%3.2f',E_s);
             handles.result_Eh.String = sprintf('%3.2f',E_h);
             handles.result_dh.String = sprintf('%3.2f',d_h);
             handles.result_switch_point.String = sprintf('%3.2f',s_p);
             handles.result_rsquare.String = sprintf('%1.4f',r_s);
             
        end
         
    case 'hertz'
        set(handles.hertz_EModul,'String', (sprintf('%.2f',(handles.fit_results.EModul/1000))));
        set(handles.hertz_gof,'String', (sprintf('%.2f', handles.fit_results.gof_rsquare)));
end

 
end
 