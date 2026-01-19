conda create -n computational-chem python=3.9
conda activate computational-chem

conda install -c conda-forge openbabel

conda install -c conda-forge pandas openpyxl

#安装 Gaussian 16.

#解压安装包以后
export g16root=/home/yourfile
export GAUSS_SCRDIR=/home/youfile/g16/scratch
source /home/sob/yourfile/bsd/g16.profile

#对/g16目录执行 
chmod 750 -R *
#运行命令
g16<test.gjf>test.out

#安装Multiwfn

ulimit -s unlimited
export OMP_STACKSIZE=200M
export Multiwfnpath=/home/yourfile/Multiwfn_3.8_dev_bin_Linux_noGUI
export PATH=$PATH:/home/yourfile/Multiwfn_3.8_dev_bin_Linux_noGUI

chmod +x /home/yourfile/Multiwfn_3.8_dev_bin_Linux_noGUI

# 安装Shermo

#解压安装包以后
export PATH=$PATH:/yourfile/Shermo_2.0
export Shermopath=/yourfile/Shermo_2.0

#需要把excel中 Smile放在第一列 第三行开始。依次执行223.py   pdb2gjf.sh (template.gjf在同一个目录下)   runall.sh   chk2fchk.sh   getGap.sh   Mayer.sh   getShermo.sh