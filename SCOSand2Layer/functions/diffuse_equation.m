function R = compute_DE_SS(musp,mua,r) % Zonios et al, AO 1999
    
    A = 3.2 ;
    
    mu = sqrt(3*mua*(mua + musp));

    z0 = 1./(mua + musp);

    r1 = sqrt(z0^2+r.^2);

    r2 = sqrt(z0^2.*(1+(4*A)/3)^2+r.^2);

    R = (z0/(4*pi))*(musp/(musp + mua)).*((mu+1./r1).*exp(-mu.*r1)./(r1.^2) + (1+(4*A)/3)*(mu+1./r2).*exp(-mu.*r2)./(r2.^2));

end 