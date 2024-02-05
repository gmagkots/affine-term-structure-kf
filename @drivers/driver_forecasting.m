function driver_forecasting(drv,NS)
%  Purpose:
%
%    Driver for the out-of-sample forecasting of the interest rate
%    term-structure.
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
%  Version: March 2012
%

% start the clock to measure performance 
tStart = tic;

% forecast the yield and relevant variables for every model
for model_iter=1:drv.models_number
    out_of_sample_forecasting(drv.model_cell{model_iter}, ...
                              NS.forecasting_periods);
end

% perform a cross-validation of the models (not implemented yet)
%if NS.cross_validation
%    for model_iter=1:drv.models_number
%        cross_validation(drv.model_cell{model_iter}, ...
%            start_date,separation_date,end_date);
%    end
%end

% export results to binary files
for model_iter=1:drv.models_number
    out_of_sample_output(drv.model_cell{model_iter});
end

% stop the clock that measures the performance
tEnd = toc(tStart);
fprintf(['Elapsed time for serial out-of-sample forecasting is ' ...
         '%i hours, %i minutes and %f seconds\n'], ...
         floor(tEnd/3600),floor(rem(tEnd/60,60)),rem(tEnd,60));

end