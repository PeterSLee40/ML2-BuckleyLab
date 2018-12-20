function kappa = forward_kappa_Liu(musp,mua,r,exp_t,Db,lambda,beta)
    
    % c = 2.99792e10;  % cm/s
    n = 1.33;
    %v = c/n;
    Reff = -1.440*n^(-2)+0.710*n^(-1)+0.668+0.00636*n;
    k0 = 2*pi/lambda;
    
    z0 = 1/musp;
    zb = 2*(1+Reff)/(3*musp*(1-Reff));

    r1 = sqrt(r^2 + z0^2);
    r2 = sqrt(r^2 + (z0 + 2*zb)^2);

    
    F = 6*musp^2*k0^2*Db;
    Kappa0 = sqrt(3*musp*mua);
    %G0 = (3*musp/(4*pi))*(exp(-Kappa0*r1)/r1 - exp(-Kappa0*r2)/r2);
    G0 = (exp(-Kappa0*r1)/r1 - exp(-Kappa0*r2)/r2);
   
    X12_t = ((r1+r2)^2*(Kappa0^2+F*exp_t)+3*(r1+r2)*sqrt(Kappa0^2+F*exp_t)+3)*exp(-(r1+r2)*sqrt(Kappa0^2+F*exp_t));
    X11_t = ((r1+r1)^2*(Kappa0^2+F*exp_t)+3*(r1+r1)*sqrt(Kappa0^2+F*exp_t)+3)*exp(-(r1+r1)*sqrt(Kappa0^2+F*exp_t));
    X22_t = ((r2+r2)^2*(Kappa0^2+F*exp_t)+3*(r2+r2)*sqrt(Kappa0^2+F*exp_t)+3)*exp(-(r2+r2)*sqrt(Kappa0^2+F*exp_t));
    
    X12_0 = ((r1+r2)^2*(Kappa0^2)+3*(r1+r2)*sqrt(Kappa0^2)+3)*exp(-(r1+r2)*sqrt(Kappa0^2));
    X11_0 = ((r1+r1)^2*(Kappa0^2)+3*(r1+r1)*sqrt(Kappa0^2)+3)*exp(-(r1+r1)*sqrt(Kappa0^2));
    X22_0 = ((r2+r2)^2*(Kappa0^2)+3*(r2+r2)*sqrt(Kappa0^2)+3)*exp(-(r2+r2)*sqrt(Kappa0^2));
    
    Y12 = 0.5*(r1+r2)^2*(1+Kappa0*(r1+r2))*exp(-Kappa0*(r1+r2));
    Y11 = 0.5*(r1+r1)^2*(1+Kappa0*(r1+r1))*exp(-Kappa0*(r1+r1));
    Y22 = 0.5*(r2+r2)^2*(1+Kappa0*(r2+r2))*exp(-Kappa0*(r2+r2));
    
    term12  = -2*(r1*r2*(r1+r2)^4)^-1*(X12_t-X12_0+Y12*F*exp_t);%+Y12*F*exp_t;
    term11  = (r1*r1*(r1+r1)^4)^-1*(X11_t-X11_0+Y11*F*exp_t);%+Y11*F*exp_t;
    term22  = (r2*r2*(r2+r2)^4)^-1*(X22_t-X22_0+Y22*F*exp_t);%+Y22*F*exp_t;
    
    kappa = sqrt((8*beta/((F*exp_t)^2*G0^2))*(term11+term22+term12));
end 