clear;
imgGT = imread('../Datasets/Current/groundTruth.png');
imgIn = imread('../Datasets/Current/input.png');

factor = 3; % indicate the factor you want to downsample
Ori = imresize(imgGT,1/factor,'lanczos3');
%In = imresize(imgIn,1/factor,'lanczos3');
% Ori = imgOri(1:factor:end,1:factor:end,:);
In = imgIn(1:factor:end,1:factor:end,:);
imwrite(Ori,'../Datasets/Current/groundTruth.png');
imwrite(In,'../Datasets/Current/input.png');




