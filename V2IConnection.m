classdef V2IConnection
    properties
        Data
        RSUs
    end
    
    methods
        % Constructor
        function obj = V2IConnection(data)
            obj.Data = data;
            obj.RSUs = data(strcmp(data.type, 'RSU'), :);
        end
    end
end
