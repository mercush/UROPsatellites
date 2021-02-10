function r = rcs_calculation(satellite_name)
satellite_name = string(satellite_name);
if ~endsWith(satellite_name,".STL")
    satellite_name = satellite_name + ".STL";
end

satdir = dir("Satellites");
p = platform;

% if ispc
%     p.FileName = myFiles(3).folder + "\" + myFiles(3).name;
% else
%     p.FileName = myFiles(3).folder + "/" + myFiles(3).name;
% end
for i = 1:length(satdir)
    if satdir(i).name == satellite_name
        p.FileName = "Satellites\"+satellite_name;
        break
    elseif i == length(satdir)
        error("satellite was not found")
    end
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