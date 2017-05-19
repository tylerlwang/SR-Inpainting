clear;
output1 = imread('Datasets/Current/output_orig.png');
output2 = imread('Datasets/Current/output_improved.png');
output3 = imread('Datasets/Current/output_contour.png');
groundTruth = imread('Datasets/Current/groundTruth.png');
filled_image = imread('Datasets/Current/input.png');
fillColor = [255 255 255];
mask = filled_image(:,:,1)==fillColor(1) & ...
    filled_image(:,:,2)==fillColor(2) & filled_image(:,:,3)==fillColor(3);

for i = 1:3
    output = eval(strcat('output', num2str(i)));
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
    plot(0:0.05:1, roc);
    hold on
end
legend('original','improved','contour');
xlabel('Threshold')
ylabel('Rate of Correctness')