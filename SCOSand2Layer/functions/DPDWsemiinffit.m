function f=DPDWsemiinffit(x0,AC,ph,r,v,w,Reff)

mua=x0(1);
musp=x0(2);
zb=2/(3.*musp)*(1+Reff)/(1-Reff);

k=sqrt(3.*musp./v.*(sqrt(-1).*w-v.*mua));

r1=sqrt(r.^2 + (1./musp)^2);
r2=sqrt(r.^2 + (1./musp-2.*zb)^2);

fitphi=3*musp/(4*pi) * ( exp(sqrt(-1).*r1.*k)./r1 - exp(sqrt(-1).*r2.*k)./r2 );

fitphi=fitphi./fitphi(1);

f=fitphi-AC.*exp(ph)./(AC(1)./exp(ph(1)));
