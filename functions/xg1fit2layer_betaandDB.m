%% Chi^2 fn for fitting G_1 (G1Fitx)
function X2=xg1fit2layer_betaandDB(x0,n0,R,mua,musp,lambda,ell,rho,taustmp,g2)
Beta=x0(1);
Db0(1)=x0(2);
Db0(2)=x0(3);

g1=sqrt((g2-1)./Beta);
%Forward solve for g1 with these values	
g1fit=g1fit2layer(Db0,n0,R,mua,musp,lambda,ell,rho,taustmp);

%Calculate difference between given solution and actual data
X2=norm(g1fit-g1);
