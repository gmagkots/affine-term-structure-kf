function plot_FED_vs_FB_data(pobj)
%  Purpose:
%
%    Plot the yield time series for given maturity values and range of
%    dates using both the FED and Fama-Bliss data to compare results.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The yield data time series plot.
%
%  Author : Georgios Magkotsios
%  Version: January 2012
%

    % save the predefined data source choice
    data_source_save = pobj.use_fed_data;

    % read the Fama-Bliss data and get the date limits within this data set
    read_fama_bliss(pobj);
    start_date = pobj.issue_dates_vec(1);
    end_date   = pobj.issue_dates_vec(end);

    % force the dates' range within the Fama-Bliss data set for all curves
    if (pobj.issuance_dates_range(1) > end_date || ...
        pobj.issuance_dates_range(2) < start_date)
        error(['Please provide dates within the range ' ...
               datestr(start_date) ' and ' datestr(end_date)]);
    end
    if pobj.issuance_dates_range(1) < start_date
        pobj.issuance_dates_range(1) = start_date;
    end
    if pobj.issuance_dates_range(2) > end_date
        pobj.issuance_dates_range(2) = end_date;
    end

    % plot the solid curves using the Fama-Bliss data
    pobj.use_fed_data = false;
    plot_yield_data_time_series(pobj,'solid');

    % hold the current device window open
    hold on;

    % plot the dashed curves using the FED data
    pobj.use_fed_data = true;
    plot_yield_data_time_series(pobj,'dash');

    % restore the predefined data source choice
    pobj.use_fed_data = data_source_save;
end