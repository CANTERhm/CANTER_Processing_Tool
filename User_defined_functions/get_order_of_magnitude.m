function [plain_numb,numb_power,value_unit,value_string] = get_order_of_magnitude(value,SI_unit)
%%  get_order_of_magnitude: Function to get the order of magnitude and the correctly formatted number and unit string.
%   
%   Syntax:
%   [plain_numb,numb_power,value_unit,value_string] = get_order_of_magnitude(value,SI_unit)
% 
%   Input:
%   - value:    Is the number you want to get the order of magnitude and
%               the formatted string of.
%   - SI_unit:  Here you can give the SI unit of the number, e.g. m, Pa, N,
%               etc.. If you don't want any unit, just give '' as input.
%               ATTENTION: The unit of time (s) is not correctly supported!
% 
%   Output:
%   (for example value=4.2e6 and SI_unit = 'Pa')
%
%   - plain_number: number devided by the order of magnitude.
%                   (plain_number = 4.2)
%   - numb_power:   power of the given number in value.
%                   (numb_power = 6)
%   - value_unit:   String of the formatted SI_unit.
%                   (value_unit = 'MPa')
%   - value_string: Complete string of plain_number and value_unit.
%                   (value_string = 4.2 MPa)
% 
%   Example 1:
%   Input:  value = 5.7e-5 
%           SI_unit = 'm'
%   Output: plain_number = 57.00
%           numb_power = -6
%           value_unit = 'µm'
%           value_string = '57.00 µm'
% 
%   Example 2:
%   Input:  value = 168e8 
%           SI_unit = 'N'
%   Output: plain_number = 16.8
%           numb_power = 9
%           value_unit = 'GN'
%           value_string = '16.80 GN'


    ord_of_mag = floor(log10(value));
            
    if ord_of_mag > 15 
        warning('The order of magnetude (%i) of the value is out of range (too high) for this function.\nThus, the output is just the input value!',ord_of_mag)
        plain_numb = value;
        numb_power = 0;
        value_unit = sprintf('%s',SI_unit);
        value_string = sprintf('%.2e %s',plain_numb,value_unit);              
    elseif ord_of_mag < -15
        warning('The order of magnetude (%i) of the value is out of range (too low) for this function.\nThus, the output is just the input value!',ord_of_mag)
        plain_numb = value;
        numb_power = 0;
        value_unit = sprintf('%s',SI_unit);
        value_string = sprintf('%.2e %s',plain_numb,value_unit);
    else
        if ord_of_mag >= 12
            plain_numb = value*1e-12;
            numb_power = 12;
            value_unit = sprintf('%s%s','T',SI_unit);
            value_string = sprintf('%.2f %s',plain_numb,value_unit);
        elseif ord_of_mag < 12 && ord_of_mag >= 9
            plain_numb = value*1e-9;
            numb_power = 9;
            value_unit = sprintf('%s%s','G',SI_unit);
            value_string = sprintf('%.2f %s',plain_numb,value_unit);
        elseif ord_of_mag < 9 && ord_of_mag >= 6
            plain_numb = value*1e-6;
            numb_power = 6;
            value_unit = sprintf('%s%s','M',SI_unit);
            value_string = sprintf('%.2f %s',plain_numb,value_unit);
        elseif ord_of_mag < 6 && ord_of_mag >= 3
            plain_numb = value*1e-3;
            numb_power = 3;
            value_unit = sprintf('%s%s','k',SI_unit);
            value_string = sprintf('%.2f %s',plain_numb,value_unit);
        elseif ord_of_mag < 3 && ord_of_mag >= 0
            plain_numb = value*1e-0;
            numb_power = 0;
            value_unit = sprintf('%s',SI_unit);
            value_string = sprintf('%.2f %s',plain_numb,value_unit);
        elseif ord_of_mag < 0 && ord_of_mag >= -3
            plain_numb = value*1e3;
            numb_power = -3;
            value_unit = sprintf('%s%s','m',SI_unit);
            value_string = sprintf('%.2f %s',plain_numb,value_unit);
        elseif ord_of_mag < -3 && ord_of_mag >= -6
            plain_numb = value*1e6;
            numb_power = -6;
            value_unit = sprintf('%s%s','µ',SI_unit);
            value_string = sprintf('%.2f %s',plain_numb,value_unit);
        elseif ord_of_mag < -6 && ord_of_mag >= -9
            plain_numb = value*1e9;
            numb_power = -9;
            value_unit = sprintf('%s%s','n',SI_unit);
            value_string = sprintf('%.2f %s',plain_numb,value_unit);
        elseif ord_of_mag < -9 && ord_of_mag >= -12
            plain_numb = value*1e12;
            numb_power = -12;
            value_unit = sprintf('%s%s','p',SI_unit);
            value_string = sprintf('%.2f %s',plain_numb,value_unit);
        elseif ord_of_mag < -12 && ord_of_mag >= -15
            plain_numb = value*1e15;
            numb_power = -15;
            value_unit = sprintf('%s%s','f',SI_unit);
            value_string = sprintf('%.2f %s',plain_numb,value_unit);
        end
    end
end