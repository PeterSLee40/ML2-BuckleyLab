function [hbseries,hbO2series,muaseries]=threewavelengthdpf_12hr(d1,d2,d3,bl1,bl2,bl3,lambdas,Leff)
%Last Edited 071610 by EB


ext1=[974 693.04; 276 2051.96; 740	957.36]*2.303/1e6;%W. B. Gratzer, converted to uM; from Prahl's website [ HbO2(826) Hb(826); HbO2(688) Hb(688); HbO2(786) Hb(786)]

muaseries=[-log(d1./bl1)/(Leff(1)) -log(d2./bl2)/(Leff(2)) -log(d3./bl3)/(Leff(3))];


for j=1:length(muaseries)
    hbtmp(j,:)=inv(ext1)*muaseries(j,:).'; %Rows=measurement no., Columns=wavelength
    hbO2series(j)=hbtmp(j,1);
    hbseries(j)=hbtmp(j,2);
end




