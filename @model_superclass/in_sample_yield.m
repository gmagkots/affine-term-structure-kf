function in_sample_yield(obj,ibar)
%  Purpose:
%
%    Perform Kalman filtering to data, and calculate the yields based on
%    the state variables estimated by the filter.
%
%  Input:
%
%    The flag for checking the Kalman filter stability criteria and
%    calculating the yield to maturity in parallel.
%
%  Output:
%
%    The yield surface data (array yield), and/or the model log-likelihood
%    function (not returned, but saved as private class properties).
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%  Initial: November 2011
%

    % initialize the Kalman filtering class and logL function
    KFobj = Kalman_filter(obj.state_const_vec,obj.meas_const_vec,...
      obj.state_par,obj.meas_par,obj.state_cov,obj.meas_cov,0,0,ibar);

    set_logL(KFobj,0);

    % calculate the yield if necessary
    if ibar
        for time = 1:obj.issue_dates
            % form the measurement vector for this time step
            obj.meas_vec = obj.meas_data(time,:)';

            % utilize Kalman filtering and get the updated variables
            obj.state_vec = evolve_filter(KFobj,obj.meas_vec);

            % calculate the yield
            obj.yield(time,:) = (obj.meas_par*obj.state_vec -  ...
                                 obj.meas_const_vec)';
        end
    else
        for time = 1:obj.issue_dates
            % form the measurement vector for this time step
            obj.meas_vec = obj.meas_data(time,:)';

            % utilize Kalman filtering and get the updated variables
            [~] = evolve_filter(KFobj,obj.meas_vec);
        end
    end

    % copy logL from the Kalman filter to the model object
    obj.logL = get_logL(KFobj);

end