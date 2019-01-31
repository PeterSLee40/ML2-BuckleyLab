load('discard5-4d.mat')
taurange = 5:75;
meanAllcorrset = squeeze(mean(mean(Allcorrset(:,2:5,taurange,2:4))));
db1 = 2.2e-9;
db2 = 6.7e-9;
Reff = 
for i = 1:3
    semilogx(meanAllcorrset(:, i)); hold on;
end
for i = 3
    g1s = getG1(n0,Reff,curmua1,curmus1,db1,tau,lambda,Rhos',w,l,curmua2,curmus2,db2,gl);
end