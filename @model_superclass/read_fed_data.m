function read_fed_data(obj,newfile,varargin)
%  Purpose:
%
%    Read the FED data from Nov 1985 to today.
%
%  Input:
%
%    A logical to determine whether the xls file or the filtered binary
%    file shall be read, and the vector of selected maturities to read the
%    data from (optional argument - used only when creating new binaries).
%
%  Output:
%
%    The M x N array of yield to maturity values (for N maturities), the
%    number of issuance dates M, and the issuance dates vector (saved as
%    class properties).
%
%  Notes:
%
%    The function requires the file feds200628.xls. The file is at
%    http://www.federalreserve.gov/econresdata/researchdata.htm
%    The downloaded file will be in xml format, despite its xls extension.
%    You need to open it in a spreadsheet program and save it in xls format
%    (Excel 97-03 compatible).
%
%    The data are filtered, so that only the values of the last day of each
%    full month are considered. In addition, the initially descending order
%    of dates in the xls file is reverted to ascending order for the
%    purpose of calculations in this code.
%
%    The N columns in the output array correspond to the maturities chosen 
%    in the main driver.
%
%  Author : Georgios Magkotsios
%  Updates: May 2012 (variable number of maturities considered)
%  Version: February 2012
%

    % set the time to maturity vector when included in the function call
    if nargin == 3
        obj.maturity = varargin{1}';
    end

    % read the data from the xls (if necessary) or the binary file
    if newfile
        % remove the warning for reading xls format in basic mode, read the
        % xls data file, and restore the warning afterwards
        warning off MATLAB:xlsread:Mode;
        [num,txt] = xlsread('feds200628.xls','','','basic');
        warning on MATLAB:xlsread:Mode;

        % find the first NaN in the yield column for the largest maturity
        nan_idx = find(isnan(num(:,max(obj.maturity))),1);

        % save the raw (daily) data
        fed_raw = 0.01*num(1:nan_idx-1,obj.maturity);
        %fed_raw = num(1:nan_idx-1,obj.maturity); % yields in basis points

        % valid dates vector
        date_raw = txt(11:11+nan_idx-2,1);

        % allocate the date indices and check if the most recent month is a
        % full month
        date_idx  = zeros(size(date_raw));
        date_save = date_raw(1);
        if day(date_save) >= 26
            date_idx(1) = 1;
        end

        % choose last day of every full month
        for i=2:length(date_raw)
            if (year(date_raw(i)) == year(date_save) && ...
                month(date_raw(i))==month(date_save))
                continue
            else
                date_idx(i) = 1;
                date_save   = date_raw(i);
            end
        end

        % return the filtered dates in ascending order (equivalent to
        % descending order for the row indices), the number of data rows
        % (issuance months), and the filtered yield values
        date_idx = sort(find(date_idx),'descend');
        obj.meas_data       = fed_raw(date_idx,:);
        obj.issue_dates_vec = datenum(date_raw(date_idx));
        obj.issue_dates     = length(obj.issue_dates_vec);

        % create the binary files with the yield data and dates
        fed_yields         = obj.meas_data;
        fed_maturities     = obj.maturity;
        fed_issuance_dates = obj.issue_dates_vec;
        save('fed_data.mat','fed_yields','fed_maturities', ...
             'fed_issuance_dates','-mat');
    else
        % load the FED data from the corresponding binary file
        load_struct = load('fed_data.mat');

        % save the fed yields, the selected maturities, the issuance dates,
        % and the number of rows (issuance months) to the corresponding
        % class properties
        obj.meas_data       = load_struct.fed_yields;
        obj.maturity        = load_struct.fed_maturities;
        obj.issue_dates_vec = load_struct.fed_issuance_dates;
        obj.issue_dates     = length(obj.issue_dates_vec);
    end

end