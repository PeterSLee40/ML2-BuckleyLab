function [eHBO2,eHB,Muawater,Mualipid]=getextinctioncoef(waterconc,lipidconc,lambdas)
%load the extinction coeffs from a variety of sources.
%lipidconc and waterconc should be in percentage.

%load the extinction coefficients needed
% From Steve Jacques' web site : Gratzer, Kollias
% Extinction Coefficients at 750 nm, 786 nm, 830 nm
load hemoglobin.dat;

for tt=1:length(lambdas)
   
   %indH(tt) = find(hemoglobin(:,1) == lambdas(tt));
   a=abs(hemoglobin(:,1) - lambdas(tt));
   indH(tt) = min(find(a == min(a)));
   clear a
end

eHBO2 = hemoglobin(indH,2) ./1000;
eHB   = hemoglobin(indH,3) ./1000;

clear hemoglobin;
clear indH;

% Mua from water (Segelstein) : interpolated data
load newwater.dat; 

for tt=1:length(lambdas)
   a=abs(newwater(:,1) - lambdas(tt));
   indW(tt) = min(find(a == min(a)));
   clear a
end



Muawater = newwater(indW,2);
Muawater=waterconc.*Muawater;

clear indW;

% Mua of Lipid (Quaresima)
load lipid.dat;

for tt=1:length(lambdas)
   a=abs(lipid(:,1) - lambdas(tt));
   indL(tt) = min(find(a == min(a)));
   clear a
end


Mualipid = lipid(indL,2);
Mualipid= lipidconc.*Mualipid;

clear lipid;
clear indL;


