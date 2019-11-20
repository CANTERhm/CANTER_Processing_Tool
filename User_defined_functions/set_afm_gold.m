function set_afm_gold(varargin)
%%  AFM_GOLD: Function to set the afm gold colorbar for any suitable
%   plot witch accepts a colorbar definition.
%   The colorbar is set on the active figure when the function is caled.
% 
%   set_afm_gold(offset,multiplier,line_num):
%   - As an optional input, offset and multiplier
%     defines the range of the colorbar using the CData standard deviation (sigma)
%     is ±(sigma*multiplier); the center of the colorbar is set to
%     (mean+(sigma*offset)).
% 
%     So the full colorbar range is:    (mean+(sigma*offset))±(sigma*multiplier)
% 
%     * Defaulvalues are: offset = 0.9 and multiplier = 2.2
% 
%   - Also as an optional input, the number of the line
%     object the colorbar is meant to be set can be given as a double. If not
%     set, the default is 1, so the colorbar is set for the first child of
%     the current active axes.
% 
%   EXAMPLE:
%   set_afm_gold();
%   set_afm_gold(1,2.5);
%   set_afm_gold(0.5,3,2);
% 
% 

    %% optional input
    if nargin < 1
        offset = 0.9;
    else
        offset = varargin{1};
    end
        
    if nargin < 2
        multiplier = 2.2;
    else
        multiplier = varargin{2};
    end
    
    if nargin < 3
        plot_num = 1;
    else
       plot_num = varargin{3}; 
    end

    %% load afm_darkgold
    load('afm_darkgold.mat','afm_darkgold');
    % set the colorbar on active plot
    colormap(afm_darkgold);
    % colorbar;
    image = findobj(gca,'Type','Image');
    
    if isempty(image)
       image = findobj(gca,'Type','Surface'); 
    end
    
    c_data = get(image(plot_num),'CData');
    c_data = reshape(c_data,[],1);
    % calculate color data statistics
    mu = mean(c_data,'omitnan');
    sigma = std(c_data,'omitnan');
    
    % calculate colorbar min and max
    cbar_range = sigma*multiplier;
    cbar_mean = mu+(offset*sigma);
    
    low =  cbar_mean - cbar_range;
    high =  cbar_mean + cbar_range;
    
    caxis([low high]);
    
    
    %% Madrill Easter Egg   -> run on own risk!
%     load('afm_darkgold.mat','afm_darkgold');
%     load('mandrill');
%     multiplier = 2.2;
%     offset = 0.9;
%     mand_fig = figure;
%     subplot(1,2,1);
%     imshow(X,[],'Colormap',map);   % original Picture
%     title('Original picture');
%     subplot(1,2,2);
%     imshow(X,[],'Colormap',afm_darkgold);
%     title('Picture with afm-darkgold colormap');
%     c_data = reshape(X,[],1);
%     mu = mean(c_data);
%     sigma = std(c_data);
%     cbar_range = sigma*multiplier;
%     cbar_mean = mu+(offset*sigma);
%     low =  cbar_mean - cbar_range;
%     high =  cbar_mean + cbar_range;
%     caxis([low high]);
%     mand_fig.WindowStyle = 'normal';
%     mand_fig.WindowState = 'maximized';

    
end



    