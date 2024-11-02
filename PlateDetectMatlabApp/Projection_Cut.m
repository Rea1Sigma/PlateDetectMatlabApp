function Final_Plate = Projection_Cut(Image_in)
    X_threshold=1;
    [y,x]=size(Image_in);
    Y_Projection = (sum((~Image_in)'))';
    X_Projection = sum((~Image_in));
    %找黑色边缘
    Y_top = fix(y/2);
    Y_threshold = mean(Y_Projection((fix(y/2)-10):(fix(y/2)+10),1))/1.6;
    while ((Y_Projection(Y_top,1)>=Y_threshold) && (Y_top>1))
        Y_top=Y_top-1;
    end
    Y_bottom = fix(y/2);
    while ((Y_Projection(Y_bottom,1)>=Y_threshold) && (Y_bottom<y))
        Y_bottom=Y_bottom+1;
    end
    X_right = 1;
    if (X_Projection(1,fix(x/14))) <= X_threshold
        X_right = fix(x/14);
    end
    % 确定黑色部分的边缘
    Final_Plate = Image_in(Y_top:Y_bottom,X_right:x);
end