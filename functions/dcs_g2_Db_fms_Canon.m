function result = dcs_g2_Db_fms_Canon(s,tau,g2,p,mu_a,mu_sp,alpha)

% mu_a and mu_sp in /mm

V = zeros(size(g2,1),1);
Db = s(1);
%Db=s(2);
%I_c=s(3);
%I_f=1-s(3);
norm_factor = s(2);

zo = (mu_sp + mu_a)^-1; 
zb = 1.76/mu_sp;
r1 = (p.^2 + zo^2).^(1/2); 
r2 = (p.^2 + (zo + 2*zb).^2).^(1/2); 

% wavelength = 852e-6 mm
k0 = 2*pi*1.4/(852*1e-6); 
msd = 6*Db * tau ;
kd = (3*mu_sp*mu_a + mu_sp^2 * k0^2 * alpha.* msd).^(1/2);
g1 = exp(-kd .* repmat(r1,1,size(tau,2)))./repmat(r1,1,size(tau,2)) - exp(-kd .* repmat(r2,1,size(tau,2)))./repmat(r2,1,size(tau,2));
% g1_1 = exp(-kd(:,1) .* r1)./r1 - exp(-kd(:,1) .* r2)./r2;

kd0 = (3*mu_sp*mu_a).^(1/2);
g1_1 = exp(-kd0 .* r1)./r1 - exp(-kd0 .* r2)./r2;

fit_g2 = 1 + repmat(norm_factor,1,size(tau,2)) .* ((g1 ./ repmat(g1_1,1,size(tau,2))).^2);

result = norm((g2 - fit_g2));