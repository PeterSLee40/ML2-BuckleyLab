%close all
clear all

load meandata.mat
beta = mean(meang2(:,5:8),2)-1;


mua1 = 0.1377;
mua2 = 0.1524;
musp1 = 6.9237;
musp2 = 6.807;
ell = 1.0;%cm
Db1 = 0.2056e-8;%cm/s2
Db2 = 0.72517e-8;
rho = [10 15 20 25]/10;%cm
n = 1.38;
Reff = -1.440./n^2+0.710/n+0.668+0.0636.*n;%Durduran RPP 2010
lambda = 852;%nm

for j = 1:length(rho)
    for i=1:length(taus)
        [amp(i,j) phase(i,j)] = diffusionforwardsolver(n,Reff,mua1,musp1,Db1,taus(i),lambda,rho(j),0,ell,mua2,musp2,Db2);
    end
    g1(:,j) = amp(:,j)./amp(1,j);
    g2(:,j) = 1+beta(j)*g1(:,j).^2;
end

DB = [Db1 Db1 Db2];
V = 0;
mua = [mua1 mua1 mua2];
musp = [musp1 musp1 musp2];
L = [0.5 0.5];
n = [1.38 1.38 1.38];

for j = 1:length(rho)
    g1_3layer(j,:) = g1fit3Lx_varyn( mua, musp, L,n, DB, V, lambda, rho(j), taus );
    g2_3layer(j,:) = 1+beta(j)*g1_3layer(j,:).^2;
end


color = {'r';'b';'g';'m'};
figure
% semilogx(taus,g2(:,1),'r--')
for d = 1:length(rho)
    semilogx(taus,g2(:,d),'--','Color',color{d})
    hold on
    semilogx(taus,meang2(d,:),'-','Color',color{d})
    hold on
    semilogx(taus,g2_3layer(d,:),'*','Color',color{d})
    hold on
end
ylim([0.9 1.6])
xlim([min(taus) 1e-2])
legend('10mm homogenous fit', '10mm data', '10mm twolayer fit', ... 
'15mm homogenous fit', '15mm data', '15mm twolayer fit', ...
'20mm homogenous fit', '20mm data', '20mm twolayer fit', ...
'25mm homogenous fit', '25mm data', '25mm twolayer fit')