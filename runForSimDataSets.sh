#!/bin/bash
# Prerequisities: MATLAB (2018 or later, tested on MATLAB 2022 MacOS, Linux), MATLAB Image Processing Toolbox, MATLAB Parallel Computing Toolbox, matlabPyrTools (included in the code)
  datasets=('Fluo-N2DH-SIM+'
            'Fluo-C3DH-A549-SIM'
            'Fluo-N3DH-SIM+');

# for video 01/02
for data in "${datasets[@]}"
do
matlab -r "zTrack4CTC ../$data/01 ../$data/01_ERR_SEG; quit" -nodesktop -nosplash -nodisplay
matlab -r "zTrack4CTC ../$data/02 ../$data/02_ERR_SEG; quit" -nodesktop -nosplash -nodisplay
done

