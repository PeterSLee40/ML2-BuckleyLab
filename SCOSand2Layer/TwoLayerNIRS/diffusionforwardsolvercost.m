function [cost] = diffusionforwardsolvercost(x, n,Reff, aDb1,tau,lambda,rho,w,aDb2, actual)
mua1 = x(1);
mus1 = x(2);
mua2 = x(3);
mus2 = x(4);
ell = x(5);
AF = x(6);
cost = 0;
firstPhase = 0;
for i = 1:size(rho,2);
    rh = rho(i);
    [amp, phase] = diffusionforwardsolver(n,Reff,mua1,mus1,aDb1,tau,lambda,rh,w,ell,mua2,mus2,aDb2);
    if firstPhase == 0
        firstPhase = phase;
    end
    phase = phase - firstPhase;
    cost = cost + .5*norm(([amp*AF, phase] - squeeze(actual(i, :))).*[1/ amp, 1])^2;
end