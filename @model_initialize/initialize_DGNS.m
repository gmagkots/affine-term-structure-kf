function initialize_DGNS(iobj)
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
        iobj.lambda                      = [0.66 0.96]';
        iobj.constant_vector             = [0.36 0.38 0.05 0.007 0.004]';
        iobj.state_transition_matrix     = diag([0.86 0.84 0.85 0.83 0.82]);
        iobj.state_transition_covariance = diag([0.005 0.008 0.008 0.01 0.008]);
        iobj.measurement_covariance = diag([8.882031e-04   5.329219e-04 ...
              1.776407e-04   2.791496e-04   4.821675e-04   2.791496e-04 ...
              4.821675e-04   4.821675e-04   5.836764e-04   6.851853e-04 ...
              7.866942e-04   7.866942e-04   7.866942e-04   7.359397e-04 ...
              6.344308e-04   5.329219e-04   4.821675e-04   2.283952e-04 ...
              2.537733e-05   2.283952e-04   4.821675e-04   7.866942e-04 ...
              1.091221e-03   1.395748e-03   1.700274e-03   2.004801e-03 ...
              2.360082e-03   2.715364e-03   3.121399e-03   3.527435e-03])*100;
    else
        % Fama-Bliss data have 16 maturity dates
        iobj.lambda                      = [1.19 0.1021]';
        iobj.constant_vector             = [0.0514 -0.007039 0.0006993 -0.0006114 0.05536]';
        iobj.state_transition_matrix     = diag([0.71 0.72 0.73 0.75 0.77]);
        iobj.state_transition_covariance = diag([0.0447 0.0656 0.0588 0.0762 0.0723]);
        iobj.measurement_covariance = diag([-0.0010  0.0002 -0.0006 ...
            -0.0007 -0.0006  0.0004  0.0003  0.0003  0.0005 -0.0004 ...
            -0.0002  0.0004  0.0010 -0.0028  0.0037 -0.0009]);
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
    filename = 'DGNS_parameter_vector.mat';
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