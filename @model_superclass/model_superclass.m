classdef model_superclass < handle
%  Purpose:
%
%    Encapsulate a few properties and functions of common use to the model
%    and the Kalman_filter classes. The current class inherits from handle,
%    in order to have the ability to pass by reference.
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%  Initial: November 2011
%
    properties (Access = 'protected')
        model_name       % model name
        lambda           % parameter vector used in measurement matrix
        logL             % negative log-likelihood function to be maximized

        use_fed_data     % control for input data source (FED/Fama-Bliss)
        issue_dates      % M: number of issuance dates (rows in data files)
        issue_dates_vec  % M x 1 vector that contains the M issuance dates
        maturity         % N x 1 vector of N maturities (in units of years)

        state_vec        % Z x 1 state vector (Z: # of state variables)
        state_par        % Z x Z state parameter matrix
        state_cov        % Z x Z state disturbances covariance matrix
        state_const_vec  % Z x 1 additive constant vector to state vector

        meas_vec         % N x 1 measurement vector used for filtering
        meas_par         % N x Z measurement parameter matrix
        meas_cov         % N x N measurement covariance matrix
        meas_const_vec   % N x 1 additive constant vector to measurement

        yield            % M x N yield surface data
        meas_data        % M x N data input
        state_array      % M x Z repository of state vectors
        hamilton_cov     % Z x Z x M repository of Hamilton covariances
        filter_cov       % Z x Z x M repository of "filter" covariances
        parameter_cov    % Z x Z x M repository of "parameter" covariances

        parameter_vector % repository of all model parameters
        param_vec_len    % model container separator in parameter vector
        state_par_idx    % non-zero elements in state transition matrix
        state_cov_idx    % non-zero elements in state transition covariance
        meas_cov_idx     % non-zero elements in measurement covariance

        forecast_dates   % Q x 1 vector of Q forecast dates/periods
        future_yield     % Q x N forecasted yield data
        future_state     % Q x Z repository of forecasted state vectors
        future_yield_cov % N x N x Q repository of yield covariances
        future_state_cov % Z x Z x Q repository of Hamilton covariances
    end

    methods
        % class default constructor
        function obj = model_superclass
        end

        % get function for the model name
        function value = get_model_name(obj)
            value = obj.model_name;
        end

        % get function for the number of issuance dates
        function value = get_issue_dates(obj)
            value = obj.issue_dates;
        end

        % get function for the times to maturity
        function value = get_maturity(obj)
            value = obj.maturity;
        end

        % set and get functions for the log-likelihood function
        function set_logL(obj,value)
            obj.logL = value;
        end
        function value = get_logL(obj)
            value = obj.logL;
        end

        % get function for the measurement data
        function mat = get_meas_data(obj)
            mat = obj.meas_data;
        end

        % get function for all properties as a group (since MATLAB does not
        % allow a copy constructor)
        function properties_structure = get_property_struct(obj)
            properties_structure.model_name       = obj.model_name;
            properties_structure.lambda           = obj.lambda;
            properties_structure.logL             = obj.logL;
            properties_structure.use_fed_data     = obj.use_fed_data;
            properties_structure.issue_dates      = obj.issue_dates;
            properties_structure.issue_dates_vec  = obj.issue_dates_vec;
            properties_structure.maturity         = obj.maturity;
            properties_structure.state_vec        = obj.state_vec;
            properties_structure.state_par        = obj.state_par;
            properties_structure.state_cov        = obj.state_cov;
            properties_structure.state_const_vec  = obj.state_const_vec;
            properties_structure.meas_vec         = obj.meas_vec;
            properties_structure.meas_par         = obj.meas_par;
            properties_structure.meas_cov         = obj.meas_cov;
            properties_structure.meas_const_vec   = obj.meas_const_vec;
            properties_structure.yield            = obj.yield;
            properties_structure.meas_data        = obj.meas_data;
            properties_structure.state_array      = obj.state_array;
            properties_structure.hamilton_cov     = obj.hamilton_cov;
            properties_structure.filter_cov       = obj.filter_cov;
            properties_structure.parameter_cov    = obj.parameter_cov;
            properties_structure.parameter_vector = obj.parameter_vector;
            properties_structure.param_vec_len    = obj.param_vec_len;
            properties_structure.state_par_idx    = obj.state_par_idx;
            properties_structure.state_cov_idx    = obj.state_cov_idx;
            properties_structure.meas_cov_idx     = obj.meas_cov_idx;
        end

        % get function for all properties as a group
        function set_property_struct(obj,properties_structure)
            obj.model_name       = properties_structure.model_name;
            obj.lambda           = properties_structure.lambda;
            obj.logL             = properties_structure.logL;
            obj.use_fed_data     = properties_structure.use_fed_data;
            obj.issue_dates      = properties_structure.issue_dates;
            obj.issue_dates_vec  = properties_structure.issue_dates_vec;
            obj.maturity         = properties_structure.maturity;
            obj.state_vec        = properties_structure.state_vec;
            obj.state_par        = properties_structure.state_par;
            obj.state_cov        = properties_structure.state_cov;
            obj.state_const_vec  = properties_structure.state_const_vec;
            obj.meas_vec         = properties_structure.meas_vec;
            obj.meas_par         = properties_structure.meas_par;
            obj.meas_cov         = properties_structure.meas_cov;
            obj.meas_const_vec   = properties_structure.meas_const_vec;
            obj.yield            = properties_structure.yield;
            obj.meas_data        = properties_structure.meas_data;
            obj.state_array      = properties_structure.state_array;
            obj.hamilton_cov     = properties_structure.hamilton_cov;
            obj.filter_cov       = properties_structure.filter_cov;
            obj.parameter_cov    = properties_structure.parameter_cov;
            obj.parameter_vector = properties_structure.parameter_vector;
            obj.param_vec_len    = properties_structure.param_vec_len;
            obj.state_par_idx    = properties_structure.state_par_idx;
            obj.state_cov_idx    = properties_structure.state_cov_idx;
            obj.meas_cov_idx     = properties_structure.meas_cov_idx;
        end

        % public function prototypes
        create_fed_data_binaries(obj,maturities_vector)
        in_sample_output(obj)
        in_sample_state(obj)
        in_sample_yield(obj,ibar)
        out_of_sample_forecasting(obj,Nmonths)
        out_of_sample_output(obj)
        Q = volatility_to_covariance(obj,dt,kappa_mat,sigma_mat)
    end

    methods (Access = 'protected')
        obj_out = choose_model(obj,vec1,vec2,mat1,mat2,mat3,use_fed_data)
        [lambda mu state_par state_cov meas_cov] = extract_parameters(obj,x)
        [Pmat_hamilton parameter_uncertainty] = ...
            hamilton_covariance(obj,a0,P0,QML_covariance,Nsteps,in_sample_flag)
        [state_vector,filter_covariance,yield] = ...
            out_of_sample_prediction(obj,a0,P0,Nsteps)
        read_fama_bliss(obj)
        read_fed_data(obj,newfile,varargin)
    end

end