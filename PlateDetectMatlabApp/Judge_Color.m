function [Blue,Green,Yellow] = Judge_Color(Image_in)
    Blue = 0;
    Green = 0;
    Yellow = 0;
%     % 转换到HSV色彩空间
%     image1HSV = rgb2hsv(Image_in);
% 
%     % 定义蓝色和绿色的HSV范围
%     % 这些范围可能需要根据您的具体图片进行调整
%     blueRange = [190/360, 260/360]; % 假定的蓝色范围
%     greenRange = [80/360, 150/360]; % 假定的绿色范围
% 
%     % 创建蓝色和绿色的掩码
%     blueMask1 = (image1HSV(:,:,1) >= blueRange(1)) & (image1HSV(:,:,1) <= blueRange(2));
%     greenMask1 = (image1HSV(:,:,1) >= greenRange(1)) & (image1HSV(:,:,1) <= greenRange(2));
%     % 评估哪种颜色的掩码区域更大，从而判断车牌颜色
%     if sum(blueMask1(:)) > sum(greenMask1(:))
%         Blue = 1;
%         Green = 0;
%         disp('Image 1 contains a blue plate');
%     else
%         Blue = 0;
%         Green = 1;
%         disp('Image 1 contains a green plate');
%     end
    img = Image_in;

    % 转换数据类型为double进行计算（可选，但推荐以避免溢出）
    img = double(img);

    % 计算每个通道的平均值
    averageR = mean(mean(img(:,:,1)));
    averageG = mean(mean(img(:,:,2)));
    averageB = mean(mean(img(:,:,3)));

    % 显示平均RGB值
    if averageG>averageB
        if averageR > averageG
            Blue = 0;
            Green = 1;
            Yellow = 1;
        else
            Blue = 0;
            Green = 1;
        end
    else
        Blue = 1;
        Green = 0;
    end
end