X=DifferencePostedRecorded();
sz=size(X,1);
Xarr=zeros(sz,1);
for row=1:sz
   Xarr(row) = X{row,1}(1);
end
%Makes the histogram
h = histogram(Xarr);
h.BinLimits=[-3 3];
title(strcat('Ephemeris Ages for Active Satellites on ', date));
xlabel('Age in Days')
ylabel('Frequency')