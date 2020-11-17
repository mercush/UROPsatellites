function EOIRData(filename)
filename = 'DetectabilityTesting/EOIR_RAW_EOIR_BAND0_029854.598.txt';
file = fopen(filename);

string = '%f';
for i=1:127
    string =append(string,' %f');
end
string = append(string);

fulltext = textscan(file,string);

end