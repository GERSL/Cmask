function autoParallel2EachImage()
%AUTOPARALLEL2EACHIMAGE  reach each image.
    dir_hpcc = '/gpfs/scratchfs1/shq19004_CmaskData/L8Biome_500_500';

    img_folders = dir(dir_hpcc);
% %     delete(gcp('nocreate'));
    parpool(24);

% % %     MdEA_all = [];
    parfor i = 1: length(img_folders)
        img_folder = img_folders(i).name;
        if strcmp(img_folder,'.')||strcmp(img_folder,'..')
            continue;
        end
        % 14 16 have problems
        % goes here
        dir_img = fullfile(dir_hpcc, img_folder);
        cd(dir_img);
% %         autoTCmaskBackgroundOnlyFit();
        
% %         MdEA = autoTCmaskDetectCirrus();
% %         MdEA_tmp = MdEA(1:500,1:500);
% %         MdEA_all = [MdEA_all; MdEA_tmp(:)];
% %         try
% %             % using 150 for the initial identification of cirrus clouds.
% %             autoPredictCirrusTOAImage150();

%             make cirrus mask.
        autoCmaskDetectCirrus();
% %             autoSelectImages2Show
% %         catch
% %            dir_img 
% %         end
    end
end

