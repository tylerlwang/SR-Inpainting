clear all;
close all;
Low = imread('Butterfly.bmp');
MagFactor = 3;
High = SuperresCode(Low, MagFactor);    %%% magnify the input image 'Low' by the factor of 'MagFactor' along each dimension.
High = uint8(High);
imwrite(High,'HighResol.png');

NNLow = imresize(Low, MagFactor, 'nearest');
subplot(1,2,1);
image(NNLow(:,200:350,:));
axis image;
subplot(1,2,2);
image(High(:,200:350,:));
axis image;

display('done.');
