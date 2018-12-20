%
tau = 1e-6:1e-5:1e-3
T = diff([tau 0]);
g1_10 = diffusionforwardsolvergl(n,Reff,mua1,mus1,db1,tau,lambda,rho(1),w,l,mua2,mus2,db2,gl);
            normg1_10 = g1_10./g1_10(1);
            [b, index10] = min(abs(normg1_10-1/e)); %find where g1 = 1/e
            gamma = 1/tau(index10);
            sigma10 = getDCSNoise(500e3,T,3,beta,gamma,tau);
            noise10 = sigma10.*randn(length(tau),1)';
            g2_10nn = 1 + beta.*normg1_10.^2;
            
            g2_10 = noise10 + 1 + beta.*normg1_10.^2;
            g2_10sf = strokefilter(g2_10,5); 

semilogx(tau, g2_10); hold on;
 semilogx(tau, g2_10sf); hold on;

 semilogx(tau, g2_10nn); hold on; 
 plot(f2)
 legend('noise','stroke');
 
%  errorNoise = (g2_10 - g2_10nn)./g2_10nn*100;
%  errorStroke = (g2_10sf - g2_10nn)./g2_10nn*100;
%  semilogx(tau, errorNoise); hold on;
%  semilogx(tau, errorStroke);
% legend('errorNoise', 'errorStroke');