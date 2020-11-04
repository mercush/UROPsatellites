function Y = DifferencePostedRecorded(TLE)
    url2='https://celestrak.com/NORAD/elements/active.php';
    data=webread(url2);
    S = TLE.data;
    sz = TLE.size;
    date = data(1031:1064);
    if strcmpi(date(6:9),'june') || strcmpi(date(6:9),'july')
        if strcmp(date(12),' ')
            dayhand = str2double(data(1061:1063));
            hourhand = str2double(data(1043:1044));
            minutehand = str2double(data(1046:1047));
            secondhand = str2double(data(1049:1050));
        elseif ~strcmp(date(12),' ')
            dayhand = str2double(data(1062:1064));
            hourhand = str2double(data(1044:1045));
            minutehand = str2double(data(1047:1048));
            secondhand = str2double(data(1050:1051));
        end
    else 
            dayhand = str2double(data(1061:1063));
            hourhand = str2double(data(1043:1044));
            minutehand = str2double(data(1046:1047));
            secondhand = str2double(data(1049:1050));
    end

    decimalday = (hourhand*3600+minutehand*60+secondhand)/(24*3600);
    DatePublished=dayhand+decimalday;

    if mod(str2double(date(1:4)),4)==0
        epsilon=366;
    else
        epsilon=365;
    end
    for row=1:sz
        Y{row,1}=mod(DatePublished-str2double(S{2}{row}(21:32))+183,epsilon)-183;
    end
    Y(:,2)=S{1};
end