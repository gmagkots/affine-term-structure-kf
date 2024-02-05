function [peak,trough] = get_recession_periods(pobj)
%  Purpose:
%
%    Export the recorded recession periods beyond 1857.
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
%    Quarterly dates are in parentheses.
%
%  Author : Georgios Magkotsios
%  Version: October 2012
%
    % 33 recession periods since 1985
    peak = zeros(33,1);
    trough = peak;

    % recession period June 1857(II) - December 1858(IV)
    peak(1)   = datenum('06/01/1857');
    trough(1) = datenum('12/31/1858');

    % recession period October 1860(III) - June 1861(III)
    peak(2)   = datenum('10/01/1860');
    trough(2) = datenum('06/30/1861');

    % recession period April 1865(I) - December 1867(I)
    peak(3)   = datenum('04/01/1865');
    trough(3) = datenum('12/31/1867');

    % recession period June 1869(II) - December 1870(IV)
    peak(4)   = datenum('06/01/1869');
    trough(4) = datenum('12/31/1870');

    % recession period October 1873(III) - March 1879(I)
    peak(5)   = datenum('10/01/1873');
    trough(5) = datenum('03/31/1879');

    % recession period March 1882(I) - May 1885(II)
    peak(6)   = datenum('03/01/1882');
    trough(6) = datenum('05/31/1885');

    % recession period March 1887(II) - April 1888(I)
    peak(7)   = datenum('03/01/1887');
    trough(7) = datenum('04/30/1888');

    % recession period July 1890(III) - May 1891(II)
    peak(8)   = datenum('07/01/1890');
    trough(8) = datenum('05/31/1891');

    % recession period January 1893(I) - June 1894(II)
    peak(9)   = datenum('01/01/1893');
    trough(9) = datenum('06/30/1894');

    % recession period December 1895(IV) - June 1897(II)
    peak(10)   = datenum('12/01/1895');
    trough(10) = datenum('06/30/1897');

    % recession period June 1899(III) - December 1900(IV)
    peak(11)   = datenum('06/01/1899');
    trough(11) = datenum('12/31/1900');

    % recession period September 1902(IV) - August 1904(III)
    peak(12)   = datenum('09/01/1902');
    trough(12) = datenum('08/31/1904');

    % recession period May 1907(II) - June 1908(II)
    peak(13)   = datenum('05/01/1907');
    trough(13) = datenum('06/30/1908');

    % recession period January 1910(I) - January 1912(IV)
    peak(14)   = datenum('01/01/1910');
    trough(14) = datenum('01/31/1912');

    % recession period January 1913(I) - December 1914(IV)
    peak(15)   = datenum('01/01/1913');
    trough(15) = datenum('12/31/1914');

    % recession period August 1918(III) - March 1919(I)
    peak(16)   = datenum('08/01/1918');
    trough(16) = datenum('03/31/1919');

    % recession period January 1920(I) - July 1921 (III)
    peak(17)   = datenum('01/01/1920');
    trough(17) = datenum('07/31/1921');

    % recession period May 1923(II) - July 1924 (III)
    peak(18)   = datenum('05/01/1923');
    trough(18) = datenum('07/31/1924');

    % recession period October 1926(III) - November 1927(IV)
    peak(19)   = datenum('10/01/1926');
    trough(19) = datenum('11/30/1927');

    % recession period August 1929(III) - March 1933(I)
    peak(20)   = datenum('08/01/1929');
    trough(20) = datenum('03/31/1933');

    % recession period May 1937(II) - June 1938(II)
    peak(21)   = datenum('05/01/1937');
    trough(21) = datenum('06/30/1938');

    % recession period February 1945(I) - October 1945(IV)
    peak(22)   = datenum('02/01/1945');
    trough(22) = datenum('10/31/1945');

    % recession period November 1948(IV) - October 1949(IV)
    peak(23)   = datenum('11/01/1948');
    trough(23) = datenum('10/31/1949');

    % recession period July 1953(II) - May 1954(II)
    peak(24)   = datenum('07/01/1953');
    trough(24) = datenum('05/31/1954');

    % recession period August 1957(III) - April 1958(II)
    peak(25)   = datenum('08/01/1957');
    trough(25) = datenum('04/30/1958');

    % recession period April 1960(II) - February 1961(I)
    peak(26)   = datenum('04/01/1960');
    trough(26) = datenum('02/28/1961');

    % recession period December 1969(IV) - November 1970(IV)
    peak(27)   = datenum('12/01/1969');
    trough(27) = datenum('11/30/1970');

    % recession period November 1973(IV) - March 1975(I)
    peak(28)   = datenum('11/01/1973');
    trough(28) = datenum('03/31/1975');

    % recession period January 1980(I) - July 1980(III)
    peak(29)   = datenum('01/01/1980');
    trough(29) = datenum('07/31/1980');

    % recession period July 1981(III) - November 1982(IV)
    peak(30)   = datenum('07/01/1981');
    trough(30) = datenum('11/30/1982');

    % recession period July 1990(III) - March 1991(I)
    peak(31)   = datenum('07/01/1990');
    trough(31) = datenum('03/31/1991');

    % recession period March 2001(I) - November 2001(IV)
    peak(32)   = datenum('03/01/2001');
    trough(32) = datenum('11/30/2001');

    % recession period December 2007(IV) - June 2009(II)
    peak(33)   = datenum('12/01/2007');
    trough(33) = datenum('06/30/2009');

end
