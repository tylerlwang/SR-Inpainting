function coeff = mlCombine(input, gTruth)
% input: input[N][M][R]
% gTruth: gTruth[N][R]
% where N is the index of images,
% M is the index of inpainting methods,
% and R is the index of image pixels.

[N, M, R] = size(input);
A = zeros(M);  % A w = b, where w is the output coeff
b = zeros(1, M);
for i = 1 : N
    for j = 1 : R
        for r = 1 : M
            for c = 1 : M
                A(r, c) = A(r, c) + input(i, r, j) * input(i, c, j);
            end
            b(r) = b(r) + gTruth(i, j) * input(i, r, j);
        end
    end
end
coeff = A \ b;
return;
end