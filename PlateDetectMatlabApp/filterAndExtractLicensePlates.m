function [filtered_image, plate_images] = filterAndExtractLicensePlates(Origin_Image, binary_image)
    % 分析二值图像中的连通区域
    [labels, num] = bwlabel(binary_image);
    stats = regionprops(labels, 'BoundingBox', 'Area');
    
    % 创建一个和原图大小相同的空图像用于显示结果
    filtered_image = zeros(size(binary_image));
    
    % 初始化一个cell array来保存符合条件的车牌图像
    plate_images = {};

    % 遍历每一个连通区域
    for i = 1:num
        bbox = stats(i).BoundingBox;
        width = bbox(3);
        height = bbox(4);
        
        % 计算长宽比
        aspectRatio = width / height;

        % 检查长宽比是否在 3:1 到 5:1 之间
        if aspectRatio >= 3 && aspectRatio <= 5
            % 如果符合条件，将此区域的位置在filtered_image中设为1
            x = ceil(bbox(1));
            y = ceil(bbox(2));
            x_end = floor(x + width - 1);
            y_end = floor(y + height - 1);
            filtered_image(y:y_end, x:x_end) = 1;
            
            % 截取原图对应区域的图像
            plate_image = imcrop(Origin_Image, bbox);
            plate_images{end + 1} = plate_image;
        end
    end

    % 返回筛选后的图片和车牌图像列表
    return
end