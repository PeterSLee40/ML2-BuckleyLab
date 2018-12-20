function intensity = getIntensity(rho, intensityat25mm)
intensity = intensityat25mm*(2.5).^2*exp(-rho)/((rho).^2*exp(-2.5))*1e3;
if intensity > 500*1e3
    intensity = 500*1e3;
end