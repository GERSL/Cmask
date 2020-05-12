classdef DefaultSetting
    %DEFAULTSETTING Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        foldername_input = 'CmaskInput'; % the stacked images for Cmask
        foldername_output = 'CmaskOutput'; % all data outputed by Cmask
            foldername_bg = 'Background'; % Coafs of Cirrus model
            foldername_pred = 'PredCirrusBand' % predicated cirrus band
            foldername_mask = 'CirrusMask'; % Cirrus mask
    end
    
    methods
        function obj = DefaultSetting()
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

