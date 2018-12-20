function [result] = twolayercost(ldb2, beta, rhog2,n,Reff,mua1,mus1,Db1,tau,lambda,w,mua2,mus2)
%this function is meant to be a cost function to find db2 and depth given the
%following parameters within a two-layer model
Db2 = ldb2(1); %1/cm
ell = ldb2(2); % cm
%plugs the values into a two layer model
i = 0;
%rhog2, all the rhos are in the first column, g2 is the second column
%extending in the z direction
for rho = rhog2(:,1)
    i = i + 1;
    curfit(i,:) = diffusionforwardsolver(n,Reff,mua1,mus1,Db1,tau,lambda,rho,w,ell,mua2,mus2,Db2);
end
    %normalizes g1
normfit = curfit./curfit(:,1);
%uses seigert relation to go from g1 to g2
fit_g2 = beta.*normfit.*normfit + 1;
%compares g2 to fitted g2.
result = norm((rhog2(:,2,:) - fit_g2));
