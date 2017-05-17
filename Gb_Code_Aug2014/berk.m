% B = bwboundaries(original_image(:,:,2) == 255);
% B = B{1};
% linearIndices = sub2ind([size(original_image,1) size(original_image,2)],B(:,1),B(:,2));


original_image_2 = (original_image(:,:,2) == 255);
output_image = imread('1.png');
output_image_masked = cat(3,output_image(:,:,1).*uint8(original_image_2),output_image(:,:,2).*uint8(original_image_2),output_image(:,:,3).*uint8(original_image_2));
[gb_thin_CSG, gb_thin_CS, gb_CS, orC, edgeImage, edgeComponents] = Gb_CSG(output_image_masked);
% edgeComponents(linearIndices) = 0;



output_image_2 = imread('5.png');
output_image_masked_2 = cat(3,output_image_2(:,:,1).*uint8(original_image_2),output_image_2(:,:,2).*uint8(original_image_2),output_image_2(:,:,3).*uint8(original_image_2));
[gb_thin_CSG, gb_thin_CS, gb_CS, orC, edgeImage, edgeComponents2] = Gb_CSG(output_image_masked_2);
% edgeComponents2(linearIndices) = 0;

nnz(edgeComponents) / nnz(original_image_2)
nnz(edgeComponents2) / nnz(original_image_2)
