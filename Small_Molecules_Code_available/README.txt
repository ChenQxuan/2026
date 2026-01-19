
# install Gaussian 16.
# get your own gaussian16 package
export g16root=/home/yourfile
export GAUSS_SCRDIR=/home/youfile/g16/scratch
source /home/sob/yourfile/bsd/g16.profile
chmod 750 -R *

# install Multiwfn
http://sobereva.com/multiwfn/

# install Shermo
http://sobereva.com/soft/shermo/
export PATH=$PATH:/yourfile/Shermo_2.0
export Shermopath=/yourfile/Shermo_2.0


# 
Need to place Smile in the first column of the Excel file, starting from the third row. Then sequentially execute: 223.py, pdb2gjf.sh (template.gjf is in the same directory), runall.sh, chk2fchk.sh, getGap.sh, Mayer.sh, getShermo.sh.
