function Wpdf = WNChygepdf(X,N,K,M,W)
%WNChygepdf returns Wallenius' non-central hypergeometric probability density values.
%
%<a href="matlab: docsearchFS('WNChygepdf')">Link to the help function</a>
%
% This function is taken from the toolbox "Generation of Random Variates"
% (function wallen_pdf.m) created by Jim Huntley, that can be found at the
% Mathworks page
% <a https://it.mathworks.com/matlabcentral/fileexchange/35008-generation-of-random-variates)</a>.
% In FSDA, the function is only used for showing the coherence of the
% non-central hypergeometric distribution probability density values with
% samples extracted with FSDA function randsampleFS using option for weighted
% sampling without replacement.
%
% To simplify the illustration of Wallenius' distribution parameters, let's use
% the classical urn example, with $m_{1}$ red balls and  $m_{2}$ white balls,
% totalling $N = m_{1}+m_{2} balls. $n$ balls are drawn at random from the urn
% one by one without replacement. Each red ball has the weight $\omega_{1}$, and
% each white ball has the weight $omega_{2}$; the probability ratio of red over
% white balls is then given by $W = \omega_{1} / \omega_{2}$.
%
%  Required input arguments:
%           X    : Total number of balls sampled. Scalar.
%                  Data Types - single|double
%           N    : Number of red balls sampled. Scalar.
%                  Data Types - single|double
%           K    : Initial number of red balls in the urn. Scalar.
%                  Data Types - single|double
%           M    : Total number of balls in urn before sampling. Scalar.
%                  Data Types - single|double
%           W    : Probability ratio of red over white balls. Scalar.
%                  Data Types - single|double
%
%  Optional input arguments:
%
%  Output:
%
%           Wpdf : Wallenius' pdf values. Probability of drawing exactly X of a
%                  possible K items in N drawings without replacement from a
%                  group of M objects, when objects are from two weighted groups.
%                  Array of numel(x) values.
%                  Data Types - single|double.
%
%
% See also randsampleFS.m, subsets.m.
%
% References:
%   A. Fog (2008). Calculation Methods for Wallenius' Noncentral Hypergeometric
%   Distribution. Communications in Statistics - Simulation and Computation
%   Volume 37, 2008 - Issue 2.
%
% Copyright 2008-2016.
% FSDA team adapted and documented Jim Huntley's function wallen_pdf for
% illustration purposes only.
%
%<a href="matlab: docsearchFS('WNChygepdf')">Link to the help function</a>
%
% Last modified 31-05-2016
%
% Examples:
%
%{
    %% Probability of getting 0 to p successes in p weighted drawns without replacement.
    M  = 500;   %we have 500 balls in the urn
    N  = 3;     %total number of red balls sampled
    K  = M/2;   %initially, in the urn we have 250 red and 250 white balls
    W  = 10;    %red balls are ten times the white balls
    % We compute the probability of getting 0, 1, 2 or 3 red balls in drawing
    % 3 balls without replacement.
    for x = 0:N
        wpdf(i+1) = WNChygepdf(x,N,K,M,W);
    end
    disp('Probability of getting 0 to p successes in p weighted drawns (non-central hypergeometric pdf):');
    disp(wpdf);

%}

n2  = N-X;
m2  = M-K;
d   = W*(K-X) + m2 - n2;
bc1 = bc(K,X);
bc2 = bc(m2,n2);
sum1 = 0;
for jn = 1:X+1
    sum1 = sum1 + (-1)^(jn-1) * bc(X,jn-1) * beta(n2+1,d+W*(jn-1));
end
Wpdf = bc1 * bc2 * d * sum1;

end