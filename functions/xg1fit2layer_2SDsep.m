%% Chi^2 fn for fitting G_1 (G1Fitx)
function X2=xg1fit2layer_2SDsep(Db0,n0,R,mua,musp,lambda,thickness,r,taustmp,g1,g1small)

%Forward solve for g1 with these values, r=2.5cm	
g1fit=g1fit2layer(Db0,n0,R,mua,musp,lambda,thickness,r(1),taustmp);
%r=0.8cm
g1fit_smallSD=g1fit2layer(Db0,n0,R,mua,musp,lambda,thickness,r(2),taustmp);

%Calculate difference between given solution and actual data
X2=norm(g1fit-g1)+norm(g1fit_smallSD-g1small);
