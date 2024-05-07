function img_cropped = ImageCropWithSquare(input_image, center, side_size, varargin)

narginchk(3, 4);

if nargin == 3
    img_expand = padarray(input_image,[side_size, side_size]);
else
    img_expand = padarray(input_image,[side_size, side_size], varargin{1}, "both");
end
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
% rect [xmin ymin width height]
rect = [(center+side_size/2) side_size side_size];
img_cropped = imcrop(img_expand, rect);

end