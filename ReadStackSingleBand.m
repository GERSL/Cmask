function band = ReadStackSingleBand(fullfile_path, reg_mark,target_gridobj,fillValue)

    band_gridobj = ReadSingleBand(fullfile_path, reg_mark, 'isGridObj');
    
    if isempty(band_gridobj)
        band=[];
        return;
    end
    
% %     addpath(fullfile(pwd,'@GRIDobj')); % add path to GRIDobj
    clear fullfile_path reg_mark;
    band2target_gridobj = resample(band_gridobj,target_gridobj,'nearest',true,'fillval',fillValue);
    clear band_gridobj target_gridobj;
    band = band2target_gridobj.Z;    
    clear band2target_gridobj;
end