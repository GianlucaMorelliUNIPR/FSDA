function psiHA = HApsi(u, ctuning)
%HApsi computes psi function  using Hampel proposal
%
%<a href="matlab: docsearchFS('HApsi')">Link to the help function</a>
%
%  Required input arguments:
%
%    u:         scaled residuals or Mahalanobis distances. Vector. n x 1
%               vector containing residuals or Mahalanobis distances
%               for the n units of the sample
%    ctuning :  tuning parameters. Scalar or Vector. Scalar or vector of length 4 which specifies the value of the tuning
%                constant c (scalar greater than 0 which controls the
%                robustness/efficiency of the estimator)
%                and the prefixed values of paramters a, b, c
%                ctuning(1) = tuning constant which will multiply
%                parameters a, b and c of Hampel rho (psi) function
%                ctuning(2) = paramter a of Hampel rho (psi) function
%                ctuning(3) = paramter b of Hampel rho (psi) function
%                ctuning(4) = paramter c of Hampel rho (psi) function
%                Remark: if length(ctuning)==1 values of a, b and c will be
%                set to a=2*ctuning b=4*ctuning c=4*ctuning 
%                With these choices, if ctuning=1  the
%                resulting influence function is nearly identical to the
%                biweight with parameter 8.
%
%
% Optional input arguments:
%
%  Output:
%
%
%   psiHA :     n x 1 vector which contains the values of Hampel psi
%                function associated to the residuals or Mahalanobis
%                distances for the n units of the sample.
%
%
% More About:
%
% Function HApsi transforms vector u as follows.
%  \[
%  HApsi(u)  = \left\{   
%  \begin{array}{cc}
%    u & |u| <= a                                       \\
%    a \times sign(u) & a <= |u| < b                    \\
%    a \frac{c-|u|}{c-b} \times sign(u) & b <= |u| <  c \\
%    0 & |u| >= c 
%  \end{array} \right.
% \]
%
%             where $a$= ctun *ctuning(2).
%                   $b$= ctun *ctuning(3).
%                   $c$= ctun *ctuning(4).
%
%             The default is
%                   $a$= 2*ctun. 
%                   $b$= 4*ctun. 
%                   $c$= 8*ctun. 
%
%	It is necessary to have 0 <= a <= b <= c
%
% See also: TBpsi, HYPpsi, OPTpsi
%
% References:
%
% D. C. Hoaglin, F. Mosteller, J. W. Tukey (1982), Understanding Robust and
% Exploratory Data Analysis Wiley, New York.
%
%
% Copyright 2008-2015.
% Written by FSDA team
%
%
%<a href="matlab: docsearchFS('hapsi')">Link to the help page for this function</a>
% Last modified 06-Feb-2015
%
% Examples:

%{

    % Obtain bottom panel of Figure 11.10 p. 375 of
    % Hoaglin et al. (1987).
    x=-9:0.1:9;
    psiHA=HApsi(x,1);
    plot(x,psiHA)
    xlabel('x','Interpreter','Latex')
    ylabel(' Hampel $\psi(x) $','Interpreter','Latex')

%}

%% Beginning of code

if length(ctuning)>1,
    
    if ((ctuning(2) < 0) || (ctuning(3) < ctuning(2)) || (ctuning(4) < ctuning(3)))
        error('FSDA:HApsi:WrongAbc',[' Illegal choice of parameters in Hampel: ' ...
            num2str(ctuning(2:4)) ]')
    end
    a =  ctuning(2)*ctuning(1);
    b =  ctuning(3)*ctuning(1);
    c =  ctuning(4)*ctuning(1);
else
    a = 2*ctuning;
    b = 4*ctuning;
    c = 8*ctuning;
end


psiHA = zeros(size(u));
absu=abs(u);


% 0.5* u^2,		   |u| <=a 
psiHA(absu<=a) = u(absu<=a); 


% a*sign(u),		                      a <= |u| < b,
psiHA(absu > a & absu <=b) = a*(sign(u(absu > a & absu <=b)));

%	a((c-|u|)/(c-b))*sign(u),	                 b <= |u| <  c,
psiHA(absu>b & absu <=c) = a*(  (c-abs(u(absu>b & absu <=c)))/(c-b)  ).*sign(u(absu>b & absu <=c));

% 0,			              |u| >= c.

end