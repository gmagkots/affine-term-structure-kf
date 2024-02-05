function out_of_sample_output(obj)
%  Purpose:
%
%    Export to binary files the results of the out-of-sample analysis.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The forecasted state variables, the yield surface, and the risk-free
%    interest rate (arbitrage-free models only).
%
%  Author : Georgios Magkotsios
%  Version: March 2012
%

    % create the output directory to move the files in (if necessary)
    if obj.use_fed_data
        dirname = 'output_fed_out_of_sample';
    else
        dirname = 'output_fama_bliss_out_of_sample';
    end
    if ~exist(dirname,'dir')
        fprintf(['Creating output directory "' dirname '".\n']);
        mkdir(dirname);
    end

    % replace the blank space with underscores and remove dots from the
    % model name
    name_prefix = obj.model_name;
    blk_idx = name_prefix == ' ';
    dot_idx = name_prefix == '.';
    name_prefix(blk_idx) = '_';
    name_prefix(dot_idx) = '';

    % export the forecasted state variables and their covariances
    if isempty(obj.future_state(obj.future_state==0))
        % state variables
        state_forecast     = obj.future_state;
        state_forecast_cov = obj.future_state_cov;
        forecast_dates     = obj.forecast_dates;
        filename = [name_prefix '_state_variables.mat'];
        save(filename,'state_forecast','state_forecast_cov', ...
                      'forecast_dates','-mat');
        movefile(filename,dirname);

        % instantaneous risk-free rate (arbitrage-free models only)
        if length(obj.model_name) >= 4 && strcmpi(obj.model_name(1:4),'AFNS')
            spot_rate = obj.future_state(:,1) + obj.future_state(:,2);
            spot_rate_variance = ...
                sqrt(squeeze(sum(sum(obj.future_state_cov(1:2,1:2,:),1),2)));
            forecast_dates     = obj.forecast_dates;
            filename = [name_prefix '_spot_rate.mat'];
            save(filename,'spot_rate','spot_rate_variance', ...
                          'forecast_dates','-mat');
            movefile(filename,dirname);
        end
        if length(obj.model_name) >= 5 && strcmpi(obj.model_name(1:5),'AFGNS')
            spot_rate = obj.future_state(:,1) + obj.future_state(:,2) + ...
                        obj.future_state(:,3);
            spot_rate_variance = ...
                sqrt(squeeze(sum(sum(obj.future_state_cov(1:3,1:3,:),1),2)));
            forecast_dates     = obj.forecast_dates;
            filename = [name_prefix '_spot_rate.mat'];
            save(filename,'spot_rate','spot_rate_variance', ...
                          'forecast_dates','-mat');
            movefile(filename,dirname);
        end
    end

    % export the forecasted yield surface. For each time t, the yield curve
    % is of theform Y = Z*X + d (measurement equation). Thus, for each time
    % t the covariance matrix of Y is given by Cov(Y) = Z*Cov(X)*Z'.
    if isempty(obj.future_yield(obj.future_yield==0))
        yield_forecast   = obj.future_yield;
        yield_covariance = obj.future_yield_cov;
        forecast_dates   = obj.forecast_dates;
        filename = [name_prefix '_yield_surface.mat'];
        save(filename,'yield_forecast','yield_covariance', ...
                      'forecast_dates','-mat');
        movefile(filename,dirname);
    end
end