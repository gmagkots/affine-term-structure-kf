function Q = volatility_to_covariance(obj,dt,kappa_mat,sigma_mat)
%  Purpose:
%
%    Convert the volatility matrix to the one-month conditional covariance
%    matrix for continuous time arbitrage-free models. The latter is the
%    state covariance matrix that is used during the Kalman filtering.
%
%  Input:
%
%    Current object, the time step dt in years, the kappa matrix used to
%    form the state parameter matrix, and the state volatility matrix
%    (sigma_mat).
%
%  Output:
%
%    The function returns the one-month conditional covariance matrix
%    (Harvey, equation 9.1.20b). 
%
%  Notes:
%
%    The product of volatility matrix and its transpose is placed in
%    parentheses to ensure the result is Hermitian. This is a MATLAB
%    intrinsic behavior. dt is the time step in years.
%
%  Author : Georgios Magkotsios
%  Version: November 2011
%
    fun = @(s)expm(-kappa_mat*(dt-s))*(sigma_mat* ...
              sigma_mat')*expm(-kappa_mat'*(dt-s));
    Q   = quadv(fun,0.0,dt);
end