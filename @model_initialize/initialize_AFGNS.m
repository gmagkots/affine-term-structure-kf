function initialize_AFGNS(iobj)
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
        iobj.lambda = [0.77 0.21]';
        iobj.constant_vector = [0.065 0.5 0.062 0.72 0.55]';
        iobj.state_transition_matrix = diag([0.95 0.95 0.95 0.95 0.95]);
        iobj.state_transition_covariance = diag([0.01 0.04 0.04 0.1 0.07]);
        iobj.measurement_covariance = diag([4.314130e-04   1.040466e-03 ...
              6.851853e-04   2.791496e-04   1.776407e-04   2.283952e-04 ...
              1.776407e-04   1.776407e-04   1.776407e-04   1.776407e-04 ...
              1.268862e-04   1.268862e-04   7.613179e-05   2.537733e-05 ...
              7.613179e-05   1.776407e-04   1.776407e-04   1.776407e-04 ...
              1.776407e-04   1.776407e-04   7.613179e-05   2.537733e-05 ...
              1.268862e-04   2.791496e-04   3.806585e-04   5.836764e-04 ...
              7.359397e-04   8.374487e-04   1.192730e-03   1.344993e-03])*100;
    else
        % Fama-Bliss data have 16 maturity dates
        iobj.lambda = [1.005 0.2343]';
        iobj.constant_vector = [0.1165 -0.04551 -0.02912 -0.02398 -0.09662]';
        iobj.state_transition_matrix = diag([8.012 9.2685 9.3812 8.409 8.894]);
        iobj.state_transition_covariance = ...
            diag([0.01057 0.01975 0.01773 0.05049 0.04304109]);
        iobj.measurement_covariance = diag([-0.0013 -0.0003  0.0007 ...
            -0.0011 -0.0011 -0.0006  0.0002 -0.0004 -0.0007  0.0005 ...
             0.0003  0.0004  0.0009  0.0030 -0.0035  0.0038]);
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
    filename = 'AFGNS_parameter_vector.mat';
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