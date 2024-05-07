function ImageProjected = zTrack_3dImageProjection(Image3d, AxisProjected)
% pay attention to the coordiance of x, y, z matching to the Matlab matrix
% size information 
% [dim1, dim2, dim3] = Image3d
% dim2 -> x-axis, dim1 -> y-axis, dim3 -> z-axis 

    % get max projection image along x, y, z axis
    switch AxisProjected
        case 'x'
            ImageProjected = squeeze(max(Image3d, [], 1));
        case 'y'
            ImageProjected = squeeze(max(Image3d, [], 2));
        case 'z'
            ImageProjected = max(Image3d, [], 3);
        otherwise
            error('Please specify the projected axis with ''x'', ''y'', or ''z''');
    end
end