function Y = DifferencePostedRecorded(TLE)
url2='https://celestrak.com/NORAD/elements/active.php';
data=webread(url2);
S = TLE.data;
sz = TLE.size;      

tok = regexp(data,'Current as of ([^<]+)','tokens');
date = tok{1}{1};

tok = regexp(date,'\([a-zA-Z]+ ([^\(]+)\)','tokens');
dayhand = str2double(tok{1}{1});

tok = regexp(date,' (..):(..):(..) ','tokens');
hourhand = str2double(tok{1}{1});
minutehand = str2double(tok{1}{2}); 
secondhand = str2double(tok{1}{3});

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