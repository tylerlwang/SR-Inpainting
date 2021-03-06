
clear;
original_image = imread('../Datasets/Current/input.png');
% mask = (original_image(:,:,2) == 255);
fillColor = [255 255 255];
mask = original_image(:,:,1)==fillColor(1) & ...
    original_image(:,:,2)==fillColor(2) & original_image(:,:,3)==fillColor(3);
weights = zeros(13,1);

for ind = 1:13
    imgFile = ['../Datasets/Current/topk' num2str(ind) '.png'];
    output_image = imread(imgFile);
    image_masked = cat(3,output_image(:,:,1).*uint8(mask),output_image(:,:,2).*uint8(mask),...
        output_image(:,:,3).*uint8(mask));
    % output_image_masked = cat(3,output_image(:,:,1).*uint8(original_image_2),output_image(:,:,2).*uint8(original_image_2),output_image(:,:,3).*uint8(original_image_2));
    [gb_thin_CSG, gb_thin_CS, gb_CS, orC, edgeImage, edgeComponents] = Gb_CSG(image_masked);
    % edgeComponents(linearIndices) = 0;
    weights(ind) = nnz(edgeComponents) / nnz(mask);
end
fid = fopen('../Datasets/Current/contour_cost.txt', 'wt');
fprintf(fid,'%f\n',weights);
fclose(fid);

