function [image_linear, image_cubic] = ImageInterpolationMFP(x_pixel,y_pixel,imagedata)
   
    %%Height interpolation
    xvector = linspace(1,x_pixel,x_pixel);
    yvector = linspace(1,y_pixel,y_pixel);

    F = griddedInterpolant({xvector,yvector},imagedata);
    % refined grid (20 times finer)
    x_interp = linspace(min(xvector),max(xvector),x_pixel*20);
    y_interp = linspace(min(yvector),max(yvector),y_pixel*20);
    y_interp = flip(y_interp',1);
    % linear interpolation
    F.Method = 'linear';
    linear_interpol = F({x_interp,y_interp});
    linear_interpol = flip(linear_interpol,2);
    image_linear = linear_interpol;
    % bicubic interpolation
    F.Method = 'cubic';
    bicubic_interpol = F({x_interp,y_interp});
    bicubic_interpol = flip(bicubic_interpol,2);
    image_cubic = bicubic_interpol;
    
end