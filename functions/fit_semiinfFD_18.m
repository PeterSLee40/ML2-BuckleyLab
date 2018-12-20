function f=fit_semiinfFD_18(x0,n,Reff,lambda,r,w,AC,ph)
%Based on Keinle 1998 paper cost function using diff and ratio
mua=x0(1);
musp=x0(2);

for j=1:length(r)
    [amp(j),phase(j)]=diffusionforwardsolver(n,Reff,mua,musp,0,0,lambda,r(j),w,0);
end

[b,idx] = sort(r);
phdiff = diff(ph(idx));
phasediff = diff(phase(idx));

for i=1:length(r)-1
    ACdiff(i) = AC(idx(i+1))./AC(idx(i));
    ampdiff(i) = amp(idx(i+1))./amp(idx(i));
end

f=norm(cat(2,(ACdiff-ampdiff), (phdiff.'-phasediff)));
