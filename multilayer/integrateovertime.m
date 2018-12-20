function integrateovertime(inttime, Fs, t, g2_withnoise)
inttime = 3;%s
block_for_avg = 3*Fs;
total_curves = floor(max(t)/inttime);
tmp = 0;
for i=1:total_curves
    t_block(i) = t(tmp+1);
    signal(i,:)=squeeze(mean(g2_withnoise(j,tmp+1:tmp+block_for_avg,:),2));
    %Smooth g2 to determine where to fit
    signal_smooth=slidingavg(signal(i,good_start:end),avgnum);
    %Find where smoothed g2 > cutoff (defined above)
    foo = min(find(signal_smooth <= cutoff))+good_start;
    if isempty(foo) || foo < good_start
        foo=70;%Fit first 70 points
    end
    %Fit non-smoothed g2 using cutoff
    %obtained from smoothed g2
    corr2fit{i}=squeeze(signal(i,good_start:foo));
    taustmp=DelayTime(good_start:foo);
    %FIT G2 FOR CBFi and BETA
    betaDbfit(i,:) = fminsearchbnd(@(x) dcs_g2_Db_GT(x,taustmp,corr2fit{i},r,mua,musp,1,k0,R),guess,lb,ub);
    Dbfit_avg(i)=betaDbfit(i,1);
    betafit_avg(i)=betaDbfit(i,2);
    %Get fit g2 to test fit
    Curvefitg2avg(i,:)=dcs_g2fit_GT([Dbfit_avg(i) betafit_avg(i)],DelayTime,r,mua,musp,k0,R,1);
    tmp = tmp+block_for_avg;
end