classdef Time
    properties
        filename = 'Hsimulasicut.xlsx';
        sheet = 'Sheet2';
        data = readtable(filename, 'Sheet', sheet);
    end

    methods
        function obj = Time(time)
            obj.filename = time;
            obj.data = [];
            obj.readTime();
        end

        function readTime(obj)
            data = xlsread(obj.filename);
            obj.data = Time;
        end

        function displayData(obj)
            display(obj.data);
        end
    end
end

%{
classdef BasicClass
    properties
        Value {mustBeNumeric}
    end
    methods
        function obj = BasicClass(val)
            if nargin == 1
                obj.Value = val;
            end
        end
        function r = roundOff(obj)
            r = round([obj.Value],2);
        end
        function r = multiplyBy(obj,n)
            r = [obj.Value] * n;
        end
        function r = plus(o1,o2)
            r = [o1.Value] + [o2.Value];
        end
    end
end

}%
