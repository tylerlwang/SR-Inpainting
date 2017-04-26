%%% Copyright (c) November 2008 by Bjoern S. Rueffer and Christopher M. 
%%% Kellett, School of Electrical Engineering and Computer Science, 
%%% University of Newcastle, Australia. All rights reserved.
%%%
%%% THIS SOFTWARE COMES WITHOUT ANY WARRANTY WHATSOEVER. USE AT YOUR OWN 
%%% RISK. THE AUTHORS OR THE UNIVERSITY OF NEWCASTLE CANNOT BE HELD
%%% RESPONSIBLE FOR ANY KIND OF CONSEQUENCES CAUSED BY USING OR NOT USING 
%%% THIS SOFTWARE.
%%% 

function x = hard_decision(u)
% HARD_DECISION - Map the LLR vector u to a binary vector x
%   
x1 = u < 0; x2 = 1 - (u>0);
x= .5 * (x1 + x2);

%% REMARK: 
% We assign the value 1/2 instead of 0 or 1 to the output, if the LLR
% is 0. We might also assign NaN, but that doesn't seem to have
% advantages.


