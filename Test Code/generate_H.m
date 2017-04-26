%%% Copyright (c) November 2008 by Bjoern S. Rueffer and Christopher M. 
%%% Kellett, School of Electrical Engineering and Computer Science, 
%%% University of Newcastle, Australia. All rights reserved.
%%%
%%% THIS SOFTWARE COMES WITHOUT ANY WARRANTY WHATSOEVER. USE AT YOUR OWN 
%%% RISK. THE AUTHORS OR THE UNIVERSITY OF NEWCASTLE CANNOT BE HELD
%%% RESPONSIBLE FOR ANY KIND OF CONSEQUENCES CAUSED BY USING OR NOT USING 
%%% THIS SOFTWARE.
%%% 

function H = generate_H(m,n,d)
% H = GENERATE_H (m,n,d) 
%
% generate a m by n parity check matrix, where the density is
% influenced by the parameter d (between zero and one)

H=sparse(m,n);
H=mod(H,2);
while not(all(sum(H,1)>=2) && all(sum(H,2)>=2)),
  H=H+abs(sprand(m,n,d))>0;
  H=mod(H,2);
end

