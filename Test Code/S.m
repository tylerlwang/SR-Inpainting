%%% Copyright (c) November 2008 by Bjoern S. Rueffer and Christopher M. 
%%% Kellett, School of Electrical Engineering and Computer Science, 
%%% University of Newcastle, Australia. All rights reserved.
%%%
%%% THIS SOFTWARE COMES WITHOUT ANY WARRANTY WHATSOEVER. USE AT YOUR OWN 
%%% RISK. THE AUTHORS OR THE UNIVERSITY OF NEWCASTLE CANNOT BE HELD
%%% RESPONSIBLE FOR ANY KIND OF CONSEQUENCES CAUSED BY USING OR NOT USING 
%%% THIS SOFTWARE.
%%% 

function y = S(x)
% S - the nonlinearity in the BP feedback system
%   
% y=S(x) is the vector obtained by applying the atanh
% formula to those indices of x corresponding to the ith
% row in the global matrix S_

global S_ q

y=ones(q,1);
for i=1:q,
  for j=find(S_(i,:)),
    y(i) = y(i) * tanh(x(j)/2);    
  end
end
y=2*atanh(y);
