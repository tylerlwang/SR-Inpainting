clear;
output = imread('temp/output.png');
groundTruth = imread('temp/groundTruth.png');
filled_image = imread('temp/img.png');
fillColor = [0 0 0];
mask = filled_image(:,:,1)==fillColor(1) & ...
    filled_image(:,:,2)==fillColor(2) & filled_image(:,:,3)==fillColor(3);
ind = 1;

for threshold = 0:0.05:1
    rs = true(nnz(mask),1);
    for channel = 1:3
        temp = groundTruth(:,:,channel);
        gt_masked = temp(find(mask));
        temp = output(:,:,channel);
        output_masked = temp(find(mask));
        
        upper = min(255, gt_masked.*(1+threshold));
        lower = max(0,gt_masked.*(1-threshold));
        
        rs = rs & output_masked <= upper;
        rs = rs & output_masked >= lower;
    end
    roc(ind) = nnz(rs) / nnz(mask);
    ind = ind + 1;
end
plot(0:0.05:1,roc)
