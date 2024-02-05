function out_of_sample_forecasting(obj,Nmonths)
%  Purpose:
%
%    Forecast the out-of-sample state vectors and yields with their
%    covariances for a number of periods ahead of the last issuance date.
%
%  Input:
%
%    The number of months (time periods) to forecast.
%
%  Output:
%
%    The approximate dates for the forecast periods, the forecasted yields
%    and state vectors, and their associated covariances (not returned, but
%    saved as private class properties).
%
%  Author : Georgios Magkotsios
%  Version: March 2012
%

    % choose the proper directory to load the data from
    if obj.use_fed_data
        dirname1 = 'output_fed_in_sample';
        dirname2 = 'output_fed_optimization';
    else
        dirname1 = 'output_fama_bliss_in_sample';
        dirname2 = 'output_fama_bliss_optimization';
    end
    if ~exist(dirname1,'dir')
        error(['Directory "' dirname1 '" not found.\n']);
    end
    if ~exist(dirname2,'dir')
        error(['Directory "' dirname2 '" not found.\n']);
    end

    % load the last in-sample model factors for the specific model
    filename = [obj.model_name  '_state_variables.mat'];
    mat_path = [dirname1 '/' filename];
    load_struct = load(mat_path);
    last_state_vector     = load_struct.state_array(end,:);
    last_state_covariance = load_struct.filter_cov(:,:,end);

    % load the QML covariance matrix for the parameters of this model
    filename = [obj.model_name '_QML_covariance.mat'];
    mat_path = [dirname2 '/' filename];
    load_struct    = load(mat_path);
    QML_covariance = load_struct.QML_covariance;

    % allocate the class containers for the forecasted variables
    Zdim = length(last_state_vector);
    Mdim = length(obj.maturity);
    obj.forecast_dates   = zeros(Nmonths,1);
    obj.future_yield     = zeros(Nmonths,Mdim);
    obj.future_state     = zeros(Nmonths,Zdim);
    obj.future_yield_cov = zeros(Mdim,Mdim,Nmonths);
    obj.future_state_cov = zeros(Zdim,Zdim,Nmonths);

    % forecast for the given number of months beyond the last issuance date
    % and save all intermediate forecasted variables
    for time=1:Nmonths
        % add the approximate date of the forecast time period
        obj.forecast_dates(time) = ...
            addtodate(obj.issue_dates_vec(end),time,'month');

        % forecasted state vectors and yields
        [obj.future_state(time,:),obj.future_state_cov(:,:,time), ...
         obj.future_yield(time,:)] = ...
            out_of_sample_prediction(obj,last_state_vector, ...
                                         last_state_covariance,time);

        % Hamilton covariance for the forecasted state vectors
        obj.future_state_cov(:,:,time) = hamilton_covariance(obj, ...
            obj.future_state(time,:),obj.future_state_cov(:,:,time), ...
            QML_covariance,1,false);

        % covariance of the forecasted yields. For each time t, the yield
        % curve is of the form Y = Z*X + d (measurement equation). Thus,
        % for each time t the covariance matrix of Y is given by 
        % Cov(Y) = Z*Cov(X)*Z'.
        obj.future_yield_cov(:,:,time) = ...
                obj.meas_par*obj.future_state_cov(:,:,time)*obj.meas_par';
    end

end