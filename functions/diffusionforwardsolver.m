function [amp phase] = diffusionforwardsolver(n,Reff,mua1,mus1,aDb1,tau,lambda,rho,w,ell,mua2,mus2,aDb2)
%This function is a forward solver of the frequency domain photon diffusion
%equation and the CW correlation diffusion equation for the fluence rate
%(amplitude and phase) and electric field correlation function (g1), 
%respectively.  The geometry can be semi-infinite or 2-layer.
%
%[amp phase] =
%diffusionforwardsolver(n,Reff,mua1,mus1,aDb1,tau,lambda,rho,w,ell,mua2,
%mus2,aDb2)
%
%amp is the calculated amplitude of the fluence rate (DOS) or 
%    the un-normalized electric field temporal correlation function (DCS) 
%
%phase is the phase of the fluence rate for DOS in freqeuncy domain
%
%n is the index of refraction of turbid medium.  If using two layers, it 
%  is assumed both layers have the same index of refraction.
%
%Reff is fraction of photons internally diffusely reflected at boundary
%     between turbid and non-scattering media.  For n = 1.4, equals 0.493.
%
%mua1,mus1 are absorption coefficient and reduced scattering coefficient
%          for "top layer"(i.e., layer contains source), units are 1/cm
%
%aDb1,aDb2 are the Brownian flow indices for the dynamics of the
%          two layers (Brownian dynamics are assumed).  If only one layer, 
%          don't specify aDb2.  If not solving
%          correlation diffusion equation, set aDb1 to zero.  
%          The units should be cm^2/s
%
%tau  is the time in the correlation function if solving correlation
%     diffusion equation (units are s).  tau can be a vector for all times
%     if using semi-infinite geometry.  Otherwise, tau must be a scalar.
%     Set to zero if not solving correlation diffusion equation.
%
%lambda is the wavelength of light in nm
%
%rho is the source-detector separation in cm.  If geometry is
%    semi-infinite, and doing DOS, rho can be a vector for all separations.
%    Otherwise, rho must be a scalar.
%
%w  is the modulation angular frequency for frequency domain, set to zero 
%   if CW light.
%
%ell is the thicknesss of top layer in cm if using a two-layer model.
%
%mua2,mus2 are optical properties for layer 2.  Don't specify if only a
%          single layer.

v = 2.9979e10 / n;
lambda = lambda*10^(-7); %convert to cm
k0 = 2*pi*n / lambda;
D1 = 1/(3*(mua1 + mus1));

z0 = 1 / (mua1 + mus1);
zb = (1+Reff)/(1-Reff) * 2*D1;

if ~exist('mua2','var')
    mua2 = 0;
end

if mua2 == 0
    %One layer
    r1 = sqrt(z0^2 + rho.^2);
    rb = sqrt((2*zb + z0)^2 + rho.^2);
    alpha1sq = (mua1 + 2*mus1*k0^2*tau*aDb1 + 1i*w/v) / D1;
    alpha1 = sqrt(alpha1sq);
    
    %phi = v/(4*pi*D1) * (exp(-alpha1 * r1)./r1 - exp(-alpha1*rb)./rb);
    phi = 1/(4*pi) * (exp(-alpha1 * r1)./r1 - exp(-alpha1*rb)./rb);
else
    %Two layer
    D2 = 1/(3*(mua2 + mus2));        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    load gauss_lag_5000.mat
    cutoff = 500; %this can be changed, usually set so that function is zero for "x-values" past cutoff.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    lagw =gl(1:cutoff,3);
    S =gl(1:cutoff,2);
    lagw = lagw .* exp(S);
    
    alpha1sq = (D1*S.^2 + mua1 + 2*mus1*k0^2*tau*aDb1 + 1i*w/v) / D1;
    alpha1 = sqrt(alpha1sq);
    alpha2sq = (D2*S.^2 + mua2 + 2*mus2*k0^2*tau*aDb2 + 1i*w/v) / D2;
    alpha2 = sqrt(alpha2sq);
        
    %Fourier transform of phi taken from solution by Kienle et al, Applied
    %Optics, V 37, pages 779-791, 1998.
    phit = (sinh(alpha1*(zb + z0)) ./ (D1*alpha1)) .* ((D1*alpha1.*cosh(alpha1*ell) + D2*alpha2.*sinh(alpha1*ell)) ...
        ./ (D1*alpha1.*cosh(alpha1*(ell+zb)) + D2*alpha2.*sinh(alpha1*(ell+zb)))) - sinh(alpha1*z0)./(D1*alpha1);
        
    invphit = lagw .* phit .* S .* besselj(0,S*rho);
    %phi = quadgk(invphit,0,inf);
    %phi = quad(invphit,0,kmax,1e-9);
    
    phi = sum(invphit);
    
    %fplot(invphit,s,0,100)
    %A = load('LaguerrequadweightsN12.txt');
    
    phi = phi / (2*pi);
end

%If phi is complex, I will break it up into amplitude and phase.
amp = abs(phi);
phase = -angle(phi);
