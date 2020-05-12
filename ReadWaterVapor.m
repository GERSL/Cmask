

function ReadWaterVapor()
    data_time  = 10;
    dates = [20130104;20130105];
    wv_dir = 'G:\TCmaskData\MERRA2_WaterVapor';
    
    trg_girdobj = GRIDobj('G:\TCmaskData\extentsample.tif');
    for i = 1: length(dates)
        wv_date = num2str(dates(i));
        net_file = dir(fullfile(wv_dir,['MERRA2*',wv_date,'.nc4.nc']));
        if ~isempty(net_file)
            net_file_path =  fullfile(wv_dir,net_file(1).name);
            wv_gridobj = ConvertNet2Tiff(net_file_path,data_time);
            test = reproject2utm(wv_gridobj,trg_girdobj);
            GRIDobj2geotiff(test,'G:\TCmaskData\testwv.tif');
        end
    end    
end

function wv_gridobj = ConvertNet2Tiff(nc4_file,hour)
%READWATERVAPOR  Read water vapor data
    
%     nc4_file = 'G:\TCmaskData\MERRA2_WaterVapor\MERRA2_400.inst1_2d_int_Nx.20130104.nc4.nc';

    WV = ncread(nc4_file,'TQV');
    
    WV = rot90(fliplr(WV));
    
    WV = WV(:,:,hour);
    % Write the .grd data into geotiff
    R = georasterref('RasterSize',size(WV),'LatitudeLimits',[-90,90],........
      'LongitudeLimits',[-180,180]);
    tiffile = strcat(nc4_file,'.tif') ;
    geotiffwrite(tiffile,WV,R);
    wv_gridobj = GRIDobj(tiffile);
end

