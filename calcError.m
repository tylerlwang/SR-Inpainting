function error = calcError(inpainted, gTruth, fillRegion)
num = size(find(fillRegion, 1));
[X, Y, RGB] = size(inpainted);
if X ~= size(gTruth, 1) || Y ~= size(gTruth, 2)
    fprintf('Error: Image sizes do not agree.\n');
    return;
end
error = 0;
C = 100 / 255 ^ 2 / (num * 3);
for i = 1 : X
    for j = 1 : Y
        for k = 1 : 3
            error = error + C * (inpainted(i, j, k) - gTruth(i, j, k)) ^ 2;
        end
    end
end
return;
end