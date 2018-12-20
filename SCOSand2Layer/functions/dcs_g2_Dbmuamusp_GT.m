function result = dcs_g2_Dbmuamusp_GT(s,tau,meas_g1,p,alpha,k0)

% mu_a and mu_sp in /mm, db in mm2/s

Db = s(1);
mu_a = s(2);
mu_sp = s(3);
%Db=s(2);
%I_c=s(3);
%I_f=1-s(3);
%norm_factor = s(2);

zo = (mu_sp + mu_a)^-1; 
zb = 1.76/mu_sp;
r1 = (p.^2 + zo^2).^(1/2); 
r2 = (p.^2 + (zo + 2*zb).^2).^(1/2); 

% wavelength = 852e-6 mm
%k0 = 2*pi*1.4/(852*1e-6); 
msd = 6*Db * tau ;
kd = (3*mu_sp*mu_a + mu_sp^2 * k0^2 * alpha.* msd).^(1/2);
kd0 = (3*mu_sp*mu_a).^(1/2);
for d=1:length(r1)
    g1(d,:) = exp(-kd .* r1(d))./r1(d) - exp(-kd .* r2(d))./r2(d);
    g1_1(d) = exp(-kd0 .* r1(d))./r1(d) - exp(-kd0 .* r2(d))./r2(d);
    fit_g1(d,:) = g1(d,:) ./ g1_1(d);
end
%fit_g2(d,:) = 1 + repmat(norm_factor,1,size(tau,2)) .* ((g1(d,:) ./ repmat(g1_1(d,:),1,size(tau,2))).^2);
% g1_1 = exp(-kd(:,1) .* r1)./r1 - exp(-kd(:,1) .* r2)./r2;

result = sum(sum((fit_g1 - meas_g1).^2,2),1);
