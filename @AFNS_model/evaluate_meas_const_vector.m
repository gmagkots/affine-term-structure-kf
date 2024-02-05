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
    tau = AFGNS.maturity;
    sig = AFGNS.state_cov;
    lam = AFGNS.lambda;
    
% Evaluate the barred coefficients
    Abar = sig(1,1)^2 + sig(1,2)^2 + sig(1,3)^2;
    Bbar = sig(2,1)^2 + sig(2,2)^2 + sig(2,3)^2;
    Cbar = sig(3,1)^2 + sig(3,2)^2 + sig(3,3)^2;

    Dbar = sig(1,1)*sig(2,1) + sig(1,2)*sig(2,2) + sig(1,3)*sig(2,3);
    Ebar = sig(1,1)*sig(3,1) + sig(1,2)*sig(3,2) + sig(1,3)*sig(3,3);

    Fbar = sig(2,1)*sig(3,1) + sig(2,2)*sig(3,2) + sig(2,3)*sig(3,3);

% Evaluate the vectors multiplied by the barred coefficients
    Avec = 1/6*tau.^2;
    Bvec = 1/(2*lam)^2 - (1-exp(-lam*tau))./(lam^3*tau) ...
           + (1-exp(-2*lam*tau))./(4*lam^3*tau);
    Cvec = 1/(2*lam)^2 + exp(-lam*tau)/lam^2 ...
           - tau.*exp(-2*lam*tau)/(4*lam) ...
           -    3*exp(-2*lam*tau)/(4*lam^2) ...
           + 5/(8*lam^3)*(1-exp(-2*lam*tau))./tau ...
           -   2/(lam^3)*(1-exp(-lam*tau))./tau;
    Dvec = 1/(2*lam)*tau + exp(-lam*tau)/(lam^2) ...
           - (1-exp(-lam*tau))./(lam^3*tau);
    Evec = 3*exp(-lam*tau)/(lam^2) + 1/(2*lam)*tau ...
           + tau.*exp(-lam*tau)/lam ...
           - 3*(1-exp(-lam*tau))./(lam^3*tau);
    Fvec = 1/(lam^2) + 1/(lam^2)*exp(-lam*tau) ...
           - 1/(2*lam^2)*exp(-2*lam*tau) ...
           -   3/(lam^3)*(1-exp(-lam*tau))./tau ...
           + 3/(4*lam^3)*(1-exp(-2*lam*tau))./tau;

% Evaluate the meas_const_vector
    meas_const_vector = Abar*Avec + Bbar*Bvec + Cbar*Cvec + Dbar*Dvec + ...
                        Ebar*Evec + Fbar*Fvec;

end