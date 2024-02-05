function driver_main
%  Purpose:
%
%    Main driver for the Nelson-Siegel models. The primary controls are
%    encapsulated in the structure NS.
%
%  Input:
%
%    None.
%
%  Output:
%
%    None.
%
%  Author : Georgios Magkotsios
%  Version: May 2012
%  Initial: February 2012
%

% clear the screen, and remove all obsolete handles
    clc; clear all; close all;

%% Primary controls

% controls for model evaluation
    NS.evaluate_DNS_uncorrelated  = true;
    NS.evaluate_DNS_correlated    = true;
    NS.evaluate_DNSS              = true;
    NS.evaluate_DGNS              = true;
    NS.evaluate_AFNS_uncorrelated = true;
    NS.evaluate_AFNS_correlated   = true;
    NS.evaluate_AFGNS             = true;

% model names
    NS.DNS_uncorrelated_name  = 'DNS_unc';
    NS.DNS_correlated_name    = 'DNS_cor';
    NS.DNSS_name              = 'DNSS';
    NS.DGNS_name              = 'DGNS';
    NS.AFNS_uncorrelated_name = 'AFNS_unc';
    NS.AFNS_correlated_name   = 'AFNS_cor';
    NS.AFGNS_name             = 'AFGNS';

% controls for parallel runs. The number of requested processors should not
% exceed the number of cores on the local machine, and it is recommended to
% be a multiple of 2.
    NS.run_parallel = false;
    NS.processors   = 8;

% control for input data source (FED or Fama-Bliss)
    NS.use_fed_data = true;
    NS.create_new_fed_data_binary = true;
    NS.fed_data_maturities_vector = [1:5 6:3:30];

% control for initial parameters (user-specified or optimal values)
    NS.user_specified_parameters = true;

% controls for the optimization of model parameters (logL maximization)
    NS.initiate_optimization = true;
    NS.perform_optimization  = true;
    NS.automatic_hessian     = true;
    NS.estimate_OPG_QML_flag = false;
    NS.use_TOMLAB_package    = false;

% controls for in-sample analysis
    NS.perform_in_sample_analysis = false;
    NS.estimate_yield_to_maturity = true;
    NS.export_state_vectors       = true;

% controls for out-of-sample forecasting
    NS.out_of_sample_forecasting = false;
    NS.forecasting_periods       = 12;
    %NS.cross_validation         = false;

% controls for plotting the results
    NS.make_plots            = false;
    NS.show_plot_on_screen   = true;
    NS.export_to_eps         = false;
    NS.include_variances     = true;
    NS.include_forecasts     = true;
    NS.plot_data_time_series = false;
    NS.plot_FED_vs_FB_data   = false;
    NS.plot_model_factors    = false;
    NS.plot_risk_free_rate   = true;
    NS.plot_yield_curve      = false;
    NS.plot_yield_surface    = false;
    NS.plot_loglikelihood    = false;

% input used for plotting (where applicable)
    % legend location
    NS.legend_location = 'SouthWest';

    % range of issuance dates
    NS.issuance_dates_range = [datenum('11/15/1998') datenum('12/15/2003')];

    % vector of times to maturity (in years) for data time series
    NS.data_time_series_maturities = [10 15 20];

    % model factors to plot
    %NS.model_factors = {'level','slope','slope2','curvature','curvature2'};
    NS.model_factors = {'slope','curvature'};

    % input for log-likelihood plot
    NS.logL_model_name        = 'DNS_unc';
    NS.logL_container_names   = {'state_par' 'meas_cov'};
    NS.logL_parameter_numbers = [1 16];
    NS.logL_parameter_range   = {[0.1 0.5] [1e-5 1e-3]};
    NS.logL_axis_label        = {'level L' '\sigma_y(16)'};
    NS.logL_log_axis_scale    = [false true];

%% Main execution

% start the clock to measure performance 
    tStart = tic;

% initiate the program
    main_object = drivers(NS);

% Stop the clock that measures the performance 
    tEnd = toc(tStart);
    fprintf(['Elapsed time for main execution is %i hours, ' ...
             '%i minutes and %f seconds\n'], ...
             floor(tEnd/3600),floor(rem(tEnd/60,60)),rem(tEnd,60));

end