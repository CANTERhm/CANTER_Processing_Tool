function displayCrosshairInfoAndPatch(src,data,patch_obj)
    pos = ceil(data.CurrentPosition);
    src.Label = sprintf('X: %3.4g',pos(1));
    patch_obj.XData(2:3) = pos(1);
end