function image_3dstack = zTrack_imread3d(filename)
    % return tiff structure, one element per image
    img_info = imfinfo(filename); 
    % read in first image
    image_3dstack = imread(filename, 1) ; 
    %concatenate each successive tiff to mask_stack
    if size(img_info, 1) > 1
        for ii = 2 : size(img_info, 1)
            temp_tiff = imread(filename, ii);
            image_3dstack = cat(3 , image_3dstack, temp_tiff);
        end
    else
        warning('zTrack: No 3d image stack is found! Check you image files.');
    end
end