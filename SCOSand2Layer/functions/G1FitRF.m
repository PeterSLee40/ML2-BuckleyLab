%% Model G_1 for diffusive dynamics
%% Semi-infinite BC
%% for source-detector pairs on the same plane (z=0) only!
%% Random Flow Model
%% Modefied by Chao, 12/16/03
function g=G1FitRF(V2,r,t,ms,ma,mx,k0,ze)
	z0=1.0;
	r1=sqrt(r*r+z0^2/(ms*ms));
	r2=sqrt(r*r+(z0+2*ze)^2/(ms*ms));
   g=exp(-sqrt(3*ms*ma+k0*k0*ms*ms*V2*t.^2)*r1)/r1 ...
		-exp(-sqrt(3*ms*ma+k0*k0*ms*ms*V2*t.^2)*r2)/r2;
	g=g-(exp(-sqrt(3*ms*(ma+mx)+k0*k0*ms*ms*V2*t.^2)*r1)/r1 ...
		-exp(-sqrt(3*ms*(ma+mx)+k0*k0*ms*ms*V2*t.^2)*r2)/r2);
	g=g/(exp(-sqrt(3*ms*ma)*r1)/r1-exp(-sqrt(3*ms*ma)*r2)/r2 ...
		-exp(-sqrt(3*ms*(ma+mx))*r1)/r1+exp(-sqrt(3*ms*(ma+mx))*r2)/r2);
