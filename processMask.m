clear;
oriMask = imread('Datasets/Current/mask2.png');
newMask = cat(3,255.*oriMask,255.*oriMask,255.*oriMask);
imwrite(newMask,'mask2.png')

