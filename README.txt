zTrack is a parameter-free "Cell Linking" algorithm that was developed by
Dr. Zhike Zi 
at Shenzhen Institute of Advanced Technology (SIAT), Chinese Academy of Sciences

The code can be run in Matlab and has been tested on MacOS and Linux Systems. 

Required toolboxs for zTrack
    - MATLAB Image Processing Toolbox
    - MATLAB Parallel Computing Toolbox
    - matlabPyrTools (included in the code) 

Instructions for compiling matlabPyrTools
    - step 1: setup C compiler for using the MATLAB MEX command, visit
    https://de.mathworks.com/support/requirements/supported-compilers-mac.html 
    Important note for MacOS: if you get an error message "Error using mex
    Supported compiler not detected...." when you run mex -setup, try the
    following solution: change the location of the Xcode.app in Applications,
    by using the "xcode-select" command from macOS Terminal: 
    sudo xcode-select -s /Applications/Xcode.app
    
    - step 2: run compilePyrTools under the MEX subfolder of matlabPyrTools
    
    - step 3: add matlabPyrTools-master and subfolders to MATLAB path


zTrack is a parameter-free algorithm for cell tracking. It only takes the
following input parameters: 

    - image_folder: the folder contains raw images
    - mask_folder: the segmentation folder contains segmentation masks
    - 'NumCores': the number of cores used for parallel cell tracking (optional)
                  Assuming the number of available cores is num_cores_sys, 
                  zTrack uses num_cores_sys - 1 by default. 

The functions 'zTrack_2d' and 'zTrack_3d' return a 'cell_track' cell array. 
For a cell labeled as 'l1' in frame t1, cell_track{t1}(l1) specifies 
the ID of the parent cell being tracked at frame t1-1. If the cell 
is newly born and lacks a tracked parent, it is denoted by '0'.

cell_track  = zTrack_2d(image_folder, image_filenames, mask_folder, mask_filenames, 'NumCores', num_cores);
cell_track  = zTrack_3d(image_folder, image_filenames, mask_folder, mask_filenames, 'NumCores', num_cores);


Usage: According to the submission note, zTrack assume that input images are
located in "../Fluo-N2DL-HeLa/01" and tracking results will be saved 
into "../Fluo-N2DL-HeLa/01_RES".  


Example of running zTrack in MATLAB for Linux/MacOS

zTrack4CTC ../Fluo-N2DL-HeLa/01 ../Fluo-N2DL-HeLa/01_ERR_SEG
zTrack4CTC ../Fluo-N2DL-HeLa/01 ../Fluo-N2DL-HeLa/01_ERR_SEG NumCores 12