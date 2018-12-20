%%%Codes from Turgut, modified by EB 2/24/10
function g1=g1fit2layer(Db0,n0,R,mua,musp,lambda,ell,rho,taustmp)
%For now, top and bottom layer have same mua, musp

w=0;%CW

for t=1:length(taustmp)
    G1(t)=diffusionforwardsolver(n0,R,mua(1),musp(1),Db0(1),taustmp(t),lambda,rho,w,ell,mua(2),musp(2),Db0(2));
end
g1=G1./G1(1);

