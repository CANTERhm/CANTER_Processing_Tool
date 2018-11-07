function [varargout] = histogram_fits(x,varargin)
%% HISTOGRAM_FITS: generates a histogram of the vector given to this
%                  function and fits a specified ditribution to it. 
%
% [op1] = histogram_fits(x)
% [op1,op2] = histogram_fits(x,FitType)
% [op1,op2] = histogram_fits(x,FitType,BinNum)
% 
% -------------------------------------------------------------------------
% 
% [op1] = histogram_fits(x)
% • This function creats a histogram from the
% • data given in X as a numeric array.
% • In the optional output variable OP1 can be optained the histogram 
%   informations stored in a struct.
% 
% -> histogram  struct contains the following informations:
%    - BinCenters (x values of histogram)
%    - BinCounts (y values of histogram)
%    - BinWidth (The width of a bin stored as a double)
%    - BinNum (The number of bins as a double)
%    - BinEdges (The values of the bin edges as a vector)
% 
% -------------------------------------------------------------------------
% 
% [op1,op2] = histogram_fits(x,FitType)
% • Tis function creats a histogram from the data given in x as a numeric
%   array.
% • In FITTYPE a function can be choosen who is fittet on the histogram as
%   a string.
% 
%   -> Allowed strings are:
%      - 'none'     (if you don't want a fit in the histogram but you want
%                    to choose a number of bins, shown in the next section)
%      - 'gauss'    (a gaussian function will be fitted on the histogram)
%      - 'bimodal'  (a sum function of two gaussian functions will be fitted
%                    on the histogram)
% 
% • In the optional output variable OP1 can be optained the histogram
%   informations stored in a struct (for more information about the struct,
%   see the section above).
% • In the optional output variable OP2 can be optained the the fit results
%   as a cfit object. From the cfit object informations of the fit can
%   be optained with the following functions:
%       - argnames (Input argument names)
%       - coeffnames (Coefficient names)
%       - coeffvalues (Fitted coefficient values)
%       - formula (a string containing the fitted function)
%       - plot (plots the fitted function)
%   [for a full list type 'methods cfit' in the command window line]
%
% -------------------------------------------------------------------------
% 
% [op1,op2] = histogram_fits(x,FitType,BinNum)
% • Tis function creats a histogram from the data given in x as a numeric
%   array.
% • In FITTYPE a function can be choosen who is fittet on the histogram as
%   a string. For a list of allowed strings look in the section above.
% • In the optional output variable OP1 can be optained the histogram
%   informations stored in a struct (for more information about the struct,
%   see the fist section).
% • In the optional output variable OP2 can be optained the the fit results
%   as a cfit object. For a list of some methods to get informations about
%   the fit from the cfit object, look at the section above or type 
%   'methods cfit' in the command window line.
% • In BINNUM the number of bins of the histogram can be chosen with a
%   positive integer.
% 
% -------------------------------------------------------------------------
% 
% EXAMPLES:
% [histogram_info,fit_object] = histogram_fits(histogram_data,'none',20)
% [histogram_info,fit_object] = histogram_fits(histogram_data,'gauss',25)
% [histogram_info,fit_object] = histogram_fits(histogram_data,'bimodal',50)
% 
% 

%% initialising inputParser for required and optional parameters
p = inputParser;

% required histogram dataset
checkData = @isnumeric;
addRequired(p,'histogramdata',checkData);

% optional parameter for function type
defaultType = 'none';
validTypes = {'none','gauss','bimodal'};
checkType = @(x) any(validatestring(x,validTypes));
addOptional(p,'FunType',defaultType,checkType);

% optional paramter for number of bins
dafaultNum = -1;
checkNum = @(x) isscalar(x) && x > 0;
addOptional(p,'BinNum',dafaultNum,checkNum);

% parse all opional inputs to inputParser
parse(p,x,varargin{:});

%% generate histogram from dataset
if p.Results.BinNum == -1
    h = histogram(x);
else
    h = histogram(x,p.Results.BinNum);
end

%% extracting x- and y-values from histogram handle
y_fit = h.BinCounts;
bins = h.BinEdges(1:2);
num = h.NumBins;
x_fit(1:num) = 0;
x_fit(1) = mean([bins(1) bins(2)]);
width = bins(2)-bins(1);
for i = 2:num
    x_fit(i) = x_fit(i-1)+width;
end

% adjust axis of plot
x_offset = (max(h.BinEdges)-min(h.BinEdges))*0.1;
y_offset = (max(h.BinCounts))*0.1;
axis([min(h.BinEdges)-x_offset max(h.BinEdges)+x_offset 0 max(h.BinCounts)+y_offset]);

% five histogram parameters as output
varargout{1} = struct('BinCenters',x_fit,'BinCounts',y_fit,'BinWidth',...
                      width,'BinNum',num,'BinEdges', h.BinEdges);

%% fitting the chosen distribution on histogram data and give back fit results
if ~strcmp(p.Results.FunType ,'none')
    switch p.Results.FunType      
        case 'gauss'
            gauss_fit = fit(x_fit',y_fit','gauss1');
            varargout{2} = gauss_fit;
            hold on
            plot(gauss_fit);
            ylabel('Frequenzy');
            xlabel(inputname(1));
            his_leg = sprintf('histogram of %s',inputname(1));
            legend(his_leg,'gauss fit');
            coef = coeffvalues(gauss_fit);
            his_title = sprintf('fitted function: a1*exp(-((x-b1)/c1)^2)\n');
            his_ann = sprintf('Fit-Results:\na1: %g\nb1: %g\nc1: %g',coef(1),coef(2),coef(3));
            annotation('textbox',[.15 .75 .1 .1],'String',his_ann,'FitBoxToText','on');
            title(his_title);
            hold off
        case 'bimodal'
            bimodal_fit = fit(x_fit',y_fit','gauss2');
            varargout{2} = bimodal_fit;
            hold on
            plot(bimodal_fit);
            ylabel('Frequenzy');
            xlabel(inputname(1));
            his_leg = sprintf('histogram of %s',inputname(1));
            legend(his_leg,'bimodal fit');
            coef = coeffvalues(bimodal_fit);
            his_title = sprintf('fitted function: a1*exp(-((x-b1)/c1)^2) + a2*exp(-((x-b2)/c2)^2)');
            his_ann = sprintf('Fit-Results:\na1: %g\nb1: %g\nc1: %g\na2: %g\nb2: %g\nc2: %g',...
                              coef(1),coef(2),coef(3),coef(4),coef(5),coef(6));
            annotation('textbox',[.15 .75 .1 .1],'String',his_ann,'FitBoxToText','on');
            title(his_title);
            hold off
    end
end

