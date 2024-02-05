classdef model_initialize < handle
%  Purpose:
%
%    Encapsulate a few properties and functions related to the models'
%    initialization. The current class inherits from handle, in order to
%    have the ability to pass by reference.
%
%  References:
%
%    1) J.H.E. Christensen, F.X. Diebold, G.D. Rudebusch,
%       Journal of Econometrics, 164, 4 (2011)
%    2) J.H.E. Christensen, F.X. Diebold, G.D. Rudebusch,
%       Econometrics Journal, 12, C33 (2009)
%
%  Notes:
%
%    For each model the logL value as published by Christensen et al (2009,
%    2011) is given as a comment next to the corresponding function
%    prototype for comparison with the maximum logL value found by this
%    code.
%
%  Author : Georgios Magkotsios
%  Updates: May 2012 (introduced the number of maturities as a property)
%  Version: February 2012
%

    properties
        % model parameter containers
        lambda
        constant_vector
        state_transition_matrix
        state_transition_covariance
        measurement_covariance

        % control variable for origin of parameters
        use_fed_data
        user_specified_parameters

        % number of maturities considered
        maturities_number
    end

    methods
        % class default constructor
        function iobj = model_initialize(NS)
            % set the control variables used in this class
            iobj.use_fed_data = NS.use_fed_data;
            iobj.user_specified_parameters = NS.user_specified_parameters;

            % specify the number of maturities considered
            if iobj.use_fed_data
                iobj.maturities_number = length(NS.fed_data_maturities_vector);
            else
                iobj.maturities_number = 16;
            end
        end

        % function prototypes
        initialize_AFGNS(iobj)                  % logL = 16982.52 (FB data)
        initialize_AFNS_correlated(iobj)        % logL = 16494.29 (FB data)
        initialize_AFNS_uncorrelated(iobj)      % logL = 16279.92 (FB data)
        initialize_DGNS(iobj)                   % logL = 16816.08 (FB data)
        initialize_DNS_correlated(iobj)         % logL = 16332.94 (FB data)
        initialize_DNS_uncorrelated(iobj)       % logL = 16415.36 (FB data)
        initialize_DNSS(iobj)                   % logL = 16658.40 (FB data)
    end
end