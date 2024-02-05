function driver_in_sample_analysis_serial(drv,NS)
%  Purpose:
%
%    Driver for the in-sample analysis of the interest rate term-structure.
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

% calculate the yield surface for every model
if NS.estimate_yield_to_maturity
    for model_iter=1:drv.models_number
        in_sample_yield(drv.model_cell{model_iter},true);
    end
end

% calculate and save the state vectors and their covariances
if NS.export_state_vectors
    for model_iter=1:drv.models_number
        in_sample_state(drv.model_cell{model_iter});
    end
end

% export results to binary files
for model_iter=1:drv.models_number
    in_sample_output(drv.model_cell{model_iter});
end

% stop the clock that measures the performance
tEnd = toc(tStart);
fprintf(['Elapsed time for serial in-sample analysis is ' ...
         '%i hours, %i minutes and %f seconds\n'], ...
         floor(tEnd/3600),floor(rem(tEnd/60,60)),rem(tEnd,60));

end