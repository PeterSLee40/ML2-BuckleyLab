function [amp, phi] = TwoLayerReflectance(mu, L, rho, en, opt)
    % Two-layer solution of the diffusion equation in semi-infinite
    % geometry.
    % Inputs:
    %       mu  -   Absorption and scattering coeficents for the first and
    %               second layer. In the format
    %               mu=[mua1, mua2, musp1, musp2]. Units are 1/mm.
    %       L   -   Thickness of the first layer. Units are mm.
    %       rho -   Source detector seperation. Units are mm.
    %       en  -   (OPTIONAL) Zeroth order Bessel function roots. Loaded 
    %               from  zeroOrdBesselRoots.mat
    %       opt -   (OPTIONAL) Options struct containing:
    %               no    - Index of refraction outside. (Default: 1)
    %               ni    - Index of refraction inside. (Default: 1.4)
    %               fmod  - Source modulation frequency. Units are Hz. 
    %                       (Default: 140 MHz)
    %               B     - Radius of the cylindrical boundary. Units are
    %                       mm. (Default: 15 cm)
    %               h_end - Number of eigenvalues. (Default: 2000)
    % Outputs:
    %       amp -   Reflectance amplitude. Units are 1/mm^2
    %       phi -   Reflectance phase. Units are radians. 

    % Written By Bertan Hallacoglu
    % Modified by Angelo Sassaroli
    % Again modified by Giles Blaney

    %% Setup
    c=2.99792458e11; %mm/sec (Speed of light)

    % Check for options
    if nargin<=3
        load('zeroOrdBesselRoots.mat', 'en');
    end
    if nargin<=4
        no=1;
        ni=1.4;
        fmod=140e6; %Hz
        B=150; %mm
        h_end=2000;
    else
        no=opt.no;
        ni=opt.ni;
        fmod=opt.fmod; %Hz
        B=opt.B; %mm
        h_end=opt.h_end;
    end

    % Parse mu=[mua1, mua2, musp1, musp2]
    mua1=mu(1); %1/mm
    mua2=mu(2); %1/mm
    musp1=mu(3); %1/mm
    musp2=mu(4); %1/mm

    % Calculate constants
    nu=c/ni; %mm/sec (Photon velocity)
    omega=2*pi*fmod; %rad/sec (Angular modulation frequency)

    D1=1/(3*musp1); %mm (Diffusion coefficient of first layer)
    D2=1/(3*musp2); %mm (Diffusion coefficient of second layer)
    z0=1/musp1; %mm (Transport mean free path)

    %% Evaluate Reflectance
    tetai=linspace(0, 90*pi/180, 1001)';
    tetar=asin(sin(tetai)*ni/no);
    tetac=asin(no/ni);
    indx=find(tetai<=tetac);

    RF=zeros(size(tetai));
    RF(indx)=0.5*((ni*cos(tetar(indx))-no*cos(tetai(indx)))./...
        (ni*cos(tetar(indx))+no*cos(tetai(indx)))).^2+...
        0.5*((ni*cos(tetai(indx))-no*cos(tetar(indx)))./...
        (ni*cos(tetai(indx))+no*cos(tetar(indx)))).^2;
    RF((indx(end)+1):end)=1;

    rp=sum(2*sin(tetai).*cos(tetai).*RF)*tetai(2);
    rj=sum(3*sin(tetai).*cos(tetai).^2.*RF)*tetai(2);

    rd=(rp+rj)/(2-rp+rj);
    zb=2*((1+rd)/(1-rd))*D1;

    n_end=numel(rho);
    [n, h]=meshgrid(1:n_end, 1:h_end);
    rho(n)=rho(n);

    Q=besselj(0,rho(n).*en(h)/B)./(besselj(1,en(h))).^2;

    a1=sqrt(mua1/D1+(en(h)/B).^2+1i*omega/(D1*nu));
    a2=sqrt(mua2/D2+(en(h)/B).^2+1i*omega/(D2*nu));
    
    flux=((exp(-a1*z0)+exp(-a1*(z0+2*zb)))/2+...
        sinh(a1*(z0+zb)).*cosh(a1*zb)./exp(a1*(L+zb)).*(D1*a1-D2*a2)./...
        (D1*a1.*cosh(a1*(L+zb))+D2*a2.*sinh(a1*(L+zb)))).*Q;

    R=1/(pi*B^2)*sum(flux,1);
    amp=(abs(R))';
    phi=(-angle(R))';

end
