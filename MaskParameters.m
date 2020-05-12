classdef MaskParameters
    %MASKPARAMETERS to save all parameters using in this method
    %Author: Shi Qiu
    %Created Date: Jun 3, 2018
    
    properties
        % save directory saving L8 Biome dataset.
%         directory_L8_Biome = 'E:\New validation dataset\L8_Biome';
%         directory_L8_Biome = '/lustre/work/qiu25856/L8_Biome';
%         directory_L8_Biome = '/Volumes/MFmask/New validation dataset/L8_Biome';
        directory_L8_Biome = '/lustre/work/qiu25856/L8_Biome';
        directory_L8_Biome_HPCC_work = '/lustre/work/qiu25856/L8_Biome';
        
        % save directory saving Landsat 8 images, such as surface
        % reflectances and Fmask results.
%         directory_L8_images = 'D:\TCmask\L8_images';
%         directory_L8_images = '/Volumes/Fusion/TCmask/L8_images';
        directory_L8_images = '/lustre/scratch/qiu25856/Clouds/Landsat/TCmask_Data/L8Biome_Pairs';
%         directory_L8_images = '/lustre/work/qiu25856/TCmask_Data';
        directory_L8_images_HPCC_scratch = '/lustre/scratch/qiu25856/Clouds/Landsat/TCmask_Data/L8Biome_Pairs';
%         directory_L8_images_HPCC_work = '/lustre/work/qiu25856/TCmask_Data';
        directory_L8_images_HPCC_work = '/lustre/scratch/qiu25856/Clouds/Landsat/TCmask_Data/L8Biome_Pairs';
        
% %         directory_L8_Biome = '/Volumes/MFmask/New validation dataset/L8_Biome';
% %         directory_L8_images = '/Volumes/MFmask/TCmaskData';
    end
    
    methods
%         function obj = MaskParameters()
%             %MASKPARAMETERS Construct an instance of this class
%             %   Detailed explanation goes here
%         end
% %         
% %         function outputArg = method1(obj,inputArg)
% %             %METHOD1 Summary of this method goes here
% %             %   Detailed explanation goes here
% %             outputArg = obj.Property1 + inputArg;
% %         end
    end
end

