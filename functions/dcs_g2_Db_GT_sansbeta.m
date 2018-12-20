function result = dcs_g2_Db_GT_sansbeta(x,beta,tau,g2,p,mu_a,mu_sp,alpha,k0,Reff)

% mu_a and mu_sp in /mm
%p in mm

Db = x(1);

zo = (mu_sp + mu_a)^-1; 
zb = 2*(1+Reff)/(3*(1-Reff)*mu_sp);
r1 = (p.^2 + zo^2).^(1/2); 
r2 = (p.^2 + (zo + 2*zb).^2).^(1/2); 

msd = 6*Db * tau ;
Kappa = (3*mu_sp*mu_a + mu_sp^2 * k0^2 * alpha.* msd).^(1/2);
G1 = exp(-Kappa .* repmat(r1,1,size(tau,2)))./repmat(r1,1,size(tau,2)) - exp(-Kappa .* repmat(r2,1,size(tau,2)))./repmat(r2,1,size(tau,2));

Kappa0 = (3*mu_sp*mu_a).^(1/2);
G1_0 = exp(-Kappa0 .* r1)./r1 - exp(-Kappa0 .* r2)./r2;

fit_g2 = 1 + repmat(beta,1,size(tau,2)) .* ((G1 ./ repmat(G1_0,1,size(tau,2))).^2);

result = norm((g2 - fit_g2));