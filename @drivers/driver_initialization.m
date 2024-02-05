function driver_initialization(drv,NS)
%  Purpose:
%
%    Driver for the initialization of the models.
%
%  Input:
%
%    The primary controls structure.
%
%  Output:
%
%    The cell array with the model objects
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

% initialize the models and the model counter
iobj = model_initialize(NS);
model_counter = 0;

% DNS uncorrelated model
if NS.evaluate_DNS_uncorrelated
    initialize_DNS_uncorrelated(iobj);
    DNS_unc_obj = DNS_model(NS.DNS_uncorrelated_name, ...
        iobj.lambda,iobj.constant_vector,iobj.state_transition_matrix, ...
        iobj.state_transition_covariance,iobj.measurement_covariance, ...
        iobj.use_fed_data);
    model_counter = model_counter + 1;
    drv.model_cell{model_counter} = copy_superclass_object(DNS_unc_obj);
end

% DNS correlated model
if NS.evaluate_DNS_correlated
    initialize_DNS_correlated(iobj);
    DNS_cor_obj = DNS_model(NS.DNS_correlated_name, ...
        iobj.lambda,iobj.constant_vector,iobj.state_transition_matrix, ...
        iobj.state_transition_covariance,iobj.measurement_covariance, ...
        iobj.use_fed_data);
    model_counter = model_counter + 1;
    drv.model_cell{model_counter} = copy_superclass_object(DNS_cor_obj);
end

% DNSS model
if NS.evaluate_DNSS
    initialize_DNSS(iobj);
    DNSS_obj = DNSS_model(NS.DNSS_name, ...
        iobj.lambda,iobj.constant_vector,iobj.state_transition_matrix, ...
        iobj.state_transition_covariance,iobj.measurement_covariance, ...
        iobj.use_fed_data);
    model_counter = model_counter + 1;
    drv.model_cell{model_counter} = copy_superclass_object(DNSS_obj);
end

% DGNS model
if NS.evaluate_DGNS
    initialize_DGNS(iobj);
    DGNS_obj = DGNS_model(NS.DGNS_name, ...
        iobj.lambda,iobj.constant_vector,iobj.state_transition_matrix, ...
        iobj.state_transition_covariance,iobj.measurement_covariance, ...
        iobj.use_fed_data);
    model_counter = model_counter + 1;
    drv.model_cell{model_counter} = copy_superclass_object(DGNS_obj);
end

% AFNS uncorrelated model
if NS.evaluate_AFNS_uncorrelated
    initialize_AFNS_uncorrelated(iobj);
    AFNS_unc_obj = AFNS_model(NS.AFNS_uncorrelated_name, ...
        iobj.lambda,iobj.constant_vector,iobj.state_transition_matrix, ...
        iobj.state_transition_covariance,iobj.measurement_covariance, ...
        iobj.use_fed_data);
    model_counter = model_counter + 1;
    drv.model_cell{model_counter} = copy_superclass_object(AFNS_unc_obj);
end

% AFNS correlated model
if NS.evaluate_AFNS_correlated
    initialize_AFNS_correlated(iobj);
    AFNS_cor_obj = AFNS_model(NS.AFNS_correlated_name, ...
        iobj.lambda,iobj.constant_vector,iobj.state_transition_matrix, ...
        iobj.state_transition_covariance,iobj.measurement_covariance, ...
        iobj.use_fed_data);
    model_counter = model_counter + 1;
    drv.model_cell{model_counter} = copy_superclass_object(AFNS_cor_obj);
end

% AFGNS model
if NS.evaluate_AFGNS
    initialize_AFGNS(iobj);
    AFGNS_obj = AFGNS_model(NS.AFGNS_name, ...
        iobj.lambda,iobj.constant_vector,iobj.state_transition_matrix, ...
        iobj.state_transition_covariance,iobj.measurement_covariance, ...
        iobj.use_fed_data);
    model_counter = model_counter + 1;
    drv.model_cell{model_counter} = copy_superclass_object(AFGNS_obj);
end

% determine the number of models used
drv.models_number = length(drv.model_cell);

end