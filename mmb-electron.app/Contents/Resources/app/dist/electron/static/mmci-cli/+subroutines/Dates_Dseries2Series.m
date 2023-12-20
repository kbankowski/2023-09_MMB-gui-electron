function DateSeries = Dates_Dseries2Series(DateDseries)
    year = DateDseries.year;
    period = DateDseries.subperiod;
    freq = DateDseries.freq;

    switch freq
        case 1
            DateSeries = reshape(yy(year, period), 1, []);

        case 2
            DateSeries = reshape(hh(year, period), 1, []);

        case 4
            DateSeries = reshape(qq(year, period), 1, []);

        case 12
            DateSeries = reshape(mm(year, period), 1, []);
    end

end