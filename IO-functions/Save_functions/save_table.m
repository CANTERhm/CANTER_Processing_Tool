function save_table(varargin)
%% SAVE_TABLE: saves a table, struct or vectors to a excel or tsv file.
%              vectors can be a string array or a numeric array.
%              The struct must contain the vectors as fields.
% 
%   Name-Vaue-Pairs:
%   - Name:     'fileFormat'
%     Value:    'tsv' (default) | 'excel'
% 
%   - Name:     'savepath'
%     Value:    'none' (default) | 'User_defined_path'
%               User_defined_path is any valid path that ends with the
%               filename. Example: C:\Users\User\Desktop\testfile.
%               If the savepath value is none, the save location will be
%               asked with a UI input.
% 
%   save_table(table,'fileFormat',formatString): saves a table to a file specified in
%   formatString. Supported file formats are 'tsv' and 'excel'
% 
%   save_table(vec1,vec2,...,'fileFormat',formatString): saves the vectors (vec1,vec2, etc.)
%   to a file specified in fileFormat as a string. Supported file formats
%   are 'tsv' and 'excel'. The vectors can be a string array or a numeric
%   array. In the output file, the vector names are written as the column
%   name.
% 
% 
%   save_table(vec1,vec2,...,'fileFormat',Format_string,'savepath',savepath_string):
%   saves the vectors (vec1,vec2, etc.) to a file specified in fileFormat
%   as a string. Supported file formats are 'tsv' and 'excel'. The vectors
%   can be a string array or a numeric array. In the output file, the vector
%   names are written as the column name.
%   • with the name-value-pair 'savepath' followed by a full savepath you
%     can define a path and a name of the output file. Otherwise, the save
%     location and filename will be requested via a dialog box.
% 
% 
%   EXAMPLES:
% 
%   save_table(table,'fileFormat','tsv')
% 
%   save_table(vec1,vec2,vec3,'fileFormat','excel')
%
%   save_table(vec1,vec2,vec3,'fileFormat','tsv','savepath','C:\Users\User\Desktop\testfile');
%

%% check if first input argument is a table


if ~istable(varargin{1}) && ~isvector(varargin{1})
    errordlg('First input parameter must be a table or a vector',...
              'First parameter error');
    return;
end


%% initialising inputParser
p = inputParser;
p.CaseSensitive = true;
p.PartialMatching = false;
p.KeepUnmatched = true;
p.StructExpand = true;

% Add name-value-pair for the file format
str = {'tsv' 'excel'};  % supported file formats
error_msg1 = 'The supported file formats are ''tsv'' and ''excel''';
valFun1 = @(x) assert(any(strcmp(x,str),2) && ischar(x),error_msg1);
addParameter(p,'fileFormat','tsv',valFun1);

% Add optional name-value-pair for savepath
error_msg2 = 'The savepath must be a char or string';
valFun2 = @(x) assert(ischar(x) || isstring(x),error_msg2);
addParameter(p,'savepath','none',valFun2);


%% saving Table

% if first input arguments are a vector, create table
if isa(varargin{1},'numeric') || isa(varargin{1},'string') || isa(varargin{1},'char')
    % convert vectors if required
    c = 1;
    len = 1;
    while c == 1
        c = ~isempty(inputname(len));
        len = len + 1;
    end
    len = len - 2;
    
    % if one or more vectors are a char vector, convert it in a string
    % vector
    for i = 1:len
        varargin{i} = convertCharsToStrings(varargin{i});
    end

    
    for i = 1:len
        if isrow(varargin{i})
            varargin{i} = varargin{i}';
        else
            continue;
        end
    end     
    
    % determing vector names
    s{1,len} = [];
    for i = 1:len
        s{1,i} = inputname(i);
    end
    
    % create VariableType string
    type = cell(1,len);
    for i = 1:len
        if isstring(varargin{i})
            type{i} = 'string';
        elseif isnumeric(varargin{i})
            type{i} = 'double';
        end
    end
    
    % creating table
    T = table('Size',[length(varargin{1}) len],'VariableNames',s,'VariableTypes',type);

    for i = 1:len
        Matr = varargin{i};
        T(:,i) = table(Matr);
    end
    
elseif isa(varargin{1}, 'struct')
    T = struct2table(varargin{1});
    
elseif isa(varargin{1},'table')
    
    T = varargin{1};
    
end

% parse the name-value-pairs to inputParser
if (isvector(varargin{1}) && isnumeric(varargin{1})) || isa(varargin{1},'string')
parse(p,varargin{len+1:end});
else
parse(p,varargin{2:end});
end

% save table in chosen file format
spec = p.Results.fileFormat;
switch spec
    case 'tsv'
        if strcmp(p.Results.savepath,'none')
            [name,path] = uiputfile('*.tsv');
            if name ~=0
                savepath = fullfile(path,name);
            else
                return;
            end
        else
            savepath = p.Results.savepath;
        end
        writetable(T,savepath,'Delimiter','\t','FileType','text');
    case 'excel'
        if strcmp(p.Results.savepath,'none')
            [name,path] = uiputfile('*.xlsx');
            if name ~= 0
                savepath = fullfile(path,name);
            else 
                return;
            end
        else
            savepath = p.Results.savepath;
        end
        writetable(T,savepath,'FileType','spreadsheet','Sheet',1,'Range','B2');
end     
           

        
        
    
