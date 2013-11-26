function [OmegaMap, BarOmega, MaxOmega, rcMax]=GetOmegaMap(c, p, k, li, di, const1, fix, pars, lim, asympt)
%GetOmegaMap calculates the map of misclassificaton betweeb groups
%
% /* GetOmegaMap calculates the map of misclassificatons
%  INPUT parameters
%  * c  - inflation parameter for covariance matrices
%  * p  - dimensionality
%  * k  - number of components
%  * li, di, const1 - parameters needed for computing overlap (see theory of method)
%    li = 3D array of size k-by-k-by-p
%    di = 3D array of size k-by-k-by-p
%
%    fix - fixed clusters that do not participate in inflation/deflation
%    fix = vector of length k containing zeros or ones
%    if fix(j) =1 cluster j does not participate to inflation or deflation.
%    This parameter is used just if heterogeneous clusters are used
%    pars, lim - parameters for qfc function
%   asympt - flag for regular or asymptotic overlap
%  Output values
%  * OmegaMap - k-by-k matrix contaoining misclassification probabilities
%  * BarOmega - average overlap
%  * MaxOmega - maximum overlap
%  * rcMax - contains the pair of components producing the highest overlap
%  */

%% Beginning of code

acc = pars(1);

% Omegamap= k-by-k matrix which will contain misclassification probabilities
OmegaMap=eye(k);
rcMax=zeros(2,1);

TotalOmega = 0.0;
MaxOmega = 0.0;

df=ones(p,1);


ii = 1;
jj = 2;


%/* check if clusters are homogeneous */
hom = 1;
for kk=1:p
    
    if li(1,2,kk) ~= li(2,1,kk)
        hom = 0;
        break
    end
end


if hom == 1
    % /* homogeneous clusters */
    
    if asympt == 0
        
        while ii < k
            
            Di =  squeeze(di(ii,jj,:)) / sqrt(c);
            Cnst1 = sum(Di.^2);
            coef = zeros(p,1);
            ncp = zeros(p,1);
            
            % t is the value in which the cdf of the mixture of
            % non central chi2 must be evaluated
            t = const1(ii,jj) - Cnst1;
            sigma = 2 * sqrt(Cnst1);
            
            % coef = coefficients of the linear combination of non
            % central chi2 distributions
            % df = degrees of freedom of mixture of non central chi2
            %
            
       
            OmegaMap(ii,jj)=ncx2mixtcdf(t, df, coef,ncp,'sigma',sigma,'lim',lim,'tol',acc);
            % c   :         scalar, value at which the cdf must be evaluated
            % n  :         vector of length k containing the degrees of freedom of the
            %               k non central chi2 distributions
            % lb  :         vector of length k containing the coefficients of the linear combinations
            %               of the k non central chi2 distributions
            %  nc :       vector of length k containing the k non centrality parameters
            %               of the k non central chi2 distributions
            
            
            
            % OmegaMap(i,j) = qfc(coef, ncp, df, &p, &sigma, &t, &lim, &acc, trace, &ifault);
            
            
            
            Di =  squeeze(di(jj,ii,:)) / sqrt(c);
            Cnst1 = sum(Di.^2);
            coef = zeros(p,1);
            ncp = zeros(p,1);
            
            
            
            t = const1(jj,ii) - Cnst1;
            sigma = 2 * sqrt(Cnst1);
            
                      
            OmegaMap(jj,ii) = ncx2mixtcdf(t, df, coef,ncp,'sigma',sigma,'lim',lim,'tol',acc);
            % OmegaMap[j][i] = qfc(coef, ncp, df, &p, &sigma, &t, &lim, &acc, trace, &ifault);
            
            OmegaOverlap = OmegaMap(ii,jj) + OmegaMap(jj,ii);
            TotalOmega = TotalOmega + OmegaOverlap;
            
            if OmegaOverlap > MaxOmega
                MaxOmega = OmegaOverlap;
                rcMax(1) = ii;
                rcMax(2) = jj;
            end
            
            
            if (jj < k) %(k - 1)
                jj = jj + 1;
            else
                ii = ii + 1;
                jj = ii + 1;
            end
            
        end
        
    end
    
    
    
    if asympt == 1
        
        while ii < k%(k - 1)
            
            if const1(ii,jj) > 0
                OmegaMap(ii,jj) = 1;
                OmegaMap(jj,ii) = 0;
            end
            
            if const1(ii,jj) < 0
                OmegaMap(ii,jj) = 0;
                OmegaMap(jj,ii) = 1;
            end
            
            if const1(ii,jj) == 0
                OmegaMap(ii,jj) = 0.5;
                OmegaMap(jj,ii) = 0.5;
            end
            
            
            OmegaOverlap = OmegaMap(ii,jj) + OmegaMap(jj,ii);
            TotalOmega = TotalOmega + OmegaOverlap;
            
            if OmegaOverlap > MaxOmega
                MaxOmega = OmegaOverlap;
                rcMax(1) = ii;
                rcMax(2) = jj;
            end
            if (jj < k) %(k - 1)
                jj = jj + 1;
            else
                ii = ii + 1;
                jj = ii + 1;
            end
            
        end
        
    end
end


% Non homogeneous (equal) covariance matrices
% /* heterogeneous clusters */
if hom == 0
    
    sigma = 0.0;
    
    if (asympt == 0)
        
        
        while ii < k
                        
            if fix(ii) == 1
                Di = squeeze(di(ii,jj,:));
                
                if fix(jj) == 1
                    Li = squeeze(li(ii,jj,:));
                    Cnst1 = const1(ii,jj);
                else
                    Li = squeeze(li(ii,jj,:))/ c;
                    Cnst1 = const1(ii,jj) - p * log(c);
                end
                
            else
                
                
                Di = squeeze(di(ii,jj,:)) / sqrt(c);
                
                if fix(jj) == 1
                    
                    Li = c * squeeze(li(ii,jj,:));
                    
                    Cnst1 = const1(ii,jj) + p * log(c);
                else
                    Li = squeeze(li(ii,jj,:));
                    
                    Cnst1 = const1(ii,jj);
                end
                
            end
            
            
            
            coef = Li - 1.0;
            ldprod = Li.*Di;
            const2 = (ldprod.*Di)./ coef;
            ncp = (ldprod./coef).^2;
            t = sum(const2)+ Cnst1;
            
            % OmegaMap[i][j] = qfc(coef, ncp, df, &p, &sigma, &t, &lim, &acc, trace, &ifault);
                    
            OmegaMap(ii,jj)=ncx2mixtcdf(t, df, coef,ncp,'sigma',sigma,'lim',lim,'tol',acc);
            
            if fix(jj) == 1
                
                
                Di = squeeze(di(jj,ii,:));
                
                if fix(ii) == 1
                    Li = squeeze(li(jj,ii,:));
                    Cnst1 = const1(jj,ii);
                else
                    Li = squeeze(li(jj,ii,:)) / c;
                    Cnst1 = const1(jj,ii) - p * log(c);
                end
                
            else
                
                Di = squeeze(di(jj,ii,:)) / sqrt(c);
                
                
                if fix(ii) == 1
                    Li = c * squeeze(li(jj,ii,:));
                    
                    Cnst1 = const1(jj,ii) + p * log(c);
                else
                    Li = squeeze(li(jj,ii,:));
                    Cnst1 = const1(jj,ii);
                end
                
            end
            
            
            coef = Li - 1.0;
            ldprod = Li.*Di;
            const2 = (ldprod.*Di)./ coef;
            ncp = (ldprod./coef).^2;
            t = sum(const2)+ Cnst1;
            
            %	OmegaMap[j][i] = qfc(coef, ncp, df, &p, &sigma, &t, &lim, &acc, trace, &ifault);
            
                     
            OmegaMap(jj,ii)=ncx2mixtcdf(t, df, coef,ncp,'sigma',sigma,'lim',lim,'tol',acc);
            
            OmegaOverlap = OmegaMap(ii,jj) + OmegaMap(jj,ii);
            TotalOmega = TotalOmega + OmegaOverlap;
            
            if OmegaOverlap > MaxOmega
                MaxOmega = OmegaOverlap;
                rcMax(1) = ii;
                rcMax(2) = jj;
            end
            if (jj < k) %(k - 1)
                jj = jj + 1;
            else
                ii = ii + 1;
                jj = ii + 1;
            end
            
        end
    end
    
    
    if asympt == 1
        
        while (ii < k)
            
            if fix(ii) == 1
                
                if fix(jj) == 1
                    
                    Di = di(ii,jj,:);
                    Li = li(ii,jj,:);
                    coef = Li - 1.0;
                    ldprod = Li.*Di;
                    const2 = (ldprod.*Di)./coef;
                    ncp = (ldprod./coef).^2;
                    
                    t = sum(const2) + const1(ii,jj);
                              
                    OmegaMap(ii,jj)=ncx2mixtcdf(t, df, coef,ncp,'sigma',sigma,'lim',lim,'tol',acc);
                    
                    % OmegaMap[i][j] = qfc(coef, ncp, df, &p, &sigma, &t, &lim, &acc, trace, &ifault);
                    
                else
                    
                    OmegaMap(ii,jj) = 0.0;
                    
                end
                
            else
                if fix(jj) == 1
                    
                    OmegaMap(ii,jj) = 0.0;
                    
                else
                    coef = squeeze(li(ii,jj,:)) - 1.0;
                    ncp = zeros(p,1);
                    
                    t = const1(ii,jj);
                    
                    OmegaMap(ii,jj)=ncx2mixtcdf(t, df, coef,ncp,'sigma',sigma,'lim',lim,'tol',acc);
                    
                    % OmegaMap[i][j] = qfc(coef, ncp, df, &p, &sigma, &t, &lim, &acc, trace, &ifault);
                    
                    
                end
            end
            % siamo alla linea 508 e 509 di libOverlap.c
            if fix(jj) == 1
                
                if fix(ii) == 1
                    
                    Di = squeeze(di(jj,ii,:));
                    Li = squeeze(li(jj,ii,:));
                    coef = Li - 1.0;
                    ldprod = Li.*Di;
                    const2 = (ldprod.*Di)./coef;
                    ncp = (ldprod./coef).^2;
                    t = sum(const2) + const1(jj,ii);
                    
                    
                    % 	OmegaMap[j][i] = qfc(coef, ncp, df, &p, &sigma, &t, &lim, &acc, trace, &ifault);
                               
                    OmegaMap(jj,ii)=ncx2mixtcdf(t, df, coef,ncp,'sigma',sigma,'lim',lim,'tol',acc);
                    
                else
                    
                    OmegaMap(jj,ii) = 0.0;
                    
                end
                
            else
                
                if fix(ii) == 1
                    OmegaMap(jj,ii) = 0.0;
                    
                else
                    coef =  squeeze(li(jj,ii,:))- 1.0;
                    ncp = zeros(p,1);
                    
                    t = const1(jj,ii);
                              
                     % OmegaMap[j][i] = qfc(coef, ncp, df, &p, &sigma, &t, &lim, &acc, trace, &ifault);
                    OmegaMap(jj,ii)=ncx2mixtcdf(t, df, coef,ncp,'sigma',sigma,'lim',lim,'tol',acc);
                    
                end
            end
            
            
            
            
            
            OmegaOverlap = OmegaMap(ii,jj) + OmegaMap(jj,ii);
            TotalOmega = TotalOmega + OmegaOverlap;
            
            if OmegaOverlap > MaxOmega
                MaxOmega = OmegaOverlap;
                rcMax(1) = ii;
                rcMax(2) = jj;
            end
            if (jj < k) %(k - 1)
                jj = jj + 1;
            else
                ii = ii + 1;
                jj = ii + 1;
            end
            
        end
        
        
    end
end
BarOmega=TotalOmega/(0.5*k*(k-1));
end
