clear;
imgOri = imread('a0.png');
imgIn = imread('a1.png');

factor = 4;
Ori = imresize(imgOri,1/factor);
In = imresize(imgIn,1/factor);
% Ori = imgOri(1:factor:end,1:factor:end,:);
% In = imgIn(1:factor:end,1:factor:end,:);




