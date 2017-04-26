
function D = getSparseDataTerm(img,k,w,sz,fillRegion)
% might need to add fillRegionInitial to static one
image = 1/3*(img(:,:,1)+img(:,:,2)+img(:,:,3));
patchP = getpatch(sz,k,w);
window = getpatch(sz,k,4*w); %6w+3
N = numel(window);
Ns = 0;
sigma = 5;
for idx = 1:N
   patchJ = getpatch(sz,window(idx),w);
   if any(fillRegion(patchJ))
      continue; 
   end
   Ns = Ns + 1;
   weight(Ns) = exp(-distance(patchP,patchJ,fillRegion,image)/sigma^2);
   weight = weight / sum(weight);
   normw = norm(weight);
   D = normw * sqrt(Ns/N);
end
end

function d = distance(patchP,patchJ,fillRegion,image)
P = image(patchP);
J = image(patchJ);
pixels = find(~(fillRegion(patchP)));
pts = [P(pixels);J(pixels)];
d = sum((pts-mean(pts)).^2);
end