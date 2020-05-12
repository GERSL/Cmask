function wv_gridobj = ConvertNet2Tiff(nc4_file,hour)
%READWATERVAPOR  Read water vapor data
    
%     nc4_file = 'G:\TCmaskData\MERRA2_WaterVapor\MERRA2_400.inst1_2d_int_Nx.20130104.nc4.nc';

    tiffile = strcat(nc4_file,'.24.tif');% 24 hours
    try
        wv_gridobj = GRIDobj(tiffile);
        WV = imread(tiffile);
        wv_gridobj.Z = WV(:,:,hour);
    catch
        % if we have no file here, then we will create this.
        WV = ncread(nc4_file,'TQV');
        WV = rot90(fliplr(WV));
        % Write the .grd data into geotiff
        R = georasterref('RasterSize',size(WV),'LatitudeLimits',[-90,90],........
          'LongitudeLimits',[-180,180]);
        geotiffwrite(tiffile,WV,R);
        wv_gridobj = GRIDobj(tiffile);
        WV = imread(tiffile);
        wv_gridobj.Z = WV(:,:,hour);
    end
end


% % function wv_gridobj = ConvertNet2Tiff(nc4_file,hour)
% % %READWATERVAPOR  Read water vapor data
% %     
% % %     nc4_file = 'G:\TCmaskData\MERRA2_WaterVapor\MERRA2_400.inst1_2d_int_Nx.20130104.nc4.nc';
% % 
% %     tiffile = strcat(nc4_file,'.avg.tif');
% %     try
% %         wv_gridobj = GRIDobj(tiffile);
% %         wv_gridobj.Z = imread(tiffile);
% %     catch
% %         % if we have no file here, then we will create this.
% %         WV = ncread(nc4_file,'TQV');
% %         WV = rot90(fliplr(WV));
% %         WV = WV(:,:,hour);
% %         % Write the .grd data into geotiff
% %         R = georasterref('RasterSize',size(WV),'LatitudeLimits',[-90,90],........
% %           'LongitudeLimits',[-180,180]);
% %         geotiffwrite(tiffile,WV,R);
% %         wv_gridobj = GRIDobj(tiffile);
% %         wv_gridobj.Z = imread(tiffile);
% %     end
% % end
