classdef TLEData
    properties
       data
       size
    end
    methods(Static)
        function r = StaticGetData()
            url='https://celestrak.com/NORAD/elements/active.txt';
            data = webread(url);
            fid=fopen('active.txt','w');
            fprintf(fid,'%s',data);
            fclose(fid);

            fid=fopen('active.txt','rt');
            r=textscan(fid, '%s %s %s', 'Delimiter','\n');
            fclose(fid);
        end
    end
    methods
        function obj = TLEData(filename)
            if nargin==0
                obj.data = TLEData.StaticGetData();
            else
                fid=fopen(filename,'rt');
                AltTLE=textscan(fid, '%s %s %s', 'Delimiter','\n');
                fclose(fid);
                obj.data = AltTLE;
            end
            obj.size = size(obj.data{1},1);
        end
        function r = GetInclination(self,n)
            r = str2double(self.data{3}{n}(9:16));
        end
        
        function r = GetRAAN(self,n)
            r = str2double(self.data{3}{n}(18:25));
        end
        
        function r = GetEccentricity(self,n)
            r = str2double(self.data{3}{n}(27:33))/10000000;
        end
        
        function r = GetArgPerigee(self,n)
            r = str2double(self.data{3}{n}(35:42));
        end
        
        function r = GetMeanAnomaly(self,n)
            r = str2double(self.data{3}{n}(44:51));
        end
        
        function r = GetMeanMotion(self,n)
            r = str2double(self.data{3}{n}(53:63))*(360/86400);
        end
        
        function r = GetSatName(self,n)
            r = self.data{1}{n};
        end
        
        
    end
end
