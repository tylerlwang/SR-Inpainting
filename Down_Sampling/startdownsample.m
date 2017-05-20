clear;
imgOri = imread('../Datasets/Current/groundTruth.png');
imgIn = imread('../Datasets/Current/input.png');

factor = 3;
Ori = imresize(imgOri,1/factor,'lanczos3');
In = imgIn(1:factor:end,1:factor:end,:);
imwrite(Ori,'../Datasets/Current/groundTruth.png');
imwrite(In,'../Datasets/Current/input.png');




