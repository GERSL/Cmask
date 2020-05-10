% Predict the entire image's cirrus TOA reflectence
% Step 1. coefficinces save local
% Step 2. 
function autoCmaskBackground()
    dir_work = pwd;
    ds=DefaultSetting();
    dir_cmask_input = fullfile(dir_work,ds.foldername_input);
    dir_cmask_output = fullfile(dir_work, ...
        ds.foldername_output, ds.foldername_bg);

    warning('off','all');
    
    num_coefs = 4;
    
    satellite = 'Landsat';
    
    % get image parameters automatically
    imf = dir(fullfile(dir_cmask_input,'L*')); % folder names
    
    % output_name
    name_output = imf(1).name;
    name_tcmask_bgd = name_output(1:9);
    
    [nrows,ncols,nbands,jiUL,resolu,zc,num_imgs] = autoPara(imf);
    fprintf('A total of %d image\n',num_imgs);
 
    img_coefs = zeros(nrows,ncols,num_coefs+1,'single')-9999; % +1 RMSE -9999 is non-value here.
    
    for row = 1: nrows
        
        % read cirrus time series
        [Xs, Ys] = InitialTimeSeriesData(dir_cmask_input, satellite, nbands, row,ncols);

        % each pixel in a row
%         for i_ids = 1:min(ncols,lim_pixels) % only to 500 pixels
        for i_ids = 1:ncols % only to 500 pixels

            col=i_ids;
            
            cirrus_toa_obs = Ys(:,(nbands*(i_ids-1)+1):(nbands*(i_ids-1)+nbands-1));
            wvs = cirrus_toa_obs(:,2)./100;% back to 100
            cirrus_toa_obs = cirrus_toa_obs(:,1);

           %% iterate fit to find out the lower enevolpe
           Xs_tmp = Xs;
           Ys_tmp = cirrus_toa_obs(:,1);
           
           % all pixels but remove the unnormal data start ...
           dr_ids = 0<Ys_tmp&Ys_tmp<10000&...
               wvs>0; % only the values between 0 and 10000 and at the same time the vw is available
           
           [fit_cft_cirrus_tmp, rmse_cirrus] = CmaskModelFit(Xs_tmp(dr_ids),Ys_tmp(dr_ids),wvs(dr_ids));
  
           fit_cft_cirrus = fit_cft_cirrus_tmp;

           img_coefs(row,col,1:num_coefs) = fit_cft_cirrus;
           img_coefs(row,col,end) = rmse_cirrus;
           clear cirrus_marks;
           clear dr_ids;
        end
    end 
    
    output_folder = fullfile(dir_cmask_output);
    if ~isfolder(output_folder)
        mkdir(output_folder);
    end
    enviwrite(fullfile(dir_cmask_output,[name_tcmask_bgd,'_BG']),img_coefs,'single',resolu,jiUL,'bsq',zc);
end



function [Xs, Ys] = InitialTimeSeriesData(dir_cur, satellite, nbands, row, ncols)
%% Filter for Landsat folders
    [num_img,imfs] = FilterImages(satellite,'STK', dir_cur); % C1 : Collection 1

    %% read Xs (date) and Ys(Cirrus TOA Ref)
    Xs = zeros(num_img,1);
% %     DOYs = zeros(num_img,1);
    Ys = zeros(num_img,nbands*ncols);
    
    %% process each image
    for i =1: num_img
        im_dir = dir(fullfile(dir_cur,imfs(i,:)));
        % exlude none-TCmask inputs
        im = '';
        for f = 1:size(im_dir, 1)
            % use regular expression to match:
            %   'C(\w*)'    Any word begining with C that has any following chars
            %   stk_n       includes stack name somewhere after L
            %   '$'           ends with the stack name (e.g., no .hdr, .aux.xml)
            if regexp(im_dir(f).name, ['L(\w*)', 'stack', '$']) == 1 % L C
                im = [imfs(i, :), '/', im_dir(f).name];
                break
            end
        end
        
        % Check to make sure we found something
        if strcmp(im, '')
            error('Could not find stack image at %s\n', imfs(i));
        end
        
        % Find date for folder imf(i)
        yr = str2num(imfs(i, 10:13));
        doy = str2num(imfs(i, 14:16));
        
        Xs(i) = datenum(yr, 1, 0) + doy;
% %         DOYs(i) = doy;
        dummy_name = im;
        
        fid_t = fopen(fullfile(dir_cur,dummy_name),'r'); % get file ids
        fseek(fid_t,2*(row-1)*ncols*nbands,'bof'); % num_byte=2 means int16
        Ys(i,:) = fread(fid_t,nbands*ncols,'int16','ieee-le'); % get Ys
        fclose('all'); % close all files
        
        fprintf('Processed %dth line\n',row);
    end
%     WVs = WVs./100;
%     WVs = 1./exp(WVs); % opposite to reflectence
end