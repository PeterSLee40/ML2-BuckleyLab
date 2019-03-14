tic
for i = 1:1000
    %target = [1, 2];
    [amp, phase] = diffusionforwardsolverPL(n,Reff,mua1,mus1,db1,tau,lambda,rh,w,l,mua2,mus2,db2, gl);
    %target = [target, amp, phase];
end
toc