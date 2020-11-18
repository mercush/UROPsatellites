
function r = EOIRData(filename) 
file = fopen(filename);

string = '%f';
for i=1:127
    string =append(string,' %f');
end
string = append(string);

fulltext = textscan(file,string);

fclose(file);
s1 = sum(fulltext{63}(63:65)) + sum(fulltext{64}(64:65)) + sum(fulltext{65}(63:65));
% This is using the equation identical to that in the pdf. It uses the 
v_mag = -2.5*log10(s1/763)+0.03;

r = v_mag;
end


%https://help.agi.com/stkdevkit/index.htm#../Subsystems/connectCmds/Content/cmd_EOIRDetails.htm#desc
%https://help.agi.com/stkdevkit/index.htm#stkObjects/ObjModMatlabCodeSamples.htm#131