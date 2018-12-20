function fit_g2 = dcs_g2fit(x0,tau,p,mu_a,mu_sp,alpha,lambda)

% mu_a and mu_sp in /cm

Db = x0(1);
beta = x0(2);

zo = (mu_sp + mu_a)^-1; 
zb = 1.76/mu_sp;
r1 = (p.^2 + zo^2).^(1/2); 
r2 = (p.^2 + (zo + 2*zb).^2).^(1/2); 

% wavelength = 785e-6 mm
k0 = 2*pi*1.4/(lambda); 
kd = (3*mu_sp*mu_a + mu_sp^2*k0^2*alpha.*(6*Db * tau)).^(1/2);
g1 = exp(-kd .* r1)./r1 - exp(-kd .* r2)./r2;
% g1_1 = exp(-kd(:,1) .* r1)./r1 - exp(-kd(:,1) .* r2)./r2;

kd0 = (3*mu_sp*mu_a).^(1/2);
g1_1 = exp(-kd0 .* r1)./r1 - exp(-kd0 .* r2)./r2;

fit_g2 = 1 + beta .* ((g1 ./ g1_1).^2);
