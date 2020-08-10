function hour = ReadMetaDataARD(mtl_xml)
    xml_landsat = xml2struct(mtl_xml);
    
    aq_time = xml_landsat.ard_metadata.scene_metadata{1, 1}.global_metadata.scene_center_time.Text;
    aq_times = split(aq_time,':');
    hour = aq_times{1};
    hour = str2num(hour(2:end));
    min = aq_times{2};
    min = str2num(min);
    hour = hour + floor(min/30);
    if hour ==0
        hour = 24;
    end
end

