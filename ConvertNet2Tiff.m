function wv_gridobj = ConvertNet2Tiff(nc4_file,hour, dir_output, issave)
%READWATERVAPOR  Read water vapor data
    if ~exist('issave', 'var')
        issave = 0;
    end
%     tiffile = strcat(nc4_file,'.24.tif');% 24 hours
    tiffile = fullfile(dir_output, 'wv22h.tif');% 24 hours
    try
        wv_gridobj = GRIDobj(tiffile);
        WV = imread(tiffile);
        wv_gridobj.Z = WV(:,:,hour);
    catch
        % if we have no file here, then we will create this.
        WV = ncread(nc4_file,'TQV');
        finfo = ncinfo(nc4_file).Attributes;
        LatitudeResolution = finfo(strcmp({finfo.Name}, 'LatitudeResolution')).Value;
        LatitudeResolution = str2num(LatitudeResolution);
        LongitudeResolution = finfo(strcmp({finfo.Name}, 'LongitudeResolution')).Value;
        LongitudeResolution = str2num(LongitudeResolution);
    	
        % Limits in latitude/longitude of the geographic quadrangle bounding the georeferenced raster. 
        LatitudeLimits = ncread(nc4_file,'lat');
        LatitudeLimits = [min(LatitudeLimits(:))-LatitudeResolution/2, max(LatitudeLimits(:))+LatitudeResolution/2];
        LongitudeLimits = ncread(nc4_file,'lon');
        LongitudeLimits = [min(LongitudeLimits(:))-LongitudeResolution/2, max(LongitudeLimits(:))+LongitudeResolution/2];

        WV = rot90(fliplr(WV));
        % Write the .grd data into geotiff
        R = georasterref('RasterSize',size(WV),'LatitudeLimits',LatitudeLimits,........
          'LongitudeLimits',LongitudeLimits);
      
        % save it locally
        % default 'CoordRefSysCode', 4326
        geotiffwrite(tiffile,WV,R);
        
        wv_gridobj = GRIDobj(tiffile);
        WV = imread(tiffile);
        wv_gridobj.Z = WV(:,:,hour);
        wv_gridobj.size(end) = [];
        if ~issave
            delete(tiffile);
        end
    end
end
