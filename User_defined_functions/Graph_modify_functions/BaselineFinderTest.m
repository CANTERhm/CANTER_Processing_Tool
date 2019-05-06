function [baseline_edges]=BaselineFinderTest(x,y)

y = smoothdata(y, 'Gaussian', 100);
y_grad = gradient(y, 100);

y_grad = y_grad/min(y_grad);
y_grad = smoothdata(y_grad, 'Gaussian', 100);
baseline = find(0.1>y_grad & y_grad>-0.1);

if size(baseline,2) > 300
    baseline = baseline(50:end-50);
end
if size(baseline,1) <= 20
    baseline(1) = 1;
    baseline(end) = 100;
end
baseline_edges(1, 1) = baseline(1);
baseline_edges(1, 2) = baseline(end);
baseline_edges(1, 3) = baseline(end);

end