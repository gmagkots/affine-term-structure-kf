function initialize_AFNS_uncorrelated(iobj)
%  Purpose:
%
%    Load the specific model parameters.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The corresponding model containers (saved as class properties).
%
%  Author : Georgios Magkotsios
%  Version: May 2012
%

% determine whether initial estimates or optimal values are used
if iobj.user_specified_parameters
    % set manually the initial parameters for this model
    if iobj.use_fed_data
        % FED data have 30 maturity dates
        iobj.lambda                      = 0.6;
        iobj.constant_vector             = [0.4 0.08 0.006]';
        iobj.state_transition_matrix     = diag([0.95 0.95 0.95]);
        iobj.state_transition_covariance = diag([0.04 0.02 0.025]);
        iobj.measurement_covariance = diag([3.121399e-03   2.791496e-04 ...
              8.882031e-04   8.882031e-04   6.851853e-04   4.821675e-04 ...
              5.329219e-04   5.329219e-04   6.344308e-04   7.359397e-04 ...
              8.374487e-04   8.882031e-04   9.389576e-04   8.882031e-04 ...
              8.374487e-04   7.866942e-04   5.836764e-04   5.329219e-04 ...
              4.821675e-04   7.613179e-05   2.283952e-04   4.821675e-04 ...
              7.866942e-04   1.091221e-03   1.344993e-03   1.751029e-03 ...
              2.106310e-03   2.461591e-03   2.715364e-03   3.222908e-03])*100;
    else
        % Fama-Bliss data have 16 maturity dates
        iobj.lambda                      = 0.5975;
        iobj.constant_vector             = [0.071 -0.0282 -0.0093]';
        iobj.state_transition_matrix     = diag([5.0816 5.2114 6.233]);
        iobj.state_transition_covariance = diag([0.0051 0.011  0.0264]);
        iobj.measurement_covariance = diag([-0.0013  0.0002  0.0007 ...
            -0.0011 -0.0011  0.0006 -0.0003  0.0004  0.0007 -0.0005 ...
             0.0003 -0.0004  0.0009 -0.0030 -0.0035  0.0038]);
    end

    % truncate the measurement covariance matrix if necessary
    iobj.measurement_covariance = iobj.measurement_covariance( ...
        1:iobj.maturities_number,1:iobj.maturities_number);
else
    % load the optimal parameters for this model
    if iobj.use_fed_data
        dirname = 'output_fed_optimization';
    else
        dirname = 'output_fama_bliss_optimization';
    end
    filename = 'AFNS_unc_parameter_vector.mat';
    mat_path = [dirname '/' filename];
    load_struct = load(mat_path);

    % copy the optimal parameters
    iobj.lambda                      = load_struct.lambda;
    iobj.constant_vector             = load_struct.mu;
    iobj.state_transition_matrix     = load_struct.state_par;
    iobj.state_transition_covariance = load_struct.state_cov;
    iobj.measurement_covariance      = load_struct.meas_cov;
end

end