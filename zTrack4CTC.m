function zTrack4CTC(image_folder, mask_folder, varargin)
%  Inputs:
%
%  'image_folder' - the folder that contains CTC challenge images
%
%  'mask_folder' - the folder that contains the segmentation mask images
%
%  varargin - Optional input arguments
%
%  'NumCores' - Specifies the number of the CPU cores used for parallel
%  cell tracking. It must be a positive integer.
%
%  Usage examples: 
%
%  zTrack4CTC ../Fluo-N2DL-HeLa/01 ../Fluo-N2DL-HeLa/01_ERR_SEG
%  zTrack4CTC ../Fluo-N2DL-HeLa/01 ../Fluo-N2DL-HeLa/01_ERR_SEG NumCores 12
%
% Required toolboxs for zTrack
% - MATLAB Image Processing Toolbox
% - MATLAB Parallel Computing Toolbox
% - matlabPyrTools (included in the code) To compile on your platform,
% simply run compilePyrTools.m which is located in the MEX subdirectory. 
% see https://github.com/LabForComputationalVision/matlabPyrTools/blob/master/README

%% compile matlabPyrTools
% step 1: setup C compiler for using the MATLAB MEX command, visit
% https://de.mathworks.com/support/requirements/supported-compilers-mac.html 
% Important note for MacOS: if you get an error message "Error using mex
% Supported compiler not detected...." when you run mex -setup, try the
% following solution: change the location of the Xcode.app in Applications,
% by using the "xcode-select" command from macOS Terminal: 
% sudo xcode-select -s /Applications/Xcode.app
%
% step 2: run compilePyrTools under the MEX subfolder of matlabPyrTools
% 
% step 3: add matlabPyrTools-master and subfolders to MATLAB path

%% optional input for the number of cpus for parallel cell tracking 
% default number of cpus for parallel cell tracking 
num_cores = feature('numcores') -1;
gold_mask_folder = [];
args_names = {'NumCores', 'GoldMaskFolder'};
narginchk(2, 6);
for i = 3:2:nargin
    arg = varargin{i-2};

    % case insensitive for input arguments
    if ischar(arg)
        idx = find(strncmpi(arg, args_names, numel(arg)));
        if isempty(idx)
            error('zTrack: unknownInputString %s', arg);
        elseif numel(idx) > 1
            error('zTrack: ambiguousInputString %s', arg);
        elseif numel(idx) == 1
            if (i+1 > nargin)
                error('zTrack: missingParameterValue');
            end
            switch arg
                case {'NumCores', 'Numcores', 'numCores', 'numcores'}
                    if isnumeric(varargin{i-1})
                        num_cores = varargin{i-1};
                    else
                        num_cores = str2double(varargin{i-1});
                    end
                    validateattributes(num_cores, {'numeric'}, ...
                        {'integer','positive'}, '', 'NumCores');
                case 'GoldMaskFolder'
                    gold_mask_folder = varargin{i-1};
                    validateattributes(gold_mask_folder, {'char'}, ...
                        {'scalartext'});
            end
        end
    else
        error('zTrack: mustBeString');
    end
end

% limit the number of used cpu cores no greater than the total number of
% cores - 1, keep one core free for system running
if num_cores > feature('numcores') -1
    num_cores = feature('numcores') -1;
end

% check image and segementation folders
if ~exist(image_folder, 'dir')
    error('The image dataset folder ''%s'' does not exit', image_folder);
end

if ~exist(mask_folder, 'dir')
    error('The segmentation mask folder ''%s'' does not exit', mask_folder);
end
addpath(genpath('matlabPyrTools-master'))
% submission note: 
% assume that input images are located in "../Fluo-N2DL-HeLa/01" and
% segmentation and/or tracking results will be saved into "../Fluo-
% N2DL-HeLa/01_RES".  
if contains(image_folder, {'BF-C2DL-MuSC', 'BF-C2DL-HSC'})
    imageName_format = 't>>>>.tif';
    maskName_format = 'mask>>>>.tif'; 
    % maskName_format = 'man_track>>>>.tif';   % for GT seg
else
    imageName_format = 't>>>.tif';
    maskName_format = 'mask>>>.tif';
    % maskName_format = 'man_track>>>.tif';   % for GT seg
end

%% Generate filenames according to the regular expression
image_filenames = zTrack_getFileNamesByFormat(image_folder, imageName_format);
mask_filenames = zTrack_getFileNamesByFormat(mask_folder, maskName_format);
%% remove last character with '/' or '\'
if or(image_folder(end) == '/',image_folder(end) == '\')
    image_folder = image_folder(1:end-1);
end
output_folder = [image_folder '_RES'];

%% renumber the label id by reading the segmentation from 3rd-party software
% newMask_folder = 'seg_renumber';
% delete(strcat(newMask_folder, '/*.*')); % remove old seg mentation files
% % delete(strcat(output_folder, '/*.*')); % remove old seg mentation files
% for t=1:length(mask_filenames)
%     seg_mask = imread(fullfile(mask_folder, mask_filenames{t}));
%     new_mask = renumberMask(seg_mask);
%     % new_mask = seg_mask;
%     imwrite(new_mask, fullfile(newMask_folder, mask_filenames{t}));
% end 

% creat RES output folder if doesn't exist
if ~exist(output_folder, 'dir')
   mkdir(output_folder);
end

% check the image type: 2d or 3d image
img_info = imfinfo(fullfile(mask_folder, mask_filenames{1}));
if size(img_info, 1) < 2   % for 2d cell tracking
    if isempty(gold_mask_folder)
        cell_track = zTrack_2d(image_folder, image_filenames, mask_folder, mask_filenames, 'NumCores', num_cores);
    else
        cell_track = zTrack_2d(image_folder, image_filenames, mask_folder, ...
            mask_filenames, 'NumCores', num_cores, 'GoldMaskFolder', gold_mask_folder);
    end
else  % for 3d cell tracking
    fprintf('Warning: 3D tracking... Please wait as it takes longer than 2D tracking\n%s\n%s', ...
        '         If the memory space is not enough for a large 3D image dataset,', ...
        '         decrease ''NumCores'' (e.g. run ''zTrack4CTC image_folder mask_folder NumCores 2'')');
    cell_track = zTrack_3d(image_folder, image_filenames, mask_folder, mask_filenames, 'NumCores', num_cores);
    
    %% for the datasets with "Important note" at CTC website
    % uncomment the line 162-207 for Fluo-N3DL-DRO/TRIC/TRIF datasets
    % Specific instructions for Fluo-N3DL-DRO, Fluo-N3DL-TRIC, and
    % Fluo-N3DL- TRIF: Due to different treatment of extra detected and
    % segmented cells in the Cell Tracking Benchmark and the Cell
    % Segmentation Benchmark for these datasets, the Cell Tracking
    % Benchmark participants are encouraged to submit not only tracking
    % results limited to the cells provided in the first frames of the gold
    % reference tracking annotations, but also complete segmentation
    % results that will automatically be purified from all extra detected
    % and segmented cells by the evaluation software and used for the Cell
    % Segmentation Benchmark. The complete segmentation results and
    % command-line executables used to produce them shall be uploaded into
    % the prepared particular folders under the CSB subfolders.            

    % if contains(image_folder, {'Fluo-N3DL-DRO', 'Fluo-N3DL-TRIC', 'Fluo-N3DL-TRIF'})
    %     % challenge-datasets/Fluo-N3DL-DRO/01_GT/TRA/man_track000.tif
    %     if isequal(image_folder(end), filesep)
    %         GT_fold = [image_folder(1:end-1) '_GT' filesep 'TRA' filesep];
    %     else
    %         GT_fold = [image_folder '_GT' filesep 'TRA' filesep];
    %     end
    %     seg_mask0 = zTrack_imread3d(fullfile(GT_fold, 'man_track000.tif'));
    %     labels_seg0 = double(setdiff(unique(seg_mask0),0));
    %     labels_stats0 = regionprops3(seg_mask0, 'Centroid', 'BoundingBox');
    %     % remove NaN values
    %     labels_stats0 = rmmissing(labels_stats0);
    %     seg_mask1=zTrack_imread3d(fullfile(mask_folder, mask_filenames{1}));
    %     labels_seg1 = double(setdiff(unique(seg_mask1),0));
    %     labels_stats1 = regionprops3(seg_mask1, 'Centroid', 'BoundingBox');
    %     track_tag = zeros(length(labels_seg0),1);
    %     % mapping the 1st image to the reference image, based on shortest distance
    %     for idx0 = 1:length(labels_seg0)
    %         d01 = zeros(length(labels_seg1),1);
    %         for idx1=1:length(labels_seg1)
    %             d01(idx1)=norm(labels_stats1.Centroid(labels_seg1(idx1),:)  -...
    %                 labels_stats0.Centroid(labels_seg0(idx0),:));
    %         end
    %         [~, track_tag(idx0)] = labels_seg1(min(d01));
    %     end
    % 
    %     % update cell_track only for those lineages of objects that are
    %     % uniquely determined by the tracking markers available in
    %     % man_track000.tif
    %     for idxc = 1:length(cell_track{1})
    %         if (~ismember(idxc, track_tag))
    %             cell_track{1}(idxc) = NaN;
    %         end
    %     end
    %     for idxt = 2:length(cell_track)
    %         for idxc = 1:length(cell_track{idxt})
    %             if cell_track{idxt}(idxc) == 0   % new cells in frame t
    %                 cell_track{idxt}(idxc) = NaN;
    %             else
    %                 if isnan(cell_track{idxt-1}(cell_track{idxt}(idxc)))    % do not belong to labeled cells
    %                     cell_track{idxt}(idxc) = NaN;
    %                 end
    %             end
    %         end
    %     end
    % end
end

%% write tracking results 
tracResult_filenames = mask_filenames;

% tracResult_filenames = cell(length(mask_filenames),1);
% for t=1:length(mask_filenames)
%     % tracResult_filenames{t} = strrep(mask_filenames{t}, 'man_seg', 'mask');
%     tracResult_filenames{t} = strrep(mask_filenames{t}, 'man_track', 'mask');
%     % copyfile(fullfile(newnewMask_folder, mask_filenames{t}), fullfile(output_folder, tracResult_filenames{t}));
% end
writeResults4CTC(cell_track, mask_folder, mask_filenames, tracResult_filenames, output_folder);

end

