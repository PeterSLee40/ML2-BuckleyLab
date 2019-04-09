function  [X, fcrv, cstf, info] = TwoLayer_InverseMarquardt(X0, data,...
    en, flags, opts)
    % Inverse two layer model using Marquardt's method for least squares. 
    % Inputs:
    %       X0    - Initial guess for fitting parameters. In the format
    %               X0=[mua1, musp1, L, mua2, musp2, af]. Units of mu's are
    %               1/mm, units of L are mm, units of af are 1/(mm^2 arb) 
    %               or unitless depending on units of amplitude data.
    %       data  - Mulidistance phase and amplitude data including errors.
    %               In the format data=[rho, phi, amp, phi_err, amp_err].
    %               Units of pho are mm, units of phi's are radians, and
    %               units of amp are 1/mm^2 or arb depending on units of
    %               af.
    %       en    - (OPTIONAL) Zeroth order Bessel function roots. Loaded 
    %               from zeroOrdBesselRoots.mat 
    %       flags - (OPTIONAL) Vector of boolean controling what parameters
    %               are fit for. Length and order are the same as X0 and X.
    %       opts  - (OPTIONAL) Options struct containing:
    %               muInit - Initial mu value. (Default: 1)
    %               grdCrt - Gradient stopping criteria. (Default: 1e-8)
    %               stpCrt - Step size stopping criteria. (Default: 1e-8)
    %               maxItr - Maximum number of iterations. (Default: 500)
    %               fwdOpt - (OPTIONAL) Forward model options struct 
    %                        containing:
    %                        no    - Index of refraction outside. 
    %                                (Default: 1)
    %                        ni    - Index of refraction inside. 
    %                                (Default: 1.4)
    %                        fmod  - Source modulation frequency. Units are
    %                                Hz. (Default: 140 MHz)
    %                        B     - Radius of the cylindrical boundary. 
    %                                Units are mm. (Default: 15 cm)
    %                        h_end - Number of eigenvalues. (Default: 2000)
    % Outputs:
    %       X     - Fitted parameters. In the format
    %               X0=[mua1, muspp1, L, mua2, muspp2, af]. Units of mu's 
    %               are 1/mm, units of L are mm, units of af are 
    %               1/(mm^2 arb) or unitless depending on units of
    %               amplitude data.
    %       fcrv  - Fitted curve of phase and amplitude. In the format
    %               fcrv=[rho, phi, amp]. Units of rho are mm, units of phi
    %               are radians, and units of amp are 1/mm^2 or arb 
    %               depending on units of af.
    %       cstf  - History of cost function value over iterations.
    %       info  - Vector with six elements:
    %               info(1) - F(X)
    %               info(2) - ||F'||_inf
    %               info(3) - ||dx||
    %               info(4) - mu/max(diag(A)) where A=J'J
    %               info(5) - Number of iterations
    %               info(6) - Stopping condition with value:
    %                         1 - Small gradient
    %                         2 - Small step
    %                         3 - Reached max iterations
    %                         4 - Singular matrix

    % Written By Bertan Hallacoglu
    % Modified by Angelo Sassaroli
    % Again modified by Giles Blaney
    
    %% Setup
    
    % Check for options
    if nargin<=2
        load('zeroOrdBesselRoots.mat', 'en');
    end
    if nargin<=3
        flags=ones(size(X0));
    end
    if nargin<=4
        optsVec=[1, 1e-8, 1e-8, 500]';
        fwdOpt=[];
    else
        optsVec=[opts.muInit, opts.grdCrt, opts.stpCrt, opts.maxItr]';
        fwdOpt=opts.fwdOpt;
    end

    if isempty(fwdOpt)
        fwdOpt.no=1;
        fwdOpt.ni=1.4;
        fwdOpt.fmod=140e6; %Hz
        fwdOpt.B=150; %mm
        fwdOpt.h_end=2000;
    end
    
    cstf=zeros(optsVec(4)+1,1);
    
    %% Initialize First Iteration
    [X, n, f, J]=...
        checkfun(@TwoLayerRef_DiffEqs, X0, data,...
        flags, en, fwdOpt);
    cstf(1)=(f'*f);
    
    A=J'*J; % Square symmetric Jacobian
    F=(f'*f)/2; % Least squares
    g=J'*f; % Gradient
    ng=norm(g, inf);               
    mu=optsVec(1)*max(diag(A));
    kmax=optsVec(4);
    k=1;   
    nu=2;   
    nh=0;   
    stop=0;

    %% Iteration Loop
    while ~stop
        %% Check Stoping Criteria
        if  ng<=optsVec(2) % gradient stopping criteria
            stop=1;                        
        else
            h=(A+mu*eye(n))\(-g); % Tikhonov-type pseudo inverse
            nh=norm(h);
            nx=optsVec(3)+max(svd(X));
            if nh<=(optsVec(3)*nx) % Step size stopping criteria
                stop=2;
            elseif nh>=(nx/eps) % Singular stopping criteria
                stop=4;
            end                                     
        end
        
        %% Carryout Iteration
        if ~stop
            xnew=X+h; % New iteration value
            h=xnew-X;   
            dL=(h'*(mu*h-g))/2; % Predicted gain
            [fnew, Jnew, fcrv]=feval(@TwoLayerRef_DiffEqs,...
                xnew, data, flags, en, fwdOpt);
            Fnew=(fnew'*fnew)/2;   
            dF = F - Fnew; % Actual gain
            if (dL>0) && (dF> 0) % Update X and modify mu
                X=xnew;
                F=Fnew;
                J=Jnew;
                f=fnew;
                A=J'*J;
                g=J'*f;
                ng=norm(g, inf);
                mu=mu*max(1/3, 1-(2*dF/dL-1)^3); % Update mu
                nu=2; % Update nu
            else % Increase mu and nu
                mu=mu*nu;
                nu=2*nu;
            end
            
            cstf(k)=F;
            k=k+1;
            
            if k>kmax % Max iterations stopping criteria
                stop=3;
            end
        end
    end

    %% Package info
    info=[F, ng, nh, mu/max(diag(A)), k-1, stop];
    
end

function  [X, n, f, J] = checkfun(fun_marq2DE_six_param,...
    x0, data, flags, en, fwdOpt)
    % Check the initialization of parameters
    sx=size(x0);
    n=max(sx);
    
    if min(sx)>1
        error('x0 must be a vector');
    end
    
    X=x0(:);
    
    [f, J]=feval(fun_marq2DE_six_param, X, data, flags, en, fwdOpt);
    sf=size(f);
    sJ=size(J);
    
    if  sf(2)~=1
        error('f must be a column vector');
    end
    if  sJ(1)~=sf(1)
        error('row numbers in f and J do not match');
    end
    if  sJ(2)~=n
        error('number of columns in J does not match X');
    end
end

function [f, J, fitCurve] = TwoLayerRef_DiffEqs(x0, data,...
    flags, en, fwdOpt)
    % Solutions for two-layer medium diffusion equation
    format long;
    
    r0=data(:, 1);
    ph0=data(:, 2);
    ac0=data(:, 3);
    phs=data(:, 4);
    acs=data(:, 5);
    
    mua1=x0(1);
    musp1=x0(2);
    L0=x0(3);
    mua2=x0(4);
    musp2=x0(5);
    af=x0(6);
    
    mu=[mua1, mua2, musp1, musp2];

    %% Forward Model
    [amp, phi]=TwoLayerReflectance(mu, L0, r0, en, fwdOpt);
    amp=amp*af;

    %% Numerical Derivatives
    derVec=[1e-04, 1e-02, 0.001, 1e-04, 1e-02, 1e-04].*flags;
    dmua1=derVec(1);
    dmusp1=derVec(2); 
    dmua2=derVec(4);
    dmusp2=derVec(5);
    daf=derVec(6);
    dL0=derVec(3);
    
    % Perturb mua1
    mu=[mua1+dmua1, mua2, musp1, musp2];
    [amp_mua1p, phi_mua1p]=TwoLayerReflectance(mu, L0, r0, en, fwdOpt);
    amp_mua1p=amp_mua1p*af;
    
    mu=[mua1-dmua1, mua2, musp1, musp2];
    [amp_mua1m, phi_mua1m]=TwoLayerReflectance(mu, L0, r0, en, fwdOpt);
    amp_mua1m=amp_mua1m*af;
    
    % 2) Perturb musp1
    mu=[mua1, mua2, musp1+dmusp1, musp2];
    [amp_musp1p, phi_musp1p]=TwoLayerReflectance(mu, L0, r0, en, fwdOpt);
    amp_musp1p=amp_musp1p*af;
    
    mu=[mua1, mua2, musp1-dmusp1, musp2];
    [amp_musp1m, phi_musp1m]=TwoLayerReflectance(mu, L0, r0, en, fwdOpt);
    amp_musp1m=amp_musp1m*af;
    
    % 3) Perturb L
    mu=[mua1, mua2, musp1, musp2];
    [amp_L0p, phi_L0p]=TwoLayerReflectance(mu, L0+dL0, r0, en, fwdOpt);
    amp_L0p=amp_L0p*af;
    
    [amp_L0m, phi_L0m]=TwoLayerReflectance(mu, L0-dL0, r0, en, fwdOpt);
    amp_L0m=amp_L0m*af;
    
    % 4) Perturb mua2
    mu=[mua1, mua2+dmua2, musp1, musp2];
    [amp_mua2p, phi_mua2p]=TwoLayerReflectance(mu, L0, r0, en, fwdOpt);
    amp_mua2p=amp_mua2p*af;
    
    mu=[mua1, mua2-dmua2, musp1, musp2];
    [amp_mua2m, phi_mua2m]=TwoLayerReflectance(mu, L0, r0, en, fwdOpt);
    amp_mua2m=amp_mua2m*af;
    
    % 5) Perturb musp2
    mu=[mua1, mua2, musp1, musp2+dmusp2];
    [amp_musp2p, phi_musp2p]=TwoLayerReflectance(mu, L0, r0, en, fwdOpt);
    amp_musp2p=amp_musp2p*af;
    
    mu=[mua1, mua2, musp1, musp2-dmusp2];
    [amp_musp2m, phi_musp2m]=TwoLayerReflectance(mu, L0, r0, en, fwdOpt);
    amp_musp2m=amp_musp2m*af;
    
    % 6) Perturbed Amplitude Factor
    mu=[mua1, mua2, musp1, musp2];
    [amp_afp, phi_afp]=TwoLayerReflectance(mu, L0, r0, en, fwdOpt);
    amp_afp=amp_afp*(af+daf);
    
    [amp_afm, phi_afm]=TwoLayerReflectance(mu, L0, r0, en, fwdOpt);
    amp_afm=amp_afm*(af+daf);
    
    %% Create Jacobian and Calculate Cost
    der_acmod(:, 1)=(1./acs).*((amp_mua1p-amp_mua1m)/(2*dmua1));       
    der_acmod(:, 2)=(1./acs).*((amp_musp1p-amp_musp1m)/(2*dmusp1));
    der_acmod(:, 3)=(1./acs).*((amp_L0p-amp_L0m)/(2*dL0));  
    der_acmod(:, 4)=(1./acs).*((amp_mua2p-amp_mua2m)/(2*dmua2));       
    der_acmod(:, 5)=(1./acs).*((amp_musp2p-amp_musp2m)/(2*dmusp2));     
    der_acmod(:, 6)=(1./acs).*((amp_afp-amp_afm)/(2*daf));         
    der_phmod(:, 1)=(1./phs).*((phi_mua1p-phi_mua1m)/(2*dmua1));
    der_phmod(:, 2)=(1./phs).*((phi_musp1p-phi_musp1m)/(2*dmusp2));
    der_phmod(:, 3)=(1./phs).*((phi_L0p-phi_L0m)/(2*dL0));    
    der_phmod(:, 4)=(1./phs).*((phi_mua2p-phi_mua2m)/(2*dmua2));
    der_phmod(:, 5)=(1./phs).*((phi_musp2p-phi_musp2m)/(2*dmusp2));
    der_phmod(:, 6)=(1./phs).*((phi_afp-phi_afm)/(2*daf));
    
    f=[(amp-ac0)./acs; (phi-ph0)./phs]; % Cost vector
    J=[der_acmod;der_phmod];  %Jacobian matrix
    J(isnan(J))=0;
    
    fitCurve = [r0,phi,amp];

end
