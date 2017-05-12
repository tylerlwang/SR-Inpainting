clear;
for i = 1:4
    input = ['LBP' num2str(i) '.png'];
    low = imread(input);
    MagFactor = 2;
    high = SuperresCode(low, MagFactor);    %%% magnify the input image 'Low' by the factor of 'MagFactor' along each dimension.
    high = uint8(high);
    output = ['high' num2str(i) '.png'];
    imwrite(high,output);
end