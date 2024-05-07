#!/bin/bash
# Prerequisities: MATLAB (2018 or later, tested on MATLAB 2022 MacOS, Linux), MATLAB Image Processing Toolbox, MATLAB Parallel Computing Toolbox, matlabPyrTools (included in the code)
  datasets=('BF-C2DL-HSC'
            'BF-C2DL-MuSC'
            'DIC-C2DH-HeLa'
            'Fluo-C2DL-MSC' 
            'Fluo-N2DH-GOWT1'
            'Fluo-N2DL-HeLa' 
            'PhC-C2DH-U373' 
            'PhC-C2DL-PSC'
            'Fluo-C3DH-A549'
            'Fluo-C3DH-H157'
            'Fluo-C3DL-MDA231'
            'Fluo-N3DH-CHO'
            'Fluo-N3DH-CE');

# for video 01/02
for data in "${datasets[@]}"
do
matlab -r "zTrack4CTC ../$data/01 ../$data/01_ERR_SEG; quit" -nodesktop -nosplash -nodisplay
matlab -r "zTrack4CTC ../$data/02 ../$data/02_ERR_SEG; quit" -nodesktop -nosplash -nodisplay
done

