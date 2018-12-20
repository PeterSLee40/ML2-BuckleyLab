%% Chi^2 fn for fitting G_1 (G1Fitx)
%% t and G1 are column vectors
%%
%%revised by EB 2/25/10
function g=xg1fitx_new1(Db,r,taustmp,muspo,muao,k0,ze,G1,N)
    f=g1fitx(Db,r,taustmp,muspo,muao,k0,ze);
    
	%g=norm(f-G2(1:N));
g=norm(f-G1(1:N));