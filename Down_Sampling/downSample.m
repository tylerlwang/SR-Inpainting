function low = downSample(high, k)
[X Y RGB] = size(high);
X = floor(X / k);
Y = floor(Y / k);
low = imresize(high, 1 / k, 'lanczos3');
for i = 1 : X
    for j = 1 : Y
        for deltaX = -(k - 1) : 0
            for deltaY = -(k - 1) : 0
                x = k * i + deltaX;
                y = k * j + deltaY;
                black = true;
                for rgb = 1 : RGB
                    if high(x, y, rgb) ~= 0
                        black = false;
                    end
                end
                if black == true
                    for ii = (i - 1) : (i + 1)
                        for jj = (j - 1) : (j + 1)
                            if ii <= 0 || ii > X || jj <= 0 || jj > Y
                                continue;
                            end
                            for rgb = 1 : RGB
                                low(ii, jj, rgb) = 0;
                            end
                        end
                    end
                    break;
                end
            end
            if black == true
                break;
            end
        end
    end
end
return;
end