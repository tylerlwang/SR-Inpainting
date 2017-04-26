%%% Copyright (c) November 2008 by Bjoern S. Rueffer and Christopher M. 
%%% Kellett, School of Electrical Engineering and Computer Science, 
%%% University of Newcastle, Australia. All rights reserved.
%%%
%%% THIS SOFTWARE COMES WITHOUT ANY WARRANTY WHATSOEVER. USE AT YOUR OWN 
%%% RISK. THE AUTHORS OR THE UNIVERSITY OF NEWCASTLE CANNOT BE HELD
%%% RESPONSIBLE FOR ANY KIND OF CONSEQUENCES CAUSED BY USING OR NOT USING 
%%% THIS SOFTWARE.
%%% 

function plot_BP_output(y,mono,filename)
% plot_BP_output(y,mono,filename) - Plot a given output trajectory.
% If mono is supplied (regardless of its value), then plot in 
% monochrome, otherwise in color. If in addition a filename is
% supplied, save the figure to that file (in EPS format). Saving
% to a file implies that the plot will be monochrome.

global n
T=size(y); T=T(2)-1;

clf;
if nargin>1,
  plot(0:T,y,'ko-') % monochrome
else
  plot(0:T,y,'o-') % color
end
grid on;
axis([0 T min(min(y))-.5 max(max(y))+.5])
LEGEND=[];
for k=1:n,
  LEGEND=[LEGEND; strcat('output',num2str(k))];
end
legend(LEGEND)
xlabel('time'); ylabel('LLR');

if nargin==3,
  if isstr(filename),
    saveas(gcf,filename,'eps');    
  end
end
