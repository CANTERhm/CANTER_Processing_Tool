function y = heaviside(x)
    % Custom HEAVISIDE step function
   y = zeros(size(x));
   y(x>0) = 1;
   y(x==0) = 0.5;
end