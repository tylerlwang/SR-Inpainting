clear;
imgOri = imread('B0.png');
imgIn = imread('B1.png');

factor = 2;
Ori = imresize(imgOri,1/factor,'lanczos3');
In = imresize(imgIn,1/factor,'lanczos3');
% Ori = imgOri(1:factor:end,1:factor:end,:);
% In = imgIn(1:factor:end,1:factor:end,:);
imwrite(Ori,'image1.png');
imwrite(In,'image2.png');




