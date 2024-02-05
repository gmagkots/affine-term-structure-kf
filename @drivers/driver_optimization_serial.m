function driver_optimization_serial(drv,NS)
%  Purpose:
%
%    Driver for the optimization of the model parameters.
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

% optimize the models
for model_iter=1:drv.models_number
    [~] = optimize_logL(drv.model_cell{model_iter},NS.perform_optimization, ...
                        NS.estimate_OPG_QML_flag,NS.automatic_hessian, ...
                        NS.use_fed_data,NS.use_TOMLAB_package);
end

% stop the clock that measures the performance
tEnd = toc(tStart);
fprintf(['Elapsed time for serial optimization is ' ...
         '%i hours, %i minutes and %f seconds\n'], ...
         floor(tEnd/3600),floor(rem(tEnd/60,60)),rem(tEnd,60));

end