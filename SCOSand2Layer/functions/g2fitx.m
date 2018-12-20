%% Model G_1 for diffusive dynamics
%% Semi-infinite BC
%% for source-detector pairs on the same plane (z=0) only!
%%
function g2=g2fitx(x0,r,taustmp,muspo,muao,ko,ze)
	z0=1.0;
	r1=sqrt(r^2+z0^2./(muspo.^2));
	r2=sqrt(r^2+(z0+2*ze).^2./(muspo.^2));
    beta=x0(2);
    Db=x0(1);
    
   G1=exp(-sqrt(3*muspo.*muao+6*ko.^2.*muspo.^2.*Db.*taustmp).*r1)./r1 ...
		-exp(-sqrt(3*muspo.*muao+6*ko.^2.*muspo.^2.*Db.*taustmp).*r2)./r2;
    g1=G1./(exp(-sqrt(3*muspo.*muao).*r1)./r1-exp(-sqrt(3*muspo.*muao).*r2)./r2);
    g2=1+beta.*g1.^2;

%% revised: 6/5/09 by EB