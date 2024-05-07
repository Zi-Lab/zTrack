function FileNameList = zTrack_getFileNamesByFormat(folder_name, filename_format)
%--------------------------------------------------------------------------
% This function get the list of file names in a folder according to
% CellTime defined file name format.
%  'folder_name' - the folder that contains the segmentation images
%
%  'filename_format' - the expression for the image names e.g.:
%  'CommonCharacters>>>.tif', '>>>' is the 3 digital numbers that specify
%  the order of the images. 
%
%  Output: FileNameList, a cell array that contains the list of file names
%
%--------------------------------------------------------------------------
[~, ~, ext] = fileparts(filename_format);
file_info = dir(fullfile(folder_name, strcat('*', ext)));
file_names = {file_info.name};
temp_ind = strfind(filename_format, '>');
temp_str = erase(filename_format, '>');
expression = insertAfter(temp_str, temp_ind(1)-1, '(?<time>\d+)');
tokenNames = regexp(file_names,expression, 'names');
% added on 27.07.2022
% remove emepty elements (unrecognized image files) in tokenNames
tokenNames = tokenNames(~cellfun('isempty',tokenNames));

tempFrames = zeros(length(tokenNames),1);
for i=1:length(tokenNames)
    tempFrames(i) = str2double(tokenNames{i}.time);
end
imgFrames = unique(tempFrames);
digitsNum_time  = length(strfind(filename_format,'>'));
formatSpec = sprintf('%%.%dd', digitsNum_time);
FileNameList = cell(length(imgFrames),1);
for i = 1:length(imgFrames)
    temp_filename = strrep(filename_format, repmat('>', ...
        [1,digitsNum_time]), num2str(imgFrames(i), formatSpec));
    FileNameList{i,1} = temp_filename;
end

end