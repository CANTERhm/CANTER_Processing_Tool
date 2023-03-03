classdef SaderMethodCalibration_GUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        GridLayout                   matlab.ui.container.GridLayout
        GridLayout7                  matlab.ui.container.GridLayout
        ParametersPanel              matlab.ui.container.Panel
        GridLayout8                  matlab.ui.container.GridLayout
        GridLayout13                 matlab.ui.container.GridLayout
        CantileverDropDown           matlab.ui.control.DropDown
        UsedCantileverLabel          matlab.ui.control.Label
        GridLayout12                 matlab.ui.container.GridLayout
        Viscosity                    matlab.ui.control.NumericEditField
        PasLabel                     matlab.ui.control.Label
        ViscosityofSurroundingLabel  matlab.ui.control.Label
        GridLayout11                 matlab.ui.container.GridLayout
        Density                      matlab.ui.control.NumericEditField
        kgm3Label                    matlab.ui.control.Label
        DensityofSurroundingLabel    matlab.ui.control.Label
        GridLayout10                 matlab.ui.container.GridLayout
        CantiLength                  matlab.ui.control.NumericEditField
        mLabel_2                     matlab.ui.control.Label
        CantileverLengthLabel        matlab.ui.control.Label
        GridLayout9                  matlab.ui.container.GridLayout
        CantiWidth                   matlab.ui.control.NumericEditField
        mLabel                       matlab.ui.control.Label
        CantileverWidthLabel         matlab.ui.control.Label
        CalculateButton              matlab.ui.control.Button
        LoadAmplitudeSweepButton     matlab.ui.control.Button
        GridLayout2                  matlab.ui.container.GridLayout
        ResultsPanel                 matlab.ui.container.Panel
        GridLayout3                  matlab.ui.container.GridLayout
        ExporttoTextFileButton       matlab.ui.control.Button
        GridLayout6                  matlab.ui.container.GridLayout
        Spring_Const_Result          matlab.ui.control.NumericEditField
        NmLabel                      matlab.ui.control.Label
        GridLayout5                  matlab.ui.container.GridLayout
        Q_Fac_Result                 matlab.ui.control.NumericEditField
        GridLayout4                  matlab.ui.container.GridLayout
        kHzLabel                     matlab.ui.control.Label
        Res_Frequ_Result             matlab.ui.control.NumericEditField
        SpringConstantLabel          matlab.ui.control.Label
        QFactorLabel                 matlab.ui.control.Label
        ResonanceFrequencyLabel      matlab.ui.control.Label
        Spectrum_Axes                matlab.ui.control.UIAxes
    end

    
    properties (Access = public)
        SweepLoaded = false % Shows if an amplitude sweep is loaded.
        Sweep_struct = struct();
        x_sweep = []; % Vector that stores the x-coordinate of the laoded amplitude sweep.
        y_sweep = []; % Vector that stores the y-coordinate of the laoded amplitude sweep.
        x_SIunit = ""; % SI unit of the x-coordinate.
        y_SIunit = ""; % SI unit of the y-coordinate.
        x_unit = ""; % Unit of the x-coordinate with corresponding prefix.
        y_unit = ""; % Unit of the y-coordinate with corresponding prefix.
        x_OoM = []; % Order of Magnitude of the x-coordinate.
        y_OoM = []; % Order of Magnitude of the y-coordinate.
        x_spline = []; % Vector that stores the x-coordinate of the interpolating spline.
        y_spline = []; % Vector that stores the y-coordinate of the interpolating spline.
        CWidth = 40e-6;
        CLength = 160e-6;
        density = 1.18;
        viscosity = 1.86e-5;
        Res_Frequ = 0; % Determined value of the resonance frequency.
        Q_Fac = 0; % Determined value of the Q-Factor.
        Spring_Const = 0; % Determined value of the spring constant.
        A_max = 0; % Maximum of resonance curve.
        A_half_power = 0; % A_max/sqrt(2).
        f1 = 0; % Left frequency at FWHPM (Full Width at Half Power Maximum).
        f2 = 0; % Right frequency at FWHPM.
        hydrodynamic_function = 0; % Calculated hydrodynamic function of the rectangular Cantilever.
        hydrodynamic_function_imag_part = 0; % Imaginary part of the hydrodynamic function.
    end
    
    methods (Access = public)
        function out_struct = LoadSweepFile(~,file_path)
            
            out_struct = [];

            file_ID = fopen(file_path,"r");
            for i = 1:11
                
                header(i,1) = string(fgetl(file_ID));
                
            end
            
            header(1) = [];
            header(end) = [];
            header = strrep(header,"# ","");
            header = split(header,": ");
            
            length_mask = strcmp(header(:,1),"length");
            length_info = header(length_mask,:);
            header(length_mask,:) = [];
            channel_info = header(end-1:end,:);
            header(end-1:end,:) = [];
            
            field_names = header(:,1);
            field_values = header(:,2);
            field_values = split(field_values," ");
            field_names = field_names + "_" + field_values(:,2);
            field_values = field_values(:,1);
            field_values_dbl = str2double(field_values);
            
            for i = 1:length(field_names)
                
                curr_field = field_names(i);
                curr_value = field_values_dbl(i);
                
                out_struct.(curr_field) = curr_value;
                
            end
            
            out_struct.(length_info(1,1)) = str2double(length_info(1,2));
            
            channel_values_cell = textscan(file_ID,"%f %f %f","Delimiter"," ");
            channel_values  = cell2mat(channel_values_cell);
            
            column_names = split(channel_info(1,2),char(9));
            column_names = strrep(column_names," ","_");
            column_names = matlab.lang.makeValidName(column_names);
            
            units = split(channel_info(2,2),char(9));
            
            column_names = column_names + "_" + units;
            out_struct.units = units;
            
            Vec_Table = table(channel_values(:,1),channel_values(:,2),channel_values(:,3),'VariableNames',column_names);
            
            out_struct.channels = Vec_Table;
            fclose(file_ID);
        end
        function Calculate_fr_andQ(app,x_spec,y_spec)
            
            x_plot = x_spec;
            y_plot = y_spec;
                
            % interpolate data using spline
            pp = spline(x_plot,y_plot);
            app.x_spline = linspace(min(x_plot),max(x_plot),2000);
            app.y_spline = ppval(pp,app.x_spline);
        
            % determining resonance frequency
            [app.A_max,A_max_idx] = max(app.y_spline);
            f_max = app.x_spline(A_max_idx);
        
            % determining the f1 and f2 at A_max/sqrt(2)
            A_delta = app.A_max/sqrt(2);
            app.A_half_power = A_delta;
        
            x_f1 = app.x_spline(app.x_spline<f_max);
            y_f1 = app.y_spline(app.x_spline<f_max)-A_delta;
            x_f2 = app.x_spline(app.x_spline>f_max);
            y_f2 = app.y_spline(app.x_spline>f_max)-A_delta;
        
            [~,f1_idx] = min(abs(y_f1));
            [~,f2_idx] = min(abs(y_f2));
        
            app.f1 = x_f1(f1_idx);
            app.f2 = x_f2(f2_idx);
        
            delta_f = app.f2-app.f1;
            app.Res_Frequ = f_max;
            app.Q_Fac = f_max/delta_f;
            
        end
        function hydro_func_rec = CalculateRecHydrodynamicFunctionAir(~,f_res,beam_width,density,viscosity)
                        
            % calculating Reynolds number
            radial_frequency = 2*pi*f_res; % w = 2*pi*f;
            Re = (density*radial_frequency*beam_width^2)/(4*viscosity);
            
            % Calculating the cyrcular hydrodynamic function
            x = -1i*sqrt(1i*Re);
            hydro_cyrc = 1+(4i*besselk(1,x))/(sqrt(1i*Re)*besselk(0,x));
            
            
            % Calulation of the correction factor to the hydrodynamic function
            % for rectangular objects
            
            % parameters of real and imaginary part of the correctio factor
            % -> from: Sader, J.E., J.Appl.Phys, 84,64 (1998).
            
            % calculating tau
            tau = log10(Re);
             
            
            % Real part
            
            % parameters of the numerator
            n0 = 0.91324;
            n1 = -0.48274;
            n2 = 0.46842;
            n3 = -0.12886;
            n4 = 0.044055;
            n5 = -0.0035117;
            n6 = 0.00069085;
            
            % parameters of the denuminator
            d1 = -0.56964;
            d2 = 0.48690;
            d3 = -0.13444;
            d4 = 0.045155;
            d5 = -0.0035862;
            d6 = 0.00069085;
            
            % calculation of the real part of the hydrodynamic function
            real_corr_fac_air = (n0+n1*tau+n2*tau^2+n3*tau^3+n4*tau^4+n5*tau^5+n6*tau^6)/...
                              (1+d1*tau+d2*tau^2+d3*tau^3+d4*tau^4+d5*tau^5+d6*tau^6);
            
            % Imaginary part
                  
            % parameters of the numerator
            n0 = -0.024134;
            n1 = -0.029256;
            n2 = 0.016294;
            n3 = -0.00010961;
            n4 = 0.000064577;
            n5 = -0.000044510;
            
            % parameters of the denuminator
            d1 = -0.59702;
            d2 = 0.55182;
            d3 = -0.18357;
            d4 = 0.079156;
            d5 = -0.014369;
            d6 = 0.0028361;
            
            % calculation of the imaginary part of the hydrodynamic function
            imag_corr_fac_air = (n0+n1*tau+n2*tau^2+n3*tau^3+n4*tau^4+n5*tau^5)/...
                              (1+d1*tau+d2*tau^2+d3*tau^3+d4*tau^4+d5*tau^5+d6*tau^6);
        
            % correctio factor
            corr_factor = real_corr_fac_air +1i*imag_corr_fac_air;
            
            % The rectangular hydrodynamic function in air
            hydro_func_rec = hydro_cyrc * corr_factor;
            
        end
        function spring_constant = SaderSpingConst(~,canti_length,canti_width,Q_factor,f_r,density,Gamma_i)
            
            % Equation parameters
            b = canti_width;
            L = canti_length;
            w_f = 2*pi*f_r;
            Q = Q_factor;
                        
            % spring constant - Sader method
            spring_constant = 0.1906 * density * b^2 * L * Q * Gamma_i * w_f^2;
            
        end
        function staticSpringConst = NewSaderSpringConst(~,canti_length,canti_width,Q_factor,f_res,density,viscosity,a0,a1,a2,C)
            
            % New Sader Method corrected for certain cantilever shapes:
            % From: Sader, et al., Rev. Sci. Instrum., 83, 103705 (2012)
            
            % simple names
            L = canti_length;
            b = canti_width;
            w_res = 2.*pi.*f_res;
            rho = density;
            mu = viscosity;
            
            % Reynold's number
            Re = (rho.*b.^2.*w_res)./(4.*mu);
            
            % simple hydrodynamic function
            Lambda = a0.*Re.^(a1+a2.*log10(Re));
            
            % dynamic spring constant
            dynamicSpringConst = rho.*b.^2.*L.*Lambda.*w_res.^2.*Q_factor;
            
            % static spring constant
            staticSpringConst = dynamicSpringConst./C;
            
        end
        
        function [f_val,f_OoM,f_unit] = OoM_Frequency(~,val)
            OoM = floor(log10(val));
            multi3 = int32(floor(OoM/3));
            f_OoM = 3*multi3;
            f_val = val/double(10^(f_OoM));
            switch multi3
                case 0
                    f_unit = "Hz";
                case 1
                    f_unit = "kHz";
                case 2
                    f_unit = "MHz";
                case 3
                    f_unit = "GHz";
                case 4
                    f_unit = "THz";
                otherwise
                    f_val = val;
                    f_OoM = 0;
                    f_unit = "Hz";
            end
        end
        
        function [x_OoM,x_new_unit,y_OoM,y_new_unit] = OoM_x_and_y(~,x_data,x_unit,y_data,y_unit)
            x_determinator = max([max(x_data),abs(min(x_data))]);
            x_OoM = floor(floor(log10(abs(x_determinator)))/3)*3;

            y_determinator = max([max(y_data),abs(min(y_data))]);
            y_OoM = floor(floor(log10(abs(y_determinator)))/3)*3;

            switch int32(x_OoM)
                case -15
                    x_new_unit = "f" + x_unit;
                case -12
                    x_new_unit = "p" + x_unit;
                case -9
                    x_new_unit = "n" + x_unit;
                case -6
                    x_new_unit = "µ" + x_unit;
                case -3
                    x_new_unit = "m" + x_unit;
                case 0
                    x_new_unit = x_unit;
                case 3
                    x_new_unit = "k" + x_unit;
                case 6
                    x_new_unit = "M" + x_unit;
                case 9
                    x_new_unit = "G" + x_unit;
                case 12
                    x_new_unit = "T" + x_unit;
                case 15
                    x_new_unit = "P" + x_unit;
            end
            switch int32(y_OoM)
                case -15
                    y_new_unit = "f" + y_unit;
                case -12
                    y_new_unit = "p" + y_unit;
                case -9
                    y_new_unit = "n" + y_unit;
                case -6
                    y_new_unit = "µ" + y_unit;
                case -3
                    y_new_unit = "m" + y_unit;
                case 0
                    y_new_unit = y_unit;
                case 3
                    y_new_unit = "k" + y_unit;
                case 6
                    y_new_unit = "M" + y_unit;
                case 9
                    y_new_unit = "G" + y_unit;
                case 12
                    y_new_unit = "T" + y_unit;
                case 15
                    y_new_unit = "P" + y_unit;
            end
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadAmplitudeSweepButton
        function LoadAmplitudeSweepButtonPushed(app, event)
            [file,path] = uigetfile("*.sweep","Select a sweep file","MultiSelect","off");
            
            % Return if user cancels 
            if file == 0
                return;
            end
            full_path = fullfile(path,file);
            % load the sweep
            app.Sweep_struct = LoadSweepFile(app,full_path);
            
            % Delete previous results
            app.Res_Frequ_Result.Value = 0;
            app.Q_Fac_Result.Value = 0;
            app.Spring_Const_Result.Value = 0;
            
            % write sweep values to properties
            app.SweepLoaded = true;
            app.x_sweep = app.Sweep_struct.channels.Excitation_Frequency_Hz;
            app.x_SIunit = app.Sweep_struct.units(1);
            field_names = string(fieldnames(app.Sweep_struct.channels));
            amp_field_idx = contains(field_names,"Lock_In_Amplitude");
            amp_field_name = field_names(amp_field_idx);
            app.y_sweep = app.Sweep_struct.channels.(amp_field_name);
            app.y_SIunit = app.Sweep_struct.units(amp_field_idx);

            % Determine OoM and prefixes
            [app.x_OoM,app.x_unit,app.y_OoM,app.y_unit] = OoM_x_and_y(app,app.x_sweep,app.x_SIunit,app.y_sweep,app.y_SIunit);
            
            % display loaded sweep;
            x_plot = app.x_sweep./10^(app.x_OoM);
            app.Spectrum_Axes.XAxis.Label.String = "Frequency [" + app.x_unit + "]";
            
            y_plot = app.y_sweep./10^(app.y_OoM);
            app.Spectrum_Axes.YAxis.Label.String = "Amplitude [" + app.y_unit + "]";
            
            plot(app.Spectrum_Axes,x_plot,y_plot,".","LineWidth",2,"MarkerSize",6);
            xlim(app.Spectrum_Axes,[min(x_plot) max(x_plot)]);
        end

        % Button pushed function: CalculateButton
        function CalculateButtonPushed(app, event)
            if ~app.SweepLoaded
                return;
            end
            Calculate_fr_andQ(app,app.x_sweep,app.y_sweep);
            
            % Write fr and Q to corresponding result fields
            [f_val,~,f_unit] = OoM_Frequency(app,app.Res_Frequ);
            app.Res_Frequ_Result.Value = f_val;
            app.kHzLabel.Text = "  " + f_unit;
            app.Q_Fac_Result.Value = app.Q_Fac;
            
            % Draw spline and dashed lines
            cla(app.Spectrum_Axes);
            x_plot = app.x_sweep./10^(app.x_OoM);
            y_plot = app.y_sweep./10^(app.y_OoM);
            plot(app.Spectrum_Axes,x_plot,y_plot,".","LineWidth",2,"MarkerSize",6);
            xlim(app.Spectrum_Axes,[min(x_plot) max(x_plot)]);
            
            hold(app.Spectrum_Axes,"on");
            plot(app.Spectrum_Axes,app.x_spline./10^(app.x_OoM),app.y_spline./10^(app.y_OoM),"g-","LineWidth",1);
            plot(app.Spectrum_Axes,app.Res_Frequ./10^(app.x_OoM),app.A_max./10^(app.y_OoM),"rx","LineWidth",1.5,"MarkerSize",10);
            legend(app.Spectrum_Axes,["Sweep Data","Interpolation Spline","Detected Maximum"],"Location","northeast","AutoUpdate","off");
            yline(app.Spectrum_Axes,app.A_half_power./10^(app.y_OoM),"--","Color",[.6 .6 .6],"LineWidth",.5);
            xline(app.Spectrum_Axes,app.f1./10^(app.x_OoM),"--","Color",[.6 .6 .6],"LineWidth",.5);
            xline(app.Spectrum_Axes,app.f2./10^(app.x_OoM),"--","Color",[.6 .6 .6],"LineWidth",.5);
            hold(app.Spectrum_Axes,"off");
            
            % Get selected Cantilever from drop down menu
            value = string(app.CantileverDropDown.Value);

            if strcmp(value,"Basic Rectangular Cantilever")
                % Calculate the hydrodynamic function of the rectangular cantilever
                app.hydrodynamic_function = CalculateRecHydrodynamicFunctionAir(app,app.Res_Frequ,app.CWidth,app.density,app.viscosity);
                app.hydrodynamic_function_imag_part = imag(app.hydrodynamic_function);
                
                % Calculate Spring Constant using the Sader Method
                app.Spring_Const = SaderSpingConst(app,app.CLength,app.CWidth,app.Q_Fac,app.Res_Frequ,app.density,app.hydrodynamic_function_imag_part);
                app.Spring_Const_Result.Value = app.Spring_Const;
            else
                switch value % Coefficiants from: Sader, et al., Rev. Sci. Instrum., 83, 103705 (2012)
                    case "AC160TS"
                        a0 = 0.7779;
                        a1 = -0.7230;
                        a2 = 0.0251;
                        C = 1.101;
                    case "AC240TM"
                        a0 = 0.8170;
                        a1 = -0.7055;
                        a2 = 0.0423;
                        C = 1.043;
                    case "AC240TS"
                        a0 = 0.8170;
                        a1 = -0.7055;
                        a2 = 0.0423;
                        C = 1.043;
                    case "ASYMFM"
                        a0 = 0.8170;
                        a1 = -0.7055;
                        a2 = 0.0423;
                        C = 1.043;
                    case "BL-RC150BV(L)"
                        a0 = 1.0025;
                        a1 = -0.7649;
                        a2 = 0.0361;
                        C = 1.035;
                    case "FMR"
                        a0 = 0.8758;
                        a1 = -0.6834;
                        a2 = 0.0357;
                        C = 1.029;
                    case "NCHR"
                        a0 = 0.9369;
                        a1 = -0.7053;
                        a2 = 0.0438;
                        C = 1.036;
                    case "TR400(S)"
                        a0 = 1.5346;
                        a1 = -0.6793;
                        a2 = 0.0265;
                        C = 1.054;
                    case "TR800(S)"
                        a0 = 1.5346;
                        a1 = -0.6793;
                        a2 = 0.0265;
                        C = 1.054;
                    case "TR400(L)"
                        a0 = 1.2017;
                        a1 = -0.6718;
                        a2 = 0.0383;
                        C = 1.072;
                    case "TR800(L)"
                        a0 = 1.2017;
                        a1 = -0.6718;
                        a2 = 0.0383;
                        C = 1.072;
                end
                app.Spring_Const = NewSaderSpringConst(app,app.CLength,app.CWidth,app.Q_Fac,app.Res_Frequ,app.density,app.viscosity,a0,a1,a2,C);
                app.Spring_Const_Result.Value = app.Spring_Const;
            end
        end

        % Value changed function: CantiWidth
        function CantiWidthValueChanged(app, event)
            value = app.CantiWidth.Value;
            app.CWidth = value.*1e-6;
        end

        % Value changed function: CantiLength
        function CantiLengthValueChanged(app, event)
            value = app.CantiLength.Value;
            app.CLength = value.*1e-6;
        end

        % Value changed function: Density
        function DensityValueChanged(app, event)
            value = app.Density.Value;
            app.density = value;
        end

        % Value changed function: Viscosity
        function ViscosityValueChanged(app, event)
            value = app.Viscosity.Value;
            app.viscosity = value;
        end

        % Button pushed function: ExporttoTextFileButton
        function ExporttoTextFileButtonPushed(app, event)
           [file,path] = uiputfile("*.txt","Save Results as Text-File","Spring-Constant-Calibration.txt");
           save_path = fullfile(path,file);
           if file == 0
               return;
           end
           
           % Write Headline
           Save_ID = fopen(save_path,"at");
           fprintf(Save_ID,"%s\n\n","Spring-Constant Calibration Results:");
           
           % Write User Entered Parameters
           fprintf(Save_ID,"%s\n","Entered Parameters:");
           fprintf(Save_ID,"%s = %.5g %s\n",...
               "Cantilever Width",app.CWidth.*1e6,"µm",...
               "Cantilever Length",app.CLength.*1e6,"µm",...
               "Density of Surrounding",app.density,"kg/m^3",...
               "Viscosity of Surrounding",app.viscosity,"Pa*s");
           fprintf(Save_ID,"%s\n","");
           
           % Write Results
           fprintf(Save_ID,"%s\n","Results:");
           fprintf(Save_ID,"%s = %.5g %s\n",...
               "Resonance Frequency",app.Res_Frequ,"Hz",...
               "Q-Factor",app.Q_Fac,"",...
               "Spring Constant",app.Spring_Const,"N/m");
           
           % Close file ID
           fclose(Save_ID);
        end

        % Close request function: UIFigure
        function UIFigureCloseRequest(app, event)
            
            delete(app)
            run("CANTER_Processing_Toolbox.mlapp")
            
        end

        % Value changed function: CantileverDropDown
        function CantileverDropDownValueChanged(app, event)
            value = app.CantileverDropDown.Value;
            
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 873 563];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Resize = 'off';
            app.UIFigure.CloseRequestFcn = createCallbackFcn(app, @UIFigureCloseRequest, true);

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.ColumnWidth = {'1x', '2x'};
            app.GridLayout.RowHeight = {'1x'};

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.ColumnWidth = {'1x'};
            app.GridLayout2.RowHeight = {'3x', '1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 2;

            % Create Spectrum_Axes
            app.Spectrum_Axes = uiaxes(app.GridLayout2);
            title(app.Spectrum_Axes, 'Displaying of Amplitude Sweep')
            xlabel(app.Spectrum_Axes, 'Frequency [kHz]')
            ylabel(app.Spectrum_Axes, 'Amplitude [nm]')
            app.Spectrum_Axes.Toolbar.Visible = 'off';
            app.Spectrum_Axes.XTickLabelRotation = 0;
            app.Spectrum_Axes.YTickLabelRotation = 0;
            app.Spectrum_Axes.ZTickLabelRotation = 0;
            app.Spectrum_Axes.Layout.Row = 1;
            app.Spectrum_Axes.Layout.Column = 1;

            % Create ResultsPanel
            app.ResultsPanel = uipanel(app.GridLayout2);
            app.ResultsPanel.Title = 'Results';
            app.ResultsPanel.Layout.Row = 2;
            app.ResultsPanel.Layout.Column = 1;
            app.ResultsPanel.FontWeight = 'bold';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.ResultsPanel);
            app.GridLayout3.ColumnWidth = {'1x', '1x', '1x'};
            app.GridLayout3.RowHeight = {'1x', '1x', '1x', '1x'};
            app.GridLayout3.RowSpacing = 0;

            % Create ResonanceFrequencyLabel
            app.ResonanceFrequencyLabel = uilabel(app.GridLayout3);
            app.ResonanceFrequencyLabel.FontWeight = 'bold';
            app.ResonanceFrequencyLabel.Layout.Row = 1;
            app.ResonanceFrequencyLabel.Layout.Column = 1;
            app.ResonanceFrequencyLabel.Text = 'Resonance Frequency';

            % Create QFactorLabel
            app.QFactorLabel = uilabel(app.GridLayout3);
            app.QFactorLabel.FontWeight = 'bold';
            app.QFactorLabel.Layout.Row = 1;
            app.QFactorLabel.Layout.Column = 2;
            app.QFactorLabel.Text = 'Q-Factor';

            % Create SpringConstantLabel
            app.SpringConstantLabel = uilabel(app.GridLayout3);
            app.SpringConstantLabel.FontWeight = 'bold';
            app.SpringConstantLabel.Layout.Row = 1;
            app.SpringConstantLabel.Layout.Column = 3;
            app.SpringConstantLabel.Text = 'Spring Constant';

            % Create GridLayout4
            app.GridLayout4 = uigridlayout(app.GridLayout3);
            app.GridLayout4.ColumnWidth = {'3x', '1x'};
            app.GridLayout4.RowHeight = {'1x'};
            app.GridLayout4.ColumnSpacing = 0;
            app.GridLayout4.RowSpacing = 0;
            app.GridLayout4.Padding = [0 0 0 0];
            app.GridLayout4.Layout.Row = 2;
            app.GridLayout4.Layout.Column = 1;

            % Create Res_Frequ_Result
            app.Res_Frequ_Result = uieditfield(app.GridLayout4, 'numeric');
            app.Res_Frequ_Result.ValueDisplayFormat = '%11.2f';
            app.Res_Frequ_Result.Editable = 'off';
            app.Res_Frequ_Result.Layout.Row = 1;
            app.Res_Frequ_Result.Layout.Column = 1;

            % Create kHzLabel
            app.kHzLabel = uilabel(app.GridLayout4);
            app.kHzLabel.Layout.Row = 1;
            app.kHzLabel.Layout.Column = 2;
            app.kHzLabel.Text = '  kHz';

            % Create GridLayout5
            app.GridLayout5 = uigridlayout(app.GridLayout3);
            app.GridLayout5.ColumnWidth = {'2x', '1x'};
            app.GridLayout5.RowHeight = {'1x'};
            app.GridLayout5.ColumnSpacing = 0;
            app.GridLayout5.RowSpacing = 0;
            app.GridLayout5.Padding = [0 0 0 0];
            app.GridLayout5.Layout.Row = 2;
            app.GridLayout5.Layout.Column = 2;

            % Create Q_Fac_Result
            app.Q_Fac_Result = uieditfield(app.GridLayout5, 'numeric');
            app.Q_Fac_Result.ValueDisplayFormat = '%11.2f';
            app.Q_Fac_Result.Editable = 'off';
            app.Q_Fac_Result.Layout.Row = 1;
            app.Q_Fac_Result.Layout.Column = 1;

            % Create GridLayout6
            app.GridLayout6 = uigridlayout(app.GridLayout3);
            app.GridLayout6.ColumnWidth = {'2x', '1x'};
            app.GridLayout6.RowHeight = {'1x'};
            app.GridLayout6.ColumnSpacing = 0;
            app.GridLayout6.RowSpacing = 0;
            app.GridLayout6.Padding = [0 0 0 0];
            app.GridLayout6.Layout.Row = 2;
            app.GridLayout6.Layout.Column = 3;

            % Create NmLabel
            app.NmLabel = uilabel(app.GridLayout6);
            app.NmLabel.Layout.Row = 1;
            app.NmLabel.Layout.Column = 2;
            app.NmLabel.Text = '  N/m';

            % Create Spring_Const_Result
            app.Spring_Const_Result = uieditfield(app.GridLayout6, 'numeric');
            app.Spring_Const_Result.ValueDisplayFormat = '%11.4f';
            app.Spring_Const_Result.Editable = 'off';
            app.Spring_Const_Result.Layout.Row = 1;
            app.Spring_Const_Result.Layout.Column = 1;

            % Create ExporttoTextFileButton
            app.ExporttoTextFileButton = uibutton(app.GridLayout3, 'push');
            app.ExporttoTextFileButton.ButtonPushedFcn = createCallbackFcn(app, @ExporttoTextFileButtonPushed, true);
            app.ExporttoTextFileButton.Layout.Row = 4;
            app.ExporttoTextFileButton.Layout.Column = 2;
            app.ExporttoTextFileButton.Text = 'Export to Text-File';

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.GridLayout);
            app.GridLayout7.ColumnWidth = {'1x'};
            app.GridLayout7.RowHeight = {'1x', '8x', '1x'};
            app.GridLayout7.Layout.Row = 1;
            app.GridLayout7.Layout.Column = 1;

            % Create LoadAmplitudeSweepButton
            app.LoadAmplitudeSweepButton = uibutton(app.GridLayout7, 'push');
            app.LoadAmplitudeSweepButton.ButtonPushedFcn = createCallbackFcn(app, @LoadAmplitudeSweepButtonPushed, true);
            app.LoadAmplitudeSweepButton.FontSize = 14;
            app.LoadAmplitudeSweepButton.FontWeight = 'bold';
            app.LoadAmplitudeSweepButton.Layout.Row = 1;
            app.LoadAmplitudeSweepButton.Layout.Column = 1;
            app.LoadAmplitudeSweepButton.Text = 'Load Amplitude Sweep';

            % Create CalculateButton
            app.CalculateButton = uibutton(app.GridLayout7, 'push');
            app.CalculateButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateButtonPushed, true);
            app.CalculateButton.FontSize = 14;
            app.CalculateButton.FontWeight = 'bold';
            app.CalculateButton.Layout.Row = 3;
            app.CalculateButton.Layout.Column = 1;
            app.CalculateButton.Text = 'Calculate';

            % Create ParametersPanel
            app.ParametersPanel = uipanel(app.GridLayout7);
            app.ParametersPanel.Title = 'Parameters:';
            app.ParametersPanel.Layout.Row = 2;
            app.ParametersPanel.Layout.Column = 1;
            app.ParametersPanel.FontWeight = 'bold';

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.ParametersPanel);
            app.GridLayout8.ColumnWidth = {'1x'};
            app.GridLayout8.RowHeight = {'1x', '1x', '1x', '1x', '1x'};

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.GridLayout8);
            app.GridLayout9.ColumnWidth = {'3x', '1x'};
            app.GridLayout9.ColumnSpacing = 0;
            app.GridLayout9.RowSpacing = 0;
            app.GridLayout9.Layout.Row = 2;
            app.GridLayout9.Layout.Column = 1;

            % Create CantileverWidthLabel
            app.CantileverWidthLabel = uilabel(app.GridLayout9);
            app.CantileverWidthLabel.Layout.Row = 1;
            app.CantileverWidthLabel.Layout.Column = 1;
            app.CantileverWidthLabel.Text = 'Cantilever Width';

            % Create mLabel
            app.mLabel = uilabel(app.GridLayout9);
            app.mLabel.Layout.Row = 2;
            app.mLabel.Layout.Column = 2;
            app.mLabel.Text = '  µm';

            % Create CantiWidth
            app.CantiWidth = uieditfield(app.GridLayout9, 'numeric');
            app.CantiWidth.Limits = [0 Inf];
            app.CantiWidth.ValueDisplayFormat = '%11.2f';
            app.CantiWidth.ValueChangedFcn = createCallbackFcn(app, @CantiWidthValueChanged, true);
            app.CantiWidth.HorizontalAlignment = 'center';
            app.CantiWidth.Layout.Row = 2;
            app.CantiWidth.Layout.Column = 1;
            app.CantiWidth.Value = 40;

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.GridLayout8);
            app.GridLayout10.ColumnWidth = {'3x', '1x'};
            app.GridLayout10.ColumnSpacing = 0;
            app.GridLayout10.RowSpacing = 0;
            app.GridLayout10.Layout.Row = 3;
            app.GridLayout10.Layout.Column = 1;

            % Create CantileverLengthLabel
            app.CantileverLengthLabel = uilabel(app.GridLayout10);
            app.CantileverLengthLabel.Layout.Row = 1;
            app.CantileverLengthLabel.Layout.Column = 1;
            app.CantileverLengthLabel.Text = 'Cantilever Length';

            % Create mLabel_2
            app.mLabel_2 = uilabel(app.GridLayout10);
            app.mLabel_2.Layout.Row = 2;
            app.mLabel_2.Layout.Column = 2;
            app.mLabel_2.Text = '  µm';

            % Create CantiLength
            app.CantiLength = uieditfield(app.GridLayout10, 'numeric');
            app.CantiLength.Limits = [0 Inf];
            app.CantiLength.ValueDisplayFormat = '%11.2f';
            app.CantiLength.ValueChangedFcn = createCallbackFcn(app, @CantiLengthValueChanged, true);
            app.CantiLength.HorizontalAlignment = 'center';
            app.CantiLength.Layout.Row = 2;
            app.CantiLength.Layout.Column = 1;
            app.CantiLength.Value = 160;

            % Create GridLayout11
            app.GridLayout11 = uigridlayout(app.GridLayout8);
            app.GridLayout11.ColumnWidth = {'3x', '1x'};
            app.GridLayout11.ColumnSpacing = 0;
            app.GridLayout11.RowSpacing = 0;
            app.GridLayout11.Layout.Row = 4;
            app.GridLayout11.Layout.Column = 1;

            % Create DensityofSurroundingLabel
            app.DensityofSurroundingLabel = uilabel(app.GridLayout11);
            app.DensityofSurroundingLabel.Layout.Row = 1;
            app.DensityofSurroundingLabel.Layout.Column = 1;
            app.DensityofSurroundingLabel.Text = 'Density of Surrounding';

            % Create kgm3Label
            app.kgm3Label = uilabel(app.GridLayout11);
            app.kgm3Label.Layout.Row = 2;
            app.kgm3Label.Layout.Column = 2;
            app.kgm3Label.Text = '  kg/m^3';

            % Create Density
            app.Density = uieditfield(app.GridLayout11, 'numeric');
            app.Density.Limits = [0 Inf];
            app.Density.ValueDisplayFormat = '%11.2f';
            app.Density.ValueChangedFcn = createCallbackFcn(app, @DensityValueChanged, true);
            app.Density.HorizontalAlignment = 'center';
            app.Density.Layout.Row = 2;
            app.Density.Layout.Column = 1;
            app.Density.Value = 1.18;

            % Create GridLayout12
            app.GridLayout12 = uigridlayout(app.GridLayout8);
            app.GridLayout12.ColumnWidth = {'3x', '1x'};
            app.GridLayout12.ColumnSpacing = 0;
            app.GridLayout12.RowSpacing = 0;
            app.GridLayout12.Layout.Row = 5;
            app.GridLayout12.Layout.Column = 1;

            % Create ViscosityofSurroundingLabel
            app.ViscosityofSurroundingLabel = uilabel(app.GridLayout12);
            app.ViscosityofSurroundingLabel.Layout.Row = 1;
            app.ViscosityofSurroundingLabel.Layout.Column = 1;
            app.ViscosityofSurroundingLabel.Text = 'Viscosity of Surrounding';

            % Create PasLabel
            app.PasLabel = uilabel(app.GridLayout12);
            app.PasLabel.Layout.Row = 2;
            app.PasLabel.Layout.Column = 2;
            app.PasLabel.Text = '  Pa*s';

            % Create Viscosity
            app.Viscosity = uieditfield(app.GridLayout12, 'numeric');
            app.Viscosity.Limits = [0 Inf];
            app.Viscosity.ValueDisplayFormat = '%11.3g';
            app.Viscosity.ValueChangedFcn = createCallbackFcn(app, @ViscosityValueChanged, true);
            app.Viscosity.HorizontalAlignment = 'center';
            app.Viscosity.Layout.Row = 2;
            app.Viscosity.Layout.Column = 1;
            app.Viscosity.Value = 1.86e-05;

            % Create GridLayout13
            app.GridLayout13 = uigridlayout(app.GridLayout8);
            app.GridLayout13.ColumnWidth = {'3x', '1x'};
            app.GridLayout13.ColumnSpacing = 0;
            app.GridLayout13.RowSpacing = 0;
            app.GridLayout13.Layout.Row = 1;
            app.GridLayout13.Layout.Column = 1;

            % Create UsedCantileverLabel
            app.UsedCantileverLabel = uilabel(app.GridLayout13);
            app.UsedCantileverLabel.Layout.Row = 1;
            app.UsedCantileverLabel.Layout.Column = 1;
            app.UsedCantileverLabel.Text = 'Used Cantilever';

            % Create CantileverDropDown
            app.CantileverDropDown = uidropdown(app.GridLayout13);
            app.CantileverDropDown.Items = {'Basic Rectangular Cantilever', 'AC160TS', 'AC240TM', 'AC240TS', 'ASYMFM', 'BL-RC150BV(L)', 'FMR', 'NCHR', 'TR400(S)', 'TR400(L)', 'TR800(S)', 'TR800(L)'};
            app.CantileverDropDown.ValueChangedFcn = createCallbackFcn(app, @CantileverDropDownValueChanged, true);
            app.CantileverDropDown.Enable = 'off';
            app.CantileverDropDown.Layout.Row = 2;
            app.CantileverDropDown.Layout.Column = 1;
            app.CantileverDropDown.Value = 'Basic Rectangular Cantilever';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SaderMethodCalibration_GUI

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end