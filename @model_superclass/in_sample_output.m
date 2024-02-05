function in_sample_output(obj)
%  Purpose:
%
%    Export to binary files the results of the in sample analysis.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The state variables, the yield surface, and the risk-free interest
%    rate (arbitrage-free models only).
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

    % create the output directory to move the files in (if necessary)
    if obj.use_fed_data
        dirname = 'output_fed_in_sample';
    else
        dirname = 'output_fama_bliss_in_sample';
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

    % export the state variables and their covariances
    if isempty(obj.state_array(obj.state_array==0))
        % state variables
        state_array   = obj.state_array;
        hamilton_cov  = obj.hamilton_cov;
        filter_cov    = obj.filter_cov;
        parameter_cov = obj.parameter_cov;
        filename = [name_prefix '_state_variables.mat'];
        save(filename,'state_array','hamilton_cov', ...
                      'filter_cov', 'parameter_cov','-mat');
        movefile(filename,dirname);

        % instantaneous risk-free rate (arbitrage-free models only)
        if length(obj.model_name) >= 4 && strcmpi(obj.model_name(1:4),'AFNS')
            spot_rate = obj.state_array(:,1) + obj.state_array(:,2);
            spot_rate_variance = ...
                sqrt(squeeze(sum(sum(obj.hamilton_cov(1:2,1:2,:),1),2)));
            filename = [name_prefix '_spot_rate.mat'];
            save(filename,'spot_rate','spot_rate_variance','-mat');
            movefile(filename,dirname);
        end
        if length(obj.model_name) >= 5 && strcmpi(obj.model_name(1:5),'AFGNS')
            spot_rate = obj.state_array(:,1) + obj.state_array(:,2) + ...
                        obj.state_array(:,3);
            spot_rate_variance = ...
                sqrt(squeeze(sum(sum(obj.hamilton_cov(1:3,1:3,:),1),2)));
            filename = [name_prefix '_spot_rate.mat'];
            save(filename,'spot_rate','spot_rate_variance','-mat');
            movefile(filename,dirname);
        end
    end

    % export the yield surface. For each time t, the yield curve is of the
    % form Y = Z*X + d (measurement equation). Thus, for each time t the
    % covariance matrix of Y is given by Cov(Y) = Z*Cov(X)*Z'.
    if isempty(obj.yield(obj.yield==0))
        yield_to_maturity = obj.yield;
        yield_covariance  = zeros(length(obj.maturity), ...
                                  length(obj.maturity),obj.issue_dates);
        for time=1:obj.issue_dates
            yield_covariance(:,:,time) = ...
                obj.meas_par*obj.hamilton_cov(:,:,time)*obj.meas_par';
        end
        filename = [name_prefix '_yield_surface.mat'];
        save(filename,'yield_to_maturity','yield_covariance','-mat');
        movefile(filename,dirname);
    end
end