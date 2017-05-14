%% Compute globalPb and hierarchical segmentation for an example image.

addpath(fullfile(pwd,'lib'));

%% 1. compute globalPb on a small image to test mex files
clear all; close all; clc;
fillImg = imread('output/img.png');
fillColor = [0 255 0];
fillRegion = fillImg(:,:,1)==fillColor(1) & ...
    fillImg(:,:,2)==fillColor(2) & fillImg(:,:,3)==fillColor(3);
ucm = zeros(size(fillImg,1),size(fillImg,2),13);

for ind = 1:8
    imgFile = ['output/' num2str(ind) '.mat'];
    load(imgFile);
    ucm(:,:,ind) = contours2ucm(gPb_orient, 'imageSize');
    temp = ucm(:,:,ind);
    %figure;imshow(temp);
    %temp = processImg(temp);
    subplot(2,4,ind); imshow(temp);
    rs(ind) = numel(find(temp(fillRegion)));
end
function temp = processImg(temp)
ind = find(temp(:));
mid = unique(temp(ind));
for i = 1:numel(temp)
    if temp(i) < mid(size(mid,1)-10)
        temp(i) = 0;
    end
end
end
