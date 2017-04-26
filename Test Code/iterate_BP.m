%%% Copyright (c) November 2008 by Bjoern S. Rueffer and Christopher M. 
%%% Kellett, School of Electrical Engineering and Computer Science, 
%%% University of Newcastle, Australia. All rights reserved.
%%%
%%% THIS SOFTWARE COMES WITHOUT ANY WARRANTY WHATSOEVER. USE AT YOUR OWN 
%%% RISK. THE AUTHORS OR THE UNIVERSITY OF NEWCASTLE CANNOT BE HELD
%%% RESPONSIBLE FOR ANY KIND OF CONSEQUENCES CAUSED BY USING OR NOT USING 
%%% THIS SOFTWARE.
%%% 

function y = iterate_BP(T,u)
% y = iterate_BP(T,u) - This function implements the BP dynamical
%  system; the output trajectory is returned for final time T and
%  input u. The initial state is always zero. 

global B P S_ q n m

x1_k=zeros(q,1);
x2_k=zeros(q,1);
x1_k_1=zeros(q,1);
x2_k_1=zeros(q,1);

y=zeros(n,T+1); 
for t=1:T,
  x1_k_1=P*x2_k+B*u;
  x2_k_1=S(x1_k);
  y(:,t)=B' * x2_k + u;
  x1_k=x1_k_1;
  x2_k=x2_k_1;
end
y(:,T+1)=B' * x2_k + u;
