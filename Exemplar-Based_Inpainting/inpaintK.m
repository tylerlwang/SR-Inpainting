function [inpaintedImg,origImg,fillImg,C,D,fillMovie] = inpaintK(imgFilename,fillFilename,fillColor,w,dataTerm,K)
%INPAINT  Exemplar-based inpainting.
%
% Usage:   [inpaintedImg,origImg,fillImg,C,D,fillMovie] ...
%                = inpaint(imgFilename,fillFilename,fillColor)
% Inputs: 
%   imgFilename    Filename of the original image.
%   fillFilename   Filename of the image specifying the fill region. 
%   fillColor      1x3 RGB vector specifying the color used to specify
%                  the fill region.
%   w              Patch size using for inpainting, actual patch size is 2
%                  * 2 + 1
%   dataTerm       Dataterm used for calculating priority, options are: 
%                  'isophote', 'tensor', 'sparse'
%   K              The number of Top K patches 

% Outputs:
%   inpaintedImg   The inpainted image; an MxNx3 matrix of doubles. 
%   origImg        The original image; an MxNx3 matrix of doubles.
%   fillImg        The fill region image; an MxNx3 matrix of doubles.
%   C              MxN matrix of confidence values accumulated over all iterations.
%   D              MxN matrix of data term values accumulated over all iterations.
%   fillMovie      A Matlab movie struct depicting the fill region over time. 
%
% Example:
%   [i1,i2,i3,c,d,mov] = inpaint('B0.png','B1.png',[0 255 0],5,'isophote',3);
%   plotall;           % quick and dirty plotting script
%   close; movie(mov); % grab some popcorn 
%
%   author: Sooraj Bhat
%   Modified by Jiacheng Guo & Tyler L.Wang
%   05/19/2017 to run on Matlab R2016b
   

warning off MATLAB:divideByZero
[img,fillImg,fillRegion] = loadimgs(imgFilename,fillFilename,fillColor);
img = double(img);
origImg = img;
ind = img2ind(img);
sz = [size(img,1) size(img,2)];
sourceRegion = ~fillRegion;

% Initialize isophote values
[Ix(:,:,3) Iy(:,:,3)] = gradient(img(:,:,3));
[Ix(:,:,2) Iy(:,:,2)] = gradient(img(:,:,2));
[Ix(:,:,1) Iy(:,:,1)] = gradient(img(:,:,1));
Ix = sum(Ix,3)/(3*255); Iy = sum(Iy,3)/(3*255);
temp = Ix; Ix = -Iy; Iy = temp;  % Rotate gradient 90 degrees

% Initialize confidence and data terms
C = double(sourceRegion);
D = repmat(-.1,sz);
iter = 1;
% Visualization stuff
if nargout==6
  fillMovie(1).cdata=uint8(img); 
  fillMovie(1).colormap=[];
  origImg(1,1,:) = fillColor; %weird part
  iter = 2;
end

% Seed 'rand' for reproducible results (good for testing)
rand('state',0);

% Initialize patch size
%w = 5;

% Loop until entire fill region has been covered
while any(fillRegion(:))
  % Find contour & normalized gradients of fill region
  fillRegionD = double(fillRegion); % Marcel 11/30/05
  dR = find(conv2(fillRegionD,[1,1,1;1,-8,1;1,1,1],'same')>0); % Marcel 11/30/05
 %dR = find(conv2(fillRegion,[1,1,1;1,-8,1;1,1,1],'same')>0);  % Original
  
  [Nx,Ny] = gradient(double(~fillRegion)); % Marcel 11/30/05
 %[Nx,Ny] = gradient(~fillRegion);         % Original
  N = [Nx(dR(:)) Ny(dR(:))];
  N = normr(N);  
  N(~isfinite(N))=0; % handle NaN and Inf
  
  % Compute confidences along the fill front
  for k=dR'
      Hp = getpatch(sz,k,w); % each value represents the index of pixel in image
      q = Hp(~(fillRegion(Hp)));
      C(k) = sum(C(q))/numel(Hp);
  end
  
  switch dataTerm
      case 'tensor'
          for k=dR'
              Hp = getpatch(sz,k,w);
              D(k) = getTensorDataTerm(img,Hp,w);
          end
          
      case 'sparse'
          for k=dR'
              D(k) = getSparseDataTerm(img,k,w,sz,fillRegion);
          end
          
      case 'isophote'
          D(dR) = abs(Ix(dR).*N(:,1)+Iy(dR).*N(:,2)) + 0.001;
          
      otherwise
           warning('Unexpected dataTerm.')
  end
  
  % Compute patch priorities = confidence term * data term
  priorities = C(dR).* D(dR);
  
  
  % Find patch with maximum priority, Hp
  [unused,ndx] = max(priorities(:));
  p = dR(ndx(1));
  [Hp,rows,cols] = getpatch(sz,p,w);
  toFill = fillRegion(Hp);
  
  % Find exemplar that minimizes error, Hq
  Hq = bestexemplar(img,img(rows,cols,:),toFill',sourceRegion,K);
  
  % Update fill region
  toFill = logical(toFill);                 % Marcel 11/30/05
  fillRegion(Hp(toFill)) = false;
  
  % Propagate confidence & isophote values
  C(Hp(toFill))  = C(p);
  IxTemp = zeros(size(Hp(toFill)));
  IyTemp = zeros(size(Hp(toFill)));
  for i = 1:K
      HqTemp = Hq(:,:,i); 
      IxTemp = IxTemp + Ix(HqTemp(toFill));
      IyTemp = IyTemp + Iy(HqTemp(toFill));
  end
  Ix(Hp(toFill)) = IxTemp/K;
  Iy(Hp(toFill)) = IyTemp/K;
%   Ix(Hp(toFill)) = (Ix(Hq1(toFill))+Ix(Hq2(toFill))+Ix(Hq3(toFill)))/3;
%   Iy(Hp(toFill)) = (Iy(Hq1(toFill))+Iy(Hq2(toFill))+Iy(Hq3(toFill)))/3;
  
  % Copy image data from Hq to Hp
  bestHq = Hq(:,:,1);
  ind(Hp(toFill)) = ind(bestHq(toFill));
  
  imgTemp = zeros(size(rows,2),size(cols,1),3);
  for i = 1:K
      HqTemp = Hq(:,:,i);
      indTemp = ind;
      indTemp(Hp(toFill)) = ind(HqTemp(toFill));
      imgTemp = imgTemp + ind2img(indTemp(rows,cols),origImg);
  end
  img(rows,cols,:) = imgTemp / K;
  
%   ind1(Hp(toFill)) = ind(Hq1(toFill));
%   ind2(Hp(toFill)) = ind(Hq2(toFill));
%   ind3(Hp(toFill)) = ind(Hq3(toFill));
%   img(rows,cols,:) = (ind2img(ind1(rows,cols),origImg)+...
%       ind2img(ind2(rows,cols),origImg)+ind2img(ind3(rows,cols),origImg))/3;
  
  % Visualization stuff
  if nargout==6
    ind2 = ind;
    ind2(logical(fillRegion)) = 1;          % Marcel 11/30/05
    %ind2(fillRegion) = 1;                  % Original
    fillMovie(iter).cdata=uint8(ind2img(ind2,origImg)); 
    fillMovie(iter).colormap=[];
  end
  iter = iter+1;
end

inpaintedImg=uint8(img);


%---------------------------------------------------------------------
% Scans over the entire image (with a sliding window)
% for the exemplar with the lowest error. Calls a MEX function.
%---------------------------------------------------------------------
function Hq = bestexemplar(img,Ip,toFill,sourceRegion,K)
m=size(Ip,1); mm=size(img,1); n=size(Ip,2); nn=size(img,2);
best = bestexemplarhelperK(mm,nn,m,n,K,img,Ip,toFill,sourceRegion);
Hq = zeros(n,m,K);
for i = 1:K
   Hq(:,:,i) = sub2ndx(best(4*(i-1)+1):best(4*(i-1)+2),(best(4*(i-1)+3):best(4*(i-1)+4))',mm);
end
% Hq1 = sub2ndx(best(1):best(2),(best(3):best(4))',mm);
% Hq2 = sub2ndx(best(5):best(6),(best(7):best(8))',mm);
% Hq3 = sub2ndx(best(9):best(10),(best(11):best(12))',mm);


%---------------------------------------------------------------------
% Returns the indices for a 9x9 patch centered at pixel p.
%---------------------------------------------------------------------
function [Hp,rows,cols] = getpatch(sz,p,w)
% [x,y] = ind2sub(sz,p);  % 2*w+1 == the patch size
%w=5; 
p=p-1; y=floor(p/sz(1))+1; p=rem(p,sz(1)); x=floor(p)+1;
rows = max(x-w,1):min(x+w,sz(1));
cols = (max(y-w,1):min(y+w,sz(2)))';
Hp = sub2ndx(rows,cols,sz(1));


%---------------------------------------------------------------------
% Converts the (rows,cols) subscript-style indices to Matlab index-style
% indices.  Unforunately, 'sub2ind' cannot be used for this.
%---------------------------------------------------------------------
function N = sub2ndx(rows,cols,nTotalRows)
X = rows(ones(length(cols),1),:);
Y = cols(:,ones(1,length(rows)));
N = X+(Y-1)*nTotalRows;


%---------------------------------------------------------------------
% Converts an indexed image into an RGB image, using 'img' as a colormap
%---------------------------------------------------------------------
function img2 = ind2img(ind,img)
for i=3:-1:1, temp=img(:,:,i); img2(:,:,i)=temp(ind); end;


%---------------------------------------------------------------------
% Converts an RGB image into a indexed image, using the image itself as
% the colormap.
%---------------------------------------------------------------------
function ind = img2ind(img)
s=size(img); ind=reshape(1:s(1)*s(2),s(1),s(2));


%---------------------------------------------------------------------
% Loads the an image and it's fill region, using 'fillColor' as a marker
% value for knowing which pixels are to be filled.
%---------------------------------------------------------------------
function [img,fillImg,fillRegion] = loadimgs(imgFilename,fillFilename,fillColor)
img = imread(imgFilename); fillImg = imread(fillFilename);
% img = imgFilename; fillImg = fillFilename;
fillRegion = fillImg(:,:,1)==fillColor(1) & ...
    fillImg(:,:,2)==fillColor(2) & fillImg(:,:,3)==fillColor(3);
% fillRegion = fillImg(:,:,1)==fillColor(1) & ...
%     fillImg(:,:,2)==fillColor(2) & fillImg(:,:,3)==fillColor(3);

function [A] = normr(N)
    for ii=1:size(N,1)
        A(ii,:) = N(ii,:)/norm(N(ii,:));
    end
%
%

function D = getTensorDataTerm(img,Hp,w)
%w = 5;
sigma = 1^2;
J = zeros(2,2);
[m,n] = size(Hp);
patch = zeros(m,n,3);
for i = 1:3
   imgT = img(:,:,i);
   patch(:,:,i) = imgT(Hp);
end

for i = 1:3
    [Ix,Iy]=gradient(patch(:,:,i));
    e1=0;e2=0;e3=0;e4=0;
    for r = -w:w
        e1 = e1 + 1/(2*pi*sigma)*exp(-(w^2)/(2*sigma))*Ix(w+1,min(w+1-r,n))^2;
        e2 = e2 + 1/(2*pi*sigma)*exp(-(2*w^2)/(2*sigma))*Ix(w+1,min(w+1-r,n))*Iy(min(w+1-r,m),w+1);
        e3 = e2;
        e4 = e4 + 1/(2*pi*sigma)*exp(-(w^2)/(2*sigma))*Iy(min(w+1-r,m),w+1)^2;
    end
    J = J + [e1 e2;e3 e4];
end
e = eig(J);
D = 0.01 + (1-0.01)*exp(-8/(e(1)-e(2))^2);

function D = getSparseDataTerm(img,k,w,sz,fillRegion)
% might need to add fillRegionInitial 
image = 1/3*(img(:,:,1)+img(:,:,2)+img(:,:,3));
patchP = getpatch(sz,k,w);
window = getpatch(sz,k,2*w); %6w+3
N = numel(window);
Ns = 0;
sigma = 5;
weight(1) = 0;
for idx = 1:N
    patchJ = getpatch(sz,window(idx),w);
    if any(fillRegion(patchJ))
        continue;
    end
    Ns = Ns + 1;
    weight(Ns) = exp(-distance(patchP,patchJ,fillRegion,image)/sigma^2);
end
weight = weight / sum(weight);
normw = norm(weight);
D = normw * sqrt(Ns/N);


function d = distance(patchP,patchJ,fillRegion,image)
P = image(patchP);
J = image(patchJ);
pixels = find(~(fillRegion(patchP)));
check = pixels(:)<=numel(P) & pixels(:)<=numel(J);
pixels = pixels(check);
pts = [P(pixels);J(pixels)];
d = sum((pts-mean(pts)).^2);

