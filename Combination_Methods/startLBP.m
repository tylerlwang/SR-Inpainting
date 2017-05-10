clear;

imagefiles = dir('set1/*.png');      
nfiles = length(imagefiles);    % Number of files found
for i = 1 : 13
   currentfilename = imagefiles(i).name;
   addr = [imagefiles(i).folder '/' currentfilename];
   images(i).val = double(imread(addr));
   % images{i} = currentimage;
end

[X, Y, RGB] = size(images(1).val);
N = 13;
output = zeros(X, Y, RGB);
input = zeros(X, Y, RGB, N);
for i = 1 : N
    input(:, :, :, i) = images(i).val;
end
% output = beliefPropagate2(input, 0.001);
output = beliefPropagate(input, 100, 0.1);
% output = meanOp(input);
% output = medianOp(input);

% imwrite(uint8(output), 'output.png');

imshow(uint8(output));