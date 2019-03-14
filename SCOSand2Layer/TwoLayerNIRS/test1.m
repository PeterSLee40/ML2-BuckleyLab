addpath('../functions')
constants
load('gauss_lag_5000.mat')
w = 110e6;
l = 1.01;
db1 = aDb1(1);
db2 = aDb2(1);

%bad
%rho = .6:.4:5;
%good
rho = 1:.1:2.5;
%bad
%rho = 1:.5:2.5;
%bad
%rho = 1:.5:4.5;
%tau = tau(1:100);
tau = 0;
AF = 100;


xtrue = [mua1, mus1, mua2, mus2, l, AF];
xreal = xtrue;
for i = 1:size(rho,2)
    rh = rho(i);
    [amp phase] = diffusionforwardsolver(n,Reff,mua1,mus1,db1,tau,lambda,rh,w,l,mua2,mus2,db2);
    tempcurve = [amp*AF phase];
    curve(i, :) = tempcurve;
end
curve(:, 2) = curve(:, 2) - curve(1, 2);
fun = @(x) diffusionforwardsolvercost(x,n,Reff,db1,tau,lambda,rho,w,db2, curve);
x0 = [.3, 8, .3, 8, .89, 152]; % mua1, mus1, mua2, mus2
lb = [.01, .1, .01, .1, .5, 50];
ub = [.5, 20, .5, 20, 2.0, 300];
%do optimization given initial guess, upper bound, and lowerbound
options = optimoptions(@lsqnonlin,'Algorithm','trust-region-reflective');
% 
options.Algorithm = 'levenberg-marquardt';
x = lsqnonlin(fun,x0,[],[],options)

%x = LevenbergMarquardt(fun,x0,lb,ub, options);% x = fminsearchbnd(fun, x0, lb, ub)
% lb = x*.5; ub = x*2;
 x2 = fminsearchbnd(fun, x0, lb, ub)

 lb3 = x2*.25; ub3 = x2*4;
 x3 = fminsearchbnd(fun, x0, lb3, ub3)

