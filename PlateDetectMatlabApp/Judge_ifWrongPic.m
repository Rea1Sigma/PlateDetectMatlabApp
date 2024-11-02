function Judgement = Judge_ifWrongPic(img1,img2)
    % 确保这两张图中的值为二值图像，即0和1
    Judgement = 0;
    % 计算两张图片大小，这里假设它们大小相同
    [rows, cols] = size(img1);

    % 计算两张图相同位置像素点一致的数量
    matchingPixels = sum(sum(img1 == img2));

    % 计算总像素数
    totalPixels = rows * cols;

    % 计算一致像素的比例
    matchingRatio = (matchingPixels / totalPixels) * 100;

    % 判断一致像素的比例是否超过90%
    if matchingRatio > 90
        Judgement = 1;
        disp('这两张图一样，因为超过90%的像素点相同。');
    else
        Judgement = 0;
        disp('这两张图不一样。');
    end
end