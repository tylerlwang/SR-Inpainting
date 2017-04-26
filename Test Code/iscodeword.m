%%% Copyright (c) November 2008 by Bjoern S. Rueffer and Christopher M. 
%%% Kellett, School of Electrical Engineering and Computer Science, 
%%% University of Newcastle, Australia. All rights reserved.
%%%
%%% THIS SOFTWARE COMES WITHOUT ANY WARRANTY WHATSOEVER. USE AT YOUR OWN 
%%% RISK. THE AUTHORS OR THE UNIVERSITY OF NEWCASTLE CANNOT BE HELD
%%% RESPONSIBLE FOR ANY KIND OF CONSEQUENCES CAUSED BY USING OR NOT USING 
%%% THIS SOFTWARE.
%%% 

function yesno = iscodeword(x)
% ISCODEWORD - Return true if input x is a codeword, i.e., H*x = 0 (mod 2)
%

global H
yesno = all(mod(H*x,2)==0);

