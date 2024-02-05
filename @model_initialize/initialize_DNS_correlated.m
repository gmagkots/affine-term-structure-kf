function initialize_DNS_correlated(iobj)
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
        iobj.lambda                      = 0.3;
        iobj.constant_vector             = [0.5 0.54 0.82]';
        iobj.state_transition_matrix     = [4.631091e-01    1.649266e-01    1.658909e-01 ; ...
                                            1.916742e-01    2.459054e-02    5.742613e-01 ; ...
                                            2.950610e-01    3.138909e-01    6.248128e-01];
        iobj.state_transition_covariance = [1.591152e-02    0.000000e+00    0.000000e+00 ; ...
                                            3.707613e-02    3.697462e-02    0.000000e+00 ; ...
                                            2.474280e-02    8.247600e-03    1.230796e-02];
        iobj.measurement_covariance = diag([4.085734e-03   1.344993e-03 ...
              2.537733e-05   5.836764e-04   7.866942e-04   6.851853e-04 ...
              4.821675e-04   2.791496e-04   2.537733e-05   2.283952e-04 ...
              4.821675e-04   5.329219e-04   6.344308e-04   6.344308e-04 ...
              5.836764e-04   4.821675e-04   4.821675e-04   2.283952e-04 ...
              2.537733e-05   2.283952e-04   4.821675e-04   8.374487e-04 ...
              1.091221e-03   1.395748e-03   1.700274e-03   2.055556e-03 ...
              2.461591e-03   2.715364e-03   3.172154e-03   3.628944e-03])*100;
    else
        % Fama-Bliss data have 16 maturity dates
        iobj.lambda                      = 0.06248;
        iobj.constant_vector             = [0.0723 -0.0294 -0.012]';
        iobj.state_transition_matrix     = [ 4.987837e-01    1.165363e-01   -9.145495e-03 ; ...
                                            -1.207316e-01    6.300504e-01    8.113669e-02 ; ...
                                             3.468887e-01    3.672784e-01    5.047149e-01];
        iobj.state_transition_covariance = [ 2.456375e-03    0.000000e+00    0.000000e+00 ; ...
                                            -2.228716e-03    2.260572e-03    0.000000e+00 ; ...
                                             2.767357e-03    6.322885e-04    6.548897e-03];
        iobj.measurement_covariance = diag([1.248302e-03  -2.903607e-04 ...
             -7.174340e-04  -1.099966e-03   1.058109e-03  -5.695743e-04 ...
             -3.038703e-04   4.418025e-04   7.490196e-04   4.525999e-04 ...
              2.707139e-04   3.731745e-04   8.826005e-04   2.977528e-03 ...
             -3.550630e-03   3.738511e-03]);
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
    filename = 'DNS_cor_parameter_vector.mat';
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