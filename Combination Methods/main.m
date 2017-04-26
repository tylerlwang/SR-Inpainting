clear;
image1 = double(imread('5x5.png'));
image2 = double(imread('7x7.png'));
image3 = double(imread('9x9.png'));
image4 = double(imread('11x11.png'));
[X, Y, Z] = size(image1);
N = 4;
output = zeros(size(image1));
for i = 1 : 3  % R, G, B
    input = zeros(X, Y, N);
    input(:, :, 1) = image1(:, :, i);
    input(:, :, 2) = image2(:, :, i);
    input(:, :, 3) = image3(:, :, i);
    input(:, :, 4) = image4(:, :, i);
    output(:, :, i) = beliefPropagate(input, 2000, 0.002);
%     output(:, :, i) = meanOp(input);
%     output(:, :, i) = medianOp(input);
end

% imwrite(uint8(output), 'output.png');

subplot(2,3,1)
imshow('5x5.png');
subplot(2,3,2)
imshow('7x7.png');
subplot(2,3,3)
imshow('9x9.png');
subplot(2,3,4)
imshow('11x11.png');
subplot(2,3,6)
imshow(uint8(output));

calcError(image1, image2