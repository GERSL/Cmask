function autoCmaskDetectCirrus()
%AUTOCMASKDETECTCIRRUS Detect cirrus clouds by differing predicted and
%observed cirrus band TOA reflectance.
    save_pcd = 1;
    
    dir_work = pwd;
    ds=DefaultSetting();
    dir_cmask_bgd = fullfile(dir_work, ...
        ds.foldername_output, ds.foldername_bg);
    
    dir_cmask_inpt = fullfile(dir_work,ds.foldername_input);
    
    dir_cmask_cirrus_mask = fullfile(dir_work, ...
        ds.foldername_output, ds.foldername_mask);
    
    dir_cmask_pred = fullfile(dir_work, ...
        ds.foldername_output, ds.foldername_pred);
    
    % load Cmask background image
    path_cmask_bgd = dir(fullfile(dir_cmask_bgd,'L*_BG'));
      [im_bgd,~,jiUL,resolu,ZC]=enviread(fullfile(dir_cmask_bgd, path_cmask_bgd.name));
        
    % get image parameters automatically
    imf = dir(fullfile(dir_cmask_inpt,'L*')); % folder names
    
    for i =1:length(imf)
        name_cmask_img = imf(i).name;
        
        % load water vapor
        path_cmask_input = fullfile(dir_cmask_inpt,name_cmask_img,[name_cmask_img,'_MTLstack']);

        im = enviread(path_cmask_input);
        img_obserd = single(im(:,:,1));
        wvs = single(im(:,:,2))./100;% back to 100
        clear im;
        % convert to X
        yr = str2num(name_cmask_img(10:13));
        doy = str2num(name_cmask_img(14:16));
        Xs = datenum(yr, 1, 0) + doy;

        w = 2*pi/365.25;
        img_pred = im_bgd(:,:,1) + ...
            im_bgd(:,:,2).*cos(Xs.*w)+im_bgd(:,:,3).*sin(Xs.*w)+...
            im_bgd(:,:,4)./exp(wvs);

         delta_obserd_pred = img_obserd - img_pred;
        
        mask_cirrus = delta_obserd_pred > 31 & delta_obserd_pred./img_obserd>0.5 ;
        clear delta_obserd_pred 
        mask_cirrus = uint8(mask_cirrus);
        
        output_folder = fullfile(dir_cmask_cirrus_mask,name_cmask_img);
        if length(dir(output_folder))==0
            mkdir(output_folder);
        end
        enviwrite(fullfile(output_folder,[name_cmask_img,'_cirrus']),mask_cirrus,'uint8',resolu,jiUL,'bsq',ZC);
        clear output_folder mask_cirrus;
        
        if save_pcd
            output_folder_pcd = fullfile(dir_cmask_pred,name_cmask_img);
            if ~isfolder(output_folder_pcd)
                mkdir(output_folder_pcd);
            end
            enviwrite(fullfile(output_folder_pcd,[name_cmask_img,'_pcb']),img_pred,'int16',resolu,jiUL,'bsq',ZC); % pcb: predicted cirrus band
        end
        clear output_folder_pcd img_pred;
        
        fprintf('Processed %dth image\n', i);
    end
end

