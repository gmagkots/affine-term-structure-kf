function [peak,trough] = get_recession_periods(pobj)
%  Purpose:
%
%    Export the recorded recession periods beyond 1985.
%
%  Input:
%
%    None.
%
%  Output:
%
%    Two vectors which contain the beginning and the end of the recession
%    period in date format.
%
%  Notes:
%
%    The business cycle data are retrieved by US NBER website at
%    http://www.nber.org/cycles.html
%
%  Author : Georgios Magkotsios
%  Version: February 2012
%
    % 3 recession periods since 1985
    peak = zeros(3,1);
    trough = peak;

    % first recession period
    peak(1)   = datenum('07/01/1990');
    trough(1) = datenum('03/31/1991');

    % first recession period
    peak(2)   = datenum('03/01/2001');
    trough(2) = datenum('11/30/2001');

    % first recession period
    peak(3)   = datenum('12/01/2007');
    trough(3) = datenum('06/30/2009');

end
