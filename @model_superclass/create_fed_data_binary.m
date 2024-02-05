function create_fed_data_binary(obj,maturities_vector)
%  Purpose:
%
%    Create new binaries of the FED data from Nov 1985 to today.
%
%  Input:
%
%    The vector of maturities to read in the FED data.
%
%  Output:
%
%    The binary files fed_dates.mat and fed_yields.mat.
%
%  Author : Georgios Magkotsios
%  Version: May 2012
%  Initial: February 2012
%

    % write a message
    fprintf('Reading the FED data to create new binary file...\n');

    % read the FED data and create the new binaries
    read_fed_data(obj,true,maturities_vector);

    % print the latest issuance date
    fprintf('Latest issuance date recorded is: %s\n', ...
            datestr(obj.issue_dates_vec(end)));

    % terminate the run with an error
    fprintf(['Binary file fed_data.mat was created successfully.\n' ...
             'Rerun with NS.create_new_fed_data_binary false.\n' ...
             'Terminating this run...\n']);
    error('Intentional error to terminate run in create_fed_data_binary.');

end