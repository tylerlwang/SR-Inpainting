%%% Copyright (c) November 2008 by Bjoern S. Rueffer and Christopher M. 
%%% Kellett, School of Electrical Engineering and Computer Science, 
%%% University of Newcastle, Australia. All rights reserved.
%%%
%%% THIS SOFTWARE COMES WITHOUT ANY WARRANTY WHATSOEVER. USE AT YOUR OWN 
%%% RISK. THE AUTHORS OR THE UNIVERSITY OF NEWCASTLE CANNOT BE HELD
%%% RESPONSIBLE FOR ANY KIND OF CONSEQUENCES CAUSED BY USING OR NOT USING 
%%% THIS SOFTWARE.
%%% 

function [H,final_column_weights,final_row_weights] = ...
    MacKayNealCreateCode(n,r,v,h)
% -------------------------------------------------------------------
% MacKay Neal algorithm for constructing parity-check matrix
%
% Date created: 3 November 2008
%
% Inputs: code length (n), code rate (r), column weight polynomial
%         (v), row weight polynomial (h)
%         
% Outputs: n(1-r) x n parity-check matrix (H), generated column
%          and row weight polynomials
%
% -------------------------------------------------------------------
% Sample parameters for rate-1/2, length 100, (3,6)-regular code
% n = 100;                     % Code length
% r = 0.5;                    % Code rate
% v = [0 0 1.0];                % Column distributions as polynomial
% h = [0 0 0 0 0 1.0];          % Row distribution as polynomial
% -------------------------------------------------------------------

% Initialisation
m = floor(n*(1-r));
H = zeros([m,n]);
alpha = [];              % alpha will contain the column weight for 
                         % each column
for i = 1:length(v)
    for j = 1:(floor(v(i)*n)) % always underfill and then add extras
                              % later
        alpha = [alpha i];
    end
end
while (length(alpha) ~= n) % fill out alpha to the appropriate length
    alpha = [alpha i];
end

beta = [];         % beta will contain the row weight for each row
for i=1:length(h)
    for j=1:(floor(h(i)*m)) % always underfill and then add extras
                            % later
        beta = [beta,i];
    end
end
while (length(beta) ~= m)  % fill out beta to the appropriate
                           % length
    beta = [beta i];
end

% Construction
for i = 1:n
    % construct column i
    c = [];
    beta_temp = beta;
    for j = 1:alpha(i)
        temp_row = randint(1,1,[1,m]);
     % We rule out choosing the same row twice for one column by 
     % indicating a selection in beta_temp with a -10.  We also
     % select a row that has yet to equal its desired row weight IF
     % POSSIBLE.  However, since we insist on getting the correct
     % column weight, we will end up with some rows having one too
     % many entries.  C'est la guerre.  The actual row weights thus
     % constructed are calculated below.  You should check that
     % they're not too far off...
        while (((beta_temp(temp_row) == 0) && ...
                (max(beta_temp) > 0)) || ...
               ((beta_temp(temp_row) <= -1)))
          temp_row = mod(temp_row+1,m)+1;
        end
        c = [c temp_row];
        beta_temp(temp_row) = -10;
    end

    % decrement entries in beta
    for k = 1:length(c)
        beta(c(k)) = beta(c(k))-1;
    end

    % populate H
    for j = 1:alpha(i)
        H(c(j),i) = 1;
    end
end

% Calculate actual column distribution
column_weights = H'*ones(m,1);
for i = 1:max(column_weights)
    count = 0;
    for j = 1:length(column_weights)
        if (column_weights(j)==i)
            count = count + 1;
        end
    end
    final_column_weights(i) = count/length(column_weights);
end

% Calculate actual row weights
row_weights = H*ones(n,1);
for i = 1:max(row_weights)
    count = 0;
    for j = 1:length(row_weights)
        if (row_weights(j)==i)
            count = count + 1;
        end
    end
    final_row_weights(i) = count/length(row_weights);
end