function r = rcs_calculation
satellites_directory = pwd;
myFiles = dir(satellites_directory + "/Satellites");
p = platform;
if ispc
    p.FileName = myFiles(3).folder + "\" + myFiles(3).name;
else
    p.FileName = myFiles(3).folder + "/" + myFiles(3).name;
end

p.Units = 'm';
freq = 450e6;
mesh(p,'MaxEdgeLength',0.5)
az = 0:1:360;
el = 0;
rcs(p, freq, az, el)
[rcsval, az, el] = rcs(p, freq, az, el);
RCSavg = mean(rcsval);
r = RCSavg;