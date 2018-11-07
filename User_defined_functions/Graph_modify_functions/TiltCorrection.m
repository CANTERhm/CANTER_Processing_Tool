function [y_corrected, varargout]=TiltCorrection(x, y, baseline_edges, varargin)   
% TiltCorrection Via the baseline_edges from the BaselineFinder 
% it does correct the tilt of a forcecurve(extend or/and retract part).
% 
% [y_corrected] = TiltCorrection(x, y_original, baseline_edges)
%
% The baseline_edges should be an array where (1,1) = minimum & (1,2) =
% maximum (Recommendation: Use the BaselineFinder)
%
% Function can also correct the tilt of the associated retract curve
%
% [y_corrected, y_retract_corrected] = TiltCorrection(x, y_original, baseline_edges, x_retract, y_retract_original)
%   

    % Define varargin
    if nargin >= 4
        x_retract = varargin{1};
        assert(nargin~=5,'If you give this function x values for the retract part you also have to give y values!')
        y_retract = varargin{2};
    end
    
    %Get the baseline via the baselineedges
    x_fit = x(baseline_edges(1,1):baseline_edges(1,2));
    y_fit = y(baseline_edges(1,1):baseline_edges(1,2));
    
    % Fit the baseline to the given window
    [p, ~] = polyfit(x_fit,y_fit,1);

    y_corrected = y-p(1).*x;
    
    %Correct the retract part as well
    if nargin == 5
        y_retract_corrected = y_retract-p(1).*x_retract;
    end
    
    % Define varargout
    if nargout == 2
        varargout{1} = y_retract_corrected;
    end
end
