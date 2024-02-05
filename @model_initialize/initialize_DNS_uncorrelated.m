function initialize_DNS_uncorrelated(iobj)
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
        iobj.lambda                      = 0.98;
        iobj.constant_vector             = [0.33 0.04 0.004]';
        iobj.state_transition_matrix     = diag([0.85 0.86 0.83]);
        iobj.state_transition_covariance = diag([0.012 0.012 0.016]);
        iobj.measurement_covariance = diag([3.679698e-03   3.933471e-03 ...
              2.715364e-03   2.512346e-03   1.598766e-03   1.395748e-03 ...
              1.446502e-03   9.389576e-04   1.395748e-03   7.866942e-04 ...
              6.851853e-04   6.851853e-04   6.851853e-04   6.851853e-04 ...
              6.344308e-04   5.329219e-04   5.329219e-04   4.821675e-04 ...
              2.283952e-04   1.776407e-04   3.299041e-04   5.329219e-04 ...
              7.866942e-04   1.040466e-03   1.395748e-03   1.649520e-03 ...
              2.004801e-03   2.258573e-03   2.715364e-03   3.070645e-03])*100;
    else
        % Fama-Bliss data have 16 maturity dates
        iobj.lambda                      = 0.0604;
        iobj.constant_vector             = [0.0696 -0.0249 -0.0108]';
        iobj.state_transition_matrix     = diag([0.7 0.7 0.7]);
        iobj.state_transition_covariance = diag([0.05 0.0575 0.009]);
        iobj.measurement_covariance = diag([1.271179e-03   2.666268e-04 ...
             -7.341905e-04   1.129197e-03   1.087789e-03  -6.107533e-04 ...
              2.497556e-04   4.270393e-04   7.294088e-04   4.537740e-04 ...
             -2.756063e-04  -3.592061e-04  -8.816727e-04  -2.955302e-03 ...
             -3.514364e-03  -3.779460e-03]);
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
    filename = 'DNS_unc_parameter_vector.mat';
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