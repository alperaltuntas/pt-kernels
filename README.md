This repository includes CESM kernels extracted from ocean components
to be used in optimization/verification studies.

The kernels are extracted from POP2 and MOM6, ocean components of CESM,
using KGen tool: https://github.com/NCAR/KGen.git

Links to the main model repositories:
    - POP2: https://github.com/ESCOMP/POP2-CESM.git
    - MOM6: https://github.com/NCAR/MOM6.git
    - CESM: https://github.com/ESCOMP/cesm.git

Note: The LLVM IR files are generated using flang compiler on
cheyenne (gnu/8.1.0). Instructions for building flang: 
https://github.com/flang-compiler/flang/wiki/Building-Flang

contact: altuntas@ucar.edu
