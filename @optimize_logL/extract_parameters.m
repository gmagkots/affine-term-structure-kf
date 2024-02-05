function [lambda mu state_par state_cov meas_cov] = extract_parameters(QML,x)
%  Purpose:
%
%    Extract parameters from the parameter vector and place them back to
%    the proper model containers.
%
%  Input:
%
%    The parameter vector.
%
%  Output:
%
%    The model containers.
%
%  Notes:
%
%    The parameter vector begins with the lambda vector, and then merges
%    the non-zero elements of the rest of the model containers. Each
%    element of param_vec_len marks the ending position of a corresponding 
%    model container in the parameter vector x. Specifically,
%    param_vec_len(1): ending position of lambda vector
%    param_vec_len(2): ending position of mu vector
%    param_vec_len(3): ending position of state parameter matrix
%    param_vec_len(4): ending position of state covariance matrix
%    param_vec_len(5): ending position of measurement covariance matrix
%    See also the comments in the class definition.
%
%  Author : Georgios Magkotsios
%  Version: January 2012
%

    % allocate the matrices
    state_par = zeros(QML.state_par_dim);
    state_cov = zeros(QML.state_cov_dim);
    meas_cov  = zeros(QML.meas_cov_dim);

    % extract the parameter vector
    lambda = x(1:QML.param_vec_len(1))';
    mu     = x(QML.param_vec_len(1)+1:QML.param_vec_len(2))';
    state_par(QML.state_par_idx) = x(QML.param_vec_len(2)+1:QML.param_vec_len(3));
    state_cov(QML.state_cov_idx) = x(QML.param_vec_len(3)+1:QML.param_vec_len(4));
    meas_cov(QML.meas_cov_idx)   = x(QML.param_vec_len(4)+1:QML.param_vec_len(5));

end