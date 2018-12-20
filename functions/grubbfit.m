function out=grubbfit(X,rCBF,rTHC)
a=X(1);
b=X(2);
rTHCfit=a*rCBF.^b;
out=sum((rTHC-rTHCfit).^2);