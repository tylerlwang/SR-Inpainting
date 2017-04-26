%%% Copyright (c) November 2008 by Bjoern S. Rueffer and Christopher M. 
%%% Kellett, School of Electrical Engineering and Computer Science, 
%%% University of Newcastle, Australia. All rights reserved.
%%%
%%% THIS SOFTWARE COMES WITHOUT ANY WARRANTY WHATSOEVER. USE AT YOUR OWN 
%%% RISK. THE AUTHORS OR THE UNIVERSITY OF NEWCASTLE CANNOT BE HELD
%%% RESPONSIBLE FOR ANY KIND OF CONSEQUENCES CAUSED BY USING OR NOT USING 
%%% THIS SOFTWARE.
%%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Setup a repeat 10-code.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

n=10; m=n-1; H=spalloc(n-1,n,2*(n-1)); 
for i=1:n-1, 
  H(i,i)=1; 
  H(i,i+1)=1; 
end
G=generatormatrix(H);
spy(H)                      % see what H looks like
spy(G)                      % see what G looks like
H2DS(H); % setup for the BP algorithm

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Alternatively: setup a random length-15 code of dimension 5.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

H=generate_H(10,15,.05); % 15-10 is 5 as we all know
%%
% at this stage H might not have full rank, in that case we just
% repeat this step
%%
global H
spy(H)                      % see what H looks like
saveas(gcf,'H.eps','eps'); 
G=generatormatrix(H);
spy(G)                      % see what G looks like
saveas(gcf,'G.eps','eps');
H2DS(H); % setup for the BP algorithm


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Now generate, encode and channel code a random message
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[m,n]=size(H); k=n-m;
message=double(rand(k,1)>0.5); % a k-vector of 0s and 1s
x=G*message; % x is now an n-vector of 0s and 1s (a codeword)
x_tilde=bpsk(x); % make that 1s and -1s (codeword in channel symbols)
iscodeword(hard_decision(x_tilde)) % everything OK up to here?


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Simulate transmission through an AWGN channel. Actually, we
% repeat as often as needed until the channel corrupts the
% transmitted codeword, so that we will have the opportunity to
% employ the iterative decoder. 
%
% 
% REPEAT FROM HERE TO VIEW PLOTS OF DIFFERENT TRAJECTORIES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


sigma=0.5; % the channel parameter

% generate a channel output which at first is not a codeword:
y=x_tilde+randn(n,1)*sigma^2; % the channel adds the noise
TRIES=100; t=0;
while iscodeword(hard_decision(y)) && t<TRIES,
  y=x_tilde+randn(n,1)*sigma; 
  t=t+1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Compute the a-priori log-likelihood ratios (u) and perfrom T
% iterations of the BP algorithm (actually, in our implementation,
% we do T HALF-iterations.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T=50; % (half-)iterations for BP to perform

u=4*y/(2*sigma^2); % compute a-posteriori LLRs
if  ~any(mod(H*double(y<0),2)),
  'y already represents a codeword'
  clf;
else
  'performing BP'
  Y=iterate_BP(T,u); % that means T (half-)iterations
  for k=1:T,
    if ~any(mod(H*double(Y(:,k)<0),2)),
      strcat('found a codeword at iteration _',num2str(k))
      break;
    end
  end
  plot(0:T,Y,'o-') 
end
