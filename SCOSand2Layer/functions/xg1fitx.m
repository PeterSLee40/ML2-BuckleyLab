%% Chi^2 fn for fitting G_1 (G1Fitx)
%% t and G1 are column vectors
%%
%% x0(1)=D_B , x0(2)=mu_x
%%revised by turgut no need for x0(2) now!
function g=XG1Fitx(x0,mx,r,t,ms,ma,k0,ze,G1,N)
%	f=G1Fitx(x0(1),r,t(1:N),ms,ma,mx,k0,ze);
	f=G1Fitx(x0,r,t(1:N),ms,ma,mx,k0,ze);
	g=norm(f-G1(1:N));
%% revised 9/2/99
