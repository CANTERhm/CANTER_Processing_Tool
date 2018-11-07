function [y_corrected, varargout]=OffsetCorrection(y, baseline_edges, varargin)
% OffsetCorrection Via the baseline_edges from the BaselineFinder 
% it does correct the offset of a forcecurve(extend or/and retract part).
% 
% [y_corrected] = OffsetCorrection(y_original, baseline_edges)
%
% The baseline_edges should be an array where (1,1) = minimum & (1,2) =
% maximum (Recommendation: Use the BaselineFinder)
%
% Function can also correct the offset of the associated retract curve
%
% [y_corrected, y_retract_corrected] = OffsetCorrection(y_original, baseline_edges, y_retract_original)
%

    % Define the varargin
    if nargin == 3
        y_retract = varargin{1};
    end

    %Get the baseline via the baselineedges
    y_fit = y(baseline_edges(1,1):baseline_edges(1,2));
    
    % Get the mean value of the baseline
    ymean = mean(y_fit);

    % Offsetcorrection
    y_corrected = y-ymean;
    
    if nargin == 3
        y_retract_corrected = y_retract-ymean;
    end
    
    % Define the varargout
    if nargout == 2
      varargout{1} = y_retract_corrected;
    end
end
    
    
