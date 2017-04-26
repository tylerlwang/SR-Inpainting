function output = beliefPropagate(input, lambda, epsilon)
% Input: n inpainted images of resolution x * y,
% in the form of an x * y * n 3D matrix;
% lambda: a factor weighing betweening label cost and discontinuity cost;
% Ouput: A combined x * y 2D matrix using loopy belief propagation.

T = 1000;  % maximum iterations
[X, Y, N] = size(input);
prev = zeros(X, Y);  % indices, ranging from 1 to N
curr = zeros(X, Y);
for i = 1 : X
    for j = 1 : Y
        curr(i, j) = randi(N);
    end
end
fill = X * Y;
for i = 1 : X
    for j = 1 : Y
        same = true;
        for k = 2 : N
            if input(i, j, k) ~= input(i, j, 1)
                same = false;
                break;
            end
        end
        if same == true
            curr(i, j) = -1;
            fill = fill - 1;
        end
    end
end
iter = 0;
while true
    prev = curr;
    for i = 1 : X
        for j = 1 : Y
            if prev(i, j) == -1
                curr(i, j) = -1;
                continue;
            end
            curr(i, j) = 1;
            Vd = zeros(1, N);
            Vs = zeros(1, N);
            E = zeros(1, N);
            for k = 1 : N
                for u = -1 : 1
                    for v = -1 : 1
                        for n = 1 : N
                            x = i + u;
                            y = j + v;
                            if x <= 0 || x > X || y <= 0 || y > Y
                                continue;
                            end
                            Vd(k) = Vd(k) + (input(x, y, k) - input(x, y, n)) ^ 2;
                        end
                    end
                end
                delta = [-1, 0; 1, 0; 0, -1; 0, 1];
                for m = 1 : 4
                    x = i + delta(m, 1);
                    y = j + delta(m, 2);
                    if x <= 0 || x > X || y <= 0 || y > Y
                        continue;
                    end
                    if prev(x, y) ~= -1 && prev(x, y) ~= k
                        Vs(k) = Vs(k) + lambda;
                    end
                end
                E(k) = Vd(k) + Vs(k);
                if E(k) < E(curr(i, j))
                    curr(i, j) = k;  % MAP estimation
                end
            end
        end
    end
    iter = iter + 1;
    diff = 0;
    for i = 1 : X
        for j = 1 : Y
            if curr(i, j) ~= prev(i, j)
                diff = diff + 1;
            end
        end
    end
    if diff < fill * epsilon
        fprintf('It converges after %d iterations\n', iter);
        break;
    end
    if iter == T
        fprintf('It does not converge after %d iterations\n', iter);
        break;
    end
end
output = zeros(X, Y);
for i = 1 : X
    for j = 1 : Y
        if curr(i, j) == -1
            output(i, j) = input(i, j, 1);
        else
            output(i, j) = input(i, j, curr(i, j));
        end
    end
end
end