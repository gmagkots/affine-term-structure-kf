function estimate_OPG_QML_matrices(QML)
%  Purpose:
%
%    Estimate the "outer product of gradients" (OPG) and the QML covariance
%    matrices associated with the optimal model parameters.
%
%  Input:
%
%    None
%
%  Output:
%
%    The OPG and QML covariance matrices (not returned, but saved in class
%    property).
%
%  References:
%
%    1) Time Series Analysis, J.D. Hamilton, 1994
%    2) Maximum Likelihood Estimation of Misspecified Models
%       H. White, Econometrica, 50(1), 1–25 (1982)
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

    % redefine model containers using the optimal values to calculate the
    % outer product of gradients (OPG) matrix
    [lambda_opt mu_opt state_par_opt state_cov_opt meas_cov_opt] = ...
        extract_parameters(QML,QML.parameter_vector);

    % create a new model using the optimal parameter values
    model_opt = choose_model(QML,lambda_opt,mu_opt,state_par_opt, ...
                             state_cov_opt,meas_cov_opt,QML.use_fed_data);

    % get the measurement data
    meas_data = get_meas_data(model_opt);
    
    % initialize the numerical differentiation class and the OPG estimator
    dobj  = numerical_differentiation;
    opg_matrix = 0;

    for time = 1:get_issue_dates(model_opt)
        % get the derivatives of the conditional log-density until this 
        % time, and check the accuracy of the numerical differentiation
        [dlogLt,err] = gradest(dobj,@logLt_fun,QML.parameter_vector);
        if (max(abs(err)) > 1)
            fprintf('Maximum error in numerical differentiation is %e\n',max(err));
        end

        % check for NaNs in the conditional log-density gradients output
        nan_idx = find(isnan(dlogLt),1);
        if ~isempty(nan_idx)
            error(['Output gradient of conditional log-density ' ...
                   'contains at least one NaN.']);
        end

        % turn the derivatives container to a column vector
        dlogLt = dlogLt(:);

        % update the OPG estimator (Hamilton, equation 5.8.4)
        opg_matrix = opg_matrix + dlogLt*dlogLt';
    end

    % save the OPG matrix (include the maximum logL to rescale values)
    QML.OPG_mat = opg_matrix;

    % QML covariance (Hamilton, equation 5.8.7). The Fisher matrix
    % (negative Hessian) is symmetric, so there is no need to transpose it.
    %QML.QML_covariance = inv(QML.Fisher_mat*inv(QML.OPG_mat)*QML.Fisher_mat);
    QML.QML_covariance = inv(QML.Fisher_mat/QML.OPG_mat*QML.Fisher_mat);

    % enforce symmetry in the QML covariance calculatied above by
    % eliminating any possible rounding errors
    QML.QML_covariance = (QML.QML_covariance + QML.QML_covariance')./2;

%% utility function

    function logLt = logLt_fun(x)
    %  Purpose:
    %
    %    Utility function that returns the conditional log-density for a
    %    time step, i.e. the contribution to the log-likelihood function
    %    due to the observation (innovation) at that time step.
    %
    %  Input:
    %
    %    Vector of model parameters as variables of the objective
    %    function.
    %
    %  Output:
    %
    %    Log-likelihood function
    %
    %  Author : Georgios Magkotsios
    %  Version: February 2012
    %
        % redefine paramater containers
        [lambda mu state_par state_cov meas_cov] = extract_parameters(QML,x);

        % create temporary model and filter objects with stability checks
        % off. Since these objects have function scope, they should be
        % automatically destroyed on function exit.
        mobj = choose_model(QML,lambda,mu, ...
                            state_par,state_cov,meas_cov,QML.use_fed_data);

        % get the property structure and use as input to the filter
        mobj_struct = get_property_struct(mobj);

        KFobj = Kalman_filter(mobj_struct.state_const_vec, ...
            mobj_struct.meas_const_vec,mobj_struct.state_par, ...
            mobj_struct.meas_par,mobj_struct.state_cov, ...
            mobj_struct.meas_cov,0,0,false);

        % reset logL to zero (in case obsolete objects exist)
        set_logL(KFobj,0);

        % evolve the filter from the first measurement until one
        % measurement prior to the current time, i.e. do not include yet
        % the current measurement
        for time2 = 1:(time - 1)
            [~,~] = evolve_filter(KFobj,meas_data(time2,:)');
        end

        % save the logL until this time instant (one prior to current)
        logL_residual = get_logL(KFobj);

        % evolve the filter only once to include the current measurement
        [~,~] = evolve_filter(KFobj,meas_data(time,:)');

        % get the observation-specific log-likelihood function logLt
        % (conditional log-density) by removing the residual logL (logL
        % until time t-1) from the total logL (logL until time t)
        logLt = get_logL(KFobj) - logL_residual;

    end

end