function hour = ReadMetaData(mtl_txt)
%READMETADATA Summary of this function goes here
%   Detailed explanation goes here
    fid_in=fopen(mtl_txt,'r');
    geo_char=fscanf(fid_in,'%c',inf);
    fclose(fid_in);
    geo_char=geo_char';
    geo_str=strread(geo_char,'%s');
    aq_time =char(geo_str(strmatch('SCENE_CENTER_TIME',geo_str)+2));
    aq_times = split(aq_time,':');
    hour = aq_times{1};
    hour = str2num(hour(2:end));
    min = aq_times{2};
    min = str2num(min);
    hour = hour + floor(min/30);
    if hour ==0
        hour = 24;
    end
    % SCENE_CENTER_TIME = "14:37:53.8047520Z"
end

