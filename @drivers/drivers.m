classdef drivers < handle
%  Purpose:
%
%    Distribute the major tasks among specialized driver files.
%
%  Notes:
%
%    Since polymorphism is not implemented properly in MATLAB and cell
%    arrays tend to convert objects/handles during concatenation, separate
%    property objects are used to host each model handle. This makes the
%    code hardwired and inflexible in terms of adding new models.
%
%    The class matlab.mixin.Heterogeneous as an alternative to class handle
%    has different side-effects.
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

    properties (Access = 'private')
        % cell array of model objects
        model_cell

        % number of models used
        models_number
    end

    methods
        % class default constructor
        function drv = drivers(NS)
            % check if new FED data binaries are requested
            if NS.create_new_fed_data_binary
                % create an object of the model superclass
                obj = model_superclass;

                % create the FED data binaries and terminate this run
                create_fed_data_binary(obj,NS.fed_data_maturities_vector);
            end

            % get the cell array of model handles from initialization
            driver_initialization(drv,NS);

            % perform optimization
            if NS.initiate_optimization
                if NS.run_parallel
                    driver_optimization_parallel(drv,NS);
                else
                    driver_optimization_serial(drv,NS);
                end
            end

            % in-sample analysis
            if NS.perform_in_sample_analysis
                if NS.run_parallel
                    driver_in_sample_analysis_parallel(drv,NS);
                else
                    driver_in_sample_analysis_serial(drv,NS);
                end
            end

            % out-of-sample forecasting
            if NS.out_of_sample_forecasting
                driver_forecasting(drv,NS);
            end

            % plot results
            if NS.make_plots
                driver_make_plots(drv,NS);
            end
        end

        % function prototypes
        driver_forecasting(drv,NS)
        driver_in_sample_analysis_parallel(drv,NS)
        driver_in_sample_analysis_serial(drv,NS)
        driver_initialization(drv,NS)
        driver_make_plots(drv,NS)
        driver_optimization_parallel(drv,NS)
        driver_optimization_serial(drv,NS)
    end

end