function displayCrosshairInfo(src,data)
    pos = ceil(data.CurrentPosition);
    src.Label = sprintf('X: %3.4g',pos(1));           
end