function [hbseries,hbO2series,muaseries]=threewavelengthdpf_withH2O(d1,d2,d3,bl1,bl2,bl3,lambdas,sdsep,DPF,waterconc)
%Last Edited 072910 by EB

lipidconc=0;
[eHBO2,eHB,Muawater,mualipid]=getextinctioncoef(waterconc,lipidconc,lambdas);

eHBO2=eHBO2.*log(10);
eHB=eHB.*log(10);

deltaod=[-log(d1./bl1)/(DPF(1)*sdsep) -log(d2./bl2)/(DPF(2)*sdsep) -log(d3./bl3)/(DPF(3)*sdsep)];
hbout=pinv([eHBO2 eHB])*deltaod';
hbO2series=hbout(1,:);
hbseries=hbout(2,:);

for i=1:length(eHB)
    muaseries(i,:)=eHBO2(i).*hbO2series+eHB(i).*hbseries+Muawater(i)+mualipid(i);
end







