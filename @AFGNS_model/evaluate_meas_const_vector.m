function meas_const_vector = evaluate_meas_const_vector(AFGNS)
%  Purpose:
%
%    Evaluate the constant vector for the measurement equation in the AFGNS
%    model.
%
%  Input:
%
%    Current object
%
%  Output:
%
%    The 16 x 1 constant vector in the measurement equation
%
%  Reference:
%
%    J.H.E. Christensen, F.X. Diebold, G.D. Rudebusch,
%    Econometrics Journal, 12, C33 (2009) -- Appendix
%    
%  Author : Georgios Magkotsios
%  Version: November 2011
%

% Simplify the notation of certain state space quantities
    tau  = AFGNS.maturity;
    sig  = AFGNS.state_cov;
    lam1 = AFGNS.lambda(1);
    lam2 = AFGNS.lambda(2);
    
% Evaluate the barred coefficients
    Abar = sig(1,1)^2 + sig(1,2)^2 + sig(1,3)^2 + sig(1,4)^2 + sig(1,5)^2;
    Bbar = sig(2,1)^2 + sig(2,2)^2 + sig(2,3)^2 + sig(2,4)^2 + sig(2,5)^2;
    Cbar = sig(3,1)^2 + sig(3,2)^2 + sig(3,3)^2 + sig(3,4)^2 + sig(3,5)^2;
    Dbar = sig(4,1)^2 + sig(4,2)^2 + sig(4,3)^2 + sig(4,4)^2 + sig(4,5)^2;
    Ebar = sig(5,1)^2 + sig(5,2)^2 + sig(5,3)^2 + sig(5,4)^2 + sig(5,5)^2;

    Fbar = sig(1,1)*sig(2,1) + sig(1,2)*sig(2,2) + sig(1,3)*sig(2,3) + ...
           sig(1,4)*sig(2,4) + sig(1,5)*sig(2,5);
    Gbar = sig(1,1)*sig(3,1) + sig(1,2)*sig(3,2) + sig(1,3)*sig(3,3) + ...
           sig(1,4)*sig(3,4) + sig(1,5)*sig(3,5);
    Hbar = sig(1,1)*sig(4,1) + sig(1,2)*sig(4,2) + sig(1,3)*sig(4,3) + ...
           sig(1,4)*sig(4,4) + sig(1,5)*sig(4,5);
    Ibar = sig(1,1)*sig(5,1) + sig(1,2)*sig(5,2) + sig(1,3)*sig(5,3) + ...
           sig(1,4)*sig(5,4) + sig(1,5)*sig(5,5);

    Jbar = sig(2,1)*sig(3,1) + sig(2,2)*sig(3,2) + sig(2,3)*sig(3,3) + ...
           sig(2,4)*sig(3,4) + sig(2,5)*sig(3,5);
    Kbar = sig(2,1)*sig(4,1) + sig(2,2)*sig(4,2) + sig(2,3)*sig(4,3) + ...
           sig(2,4)*sig(4,4) + sig(2,5)*sig(4,5);
    Lbar = sig(2,1)*sig(5,1) + sig(2,2)*sig(5,2) + sig(2,3)*sig(5,3) + ...
           sig(2,4)*sig(5,4) + sig(2,5)*sig(5,5);

    Mbar = sig(3,1)*sig(4,1) + sig(3,2)*sig(4,2) + sig(3,3)*sig(4,3) + ...
           sig(3,4)*sig(4,4) + sig(3,5)*sig(4,5);
    Nbar = sig(3,1)*sig(5,1) + sig(3,2)*sig(5,2) + sig(3,3)*sig(5,3) + ...
           sig(3,4)*sig(5,4) + sig(3,5)*sig(5,5);

    Obar = sig(4,1)*sig(5,1) + sig(4,2)*sig(5,2) + sig(4,3)*sig(5,3) + ...
           sig(4,4)*sig(5,4) + sig(4,5)*sig(5,5);

% Evaluate the vectors multiplied by the barred coefficients
    Avec = 1/6*tau.^2;
    Bvec = 1/(2*lam1)^2 - (1-exp(-lam1*tau))./(lam1^3*tau) ...
           + (1-exp(-2*lam1*tau))./(4*lam1^3*tau);
    Cvec = 1/(2*lam2)^2 - (1-exp(-lam2*tau))./(lam2^3*tau) ...
           + (1-exp(-2*lam2*tau))./(4*lam2^3*tau);
    Dvec = 1/(2*lam1)^2 + exp(-lam1*tau)/lam1^2 ...
           - tau.*exp(-2*lam1*tau)/(4*lam1) ...
           -    3*exp(-2*lam1*tau)/(4*lam1^2) ...
           + 5/(8*lam1^3)*(1-exp(-2*lam1*tau))./tau ...
           -   2/(lam1^3)*(1-exp(-lam1*tau))./tau;
    Evec = 1/(2*lam2)^2 + exp(-lam2*tau)/lam2^2 ...
           - tau.*exp(-2*lam2*tau)/(4*lam2) ...
           -    3*exp(-2*lam2*tau)/(4*lam2^2) ...
           + 5/(8*lam2^3)*(1-exp(-2*lam2*tau))./tau ...
           -   2/(lam2^3)*(1-exp(-lam2*tau))./tau;
    Fvec = 1/(2*lam1)*tau + exp(-lam1*tau)/(lam1^2) ...
           - (1-exp(-lam1*tau))./(lam1^3*tau);
    Gvec = 1/(2*lam2)*tau + exp(-lam2*tau)/(lam2^2) ...
           - (1-exp(-lam2*tau))./(lam2^3*tau);
    Hvec = 3*exp(-lam1*tau)/(lam1^2) + 1/(2*lam1)*tau ...
           + tau.*exp(-lam1*tau)/lam1 ...
           - 3*(1-exp(-lam1*tau))./(lam1^3*tau);
    Ivec = 3*exp(-lam2*tau)/(lam2^2) + 1/(2*lam2)*tau ...
           + tau.*exp(-lam2*tau)/lam2 ...
           - 3*(1-exp(-lam2*tau))./(lam2^3*tau);
    Jvec = 1/(lam1*lam2) ...
           - 1/(lam1^2*lam2)*(1-exp(-lam1*tau))./tau ...
           - 1/(lam1*lam2^2)*(1-exp(-lam2*tau))./tau ...
           + 1/(lam1*lam2*(lam1+lam2))*(1-exp(-(lam1+lam2)*tau))./tau;
    Kvec = 1/(lam1^2) + 1/(lam1^2)*exp(-lam1*tau) ...
           - 1/(2*lam1^2)*exp(-2*lam1*tau) ...
           -   3/(lam1^3)*(1-exp(-lam1*tau))./tau ...
           + 3/(4*lam1^3)*(1-exp(-2*lam1*tau))./tau;
    Lvec =   1/(lam1*lam2) ...
           + 1/(lam1*lam2)*exp(-lam2*tau) ...
           - 1/(lam1*(lam1+lam2))*exp(-(lam1+lam2)*tau) ...
           - 1/(lam1^2*lam2)*(1-exp(-lam1*tau))./tau ...
           - 2/(lam1*lam2^2)*(1-exp(-lam2*tau))./tau ...
           + (lam1+2*lam2)/(lam1*lam2*(lam1+lam2)^2)*(1-exp(-(lam1+lam2)*tau));
    Mvec =   1/(lam1*lam2) ...
           + 1/(lam1*lam2)*exp(-lam1*tau) ...
           - 1/(lam2*(lam1+lam2))*exp(-(lam1+lam2)*tau) ...
           - 1/(lam1*lam2^2)*(1-exp(-lam2*tau))./tau ...
           - 2/(lam1^2*lam2)*(1-exp(-lam1*tau))./tau ...
           + (lam2+2*lam1)/(lam1*lam2*(lam1+lam2)^2)*(1-exp(-(lam1+lam2)*tau));
    Nvec = 1/(lam2^2) + 1/(lam2^2)*exp(-lam2*tau) ...
           - 1/(2*lam2^2)*exp(-2*lam2*tau) ...
           -   3/(lam2^3)*(1-exp(-lam2*tau))./tau ...
           + 3/(4*lam2^3)*(1-exp(-2*lam2*tau))./tau;
    Ovec =   1/(lam1*lam2) ...
           + 1/(lam1*lam2)*exp(-lam1*tau) ...
           + 1/(lam1*lam2)*exp(-lam2*tau) ...
           - (1/lam1+1/lam2)/(lam1+lam2)*exp(-(lam1+lam2)*tau) ...
           - 2/(lam1+lam2)^2*exp(-(lam1+lam2)*tau) ...
           - 1/(lam1+lam2)*tau.*exp(-(lam1+lam2)*tau) ...
           - 2/(lam1^2*lam2)*(1-exp(-lam1*tau))./tau ...
           - 2/(lam1*lam2^2)*(1-exp(-lam2*tau))./tau ...
           + 2/((lam1+lam2)^3)*(1-exp(-(lam1+lam2)*tau))./tau ...
           + (1/lam1+1/lam2)/(lam1+lam2)^2*(1-exp(-(lam1+lam2)*tau))./tau ...
           + 1/(lam1*lam2*(lam1+lam2))*(1-exp(-(lam1+lam2)*tau))./tau;

% Evaluate the meas_const_vector
    meas_const_vector = Abar*Avec + Bbar*Bvec + Cbar*Cvec + Dbar*Dvec + ...
                        Ebar*Evec + Fbar*Fvec + Gbar*Gvec + Hbar*Hvec + ...
                        Ibar*Ivec + Jbar*Jvec + Kbar*Kvec + Lbar*Lvec + ...
                        Mbar*Mvec + Nbar*Nvec + Obar*Ovec;

end