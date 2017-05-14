clear;
w = [2 2 3 3 5 5 4 4 4 3 2 5 4]; % patch size = 2*w+1
fillColor = [0 255 0];
mkdir('../Datasets/','workingset')
for i = 1:13
    if i <= 6
        dataTerm = 'isophote';
    else
        dataTerm = 'tensor';
    end
    if any(i == [2 4 6 8 10 12])
        %imgFilename = 'img1R.png';
        %fillFilename = 'img2R.png';
        imgFilename = 'B1.png';
        fillFilename = 'B1.png';
        K = 3;
    else
        imgFilename = 'B1.png';
        fillFilename = 'B1.png';
        K = 1;
    end
    inpainted = inpaintK(imgFilename,fillFilename,fillColor,w(i),dataTerm,K);
    name = ['../Datasets/workingset/' num2str(i)];
    imwrite(uint8(inpainted),[name,'.png'])
end
command = 'cd ../LoopyBP; ./LoopyBP';
system(command);
mkdir('../Datasets/',['setNew' num2str(3)]);
command = ['mv ../Datasets/workingset/* ../Datasets/setNew' num2str(3)];
system(command);