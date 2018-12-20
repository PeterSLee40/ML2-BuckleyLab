%% Chi^2 fn for fitting G_2 (G2Fitx)
%% t and G2 are column vectors
%%
%% x0(1)=D_B , x0(2)=beta
%%revised by EB 7/1/10
function g=xg2fitx_RF(V,beta,r,taustmp,muspo,muao,k0,ze,G2,N)
    x0=[V beta];
	f=g2fitx_RF(x0,r,taustmp,muspo,muao,k0,ze);
    
	%g=norm(f-G2(1:N));
g=norm(f-G2(1:N)');