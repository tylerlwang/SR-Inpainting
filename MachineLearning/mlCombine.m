function coeff = mlCombine(input, gTruth)
[N, M, R] = size(input);
coeff = zeros(1, M);
for i = 1 : N
    