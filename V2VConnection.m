classdef V2VConnection
    properties
        Data
        Vehicles
    end
    
    methods
        % Constructor
        function obj = V2VConnection(data)
            obj.Data = data;
            obj.Vehicles = data(~strcmp(data.type, 'RSU'), :);
        end
    end
end
