clear;
w = [2 2 3 3 5 5 4 4 4 3 2 5 4]; % patch size = 2*w+1
fillColor = [0 0 0];
for i = 1:13
    if i <= 8
        dataTerm = 'sparse';
    else
        dataTerm = 'tensor';
    end
    if any(i == [2 4 6 8 13])
        imgFilename = 'image1R.png';
        fillFilename = 'image2R.png';
    else
        imgFilename = 'image1.png';
        fillFilename = 'image2.png';
    end
    inpainted = inpaint7(imgFilename,fillFilename,fillColor,w(i),dataTerm);
    name = [num2str(i) '_' num2str(w(i)) 'x' num2str(w(i))];
    imwrite(uint8(inpainted),[name,'.png'])
end