function driver_optimization_parallel(drv,NS)
%  Purpose:
%
%    Driver for the parallel optimization of the model parameters.
%
%  Input:
%
%    The primary controls structure.
%
%  Output:
%
%    None.
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

% start the clock to measure performance 
tStart = tic;

% initiate the parallel session using the user-specified
%matlabpool close force
matlabpool('local',NS.processors)

% save the number of open labs
Nlabs = matlabpool('size');

% run in serial mode when there is only a single lab
if Nlabs == 1
    warning_str = ['The number of cores on the local machine is 1.\n' ...
        'Closing the parallel environment and ' ...
        'returning to serial execution mode.\n'];
    warning('MATLAB:matlabpool:SystemSingleCore',warning_str);
    matlabpool close;
    driver_optimization_serial(drv,NS);
    return
end

% initiate the parallel environment
spmd (Nlabs)

    if Nlabs == 2
        % case of 2 labs
        iterator_stop = ceil(drv.models_number/2);
        switch labindex
            case 1
                for model_iter=1:iterator_stop
                    [~] = optimize_logL(drv.model_cell{model_iter}, ...
                        NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                        NS.automatic_hessian,NS.use_fed_data, ...
                        NS.use_TOMLAB_package);
                end
            case 2
                for model_iter=iterator_stop+1:drv.models_number
                    [~] = optimize_logL(drv.model_cell{model_iter}, ...
                        NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                        NS.automatic_hessian,NS.use_fed_data, ...
                        NS.use_TOMLAB_package);
                end
        end
    elseif Nlabs == 4
        % case of 4 labs
        iterator_stop = ceil(drv.models_number/4);
        switch labindex
            case 1
                for model_iter=1:iterator_stop
                    [~] = optimize_logL(drv.model_cell{model_iter}, ...
                        NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                        NS.automatic_hessian,NS.use_fed_data, ...
                        NS.use_TOMLAB_package);
                end
            case 2
                if 2*iterator_stop <= drv.models_number
                    iterator_mid = 2*iterator_stop;
                else
                    iterator_mid = drv.models_number;
                end
                for model_iter=iterator_stop+1:iterator_mid
                    [~] = optimize_logL(drv.model_cell{model_iter}, ...
                        NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                        NS.automatic_hessian,NS.use_fed_data, ...
                        NS.use_TOMLAB_package);
                end
            case 3
                if (2*iterator_stop + 1) <= drv.models_number
                    if 3*iterator_stop <= drv.models_number
                        iterator_mid = 3*iterator_stop;
                    else
                        iterator_mid = drv.models_number;
                    end
                    for model_iter=2*iterator_stop+1:iterator_mid
                        [~] = optimize_logL(drv.model_cell{model_iter}, ...
                            NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                            NS.automatic_hessian,NS.use_fed_data, ...
                            NS.use_TOMLAB_package);
                    end
                end
            case 4
                for model_iter=3*iterator_stop+1:drv.models_number
                    [~] = optimize_logL(drv.model_cell{model_iter}, ...
                        NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                        NS.automatic_hessian,NS.use_fed_data, ...
                        NS.use_TOMLAB_package);
                end
        end
    elseif Nlabs == 8
        % case of 8 labs (hardwire for the moment)
        %iterator_stop = ceil(drv.models_number/8);
        switch labindex
            case 1
                [~] = optimize_logL(drv.model_cell{labindex}, ...
                    NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                    NS.automatic_hessian,NS.use_fed_data, ...
                    NS.use_TOMLAB_package);
            case 2
                [~] = optimize_logL(drv.model_cell{labindex}, ...
                    NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                    NS.automatic_hessian,NS.use_fed_data, ...
                    NS.use_TOMLAB_package);
            case 3
                [~] = optimize_logL(drv.model_cell{labindex}, ...
                    NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                    NS.automatic_hessian,NS.use_fed_data, ...
                    NS.use_TOMLAB_package);
            case 4
                [~] = optimize_logL(drv.model_cell{labindex}, ...
                    NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                    NS.automatic_hessian,NS.use_fed_data, ...
                    NS.use_TOMLAB_package);
            case 5
                [~] = optimize_logL(drv.model_cell{labindex}, ...
                    NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                    NS.automatic_hessian,NS.use_fed_data,NS.use_TOMLAB_package);
            case 6
                [~] = optimize_logL(drv.model_cell{labindex}, ...
                    NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                    NS.automatic_hessian,NS.use_fed_data, ...
                    NS.use_TOMLAB_package);
            case 7
                [~] = optimize_logL(drv.model_cell{labindex}, ...
                    NS.perform_optimization, NS.estimate_OPG_QML_flag, ...
                    NS.automatic_hessian,NS.use_fed_data, ...
                    NS.use_TOMLAB_package);
        end
    else
        error(['The number of processors requested must be a ' ...
               'multiple of 2.\n You requested %i processors.'],Nlabs);
    end
% close the parallel environment
end

% turn off matlabpool
matlabpool close

% stop the clock that measures the performance 
tEnd = toc(tStart);
fprintf(['Elapsed time for parallel optimization is ' ...
         '%i hours, %i minutes and %f seconds\n'], ...
         floor(tEnd/3600),floor(rem(tEnd/60,60)),rem(tEnd,60));

end