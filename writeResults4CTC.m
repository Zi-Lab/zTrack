function writeResults4CTC(cell_track, mask_folder, filenames_mask, tracResult_filenames, output_folder)
%  Inputs:
%  cell_track - A cell vector which specifies the parent-child relationship
%  in current frame. The matrix has one row for each frame. Element
%  cell_track{t}(l) has the parent id (in previous frame t-1) of the cell l
%  in frame t. For the first frame cell_track{1}, all the elements are 0
%  indicating no paraent for the cells in the first frame.

% cell_in_branch: the record of cell tracking by their mask labels in different frames
cell_in_edge = cell(size(cell_track));
% for CTC tracking results
% format: index cell@firstFrame-1, cell@lastFrame-1, parentIndex
%   i.e.: 'index', 'start', 'stop', 'parent_branch_in2i2hikedex'
edge_tracks = NaN([0,4]);

for t = 1:length(cell_in_edge)
    cell_in_edge{t} = NaN(size(cell_track{t}));
end

for t = 1:length(cell_in_edge)         % iterate image frames i
    for l = 1:length(cell_in_edge{t})  % iterate mask labels in frame i
        % get parent edge (branch) index information
        if ~isnan(cell_track{t}(l))    
            if cell_track{t}(l) == 0
                parent_edge_index = 0;
            else
                parent_edge_index = cell_in_edge{t-1}(cell_track{t}(l));
            end

            % check whether cell division (edge split) exist or not. 
            % i.e.: whether >=2 cells have the same parent edge
            children_num = (sum(cell_track{t} == cell_track{t}(l)) == 1);
            if (children_num == 1) && (cell_track{t}(l) ~= 0)
                edge_index = parent_edge_index;
                % update last frame information
                last_frame = t;
                edge_tracks(edge_index, 3) = last_frame;
            else
                % create a new edge
                edge_index = size(edge_tracks,1) + 1;
                first_frame = t;
                last_frame = t;
                newBrach = [edge_index first_frame last_frame parent_edge_index];
                edge_tracks = [edge_tracks; newBrach];
            end
            cell_in_edge{t}(l) = edge_index;
        end
    end
end

%% Adjust frame number for CellTrackingChallenge
% The frame number starts from 0 in Cell tracking challenge
edge_tracks(:,2) = edge_tracks(:,2) -1;
edge_tracks(:,3) = edge_tracks(:,3) -1;

loop_steps = length(cell_in_edge);
dot_num = floor(loop_steps/ceil(loop_steps*0.05));
if loop_steps <20
    fprintf(['\n   Write tracking result progress ' repmat('.', 1, loop_steps) '\n' repmat(' ', 1, 39)]);
else
    fprintf(['\n   Write tracking result progress ' repmat('.', 1, dot_num) '\n' repmat(' ', 1, 39)]);
end


img_info = imfinfo(fullfile(mask_folder, filenames_mask{1})); 
for t = 1:length(cell_in_edge)
    if size(img_info, 1) < 2   % for 2d cell tracking
        I1 = imread([mask_folder filesep filenames_mask{t}]);
        I2 = uint16(I1);
        labels = setdiff(unique(I1(:)),0);
        for l = 1:length(cell_in_edge{t})
            I2(I1 == labels(l)) = cell_in_edge{t}(l);
        end
        imwrite(I2 , [output_folder filesep tracResult_filenames{t}]);
    else  % for 3d cell tracking
        I1 = zTrack_imread3d([mask_folder filesep filenames_mask{t}]);
        I2 = uint16(I1);
        labels = setdiff(unique(I1(:)),0);
        for l = 1:length(cell_in_edge{t})
            I2(I1 == labels(l)) = cell_in_edge{t}(l);
        end

        for idx = 1:size(img_info, 1)
            if idx == 1
                imwrite(I2(:,:,idx), [output_folder filesep tracResult_filenames{t}]);
            else
                imwrite(I2(:,:,idx), [output_folder filesep tracResult_filenames{t}], 'WriteMode','append');
            end
        end
    end

    if loop_steps <= 20 || ...
       isequal(mod(t, ceil(loop_steps*0.05)), 0) 
        fprintf('\b\b\b\b\b|');
    else
        fprintf('\b\b\b\b\b');
    end
    fprintf('%4.0f%%', 100*t/loop_steps);
    pause(0.02);
end

fileID = fopen([output_folder filesep 'res_track.txt'],'w');
nbytes = fprintf(fileID,'%d %d %d %d\r\n',edge_tracks');
fclose(fileID);
fprintf('\n   zTrack: Write tracking result for CTC challenge finished!\n');

end