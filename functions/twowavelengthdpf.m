function [hbseries,hbO2series,muaseries]=twowavelengthdpf(d1,d2,bl1,bl2,lambdas,sdsep,DPF)
%Last Edited 070609 by EB



waterconc=0;
lipidconc=0;
[eHBO2,eHB,Muawater,mualipid]=getextinctioncoef(waterconc,lipidconc,lambdas);

eHBO2=eHBO2.*log(10);
eHB=eHB.*log(10);

deltaod1=-log(d1./bl1);
deltaod2=-log(d2./bl2);

%david boas eq4
hbseries=(eHBO2(2).*deltaod1./DPF(1)-eHBO2(1).*deltaod2./DPF(2))./((eHB(1).*eHBO2(2)-eHB(2).*eHBO2(1)).*sdsep);
hbO2series=(eHB(1).*deltaod2./DPF(2)-eHB(2).*deltaod1./DPF(1))./((eHB(1).*eHBO2(2)-eHB(2).*eHBO2(1)).*sdsep);
for i=1:length(eHB)
    muaseries(i,:)=eHB(i).*hbseries+eHBO2(i).*hbO2series;
end








