a = TLEData('activeabridged.txt');
results = zeros(a.size, 5);
[Y] = DifferencePostedRecorded(a);
ages = cell2mat(Y(:,1));
for n = 0:uint64(floor(a.size/20))

    [avg_pass, avg_coverage, avg_interval] = STK_access_radar(n,a);
    for i = 20*n+1:20*n+20
        results(i,:)= [i, avg_pass, avg_coverage, avg_interval, ages(i)]; 
        if i == a.size
            break;
        end
    end
    save('active_access')
    CyclesRun = n+1;
    disp(CyclesRun);
    disp(avg_pass);
    disp(avg_coverage);
    disp(avg_interval);
end