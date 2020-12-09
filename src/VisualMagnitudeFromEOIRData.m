function r = VisualMagnitudeFromEOIRData(directory_name)
directory = ls(directory_name);
v_mag = zeros(size(directory,1)-2,1);
for temp = 3:size(directory,1)
    filename = strcat(directory_name,'\',directory(temp,:));
    
    string_format = '%f';
    for i=1:127
        string_format =append(string_format,' %f');
    end
    file = fopen(filename);

    fulltext = textscan(file,string_format);
    fclose(file);
    
    s1 = sum(fulltext{63}(63:65)) + sum(fulltext{64}(64:65)) + sum(fulltext{65}(63:65));
    v_mag(temp)= -2.5*log10(s1/763)+0.03;
end

r = v_mag;
end


%https://help.agi.com/stkdevkit/index.htm#../Subsystems/connectCmds/Content/cmd_EOIRDetails.htm#desc
%https://help.agi.com/stkdevkit/index.htm#stkObjects/ObjModMatlabCodeSamples.htm#131