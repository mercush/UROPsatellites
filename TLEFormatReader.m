clear;

url='https://celestrak.com/NORAD/elements/active.txt';
data = webread(url);

url2='https://celestrak.com/NORAD/elements/active.php';
data2=webread(url2);

dayhand = str2double(data2(1061:1063));
hourhand = str2double(data2(1043:1044));
minutehand = str2double(data2(1046:1047));
secondhand = str2double(data2(1049:1050));

decimalday = (hourhand*3600+minutehand*60+secondhand)/(24*3600);
n=dayhand+decimalday;

fid=fopen('active.txt','w');
if fid<0
    disp('Error')
end
fprintf(fid,'%s',data);
fclose(fid);

fid=fopen('active.txt','r');
S=textscan(fid, '%s %s %s', 'Delimiter','\n');
fclose(fid);

sz=size(S{1},1);
%a and b are the starting and ending positions for our search
a=21;
b=32;
X=zeros(sz,1);
for i=1:sz
    X(i)=str2double(S{2}{i}(a:b));
end
Y=zeros(sz,1);
for i=1:sz
    Y(i)=n-X(i);
end
histogram(Y);
