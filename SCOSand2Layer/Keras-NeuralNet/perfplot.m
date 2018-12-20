db1 = 8.0e-9;

i = 0; j=0;
addpath('C:\Users\PeterLee\Documents\GitHub\ML-Multilayer\SCOSand2Layer\functions');
constants
betarand = randn(1)/1e2;
ellrand = randn(1)/1e3;
ratiorand = randn(1)/1e3;

beta = .5
Ratio = 3.1:.4121:9.9;
ell = .525 + ellrand:.01123121 + ellrand:1.475 + ellrand;
[X Y] = meshgrid(Ratio, ell);
noise = true;
i = 0; j =0;
tau = DelayTime(1:1:100);
T = diff(DelayTime(1:1:101));
Zdb1 = 0; Zl = 0; Zdb2 = 0;
for ratio = Ratio
    i = i+1
    for l = ell
        j = j + 1;
        db2 = db1*ratio;
        
        g1_short = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.0,w,l,mua2,mus2,db2, gl);
        normg1_short = g1_short./g1_short(1);
        [b, indexshort] = min(abs(normg1_short-1/e)); %find where g1 = 1/e
        gammashort = 1/tau(indexshort);
        
        g1_long = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,1.5,w,l,mua2,mus2,db2, gl);
        normg1_long = g1_long./g1_long(1);
        [b, indexlong] = min(abs(normg1_long-1/e)); %find where g1 = 1/e
        gammalong = 1/tau(indexlong);
        
        g2_shortnn =  1 + beta.*normg1_short.^2;
        g2_longnn =  1 + beta.*normg1_long.^2;
        
        sigmashort = getDCSNoise(500e3,T,3,beta,gammashort,tau);
        noiseshort = sigmashort.*randn(length(tau),2)';
        %noiseshort = 0;
        
        g2_short = noiseshort + g2_shortnn;
        
        sigmalong = getDCSNoise(Intensity,T,3,beta,gammalong,tau);
        noiselong = sigmalong.*randn(length(tau),6)';
        %noiseshort = 0;
        
        g2_long = noiselong + g2_longnn;
        
        prediction = net4([g2_short(:)' g2_long(:)']');
        Zdb2(j,i,:) = ((prediction(1)*1e-8) - db2)./db2*100;
        
    end
    j = 0;
end
surf(X,Y,Zdb2), colorbar;
xlabel('log(ratio of db1/db2)');
ylabel('thickness');
zlabel('Percent Error in db2');
set(gca,'YDir','reverse');
c = colorbar;
caxis([-20 20]);