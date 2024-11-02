function [Char_Image,Char_Position,Projection_Page] = GetCharFrom_Plate(Image_in)
    PlateImage = Image_in;
    PlateSize = size(PlateImage);
    X = PlateSize(1);
    Y = PlateSize(2);
    verticalProjection = X-sum(PlateImage, 1);
    verticalProjectionBlack = verticalProjection;
    Projection_Page = verticalProjection;
    % 初始化存储波谷起始位置的数组
    valleyStarts = [];
    prevPixelCount = inf;
    % 遍历verticalProjectionBlack数组，寻找符合波谷条件的位置
    for i = 1:length(verticalProjectionBlack)
        % 检查当前位置黑色像素点数量是否小于100，并处于下降趋势
        if verticalProjectionBlack(i) < 20 && verticalProjectionBlack(i) < prevPixelCount
            % 记录波谷起始位置，只有在之前不是波谷时才记录当前位置
            if isempty(valleyStarts) || valleyStarts(end) ~= i-1
                valleyStarts = [valleyStarts, i];
            end
        end
        % 更新上一个像素点的数量
        prevPixelCount = verticalProjectionBlack(i);
    end
    Char_Position=valleyStarts;
    filteredX = Char_Position(1); % 初始化过滤后的数组，首先包含X的第一个元素
    for i = 2:length(Char_Position)
        % 如果当前元素与filteredX最后一个元素的差的绝对值大于10，则将其添加到filteredX中
        if abs(Char_Position(i) - filteredX(end)) > 10
            filteredX = [filteredX, Char_Position(i)];
        end
    end
    xCoords = filteredX;
    % 初始化结构体X
    X = struct;
    % 添加图像的开始边缘到数组（如果需要从图像的最左边开始分割）
    xCoords = [0, xCoords];
    % 添加图像的结尾边缘到数组（如果需要分割到图像的最右边）
    xCoords = [xCoords, size(PlateImage, 2)];
    % 遍历xCoords数组进行分割
    for i = 1:(length(xCoords) - 1)
        % 分割图像
        segmentedImg = PlateImage(:, (xCoords(i)+1):xCoords(i+1));
        % 存储到结构体中，使用动态字段名
        fieldName = sprintf('segment_%d', i);
        X.(fieldName) = segmentedImg;
    end
    fields = fieldnames(X);  % 获取所有字段名称
    for i = 1:length(fields)
        fieldName = fields{i};  % 当前字段的名称
        img = X.(fieldName);  % 提取当前字段中的图像
        [height, width] = size(img);  % 获取图像的尺寸。

        if width <= 256
            % 如果图像宽度小于等于128，从结构体中删除该字段
            X = rmfield(X, fieldName);
        end
    end
    fields = fieldnames(X); % 获取结构体中所有图像字段的名称
    for i = 1:length(fields)
        fieldName = fields{i}; % 当前图像字段的名称
        img = X.(fieldName); % 从结构体中提取当前字段的图像
        % 计算图像中的总像素数
        totalPixels = numel(img);
        % 计算黑色像素的数量，假设图像是灰度图像且黑色像素值为0
        blackPixels = sum(img(:) == 0);
        % 计算黑色像素占总像素的百分比
        blackPixelRatio = (blackPixels / totalPixels) * 100;
        % 如果黑色像素占比小于等于10%，则删除该图像字段
        if blackPixelRatio <= 10
            X = rmfield(X, fieldName);
        end
    end

     fields = fieldnames(X); % 获取结构体中所有图像字段的名称
    for i = 1:length(fields)
        fieldName = fields{i}; % 当前图像字段的名称
        img = X.(fieldName); % 从结构体中提取当前字段的图像
        % 计算图像中的总像素数
        totalPixels = numel(img);
        % 计算黑色像素的数量，假设图像是灰度图像且黑色像素值为0
        blackPixels = sum(img(:) == 0);
        % 计算黑色像素占总像素的百分比
        blackPixelRatio = (blackPixels / totalPixels) * 100;
        % 如果黑色像素占比大于等于80%，则删除该图像字段
        if blackPixelRatio >= 80
            X = rmfield(X, fieldName);
        end
    end
    
    %% 移动字符
    thresholdFraction = 0.1; % 定义阈值为图像宽度的5%
    fields = fieldnames(X); % 获取结构体中所有图像字段的名称
    for i = 1:length(fields)
        fieldName = fields{i}; % 当前图像字段的名称
        img = X.(fieldName); % 继续使用之前的假设：每张图像储存在结构体的'image'字段
        % 计算字符的水平边界
        sumCols = sum(img, 1); % 按列求和，寻找字符存在的列
        charCols = find(sumCols < max(sumCols)); % 找到非纯白列
        if isempty(charCols)
            continue; % 如果图像中没有字符（全白图像），则跳过
        end
        leftBound = min(charCols);
        rightBound = max(charCols);
        charWidth = rightBound - leftBound + 1;
        charCenter = (leftBound + rightBound) / 2;
        imgCenter = size(img, 2) / 2;
        % 判断字符中心是否明显偏离图像中心
        offset = abs(charCenter - imgCenter);
        if offset < thresholdFraction * size(img, 2) % 如果偏移小于阈值，不处理
            continue;
        end
        % 提取字符
        charImg = img(:, leftBound:rightBound);
        % 创建一个新的全白图像作为背景
        newImg = 255 * ones(size(img), 'like', img); % 假设背景为白色，且图像为uint8类型
        % 计算新的字符位置，使其位于中心
        startPos = round((size(img, 2) - charWidth) / 2); % 中心对齐的起始列
        endPos = startPos + charWidth - 1; % 中心对齐的结束列
        % 将字符放置到中间
        newImg(:, startPos:endPos) = charImg;
        % 更新结构体中的图像
        X.(fieldName) = newImg;
    end
    %% 移动字符
    Char_Image = X;
end