clear;

% 1. Perform exemplar-based inpainting 13 times
w = [2 2 3 3 4 4 5 5 6 6 7 7 8];  % patch size = 2 * w + 1
fillColor = [255 255 255];
cd Exemplar-Based_Inpainting;
parfor i = 1 : 13
    if any(i == [1 3 5 7 9 11])
        dataTerm = 'isophote';
    else
        dataTerm = 'tensor';
    end
    imgFilename = '../Datasets/Current/groundTruth.png';
    fillFilename = '../Datasets/Current/input.png';
    K = 1;
    inpainted = inpaintK(imgFilename, fillFilename, fillColor, w(i), dataTerm, K);
    imwrite(uint8(inpainted), ['../Datasets/Current/orig', num2str(i), '.png']);
    K = 3;
    inpainted = inpaintK(imgFilename, fillFilename, fillColor, w(i), dataTerm, K);
    imwrite(uint8(inpainted), ['../Datasets/Current/topk', num2str(i), '.png']);
end

% 2. Calculate contour-based costs
cd ../Contour_Gb
calculate_cost;

% 3. Run C++ programs loopy belief propagation
cd ../LoopyBP;
system('./bp_orig');
system('./bp_improved');
system('./bp_contour');
delete ../Datasets/Current/contour_cost.txt

% 4. Draw ROC(Receiver Operating Characteristic) graphs
cd ..;
Calculate_ROC;
