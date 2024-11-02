function Angle = Re_Correct(Image_OriginPlate)
    Image = edge(Image_OriginPlate);
    theta = 1:100;
    [R,~] = radon(Image,theta);
    [~,J] = find(R>=max(max(R)));
    Angle = 90-J;
end