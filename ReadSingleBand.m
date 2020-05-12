function band = ReadSingleBand(fullfile_path, reg_mark, isGridobj)
     if ~exist('isGridobj','var')
         isGridobj = 'nonGridObj';
     end
     path = dir(fullfile(fullfile_path,reg_mark));
     if isempty(path)
        band=[];
        return;
     end
     % 255 will lead to NaN.
     if strcmpi (isGridobj, 'isGridObj') 
        band = GRIDobj(fullfile(path.folder,path.name));
        band_tmp = imread(fullfile(path.folder,path.name));
        band_tmp(band_tmp==-9999) = 0;
        band.Z = band_tmp;
     else
        band = imread(fullfile(path.folder,path.name));
     end
end