%% Chi^2 fn for fitting G_1 (G1Fitx)
function X2=xg1fit2layer(Db0,n0,R,mua,musp,lambda,ell,rho,taustmp,g1)

%Forward solve for g1 with these values	
g1fit=g1fit2layer(Db0,n0,R,mua,musp,lambda,ell,rho,taustmp);

%Calculate difference between given solution and actual data
X2=norm(g1fit-g1);
