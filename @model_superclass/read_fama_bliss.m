function read_fama_bliss(obj)
%  Purpose:
%
%    Read the Fama Bliss unsmoothed data from 1987 to 2002.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The 192x16 array of yield to maturity values, the number of issuance
%    dates (equal to 192 for the Fama-Bliss data), and the issuance dates
%    vector (saved as class properties).
%
%  Notes:
%
%    The 16 columns in the output array are yields for time to maturity in
%    months: 3,6,9,12,18,24,36,48,60,84,96,108,120,180,240, and 360 months
%    respectively.
%
%  Author : Georgios Magkotsios
%  Version: November 2011
%

    % set the time to maturity vector
    obj.maturity = ...
        [3 6 9 12 18 24 36 48 60 84 96 108 120 180 240 360]'/12;

    % read the ascii data file and store the number of rows
    dat = load('Fama_Bliss_unsmoothed_data_1987_2002.txt','-ascii');
    FB  = 0.01*dat(:,2:17);
    %FB  = dat(:,2:17); % yield values in basis points
    nrow = size(FB,1);

    % create the vector of monthly dates from 01/31/1987 to 12/31/2002 that
    % correspond to the Fama-Bliss data
    date_range(1) = datenum('01/15/1987');
    date_range(2) = datenum('12/15/2002');
    dates_vector  = linspace(date_range(1),date_range(2),size(dat,1))';

    % save the fed yields, the issuance dates, and the number of rows
    % (issuance months)  to the corresponding class properties
    obj.meas_data       = FB;
    obj.issue_dates_vec = dates_vector;
    obj.issue_dates     = length(obj.issue_dates_vec);

end