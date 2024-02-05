function in_sample_state(obj)
%  Purpose:
%
%    Perform Kalman filtering to data, and calculate the state vectors and
%    their covariances, including both filter and parameter uncertainty.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The calculated state vectors and their associated covariance matrices
%    tiled in containers state_array, hamilton_cov, filter_cov, and
%    parameter_cov respectively (not returned, but saved as private class
%    properties).
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

    % initialize the Kalman filtering class with stability criteria on
    KFobj = Kalman_filter(obj.state_const_vec,obj.meas_const_vec,...
      obj.state_par,obj.meas_par,obj.state_cov,obj.meas_cov,0,0,true);

    % load the QML covariance matrix for the parameters of this model
    filename = [obj.model_name '_QML_covariance.mat'];
    if obj.use_fed_data
        dirname = 'output_fed_optimization';
    else
        dirname = 'output_fama_bliss_optimization';
    end
    if ~exist(dirname,'dir')
        error(['Directory "' dirname '" not found.\n']);
    end
    mat_path = [dirname '/' filename];
    load_struct = load(mat_path);
    QML_covariance = load_struct.QML_covariance;

    % calculate the state vectors and their covariances
    for time = 1:obj.issue_dates
        % form the measurement vector for this time step
        obj.meas_vec = obj.meas_data(time,:)';

        % utilize Kalman filtering and get the updated state vectors and
        % filter covariance matrix
        [obj.state_vec,obj.state_cov] = evolve_filter(KFobj,obj.meas_vec);

        % save the state vector and filter covariance in their repositories
        obj.state_array(time,:)  = obj.state_vec;
        obj.filter_cov(:,:,time) = obj.state_cov;

        % calculate the state vector covariance that includes both filter
        % and parameter uncertainty, and save the Hamilton and parameter
        % covariances
       [Pmat_hamilton Pmat_parameter] = ...
            hamilton_covariance(obj,0,0,QML_covariance,time,true);
        obj.hamilton_cov(:,:,time)  = Pmat_hamilton;
        obj.parameter_cov(:,:,time) = Pmat_parameter;
    end

end