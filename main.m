clear;

% 1. Perform exemplar-based inpainting 13 times
w = [2 2 3 3 5 5 4 4 4 3 2 5 4];  % patch size = 2 * w + 1
fillColor = [0 255 0];
cd Exemplar-Based_Inpainting;
% for i = 1 : 13
%     if i <= 6
%         dataTerm = 'isophote';
%     else
%         dataTerm = 'tensor';
%     end
%     if any(i == [2 4 6 8 10 12])
%         K = 3;
%     else
%         K = 1;
%     end
%     imgFilename = '../Datasets/Current/input.png';
%     inpainted = inpaintK(imgFilename, imgFilename, fillColor, w(i), dataTerm, K);
%     imwrite(uint8(inpainted), ['../Datasets/Current/', num2str(i), '.png']);
% end

% 2. Run C++ programs loopy belief propagation
cd ../LoopyBP;
system('./bp_orig');

% 3. Draw ROC(Receiver Operating Characteristic) graphs
cd ../Datasets/Current;
