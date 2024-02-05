       function forecast_error_rms = resample_jackknife(obj,timestep)
       %  Purpose:
       %
       %    Perform out-of-sample forecasting to test the predictability of
       %    the models, using the method of jackknifing (data set split).
       %    The function considers all possible splits of the data set in
       %    two parts. The first part is assumed to be the only available
       %    data, and the forecasted yields within the second part are
       %    compared with the pre-existent calculated yields from the
       %    in-sample analysis.
       %
       %  Input:
       %
       %    Current object and the time step in months used for forecasting
       %
       %  Output:
       %
       %    The root mean squared forecast errors for the 16 maturities
       %
       %  Notes:
       %
       %    Each iteration in the main loop assumes that all previous 
       %    iterations were filtered by using the measured data. Thus, the 
       %    current iteration in the loop is the splitting point between 
       %    the two data sets.
       %
       %    The first year of data (12 data points) is not considered in
       %    the estimation of forecasting errors, because the covariance
       %    matrix of the calculated state vectors may have not converged.
       %    Excluding 12 points should suffice, since the convergence tends
       %    to be exponential in most cases (line 49).
       %
           % initialize the Kalman filtering class with stability checks on
           KFobj = Kalman_filter(obj.state_const_vec,obj.meas_const_vec,...
              obj.state_par,obj.meas_par,obj.state_cov,obj.meas_cov,0,0,1);

           % allocate the root mean squared forecast errors and the 
           % forecasted yield vectors for each of the 16 maturities
           yield_forecast     = zeros(16,1);
           forecast_error_rms = zeros(16,1);

           % utilize the Kalman prediction algorithm. The attempted time 
           % step should not exceed the last issue date.
           for time = 13:(obj.iter - timestep)
               % update the initial state vector for the Kalman filter
               set_state_vec(KFobj,obj.state_array(time,:))

               % evolve the Kalman filter forecasting algorithm
               [obj.state_vec,obj.state_cov] = evolve_filter(KFobj,0);

               % calculate the forecasted yield and its squared error
               % compared to the corresponding data value
               yield_forecast     = obj.meas_par*obj.state_vec - ...
                                    obj.meas_const_vec;
               forecast_error_rms = forecast_error_rms + (yield_forecast - ...
                                    obj.yield(time+timestep,:)').^2;
           end

           % calculate the rms errors for each maturity
           forecast_error_rms = sqrt( forecast_error_rms./ ...
                                     (obj.iter - timestep - 12) );
       end