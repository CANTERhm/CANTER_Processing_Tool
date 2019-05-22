%% LICENSE
% 
% 
% CANTER_Auswertetool: A tool for the data processing of force-indentation curves and more ...
%     Copyright (C) 2018-2019  Bastian Hartmann and Lutz Fleischhauer
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
%     
% 

%% Steuerscipt für das CANTER Auswertetool

options = CANTER_Auswertetool;

if ~isempty(options)
    switch options.list_object
        case 1
            bihertz_gui(options);
        case 2
            bihertz_gui(options);
        case 3

        case 4

        case 5

        case 6

        case 7
            lateral_dev_gui;
    end
end
    

