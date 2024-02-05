function initialize_AFNS_correlated(iobj)
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
        iobj.lambda                      = 0.02;
        iobj.constant_vector             = [0.9 0.3 0.7]';
        iobj.state_transition_matrix     = [0.1 0.07 0.02 ; ...
                                            0.4 0.78 0.95 ; ...
                                            0.7 0.18 0.75];
        iobj.state_transition_covariance = [3.452572e-01  0.000000e+00  0.000000e+00 ; ...
                                            1.225720e-02  1.466043e-01  0.000000e+00 ; ...
                                            3.768519e-02  1.973080e-01  4.940947e-02];
        iobj.measurement_covariance = diag([4.085734e-03   2.715364e-03 ...
              1.344993e-03   1.192730e-03   7.359397e-04   5.329219e-04 ...
              1.395748e-03   1.395748e-03   9.389576e-04   8.374487e-04 ...
              7.359397e-04   5.836764e-04   4.821675e-04   3.299041e-04 ...
              1.776407e-04   2.537733e-05   1.776407e-04   4.821675e-04 ...
              4.821675e-04   4.821675e-04   4.821675e-04   4.821675e-04 ...
              5.329219e-04   4.821675e-04   1.776407e-04   2.537733e-05 ...
              2.283952e-04   4.821675e-04   7.866942e-04   1.395748e-03])*100;
    else
        % Fama-Bliss data have 16 maturity dates
        iobj.lambda                      = 0.8244;
        iobj.constant_vector             = [ 0.0794 -0.0396 -0.0279]';
        iobj.state_transition_matrix     = [10.274  19.01  -30.71 ; ...
                                            -5.2848  5.573  -8.55 ; ...
                                            -7.31   -6.77   30.09];
        iobj.state_transition_covariance = [ 0.0154  0.0     0.0    ; ...
                                            -0.0013  0.0117  0.0    ; ...
                                            -0.1641 -0.059   0.0001];
        iobj.measurement_covariance = diag([1.247556e-03  -2.929128e-04 ...
             -7.162340e-04   1.097962e-03  -1.055842e-03   5.665480e-04 ...
             -3.074675e-04  -4.436635e-04  -7.498841e-04  -4.525169e-04 ...
              2.705908e-04  -3.737866e-04  -8.828232e-04  -2.978022e-03 ...
             -3.551261e-03   3.737115e-03]);
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
    filename = 'AFNS_cor_parameter_vector.mat';
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