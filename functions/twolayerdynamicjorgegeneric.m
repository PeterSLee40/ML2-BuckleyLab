function Rac=twolayerdynamicjorgegeneric(M0, mua0, mus0, mua1, mus1,z0,tau,Db0,Db1,indexref,w,vo,lambda,r1,r2);
% Last Edited: 12/01/04 by TD
%added "any place detector" option. the original works only for detectors
%on surface. there may be  some errors.
% Ulas' corrected version of Jorge's codes with dynamic properties inserted
% dynamic properties like dboas
% last updated after taking care of fft problem 
% ---------------------------------------------------
%2/24/10 annotated by EB

% FFT PROPERTIES:
% ===================
kmax = 50.0; 	% Stuff you can fiddle with in order to 	
terms= 5000;		% change the accuracy.vs.time
dk = kmax/(terms);  
kK = [0:terms]*dk;
K = kK.^2;
dk = gradient(K);



% R=Source-detector separation
% r1=source coordinates
% r2=detector coordinates
R = sqrt((r1(1,:)-r2(1,:)).^2+(r1(2,:)-r2(2,:)).^2+(r1(3,:)-r2(3,:)).^2);%%Modified by EB to include z-coordinate too!

[newn,newm]=size(R);
Rmat = ones([terms+1,1])*R;
Kmat = (ones([newm,1])*K)';
KR = Kmat.*Rmat;


% TISSUE PROPERTIES:
% =====================
D0 = 1./(3*mus0);%Top layer
D1 = 1./(3*mus1);%Bottom layer
Z = 0;
%z0 = 0.2;
zs = r1(3,:); %!!!

% detector is at the surface:
zd = r2(3,:); % it's better
L = abs(z0-Z);


%indexref = 1.4;
c = 2.9979e10; % speed of light in vacuum,cm/s
f = 0; % CW !
%w = 2.*pi.*f;
%vo = c/indexref; %speed of light in medium
ko=2*pi*indexref/lambda;

k0sq = (-mua0-2*mus1*Db0*ko.^2*tau + i.*w/vo)/D0;  % static layer
k0 = sqrt(k0sq);
k1sq = (-mua1-2*mus1*Db1*ko.^2*tau - i.*w/vo)/D1;  % dynamic layer
k1 = sqrt(k1sq);


q0 = sqrt(k0sq - K.*K);
q1 = sqrt(k1sq - K.*K);  
% ======================================


% alpha!  coefficient that takes into account refractive index mismatch
alpha = 5.8969;

%TOA, ROA--> Frequency-dependent reflection and transmission coefficients, respectively, for diffusive–
%nondiffusive interfaces
T0A = 2*i*alpha*D0*q0./(i*alpha*D0*q0-1.);
R0A = T0A-1.;

R01 = (D0*q0-D1*q1)./(D0*q0 + D1*q1);
T01 = 2*D0*q0./(D0*q0 + D1*q1);

So = 1;
% At z=z0:
Uinc_k_z0 = 1/4./pi.*(i./(2*pi*q0)).*exp(i*q0*abs(z0-zs));

% At z=0:
Uinc_k_0 =  1/4./pi.*(i./(2*pi*q0)).*exp(i*q0*abs(zs));

% At z=zd:
Uinc_k_zd =  1/4./pi.*(i./(2*pi*q0)).*exp(i*q0*abs(zd-zs));

% Reflected amplitude in k-space:
% ----------------------------------
K_Factor = (1./(1-R01.*exp(2*i*q0*L).*R0A));

% Reflection at the detector z=zd=1/mus, in k-space:
U_k_R = Uinc_k_zd + Uinc_k_z0.*R01.*(exp(i*q0*(z0-zd))+...
      exp(i*q0*(z0-0)).*R0A.*exp(i*q0*(zd-0))).*K_Factor+...            
      Uinc_k_0.*R0A.*(exp(i*q0*(zd-0))+...
      exp(i*q0*(z0-0)).*R01.*exp(i*q0*(z0-zd))).*K_Factor;

% BACK TO REAL
% =============
% Reflected amplitude in x-y space:
U_r = (U_k_R.*K.*dk)*(besselj(0,KR));  
% ---------------------------------------------------
U_d_r = abs(U_r);
U_d_ph = angle(U_r);
% ---------------------------------------------------

Rac = U_d_r.*exp(i*U_d_ph);
