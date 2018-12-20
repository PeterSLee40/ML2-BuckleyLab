i = 0;
j = 0;
[X Y] = meshgrid(Ratio, ell);
for ratio = Ratio
    i = i+1;
    for l = ell
        j = j + 1;
        db2 = db1*ratio;
            %db2 = db1*10^ratio;
            for a = 1:numDetectors
                currRho = rho(a);
                currInt = getIntensity(currRho,20);
                [g1s(a,:), gamma] = getG1(n,Reff,mua1,mus1,db1,tau,lambda,currRho,w,l,mua2,mus2,db2,gl);
                sigmas(a,:) = getDCSNoise(currInt,T,inttime,beta,gamma,tau);
            end
            for rep = 1:Rep
                for beta = Beta
                noises = sigmas.*randn(numDetectors, size(tau,2));
                g2s = beta.*g1s.^2 + 1;
                g2s_noise = noises + 1 + beta.*g1s.^2;
            end
            end
        pred = net(g2s_noise(:));
        Z(j,i,:) = (pred*1e-9 - db2)./db2*100;
    end
    j = 0;
end
surf(X,Y,Z), colorbar;
xlabel('log(ratio of db1/db2)');
ylabel('thickness');
zlabel('Percent Error');
set(gca,'YDir','reverse');
c = colorbar;
caxis([-20 20]);  