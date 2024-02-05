function driver_in_sample_analysis_parallel(drv,NS)
%  Purpose:
%
%    Driver for the in-sample analysis of the interest rate term-structure,
%    with the state vector calculation done in parallel.
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

% initiate the parallel session using the requested number of labs
% matlabpool close force
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
    driver_in_sample_analysis_serial(drv,NS);
    return
end

% initiate the parallel environment
spmd (Nlabs)
    if Nlabs == 2
        % case of 2 labs
        iterator_stop = ceil(drv.models_number/2);
        switch labindex
            case 1
                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    for model_iter=1:iterator_stop
                        in_sample_yield(drv.model_cell{model_iter},true);
                    end
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    for model_iter=1:iterator_stop
                        in_sample_state(drv.model_cell{model_iter});
                    end
                end

                % export results to binary files
                for model_iter=1:iterator_stop
                    in_sample_output(drv.model_cell{model_iter});
                end

            case 2
                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    for model_iter=iterator_stop+1:drv.models_number
                        in_sample_yield(drv.model_cell{model_iter},true);
                    end
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    for model_iter=iterator_stop+1:drv.models_number
                        in_sample_state(drv.model_cell{model_iter});
                    end
                end

                % export results to binary files
                for model_iter=iterator_stop+1:drv.models_number
                    in_sample_output(drv.model_cell{model_iter});
                end
        end
    elseif Nlabs == 4
        % case of 4 labs
        iterator_stop = ceil(drv.models_number/4);
        switch labindex
            case 1
                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    for model_iter=1:iterator_stop
                        in_sample_yield(drv.model_cell{model_iter},true);
                    end
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    for model_iter=1:iterator_stop
                        in_sample_state(drv.model_cell{model_iter});
                    end
                end

                % export results to binary files
                for model_iter=1:iterator_stop
                    in_sample_output(drv.model_cell{model_iter});
                end

            case 2
                if 2*iterator_stop <= drv.models_number
                    iterator_mid = 2*iterator_stop;
                else
                    iterator_mid = drv.models_number;
                end

                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    for model_iter=iterator_stop+1:iterator_mid
                        in_sample_yield(drv.model_cell{model_iter},true);
                    end
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    for model_iter=iterator_stop+1:iterator_mid
                        in_sample_state(drv.model_cell{model_iter});
                    end
                end

                % export results to binary files
                for model_iter=iterator_stop+1:iterator_mid
                    in_sample_output(drv.model_cell{model_iter});
                end

            case 3
                if (2*iterator_stop + 1) <= drv.models_number
                    if 3*iterator_stop <= drv.models_number
                        iterator_mid = 3*iterator_stop;
                    else
                        iterator_mid = drv.models_number;
                    end

                    % calculate the yield surface for every model
                    if NS.estimate_yield_to_maturity
                        for model_iter=2*iterator_stop+1:iterator_mid
                            in_sample_yield(drv.model_cell{model_iter},true);
                        end
                    end

                    % save the state vectors for every model
                    if NS.export_state_vectors
                        for model_iter=2*iterator_stop+1:iterator_mid
                            in_sample_state(drv.model_cell{model_iter});
                        end
                    end

                    % export results to binary files
                    for model_iter=2*iterator_stop+1:iterator_mid
                        in_sample_output(drv.model_cell{model_iter});
                    end

                end
            case 4
                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    for model_iter=3*iterator_stop+1:drv.models_number
                        in_sample_yield(drv.model_cell{model_iter},true);
                    end
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    for model_iter=3*iterator_stop+1:drv.models_number
                        in_sample_state(drv.model_cell{model_iter});
                    end
                end

                % export results to binary files
                for model_iter=3*iterator_stop+1:drv.models_number
                    in_sample_output(drv.model_cell{model_iter});
                end
        end
    elseif Nlabs == 8
        % case of 8 labs (hardwire for the moment)
        switch labindex
            case 1
                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    in_sample_yield(drv.model_cell{labindex},true);
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    in_sample_state(drv.model_cell{labindex});
                end

                % export results to binary files
                in_sample_output(drv.model_cell{labindex});

            case 2
                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    in_sample_yield(drv.model_cell{labindex},true);
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    in_sample_state(drv.model_cell{labindex});
                end

                % export results to binary files
                in_sample_output(drv.model_cell{labindex});

            case 3
                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    in_sample_yield(drv.model_cell{labindex},true);
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    in_sample_state(drv.model_cell{labindex});
                end

                % export results to binary files
                in_sample_output(drv.model_cell{labindex});

            case 4
                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    in_sample_yield(drv.model_cell{labindex},true);
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    in_sample_state(drv.model_cell{labindex});
                end

                % export results to binary files
                in_sample_output(drv.model_cell{labindex});

            case 5
                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    in_sample_yield(drv.model_cell{labindex},true);
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    in_sample_state(drv.model_cell{labindex});
                end

                % export results to binary files
                in_sample_output(drv.model_cell{labindex});

            case 6
                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    in_sample_yield(drv.model_cell{labindex},true);
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    in_sample_state(drv.model_cell{labindex});
                end

                % export results to binary files
                in_sample_output(drv.model_cell{labindex});

            case 7
                % calculate the yield surface for every model
                if NS.estimate_yield_to_maturity
                    in_sample_yield(drv.model_cell{labindex},true);
                end

                % save the state vectors for every model
                if NS.export_state_vectors
                    in_sample_state(drv.model_cell{labindex});
                end

                % export results to binary files
                in_sample_output(drv.model_cell{labindex});
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
fprintf(['Elapsed time for parallel in-sample analysis is ' ...
         '%i hours, %i minutes and %f seconds\n'], ...
         floor(tEnd/3600),floor(rem(tEnd/60,60)),rem(tEnd,60));

end