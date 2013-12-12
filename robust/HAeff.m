function ceff = HAeff(eff,v,abc)
%HAeff finds the tuning constant guarrantes a requested asymptotic efficiency
%
%  Required input arguments:
%
%    eff:       scalar which contains the required efficiency (of location
%               of scale estimator)
%               Generally eff=0.85, 0.9 or 0.95
%    p :        scalar, number of response variables
%
%
%  Optional input arguments:
%
%     abc     : vector of length 3 which contains the parameters of Hampel
%               estimator. If vector abc is not specified it is set equal
%               to [2, 4, 8]
%
%
% Output:
%
%  c = scalar of Hampel estimattor associated to the nominal (location or
%  shape) efficiency
%
% Copyright 2008-2014.
% Written by FSDA team
%
%
%<a href="matlab: docsearch('haeff')">Link to the help page for this function</a>
% Last modified 08-Dec-2013
%
% Paramter ceff multiplies parameters (a,b,c) of Hampel estiamtor
%
%
% Examples:
%
%{
    % The constant c associated to a nominal location efficiency of 95% in regression is
    % c = 0.690998716841394
    c=HAeff(0.95,1)
    % for a fixed shape efficiency we have
    % c= 5.490249208447494
    c=HAeff(0.95,1,1)
%}
%
%
%
%{
    % Compare constant c for the range of values of p from 1 to 200 using
    % approximate and exact formula for fixed shape efficiemcy
    % Number of variables
    p=200;
    pp=1:1:p;
    % Initialize the matrix which stores the values of c for the two
    % methods
    cc=[pp' zeros(p,2)];

    eff=0.75;
    % eff=0.99;
    for i=pp
        % Use exact formula for finding the value of c associated to a fixed
        % level of shape efficiency
        cc(i,2)=HAeff(eff,i,1);
        % Use approximate formula for finding the value of c associated to a fixed
        % level of shape efficiency
        cc(i,3)=TBeff(eff,i,1,1);
    end
    figure
    plot(cc(:,1),cc(:,2),'LineStyle','-','LineWidth',2)
    hold('on')
    plot(cc(:,1),cc(:,3),'LineStyle','-.','LineWidth',2)
    legend('True value of c', 'Approximate value of c','Location','best')
    xlabel('Number of variables')
    ylabel('Value of c')
%}

%

%% Beginning of code


if (nargin >2),
    if ((abc(1) < 0) || (abc(2) < abc(1)) || (abc(3) < abc(2))),
        error([' illegal choice of parameters in Hampel: ' ...
            num2str(abc) ]')
    end
    a0 = abc(1);
    b0 = abc(2);
    c0 = abc(3);
else
    a0 = 2;
    b0 = 4;
    c0 = 8;
%     a0 = 1.5;
%     b0 = 3.5;
%     c0 = 8;
end



% LOCATION EFFICIENCY

% ctun = starting point of the iteration
ctun=0.57;
% c = starting point of the iteration
% Remark: the more refined approximation for the starting value of
% sqrt(chi2inv(eff,p))+2; does not seem to be necessary in the case of
% location efficiency

% step = width of the dichotomic search (it decreases by half at each
% iteration).
step=0.5;


% Convergence condition is
%  .......
empeff=1;

eps=1e-14;
% ctun=(0:0.01:1)';
while abs(empeff-eff)> eps
    
    a=(a0*ctun);
    b=(b0*ctun);
    c=(c0*ctun);
    
    a2=a.^2/2;
    b2=b.^2/2;
    c2=c.^2/2;
    
    % bet  = \int  \psi'(x) d \Phi(x)
    % bet = \int_-a^a d \Phi(x) +2* \int_b^c -a/(c-b)
    bet= gammainc(a2,v/2)+(gammainc(b2,v/2)-gammainc(c2,v/2))*a/(c-b);
    
    % alph = \int \psi^2(x) d \Phi(x)
    alph= v*gammainc(a2,(v+2)/2)...                                        % 2* \int_0^a x^2 f(x) dx
        +a.^2 .*(gammainc(b2,v/2)-gammainc(a2,v/2))...                     % 2* a^2 \int_a^b f(x) dx  
        +(a./(c-b)).^2 .*(c.^2.*(gammainc(c2,v/2)-gammainc(b2,v/2)) ...    %(a./(c-b)).^2 (2 c^2 \int_b^c f(x) dx 
        + v*(gammainc(c2,(v+2)/2)-gammainc(b2,(v+2)/2)) ...                %   + 2*  \int_b^c x^2 f(x) dx  
    -2*c*v*sqrt(2/pi)*(gammainc(c2,(v+1)/2)-gammainc(b2,(v+1)/2)));        % +2 *2* \int_b^c |x| f(x) 
    

   % Remark: if v=1
   % -2*c*v*sqrt(2/pi)*(gammainc(c2,(v+1)/2)-gammainc(b2,(v+1)/2))); 
   %     -4*c.*(normpdf(b)-normpdf(c))  );                                     
    
    % empeff = bet^2/alph = 1 / [var (robust estimator of location)]
    empeff=(bet^2)/alph;
    
    step=step/2;
    if empeff<eff
        ctun=ctun+step;
    elseif empeff>eff
        ctun=max(ctun-step,0.01);
    else
    end
    
  % disp([empeff eff ctun])
end


ceff=ctun;
% Remark:
% chi2cdf(x,v) = gamcdf(x,v/2,2) = gammainc(x ./ 2, v/2);

end

