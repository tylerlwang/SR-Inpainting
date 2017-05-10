function output = beliefPropagate(input, lambda, epsilon)
% Input: n inpainted images of resolution x * y,
% in the form of an x * y * 3 * n 4D matrix;
% lambda: a factor weighing betweening label cost and discontinuity cost;
% epsilon: condition of convergence
% Ouput: A combined x * y * 3 3D matrix using loopy belief propagation.

[X, Y, RGB, N] = size(input);
prev = zeros(X, Y);  % index of the origin of each pixel, ranging from 1 to N
curr = zeros(X, Y);
fill = 0;
for i = 1 : X
    for j = 1 : Y
        same = true;
        for k = 2 : N
            for rgb = 1 : 3
                if input(i, j, rgb, k) ~= input(i, j, rgb, 1)
                    same = false;
                    break;
                end
            end
            if same == false
                break;
            end
        end
        if same == true
            curr(i, j) = -1;
        else
            fill = fill + 1;
        end
    end
end
for i = 1 : X
    for j = 1 : Y
        if curr(i, j) ~= -1
            curr(i, j) = randi(N);
        end
    end
end
energy = 0;
for t = 1 : 20
    energy(t) = 0;
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
                            for rgb = 1 : 3
                                Vd(k) = Vd(k) + (input(x, y, rgb, k) - input(x, y, rgb, n)) ^ 2;
                            end
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
                    if curr(x, y) ~= -1 && curr(x, y) ~= k
                        Vs(k) = Vs(k) + lambda;
                    end
                end
                E(k) = Vd(k) + Vs(k);
                if E(k) < E(curr(i, j))
                    curr(i, j) = k;  % MAP estimation
                end
            end
            energy(t) = energy(t) + E(curr(i, j));
        end
    end
    diff = 0;
    for i = 1 : X
        for j = 1 : Y
            if curr(i, j) ~= prev(i, j)
                diff = diff + 1;
            end
        end
    end
    if diff < fill * epsilon
        fprintf('It converges after %d iterations in round %d\n', t, t1);
        tt = 1 : t;
        plot(tt, energy);
        output = zeros(X, Y);
        for i = 1 : X
            for j = 1 : Y
                for rgb = 1 : 3
                    output(i, j, rgb) = input(i, j, rgb, abs(curr(i, j)));
                end
            end
        end
        return;
    end
end
fprintf('It does not converge.\n');
end