function DateSeries = Dates_Dseries2Series(dseriesDates)

    % a solution with creating a temporary Dseries object
    ts = dseries(NaN, dseriesDates);
    Year = ts.firstdate.year;
    Month = int8(positiveMod(ts.firstdate.double,ts.firstdate.year) * 12 +1);
    StartDate = DateWrapper.fromDatetime(frequency(ts), datetime(Year, Month, 1));

    DateSeries = StartDate: StartDate+length(dseriesDates)-1;
end

function positiveRemainder = positiveMod(dividend, divisor)
    remainder = rem(dividend, divisor);
    if remainder < 0
        positiveRemainder = remainder + abs(divisor);
    else
        positiveRemainder = remainder;
    end
end