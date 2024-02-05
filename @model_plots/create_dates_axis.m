function create_dates_axis(pobj)
%  Purpose:
%
%    Create an x-axis of dates for plots that use such an axis.
%
%  Input:
%
%    None.
%
%  Output:
%
%    The axis of dates according to the user-specified range, and the
%    indices that correspond this range for associated model containers
%    (not returned, but saved as class proparties).
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%

    % read the yield data
    if pobj.use_fed_data
        read_fed_data(pobj,false);
    else
        read_fama_bliss(pobj);
    end

    % create the x-axis data (in date format) to correspond to the number
    % of months between the start and end dates in the input data file, and
    % include any forecast dates
    start_date = pobj.issue_dates_vec(1);
    if pobj.include_forecasts
        end_date = pobj.forecast_dates(end);
        Nmonths  = pobj.issue_dates + length(pobj.forecast_dates);
    else
        end_date = pobj.issue_dates_vec(end);
        Nmonths  = pobj.issue_dates;
    end
    dates_axis = linspace(start_date,end_date,Nmonths)';

    % find the dates that are the closest to the requested range
    [~,pobj.idx_lo] = min(abs(dates_axis - min(pobj.issuance_dates_range)));
    [~,pobj.idx_hi] = min(abs(dates_axis - max(pobj.issuance_dates_range)));

    % create the final axis of dates limited to the requested range, and
    % find the index corresponding to the last known issuance date (last
    % in-sample data point)
    pobj.dates_axis = dates_axis(pobj.idx_lo:pobj.idx_hi);
    [~,pobj.idx_in] = min(abs(pobj.dates_axis - pobj.issue_dates_vec(end)));

end