classdef model_plots < model_superclass
%  Purpose:
%
%    Encapsulate the plotting routines associated with the models
%
%  Author : Georgios Magkotsios
%  Version: January 2012
%

    properties (Access = 'private')
        % models' container, number, and modified names (used as prefixes
        % to output files)
        model_cell
        models_number
        file_prefix

        % plot controls
        visible
        export_to_eps
        include_variances
        include_forecasts
        legend_location

        % range of issuance dates and maturities used
        issuance_dates_range
        selected_maturities

        % dates axis, and indices for user-specified range and last
        % issuance date (last in-sample data point)
        dates_axis
        idx_lo
        idx_hi
        idx_in

        % log-likelihood plot options
        logL_model_name
        logL_container_names
        logL_parameter_numbers
        logL_parameter_range
        logL_axis_label
        logL_log_axis_scale
    end

    methods
        % class constructor
        function pobj = model_plots(NS,model_cell,models_number)
            % model info and file name prefixes
            pobj.model_cell = model_cell;
            pobj.models_number = models_number;
            remove_dots_blanks(pobj);

            % flag to show plot on screen
            if NS.show_plot_on_screen
                pobj.visible = 'on';
            else
                pobj.visible = 'off';
            end

            % flag to export to eps file and legend location
            pobj.export_to_eps   = NS.export_to_eps;
            pobj.legend_location = NS.legend_location;

            % flag for input data source and range of dates to use
            pobj.use_fed_data = NS.use_fed_data;
            pobj.issuance_dates_range = NS.issuance_dates_range;

            % flag for maturities to plot
            pobj.selected_maturities = NS.data_time_series_maturities;

            % flag for variance and forecast curves
            pobj.include_variances = NS.include_variances;
            pobj.include_forecasts = NS.include_forecasts;

            % set the log-likelihood plot options
            pobj.logL_model_name        = NS.logL_model_name;
            pobj.logL_container_names   = NS.logL_container_names;
            pobj.logL_parameter_numbers = NS.logL_parameter_numbers;
            pobj.logL_parameter_range   = NS.logL_parameter_range;
            pobj.logL_axis_label        = NS.logL_axis_label;
            pobj.logL_log_axis_scale    = NS.logL_log_axis_scale;
        end

        % function prototypes
        plot_FED_vs_FB_data(pobj)
        plot_logL(pobj)
        plot_model_factors(pobj,model_factors)
        plot_risk_free_rate(pobj)
        plot_yield_curve(pobj)
        plot_yield_data_time_series(pobj,linemode)
        plot_yield_surface(pobj)
    end

    methods (Access = 'private')
        create_dates_axis(pobj)
        [peak,trough] = get_recession_periods(pobj)
        remove_dots_blanks(pobj)
        shade_forecasting_dates(pobj)
        shade_recession_periods(pobj)
    end

end