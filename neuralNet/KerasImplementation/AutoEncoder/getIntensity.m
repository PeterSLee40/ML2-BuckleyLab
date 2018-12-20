function intensity = getIntensity(rho)
%rho is in cm
intensity = exp(-rho*2.9)*31000000
if (intensity > 500000)
    intensity = 500000;
end
end