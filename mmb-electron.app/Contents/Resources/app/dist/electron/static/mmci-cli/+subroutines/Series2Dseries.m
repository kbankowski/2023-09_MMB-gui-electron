function TS = Series2Dseries(ts)
    dates_ = databank.range(ts);%, "Frequency=", frequency);
    names =  databank.filter(ts, "Filter", @(x) isa(x, "Series"));
    data =   databank.toDoubleArray(ts, names, dates_);
    
    TS = dseries(data, dates(replace(dat2char(dates_(1)),'M0','M')), names);
end