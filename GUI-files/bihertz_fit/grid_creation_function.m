function handles = grid_creation_function(handles)
%%  Function to arrange and rearrange the fit results display fields in
%   dependency of the chosen fit model (bihertz_sum_heavyside or bihertz_
%   split_heavyside)
% 
% 
% 
% 
% 
% 

%%
    

    % scroll panel
    handles.scroll_pan = uix.ScrollingPanel();
    % pos panel layout
    handles.pan_grid = uix.Grid();

    % Parent properties
    handles.scroll_pan.Parent = handles.uipanel10;
    handles.pan_grid.Parent = handles.scroll_pan;

    % Scoll panel properties
    units_pan = handles.uipanel10.Position;
    handles.uipanel10.Units = 'pixel';
    handles.scroll_pan.MinimumHeights = handles.uipanel10.Position(3);
    handles.scroll_pan.MinimumWidths = handles.uipanel10.Position(4);
    handles.uipanel10.Units = 'normalized';
    handles.uipanel10.Position = units_pan;

    grid_spaceing = 12;
    grid_padding = 4;

    if strcmp(handles.options.model,'bihertz') && handles.options.bihertz_variant == 1
        % empty elements (12)
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);

        % Grid elements
        % first element
        uix.Empty('Parent',handles.pan_grid);
        % second element
        handles.text12.Parent = handles.pan_grid;
        % third element
        handles.hbox1 = uix.HBox('Parent',handles.pan_grid,'Spacing',grid_spaceing,'Padding',grid_padding);
        handles.result_Es.Parent = handles.hbox1;
        handles.text14.Parent = handles.hbox1;
        handles.hbox1.Widths = [-2 -1];
        % fourth element
        uix.Empty('Parent',handles.pan_grid);
        % fifth element
        handles.text15.Parent = handles.pan_grid;
        % sixth element
        handles.hbox2 = uix.HBox('Parent',handles.pan_grid,'Spacing',grid_spaceing,'Padding',grid_padding);
        handles.result_Eh.Parent = handles.hbox2;
        handles.text17.Parent = handles.hbox2;
        handles.hbox2.Widths = [-2 -1];
        % seventh element
        uix.Empty('Parent',handles.pan_grid);
        % eighth element
        handles.text18.Parent = handles.pan_grid;
        % nineth element
        handles.hbox3 = uix.HBox('Parent',handles.pan_grid,'Spacing',grid_spaceing,'Padding',grid_padding);
        handles.result_dh.Parent = handles.hbox3;
        handles.text20.Parent = handles.hbox3;
        handles.hbox3.Widths = [-2 -1];
        % tenth element
        uix.Empty('Parent',handles.pan_grid);
        % eleventh element
        handles.text30.Parent = handles.pan_grid;
        % twelveth element
        handles.hbox4 = uix.HBox('Parent',handles.pan_grid,'Spacing',grid_spaceing,'Padding',grid_padding);
        handles.result_rsquare.Parent = handles.hbox4;
        uix.Empty('Parent',handles.hbox4);
        handles.hbox4.Widths = [-2 -1];
        % empty elements (12)
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);

        % Grid properties
        handles.pan_grid.Heights = [10 20 30 10 20 30 10 20 30 10 20 30];
        handles.pan_grid.Widths = [-0.25 -2 -1];

    elseif strcmp(handles.options.model,'bihertz') && handles.options.bihertz_variant == 2
        % empty elements (15)
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);

        % Grid elements
        % first element
        uix.Empty('Parent',handles.pan_grid);
        % second element
        handles.text12.Parent = handles.pan_grid;
        % third element
        handles.hbox1 = uix.HBox('Parent',handles.pan_grid,'Spacing',grid_spaceing,'Padding',grid_padding);
        handles.result_Es.Parent = handles.hbox1;
        handles.text14.Parent = handles.hbox1;
        handles.hbox1.Widths = [-2 -1];
        % fourth element
        uix.Empty('Parent',handles.pan_grid);
        % fifth element
        handles.text15.Parent = handles.pan_grid;
        % sixth element
        handles.hbox2 = uix.HBox('Parent',handles.pan_grid,'Spacing',grid_spaceing,'Padding',grid_padding);
        handles.result_Eh.Parent = handles.hbox2;
        handles.text17.Parent = handles.hbox2;
        handles.hbox2.Widths = [-2 -1];
        % seventh element
        uix.Empty('Parent',handles.pan_grid);
        % eighth element
        handles.text18.Parent = handles.pan_grid;
        % nineth element
        handles.hbox3 = uix.HBox('Parent',handles.pan_grid,'Spacing',grid_spaceing,'Padding',grid_padding);
        handles.result_dh.Parent = handles.hbox3;
        handles.text20.Parent = handles.hbox3;
        handles.hbox3.Widths = [-2 -1];
        % tenth element
        uix.Empty('Parent',handles.pan_grid);
        % eleventh element
        handles.text69.Parent = handles.pan_grid;
        % twelveth element
        handles.hbox4 = uix.HBox('Parent',handles.pan_grid,'Spacing',grid_spaceing,'Padding',grid_padding);
        handles.result_switch_point.Parent = handles.hbox4;
        handles.text71.Parent = handles.hbox4;
        handles.hbox4.Widths = [-2 -1];
        % thirteenth element
        uix.Empty('Parent',handles.pan_grid);
        % fourteenth element
        handles.text30.Parent = handles.pan_grid;
        % fifteenth element
        handles.hbox5 = uix.HBox('Parent',handles.pan_grid,'Spacing',grid_spaceing,'Padding',grid_padding);
        handles.result_rsquare.Parent = handles.hbox5;
        uix.Empty('Parent',handles.hbox5);
        handles.hbox5.Widths = [-2 -1];
        % empty elements (15)
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);
        uix.Empty('Parent',handles.pan_grid);

        % Grid properties
        handles.pan_grid.Heights = [10 20 30 10 20 30 10 20 30 10 20 30 10 20 30];
        handles.pan_grid.Widths = [-0.25 -2 -1];

    end
    
end