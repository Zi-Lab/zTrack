function img_cropped = Image3dCropWithCuboid(input_image, center, cuboidWHD)
img_expand = padarray(input_image,cuboidWHD);

%     [dim1, dim2] = size(input_image);
%      side
%      - -- - - - - - -   ( | column, dim2, y)
%     |    ________    |
%     |   |        |   |
%     |   | input  |   |
%     |   | image  |   |
%     |    --------    |
%     |                |
%      - - - - - - - --
%     (->row, dim1, x)
% padarray changes the original x, y axis, x,y_new = x,y_old + side_size
% 

% cuboid [xmin ymin zmin width height depth]
% Size and position of the crop volume in spatial coordinates, specified as
% a 6-element vector of the form [xmin ymin zmin width height depth] 
cuboid = [center+cuboidWHD/2 cuboidWHD];
img_cropped = imcrop3(img_expand, cuboid);
end
