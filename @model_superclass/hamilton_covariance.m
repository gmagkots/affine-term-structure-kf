function [Pmat_hamilton parameter_uncertainty] = ...
    hamilton_covariance(obj,a0,P0,QML_covariance,Nsteps,in_sample_flag)
%  Purpose:
%
%    Estimate the covariance matrix for the state vector by including both
%    filter and parameter uncertainty, as defined by Hamilton.
%
%  Input:
%
%    The initial state vector and its covariance matrix for the Kalman
%    filter, the QML covariance matrix for this model, the number of steps
%    from the beginning of the filtering process (corresponding to the
%    issuance date of interest), and the logical to distinguish between
%    in-sample and out-of-sample filtering mode.
%
%  Output:
%
%    The Hamilton covariance matrix for the state vector.
%
%  References:
%
%    1) Time Series Analysis, J.D. Hamilton, 1994
%    2) A standard error for the estimated state vector of a state-space
%       model, J.D. Hamilton, Journal of Econometrics, 33, 387-397 (1986)
%
%  Notes:
%
%    The routine requires the existence of the reference state vector for
%    the optimal set of parameters. All reference state vectors are saved
%    in state_array, which is created by routine in_sample_state.
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

    % set warning verbose on to identify frequent warning handles, and turn
    % off some of these frequent warnings during the estimation process
    warning verbose on
    warning('off', 'MATLAB:nearlySingularMatrix')
    warning('off', 'MATLAB:illConditionedMatrix')
    warning('off', 'MATLAB:singularMatrix')

    % set the number of Monte Carlo samples for the parameter vector
    MC_draws = 200;

    % initialize the filter and parameter uncertainty covariance matrices
    filter_uncertainty    = zeros(length(obj.state_cov));
    parameter_uncertainty = zeros(length(obj.state_cov));

    % get the parameter vector samples (MC_draws x Z matrix, where Z is the
    % number of state variables in the parameter vector) using a
    % multivariate normal distribution centered at the optimal parameter
    % vector with the QML covariance associated with it
    parameter_vector_samples = ...
        mvnrnd(obj.parameter_vector,QML_covariance,MC_draws);

    % Monte Carlo loop
    for MC_iter=1:MC_draws
        % extract the parameter vector into the model containers
        [lambda mu state_par state_cov meas_cov] = ...
            extract_parameters(obj,parameter_vector_samples(MC_iter,:));

        % initialize a model with the sampled parameter values
        sobj = choose_model(obj,lambda,mu, ...
                            state_par,state_cov,meas_cov,obj.use_fed_data);

        % initialize the Kalman filtering class with stability criteria off
        KFsobj = Kalman_filter(sobj.state_const_vec,sobj.meas_const_vec,...
          sobj.state_par,sobj.meas_par,sobj.state_cov,sobj.meas_cov,a0,P0,false);

        % evolve the filter until the time requested and get the related
        % state vector and its filter covariance matrix samples
        for time = 1:Nsteps
            % form the measurement vector for this time step
            meas_vec = sobj.meas_data(time,:)';

            % utilize Kalman filtering and get the updated variables
            if in_sample_flag
                [MC_state_vec,MC_state_cov] = evolve_filter(KFsobj,meas_vec);
            else
                [MC_state_vec,MC_state_cov] = evolve_filter(KFsobj,0);
            end
        end

        % ensure the reference state vector is a column vector
        if in_sample_flag
            state_vec_ref = obj.state_array(Nsteps,:);
        else
            state_vec_ref = a0;
        end
        state_vec_ref = state_vec_ref(:);

        % update the filter and parameter uncertainty matrices (Hamilton
        % 1994, equations 13.7.6 and 13.7.5 respectively)
        filter_uncertainty    = filter_uncertainty + MC_state_cov;
        parameter_uncertainty = parameter_uncertainty + ...
            (MC_state_vec - state_vec_ref)*(MC_state_vec - state_vec_ref)';
    end

    % average the filter and parameter uncertainties and return the
    % Hamilton and parameter covariance matrices of the state vector
    filter_uncertainty    = 1/MC_draws*filter_uncertainty;
    parameter_uncertainty = 1/MC_draws*parameter_uncertainty;
    Pmat_hamilton = filter_uncertainty+parameter_uncertainty;

    % turn back on all warnings and shut off the verbose mode
    warning on all
    warning verbose off

end