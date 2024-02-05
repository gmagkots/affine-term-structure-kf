function initialize_DNSS(iobj)
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
        iobj.lambda                      = [0.066 0.9]';
        iobj.constant_vector             = [0.10 0.01 0.004 0.037]';
        iobj.state_transition_matrix     = diag([0.85 0.87 0.84 0.86]);
        iobj.state_transition_covariance = diag([0.004 0.013 0.016 0.012]);
        iobj.measurement_covariance = diag([4.314130e-04   6.344308e-04 ...
              2.791496e-04   3.806585e-04   4.821675e-04   2.283952e-04 ...
              1.776407e-04   3.299041e-04   4.821675e-04   6.344308e-04 ...
              7.359397e-04   7.359397e-04   7.866942e-04   7.359397e-04 ...
              6.344308e-04   5.329219e-04   4.821675e-04   2.283952e-04 ...
              7.613179e-05   2.283952e-04   4.821675e-04   7.866942e-04 ...
              1.040466e-03   1.395748e-03   1.700274e-03   2.055556e-03 ...
              2.410837e-03   2.715364e-03   2.715364e-03   3.476680e-03])*100;
    else
        % Fama-Bliss data have 16 maturity dates
        iobj.lambda                      = [0.8379 0.09653]';
        iobj.constant_vector             = [0.04907 -0.006021 0.003424 0.06082]';
        iobj.state_transition_matrix     = diag([0.71 0.72 0.73 0.74]);
        iobj.state_transition_covariance = diag([0.0428 0.0522 0.0894 0.0797]);
        iobj.measurement_covariance = diag([-0.0012  0.0002 -0.0007 ... 
             0.0010 -0.0007  0.0005  0.0003 -0.0005 -0.0006 -0.0004 ...
            -0.0002  0.0005  0.0012  0.0026 -0.0035 -0.0020]);
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
    filename = 'DNSS_parameter_vector.mat';
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