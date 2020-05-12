% function LoadL8Biome(index)
    index=23;
    % LOADIMAGES Load the data based on L8 Biome folder.
    [fullfile_path_L8Biome, path_row, year_doy]= FindL8BiomeImage(index);
    
    if ~isequal(path_row,'229057')
        return;
    end
    
    [fullfile_path_Img_before,fullfile_path_Img, fullfile_path_Img_after]...
     = FindNearImages(path_row, year_doy);
 
    % vars
    %% target image (L8_Biome)
    target_gridobj = ReadSingleBand(fullfile_path_L8Biome,'LC*B2.tif','isGridObj');
%     target_gridobj.Z = [];
    % manual cloud masks (also target image)
    mmask = ReadSingleBand(fullfile_path_L8Biome,'LC*_mask.tif');
    figure;
    imshow(mmask==192);
    
    %      0	   Fill
    %     64	   Cloud Shadow
    %     128	   Clear
    %     192	   Thin Cloud
    %     255	   Cloud
     
    % observations
    fmask_target = ReadStackSingleBand(fullfile_path_Img, 'LC*Fmask.tif',target_gridobj);
    mask = fmask_target<255; %clear fmask_target;

    
    %% previous image
    % fmask results
    fmask_before = ReadStackSingleBand(fullfile_path_Img_after, 'LC*Fmask.tif',target_gridobj);
    % refresh observation extent
    mask = mask&fmask_before<255;
    % clear sky pixels
    clear_before = fmask_before ==0|fmask_before ==1|fmask_before ==3; % 0 is clear land, 1 is clear water, 3 is snow
    % overlap bewteen the thin clouds and clear surface in the target image
    % and the clear surface in the this image obtained by Fmask 4.0. 
%     overlap_comped_ids = find ((clear_before&(mmask==192|mmask==128)&mask==1)==1);
    overlap_comped_ids = find ((clear_before&(mmask==192)&mask==1)==1);
    
    
    %% Diff TOA reflectance of cirrus band (band 9)
    toa_cirrus_before = ReadStackSingleBand(fullfile_path_Img_after,'LC*toa_band9.tif',target_gridobj);
    toa_cirrus_target = ReadStackSingleBand(fullfile_path_Img,'LC*toa_band9.tif',target_gridobj);
    toa_cirrus_diff = abs(toa_cirrus_before - toa_cirrus_target);
    toa_cirrus_diff = toa_cirrus_diff(overlap_comped_ids);
    
    %% Diff surface reflectance of NIR (band 5)
    sr_nir_target = ReadStackSingleBand(fullfile_path_Img,'LC*sr_band5.tif',target_gridobj);
    sr_nir_before = ReadStackSingleBand(fullfile_path_Img_after,'LC*sr_band5.tif',target_gridobj);
    sr_nir_diff = abs(sr_nir_target - sr_nir_before);
    sr_nir_diff = sr_nir_diff(overlap_comped_ids);
    
    ShowDensityPlot_DiffCirrusTOA2DiffSR(double(toa_cirrus_diff),double(sr_nir_diff));
% end


