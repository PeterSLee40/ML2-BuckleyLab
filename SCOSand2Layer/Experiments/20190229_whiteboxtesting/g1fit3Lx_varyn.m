function [ g1] = g1fit3Lx_varyn( mua, musp, L,n, DB, V, lambda, rho, taus )
%ES
% generate g1 curve from 3 layer model
%all units in cm
%mua --> absorption for the 3 layers (cm-1)
%mu_sp --> reduced scattering for 3 layers (cm-1)
%L --> thickness of the two layers (cm)
%n --> only one value for index of refractions
%DB --> DB values for all 3 layers (cm2/s)
%lambda --> wavelength in nm
% rho --> SDS in cm




mu_a1 = mua(1); 
mu_a2 = mua(2);
mu_a3 = mua(3);

mu_sp1 = musp(1);
mu_sp2 = musp(2);
mu_sp3 = musp(3);

L1 = L(1);
L2 = L(2);

k01 = (2*pi*n(1))/(lambda*10^-7);
k0_sq1 = k01.^2;

k02 = (2*pi*n(2))/(lambda*10^-7);
k0_sq2 = k02.^2;

k03 = (2*pi*n(3))/(lambda*10^-7);
k0_sq3 = k03.^2;

DB1 = DB(1);
DB2 = DB(2);
DB3 = DB(3);

D1 = 1/(3*mu_sp1);
D2 = 1/(3*mu_sp2);
D3 = 1/(3*mu_sp3);

z0 = 1/(mu_sp1+mu_a1);

load gauss_lag_5000.mat
cutoff = 500; %this can be changed, usually set so that function is zero for "x-values" past cutoff.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lagw =gl(1:cutoff,3);
S =gl(1:cutoff,2);
lagw = lagw .* exp(S);


for tauLength = 1:length(taus)
    beta1_sq = S.^2 + 3*mu_a1*mu_sp1 + 6*mu_sp1*mu_sp1*k0_sq1*DB1*taus(tauLength);
    beta1 = sqrt(beta1_sq);
    beta2_sq = S.^2 + 3*mu_a2*mu_sp2 + mu_sp2*mu_sp2*k0_sq2*(6*DB2*taus(tauLength)+(V^2)*(taus(tauLength)^2));
    beta2 = sqrt(beta2_sq);
    beta3_sq = S.^2 + 3*mu_a3*mu_sp3 + 6*mu_sp3*mu_sp3*k0_sq3*DB3*taus(tauLength);
    beta3 = sqrt(beta3_sq);
    
%     Reff = 0.431;
 %         zb =(2*(D1)*(1+Reff))/(1-Reff);
    zb=1/mu_sp1;
    numerator = (beta1.*D1.*cosh(beta1.*(L1-zb)) .* ...
        (beta2.*D2.*cosh(beta2.*L2) + beta3.*D3.*sinh(beta2.*L2)) + ...
        beta2.*D2.*(beta3.*D3.*cosh(beta2.*L2) + beta2.*D2.*sinh(beta2.*L2)).*...
        sinh(beta1.*(L1-zb)));
    
    denominator = beta2.*D2.*cosh(beta2.*L2) .* (beta1.*(D1+beta3.*D3.*z0).*...
        cosh(beta1.*L1) + (beta3.*D3 + beta1.*beta1.*D1.*z0).*sinh(beta1.*L1)) + ...
        (beta1.*(beta3.*D1.*D3 + beta2.*beta2.*D2.*D2.*z0).*cosh(beta1.*L1) + ...
        (beta2.*beta2.*D2.*D2 + beta1.*beta1.*beta3.*D1.*D3.*z0).*sinh(beta1.*L1)) .* ...
        sinh(beta2.*L2);
    
    G1 = numerator./denominator;
    
  
    invG1 =  lagw .* G1 .* S .* besselj(0,S*rho);
    
    phi(tauLength,1) = sum(invG1);
    
    
    phi(tauLength,1) = phi(tauLength,1) / (2*pi);
    
    
    
end

g1 = phi./phi(1);