function [state_vector,filter_covariance,yield] = ...
    Kalman_filter_prediction(obj,a0,P0,Nsteps)
%  Purpose:
%
%    Utilize the Kalman filter prediction formulae (involving zero
%    innovations) for out-of-sample forecasting.
%
%  Input:
%
%    The state vector and its covariance matrix to initiate the filter
%    prediction, and the number of steps that will be taken without
%    innovations.
%
%  Output:
%
%    The predicted state vector, covariance matrix, and yield.
%
%  Author : Georgios Magkotsios
%  Version: March 2012
%
    % initialize the Kalman filtering class with stability checks off, and
    % initial values for the state vactor and its filter covariance
    KFobj = Kalman_filter(obj.state_const_vec,obj.meas_const_vec, ...
      obj.state_par,obj.meas_par,obj.state_cov,obj.meas_cov,a0,P0,false);

    % utilize the Kalman prediction algorithm for the given number of steps
    for time = 1:Nsteps
        % evolve the Kalman filter forecasting algorithm
        [state_vector,filter_covariance] = evolve_filter(KFobj,0);

        % calculate the predicted yield
        yield = obj.meas_par*state_vector - obj.meas_const_vec;
    end

end