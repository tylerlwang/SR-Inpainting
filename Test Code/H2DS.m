%%% Copyright (c) November 2008 by Bjoern S. Rueffer and Christopher M. 
%%% Kellett, School of Electrical Engineering and Computer Science, 
%%% University of Newcastle, Australia. All rights reserved.
%%%
%%% THIS SOFTWARE COMES WITHOUT ANY WARRANTY WHATSOEVER. USE AT YOUR OWN 
%%% RISK. THE AUTHORS OR THE UNIVERSITY OF NEWCASTLE CANNOT BE HELD
%%% RESPONSIBLE FOR ANY KIND OF CONSEQUENCES CAUSED BY USING OR NOT USING 
%%% THIS SOFTWARE.
%%% 

function []=H2DS(H) 
% H2DS (H) 
%
% generate matrices for dynamical system associated to H, i.e., P,
% S_, and q, which are stored as global variables, as well as m and
% n, the dimensions of H

global B P S_ q m n

[m,n]=size(H);
q=nnz(H);

% calculate the amount of nonzero elements 
% needed for these matrices:
P=spalloc(q,q,(sum(H,2)-1)' * sum(H,2));
S_=spalloc(q,q,(sum(H,1)-1) * sum(H,1)');

% find the matrix P
k=0;
for j=1:n,
  I=find(H(:,j));
  for x=1:length(I),
    for y=x+1:length(I),
      P(k+x,k+y)=1;
      P(k+y,k+x)=1;      
    end
  end
  k=k+length(I);
end

% find S_ (structure for the nonlinearity S)
k=0;
for i=1:m,
  J=find(H(i,:));
  for x=1:length(J),
    for y=x+1:length(J),
      S_(k+x,k+y)=1;
      S_(k+y,k+x)=1;      
    end
  end
  k=k+length(J);
end

% compute matrix B
B=spalloc(q,n,q);
b=[];
for k=1:m,
  b=[b find(H(k,:))];
end
B=sparse([1:q]',b',ones(q,1),q,n);

