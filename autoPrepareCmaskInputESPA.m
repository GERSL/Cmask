function autoPrepareCmaskInputESPA(varargin)
%autoPrepareCmaskInputESPA Prepare Landsat Band 9 into Cmask input format, 
% which are downloaded from USGS Earth Resources Observation and Science
% (EROS) Center Science Processing Architecture (ESPA)
% (https://espa.cr.usgs.gov/)
%
%   same extent using nearest method based on the Topotoolbox 
%   https://topotoolbox.wordpress.com/topotoolbox/).
%
% Data Support
%   -------------
%   The input data must be of class .tif.
%   
%
% Specific parameters
% ------------------------
%   'DirL'     Directory of inpu Landsat data.  Default is the path to
%                        the current folder.
%   'DirWV'     Directory of input water vapor data.  Default is the path to
%                        the current folder.
%   'DirOut'    Directory of output data.  Default is the path to
%                        the current folder.
%   'ExtentSample'       An example geotiff file, of which extent will be 
%                        used as basic reference. All images will be 
%                        resampled to this same extent.  Default is not to
%                        do this process if no input for this.
%

%   Author:  Shi Qiu (shi.qiu#uconn.edu)
%            Zhe Zhu (zhe.zhu#uconn.edu)
%            
%   Date: 8. Aug, 2020
% 
% History:
% 1. add a variable 'ExtentSample' to define a extent geotiff, which will be used to clip all images into a same extent and a same spatial resolution. 16 Aug., 2020  Shi
%
% Example:
% To prepare data without extent file:
% autoPrepareCmaskInputESPA('DirL', 'C:\Users\qsly0\Desktop\Example_Data_Cmask\espa-xxx-08212018-150747-713', 'DirWV','C:\Users\qsly0\Desktop\Example_Data_Cmask\MERRA2_HourlyWaterVapor', 'DirOut', 'C:\Users\qsly0\Desktop\Example_Data_Cmask\CmaskInput')
% To prepare data with extent file:
% autoPrepareCmaskInputESPA('DirL', 'C:\Users\qsly0\Desktop\Example_Data_Cmask\espa-xxx-08212018-150747-713', 'DirWV','C:\Users\qsly0\Desktop\Example_Data_Cmask\MERRA2_HourlyWaterVapor', 'DirOut', 'C:\Users\qsly0\Desktop\Example_Data_Cmask\CmaskInput', 'ExtentSample', 'C:\Users\qsly0\Desktop\Example_Data_Cmask\LC080200462013061101T1-SC20180821151847.tar\LC080200462013061101T1-SC20180821151847/LC08_L1TP_020046_20130611_20170504_01_T1_bt_band10.tif' )

    %% get parameters from inputs
    % where all the  Landsat zipped files are
    dir_landsat = pwd;
    % where all the MERRA-2 water vapor files are
    dir_wv = '';
    % where the output files are
    dir_out = '';
    % total number of bands
    nbands = 2;
    
    p = inputParser;
    p.FunctionName = 'prepParas';
    % optional
    % default values.
    addParameter(p,'DirL',dir_landsat);
    addParameter(p,'DirWV',dir_wv);
    addParameter(p,'DirOut',dir_out);
    addParameter(p,'ExtentSample','');
    
    % request user's input
    parse(p,varargin{:});
    dir_landsat = p.Results.DirL;
    dir_wv = p.Results.DirWV;
    dir_out = p.Results.DirOut;
    if isempty(dir_out)
        dir_out = dir_landsat;
    end
    trgt_file = p.Results.ExtentSample;
    
    warning('off','all');
    
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
    imfs = dir(fullfile(dir_landsat,'L*.tar.gz'));
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
        n_stack = [char(n_mtl),'_MTLstack'];
        % add directory
        n_dir = fullfile(dir_out,n_mtl);
        if isfile(fullfile(n_dir, n_stack))&&isfile(fullfile(n_dir, [n_stack, '.hdr']))
            fprintf('Already exist %s\r',n_mtl);
            continue;
        end
        
        % MERRA2_400.inst1_2d_int_Nx.20130322.nc4.nc.tif
        nc4_file = dir(fullfile(dir_wv,['MERRA2_400.inst1_2d_int_Nx.',yyyymmdd_str,'.*.nc']));
        if isempty(nc4_file)
            error('No Water Vapor data for %s, lack of %s!\r', n_mtl, ['MERRA2_400.inst1_2d_int_Nx.',yyyymmdd_str]);
%             continue;
        end
        
        % names of image folder that are processed
        try
            n_gun = gunzip(fullfile(dir_landsat,imf),fullfile(dir_out,n_tmp));
            n_tar = untar(fullfile(dir_out,n_tmp,imf(1:end-3)),fullfile(dir_out,n_tmp));
        catch me
            if isfolder(fullfile(dir_out,n_tmp))
                rmdir(fullfile(dir_out,n_tmp),'s');
            end
            fprintf('Unzip errors in the %s image',n_mtl);
            continue;
        end
        
        % meta data to obtain acqurision time
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
        
        tif_b9 = dir(fullfile(dir_out,n_tmp,'L*toa_band9.tif'));

        if ~isempty(tif_b9) % tif format(tif_cfmask);
            % read Band 9
            tif_b9 = fullfile(dir_out,n_tmp,tif_b9.name);
            trg_girdobj = GRIDobj(tif_b9);
            % resample Band 9 into the file named by 'ExtentSample'
            if ~isempty(trgt_file)
                % have targt file
                try
                    trgt_obj_extent = GRIDobj(trgt_file);
                    trgt_obj_extent.Z = zeros(trgt_obj_extent.size);% empty memory initially masked as 0
                    % same extent and resolution
                    trg_girdobj = resample(trg_girdobj, trgt_obj_extent, 'nearest', true, 'fillval', 0);
                    clear trgt_obj_extent;
                catch
                    fprintf('Sample file can not be support for resampling to same extent. Only geotiff is workable.\n');
                    return;
                end
            end
            b9 = trg_girdobj.Z;
            
            % get projection information from geotiffinfo
            info = geotiffinfo(tif_b9);
            jidim = [info.SpatialRef.RasterSize(2),info.SpatialRef.RasterSize(1)];
            jiul = [info.SpatialRef.XLimWorld(1),info.SpatialRef.YLimWorld(2)];
            resolu = [info.PixelScale(1),info.PixelScale(2)];
            zc = info.Zone;
            clear info;
        end
        % prelocate image for the stacked image
        stack = zeros(jidim(2),jidim(1),nbands,'int16');
        %% add cirrus TOA
        stack(:,:,1) = b9;

        %% add water vapor
        scale = 100; % to save as int16
        nc4_file = fullfile(dir_wv,nc4_file.name);
        wv_gridobj = ConvertNet2Tiff(nc4_file,data_time,fullfile(dir_out,n_tmp));
        %  interpolation method ('bilinear' (default)
        wv_obj = reproject2utm(wv_gridobj,trg_girdobj,'method','nearest');
        
        % if dimensions are different
        if ~isequal(size(wv_obj.Z), size(trg_girdobj.Z))
            wv_obj = resample(wv_obj,trg_girdobj);
            wv_obj.Z = fillmissing(wv_obj.Z,'linear',1);
            wv_obj.Z = fillmissing(wv_obj.Z,'linear',2);
        end
        stack(:,:,2) = int16(wv_obj.Z*scale);

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
        if ~isempty(trgt_file)
            fprintf('Successfully processed %s with being clipped\r',n_mtl);
        else
            fprintf('Successfully processed %s\r',n_mtl);
        end
    end
end
