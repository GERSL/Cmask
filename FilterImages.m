function [num_img,imfs] = FilterImages(satellite, product_type, dir_cur)
%LANDSATDATAFILTER Filter for all landsat folders
% Inputs:
% satellite:
% Landsat
% 
% product_type:
% C1  Collection 1
% STK Stacked image ready to use
%
    switch satellite
        case 'Landsat'
            if isequal(product_type, 'C1')
                % get num of total folders start with "L"
                imfs = dir(fullfile(dir_cur,'L*'));
                % filter for Landsat folders
                % espa data
                imfs = regexpi({imfs.name}, 'L(T05|T04|E07|C08)(\w*)', 'match'); 
                imfs = [imfs{:}];
                if isempty(imfs)
                    num_img = 0;
                    imfs = [];
                    yyyymmdd = [];
                    return;
                end
                imfs = vertcat(imfs{:});
                % sort according to yeardoy
                yyyymmdd = str2num(imfs(:, 18:25)); % should change for different sets
                [~, sort_order] = sort(yyyymmdd);
                imfs = imfs(sort_order, :);
                % number of folders start with "L"
                num_img = size(imfs,1);
                return;
            end
            
            if isequal(product_type, 'STK')
                % get num of total folders start with "L"
                imfs = dir(fullfile(dir_cur,'L*')); % folder names
                % filter for Landsat folders
                imfs = regexpi({imfs.name}, 'L(T5|T4|E7|C8|ND)(\w*)', 'match');
                imfs = [imfs{:}];
                imfs = vertcat(imfs{:});
                % sort according to yeardoy
                yeardoy = str2num(imfs(:, 10:16));
                [~, sort_order] = sort(yeardoy);
                imfs = imfs(sort_order, :);
                % number of folders start with "L"
                num_img = size(imfs,1);
                return;
            end
    end
    num_img = 0;
    imfs = [];
    yyyymmdd = [];
end

