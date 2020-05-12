function autoPrepareCmaskInputESPA(varargin)
%autoPrepareCmaskInputESPA Prepare Landsat Surface Reflectance into CCDC format, 
% which are downloaded from USGS Earth Resources Observation and Science
% (EROS) Center Science Processing Architecture (ESPA)
% (https://espa.cr.usgs.gov/)
%
%   autoPrepareCmaskInputESPA() automatically prepares all Landsat ESPA product in
%   the current folder into CCDC format.
%   autoPrepareCmaskInputESPA(PARAM1,VAL1,PARAM2,VAL2,PARAM3,VAL3,PARAM4,VAL4) specifies 
%   parameters that control input and outout directory, the clear pixel
%   filter condition, and sample file (used to restrict same extent using 
%   nearest method based on the Topotoolbox 
%   https://topotoolbox.wordpress.com/topotoolbox/).
%
% Data Support
%   -------------
%   The input data must be of class .tif or .img. Only .tif format can be 
%   resamlped to a same extent.
%   
%
% Specific parameters
% ------------------------
%   'InputDirectory'     Directory of input data.  Default is the path to
%                        the current folder.
%   'OutputDirectory'    Directory of output data.  Default is the path to
%                        the current folder.
%   'ExtentSample'       An example geotiff file, of which extent will be 
%                        used as basic reference. All images will be 
%                        resampled to this same extent.  Default is not to
%                        do this process if no input for this.
%   'ClearPixelPercent'  Percentage of mininum clear pixels 
%                        (non-ice/snow covered). Unit is %. Default is '20'.
%
%
%   Author:  Zhe Zhu (zhe.zhu#ttu.edu)
%            Shi Qiu (shi.qiu#ttu.edu)
%            Junxue Zhang (junxue.zhang#ttu.edu)
%   Date: 24. Jun, 2018

    %% get parameters from inputs
    % where the all Landsat zipped files are
    dir_cur = pwd;
    % where the output files are
    dir_out = '';
    % min clear pixel
    clr_pct_min = 0; % unit %
    % total number of bands
    nbands = 3;
    
    p = inputParser;
    p.FunctionName = 'prepParas';
    % optional
    % default values.
    addParameter(p,'InputDirectory',dir_cur);
    addParameter(p,'OutputDirectory',dir_out);
    addParameter(p,'ClearPixelPercent',clr_pct_min);
    addParameter(p,'ExtentSample','');
    wv_dir = '/Users/shi/Documents/Cmask_Data/MERRA2_WaterVapor';
    
    % request user's input
    parse(p,varargin{:});
    dir_cur = p.Results.InputDirectory;
    dir_out = p.Results.OutputDirectory;
    if isempty(dir_out)
        dir_out = dir_cur;
    end
    clr_pct_min = p.Results.ClearPixelPercent;
    trgt_file = p.Results.ExtentSample;
  
    %% Locate to the current directory
    % name of the temporary folder for extracting zip files
    name_tmp = 'tmp';
    % remove all temp folders
    tmpf = dir(fullfile(dir_out,[name_tmp,'*']));
    if ~isempty(tmpf)
        for i = 1:length(tmpf)
            if tmpf(i).isdir
                rmdir(fullfile(dir_out,tmpf(i).name),'s');
            end
        end
    end
    
    %% Filter for Landsat folders
    % get num of total folders start with "L"
    %imf = dir('L*SR.tar'); % folder names
    imfs = dir(fullfile(dir_cur,'L*.tar.gz'));
    % filter for Landsat folders
    % espa data
    imfs = regexpi({imfs.name}, 'L(T05|T04|E07|C08)(\w*)\-(\w*).tar.gz', 'match'); 
    imfs = [imfs{:}];
    if isempty(imfs)
        warning('No images here!');
        return;
    end
    imfs = vertcat(imfs{:});
    % sort according to yeardoy
    yyyymmdd = str2num(imfs(:, 11:18)); % should change for different sets
    [~, sort_order] = sort(yyyymmdd);
    imfs = imfs(sort_order, :);
    % number of folders start with "L"
    num_t = size(imfs,1);
    fprintf('A total of %d images will be prepared...\n',num_t);
    for i = 1:num_t
        % name of the temporary folder for extracting zip files
        n_tmp = [name_tmp,num2str(i)];
        imf = imfs(i,:);
        % new filename in format of LXSPPPRRRYYYYDOYLLLTT   
        yr = (imf(11:14));
        % converst mmdd to doy
        mm = (imf(15:16));
        dd = (imf(17:18));
        yyyymmdd_str = [yr,mm,dd];
        yr = str2num(yr);
        mm = str2num(mm);
        dd = str2num(dd);
        
        doy = datenummx(yr,mm,dd)-datenummx(yr,1,0);
        % set folder and image name
        n_mtl = [imf([1,2,4:14]),num2str(doy,'%03d'),'0',imf(19:22)];
        % check if folder exsit or not
        % names of image folder that are processed
        n_img = dir(fullfile(dir_out,'L*'));
        num_img = size(n_img,1);
        try
            n_gun = gunzip(fullfile(dir_cur,imf),fullfile(dir_out,n_tmp));
            n_tar = untar(fullfile(dir_out,n_tmp,imf(1:end-3)),fullfile(dir_out,n_tmp));
        catch me
            if isfolder(fullfile(dir_out,n_tmp))
                rmdir(fullfile(dir_out,n_tmp),'s');
            end
            fprintf('File cannot be found in the %dth image',i);
            continue;
        end
        
        % remove all files in subfolder
        for j = 1: length(n_tar)
            single_img_path = n_tar(j);
            single_img_path  = single_img_path{1};
            % move all files to 
            [status,~,~] = movefile(single_img_path,fullfile(dir_out,n_tmp));
        end
        
        % meta data
        
        mtl_txt = dir(fullfile(dir_out,n_tmp,'L*MTL.txt'));
        if ~isempty(mtl_txt) % envi format
            mtl_txt = fullfile(dir_out,n_tmp,mtl_txt.name);
        else
            mtl_txt = '';
        end
        
        % when no meta data, give the water vapor at 12:00 UTC
        if isempty(mtl_txt)
            data_time = 12;
        else
            data_time = ReadMetaData(mtl_txt);
        end
        
        % decide image format (tif or envi)
        env_cfmask = dir(fullfile(dir_out,n_tmp,'L*pixel_qa.img'));
        tif_cfmask = dir(fullfile(dir_out,n_tmp,'L*pixel_qa.tif'));

        % picking surf ref 1-7, bt, and cfmask and save to the images folder
        % get names of surf 1-7
        % fprintf('Reading images ...\n');
        
        % read cfmask first to caculate clear pixel percet
        if ~isempty(env_cfmask) % envi format
            env_cfmask = fullfile(dir_out,n_tmp,env_cfmask.name);
            [cfmask0,jidim,jiul,resolu,zc] = enviread(env_cfmask);
            if ~isempty(trgt_file)
                fprintf('Images can not be support for resampling to same extent. Only geotiff is workable.\n');
                return;
            end
        else
            tif_cfmask = fullfile(dir_out,n_tmp,tif_cfmask.name);
            cfmask0 = geotiffread(tif_cfmask);
        end
        cfmask = cfmask0;

        % convert pixel QA to fmask values
        cfmask(bitget(cfmask0,1) == 1) = 255;
        cfmask(bitget(cfmask0,2) == 1) = 0;
        cfmask(bitget(cfmask0,3) == 1) = 1;
        cfmask(bitget(cfmask0,4) == 1) = 2;
        cfmask(bitget(cfmask0,5) == 1) = 3;
        cfmask(bitget(cfmask0,6) == 1) = 4;

        clr_pct = sum(cfmask(:)<=1)/sum(cfmask(:)<255);
        clr_pct = 100*clr_pct;
        if clr_pct < clr_pct_min % less than 20% clear observations
            % remove the tmp folder
            % fprintf('Clear observation less than 20 percent (%.2f) ...\n',clr_pct*100);
            rmdir(fullfile(dir_out,n_tmp),'s');
            % fprintf('Clear pixels less than %.2f percent (%.2f) ...\n',clr_pct_min,clr_pct););
            fprintf('Clear pixels less than %.2f percent (%.2f) for %s\n',clr_pct_min,clr_pct,imf);
            continue;
        else
            if ~isempty(tif_cfmask) % tif format(tif_cfmask);
                % get projection information from geotiffinfo
                info = geotiffinfo(tif_cfmask);
                jidim = [info.SpatialRef.RasterSize(2),info.SpatialRef.RasterSize(1)];
                jiul = [info.SpatialRef.XLimWorld(1),info.SpatialRef.YLimWorld(2)];
                resolu = [info.PixelScale(1),info.PixelScale(2)];
                zc = info.Zone;
                clear info;
            end
            % prelocate image for the stacked image
            stack = zeros(jidim(2),jidim(1),nbands,'int16');
            % give cfmask to the last band
            stack(:,:,end) = cfmask;
        end

        % add cirrus TOA
        n_surf = dir(fullfile(dir_out,n_tmp,'L*toa_band9.tif'));
        n_surf = fullfile(dir_out,n_tmp,n_surf.name);
        surf_b1 = geotiffread(n_surf);
        stack(:,:,1) = surf_b1;
        
        % add water vapor
        
% %         data_time  = 10;
        scale = 100;
% %         data_time
        trg_girdobj = GRIDobj(n_surf);
        
        % MERRA2_400.inst1_2d_int_Nx.20130322.nc4.nc.tif
        nc4_file = (fullfile(wv_dir,['MERRA2_400.inst1_2d_int_Nx.',yyyymmdd_str,'.nc4.nc']));
        wv_gridobj = ConvertNet2Tiff(nc4_file,data_time);
        wv_obj = reproject2utm(wv_gridobj,trg_girdobj);
        
        % if dimensions are different
        if ~isequal(size(wv_obj.Z), size(trg_girdobj.Z))
            wv_obj = resample(wv_obj,trg_girdobj);
            wv_obj.Z = fillmissing(wv_obj.Z,'linear',1);
            wv_obj.Z = fillmissing(wv_obj.Z,'linear',2);
        end
        stack(:,:,2) = int16(wv_obj.Z*scale);

        n_stack = [char(n_mtl),'_MTLstack'];


        % add directory
        n_dir = fullfile(dir_out,n_mtl);
        % if ~isfolder(n_dir)
        %     mkdir(n_dir);
        % end
        % works before 2017b
        n_dir_isfolder = dir(n_dir);
        if isempty(n_dir_isfolder)
            mkdir(n_dir);
        end
        clear n_dir_isfolder;

        % write to images folder
        % fprintf('Writing %s image ...\n',n_mtl);
        n_stack = fullfile(n_dir,n_stack);
        enviwrite(n_stack,stack,'int16',resolu,jiul,'bip',zc);

        % remove the tmp folder
        rmdir(fullfile(dir_out,n_tmp),'s');
    end
end