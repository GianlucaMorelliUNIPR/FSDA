function rho=OPTrho(x, c)
%OPTrho computes rho function for optimal weight function
%
%<a href="matlab: docsearch('optrho')">Link to the help function</a>
%
%  Required input arguments:
%
%    u:         n x 1 vector containing residuals or Mahalanobis distances
%               for the n units of the sample
%    c :        scalar greater than 0 which controls the robustness/efficiency of the estimator 
%               (beta in regression or mu in the location case ...) 
%
% Function OPTrho transforms vector u as follows 
%
%               |  (1/3.25*c^2) x^2/2                                                     |x|<=2c
%               |   
%   \rho(x,c) = |  (1/3.25) * (1.792 - 0.972 * (x/c)^2 + 0.432 * (x/c)^4 - 0.052 * (x/c)^6 + 0.002 * (x/c)^8)    2c<=|x|<=3c
%               |
%               |   1                                                                      |x|>3c                              
%
%
% References:
%
%  Remark: Yohai and Zamar (1988)  showed that the \rho function given above
%  is optimal in the following highly desirable sense: the final M estimate
%  has a breakdown point of one-half and minimizes the maximum bias under
%  contamination distributions (locally for small fraction of
%  contamination), subject to achieving a desidered nominal asymptotic
%  efficiency when the data are Gaussian.
%
% Copyright 2008-2014.
% Written by FSDA team
%
%
%<a href="matlab: docsearch('Tbrho')">Link to the help page for this function</a>
% Last modified 08-Dec-2013
%
% Examples:

%{

x=-6:0.01:6;
rhoOPT=OPTrho(x,2);
plot(x,rhoOPT)
xlabel('x','Interpreter','Latex')
ylabel('$\rho (x)$','Interpreter','Latex')

%}

%% Beginning of code


rho = ones(length(x),1);
absx=abs(x);

% x^2/2 /(3.25c^2) if x <=2*c
inds1 = absx <= 2*c;
rho(inds1) = x(inds1).^2 / 2 / (3.25*c^2);

% 1/(3.25) * ( 1.792 .... +0.002 (r/c)^8 )    if    2c< |x| <3c
inds1 = (absx > 2*c)&(absx <= 3*c);
x1 = x(inds1);
rho(inds1) = (1.792 - 0.972 * x1.^2 / c^2 + 0.432 * x1.^4 / c^4 - 0.052 * x1.^6 / c^6 + 0.002 * x1.^8 / c^8) / 3.25;

% 1 if r >3*c
end
