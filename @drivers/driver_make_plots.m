function driver_make_plots(drv,NS)
%  Purpose:
%
%    Driver for creating the plots.
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

% create the plotting object
plot_obj = model_plots(NS,drv.model_cell,drv.models_number);

% yield data time series
if NS.plot_data_time_series
    plot_yield_data_time_series(plot_obj,'solid');
end
if NS.plot_FED_vs_FB_data
    plot_FED_vs_FB_data(plot_obj);
end

% model factor plots (level, slope, curvature)
if NS.plot_model_factors
    plot_model_factors(plot_obj,NS.model_factors);
end

% instantaneous (spot) risk-free interest rate
if NS.plot_risk_free_rate
    plot_risk_free_rate(plot_obj);
end

% term structure of interest rates (yield curves)
if NS.plot_yield_curve
    plot_yield_curve(plot_obj);
end

% yield surface
if NS.plot_yield_surface
    plot_yield_surface(plot_obj);
end

% log-likelihood
if NS.plot_loglikelihood
    plot_logL(plot_obj);
end

end