function f=fit_semiinfFD_5(x0,n,Reff,lambda,r,w,AC,ph)
%Method 5
mua=x0(1);
musp=x0(2);

for j=1:length(r)
    [amp(j),phase(j)]=diffusionforwardsolver(n,Reff,mua,musp,0,0,lambda,r(j),w);
end

ind=find(r==min(r));

%Normalize amp and phase to smallest s-d separation
amp=amp./amp(ind);
phase=phase-phase(ind);
AC=AC./AC(ind);
ph=ph-ph(ind);


indamp=find(amp~=1);
indph=find(phase~=0);
%f=norm(cat(2,((log(amp(indamp))-log(AC(indamp).'))./log(amp(indamp))).^2 , ((phase(indph)-ph(indph).')./phase(indph)).^2));
%f=norm(cat(2,(log(amp(indamp))-log(AC(indamp).'))./log(amp(indamp)) , (phase(indph)-ph(indph).')./phase(indph)));
%f=norm(cat(2,(log(amp)-log(AC.'))./log(amp) , (phase-ph.')./phase));
f=norm(cat(2,(amp-AC.')./amp , (phase-ph.')./phase));
%f=norm(cat(2,(log(AC)-log(amp))./log(ACse) , (ph-phase)./phse));

%ACrange = max(log(AC)) - min(log(AC));
%phrange = max(ph) - min(ph);

%f=norm(cat(2,(log(AC)-log(amp)), (ph-phase)*ACrange/phrange ));
%ACrange = max(AC) - min(AC);
%phrange = max(ph) - min(ph);

%f=norm(cat(2,(AC-amp.'), (ph-phase.')*ACrange/phrange ));
