zTrack is a parameter-free "Cell Linking" algorithm that was developed by
Dr. Zhike Zi 
at Shenzhen Institute of Advanced Technology (SIAT), Chinese Academy of Sciences

The full open source code will be released when the manuscript is prepared in the future.

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
    
    - step 2: unzip matlabPyrTools-master.zip to the same folder, then run compilePyrTools under the MEX subfolder of matlabPyrTools
    
    - step 3: add matlabPyrTools-master and subfolders to MATLAB path


zTrack is a parameter-free algorithm for cell tracking. It only takes the
following input parameters: 

    - image_folder: the folder contains raw images
    - mask_folder: the segmentation folder contains segmentation masks
    - 'NumCores': the number of cores used for parallel cell tracking (optional)
                  Assuming the number of available cores is num_cores_sys, 
                  zTrack uses num_cores_sys - 1 by default. 
  

According to the submission note, zTrack assume that input images are
located in "../Fluo-N2DL-HeLa/01" and tracking results will be saved 
into "../Fluo-N2DL-HeLa/01_RES".  


Example of running zTrack in MATLAB for Linux/MacOS

zTrack4CTC ../Fluo-N2DL-HeLa/01 ../Fluo-N2DL-HeLa/01_ERR_SEG
zTrack4CTC ../Fluo-N2DL-HeLa/01 ../Fluo-N2DL-HeLa/01_ERR_SEG NumCores 12