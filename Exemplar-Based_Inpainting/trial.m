clear;
img = imread('image1.png');
w = [2 2 3 3 5 5 4 4 4 3 2 5 4];
for i = 1:2
   name = [num2str(i) '_' num2str(w(i)) 'x' num2str(w(i))];
end