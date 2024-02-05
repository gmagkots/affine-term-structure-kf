function [res,msg] = Kalman_stability(KF)
%  Purpose:
%
%    Check the stability conditions required for a time-invariant
%    Kalman filter
%
%  Input:
%
%    None
%
%  Output:
%
%    A logical that verifies the success or failure of the stability
%    test, and a message that displays the type of error.
%
%  Notes:
%
%    The requirements that the state transition and measurement covariance
%    matrices are positive definite imply that the state vector covariance
%    matrix P evaluated by the filter is also positive definite.
%
%  Author : Georgios Magkotsios
%  Version: January 2012
%

    % stable filter
    res = true;
    msg = '';

    % the state covariance matrix should be positive-definite (using the
    % cholesky decomposition intrinsic instead of the eigenvalue intrinsic
    % is more efficient computationally)
    % if eig(KF.Qmat) > 0
    [~,flag] = chol(KF.Qmat);
    if flag ~= 0
        res = false;
        msg = ['The state covariance matrix is not ' ...
               'positive-definite.\n'];
        return;
    end

    % the measurement covariance matrix should be positive-definite
    % if eig(KF.Hmat) > 0
    [~,flag] = chol(KF.Hmat);
    if flag ~= 0
        res = false;
        msg = ['The measurement covariance matrix is not ' ...
               'positive-definite.\n'];
        return;
    end

    % Controllability and observability criteria (Harvey, equations 3.3.4
    % and 3.3.5 respectively). The control matrix is the Cholesky
    % decomposition of the state covariance matrix (Harvey, equation
    % 3.3.8). Preallocate the block matrix containers for optimal
    % performance.
    block_ctr   = zeros(KF.Npar,KF.Npar^2);
    block_obs   = zeros(KF.Npar,KF.Npar*KF.Ndat);
    control_mat = chol(KF.Qmat,'lower');
    for i=0:KF.Npar-1
        temp_ctr  = (KF.Tmat)^i*control_mat;
        temp_obs  = (KF.Tmat')^i*KF.Zmat';
        block_ctr(:,(1:KF.Npar)+i*KF.Npar) = temp_ctr;
        block_obs(:,(1:KF.Ndat)+i*KF.Ndat) = temp_obs;
    end

    if rank(block_ctr) ~= KF.Npar
        res = false;
        msg = 'The controllability condition is violated.\n';
        return;
    end
    if rank(block_obs) ~= KF.Npar
        res = false;
        msg = 'The observability condition is violated.\n';
        return;
    end

    % the eigenvalues of the state transition matrix should lie within the
    % unit circle (Harvey, equation 3.3.3)
    if max(abs(eig(KF.Tmat))) >= 1
        res = false;
        msg = ['At least one eigenvalue of the state transition ' ...
               'matrix lies outside the unit circle.\n'];
        return;
    end

end