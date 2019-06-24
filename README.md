## pt-kernels

This repository includes kernels extracted from the ocean components of the Community Earth System Model (CESM).

The kernels are to be used for optimization/verification studies and usually consist of:
 1. A main Fortran module containing the subroutine targeted for optimization/verification.
 2. Auxiliary modules required for dependencies
 3. Data sampled from an actual model run and to be used to run the kernels
 4. The kernel driver

### Building kernels:
 1. ```cd``` to a kernel directory.
 2. Compile the kernel:
    - For Intel compiler:
    ```make``` 
    - For GNU Fortran compiler:
    ```make -f Makefile.gnu```
    - For LLVM compiler (flang):
    ```make -f Makefile.llvm```

	NOTE!: All the kernel data was generated with CESM compiled with intel,
				 so it is advisable to compile the kernels with intel Fortran
				 compiler. Otherwise, verification tests may fail.

### Running kernels:
	```mpirun -n 1 ./kernel.exe```

------

The kernels are extracted from POP2 and MOM6, ocean components of CESM, using KGen tool:
https://github.com/NCAR/KGen.git

Links to the main model repositories:
 - POP2: https://github.com/ESCOMP/POP2-CESM.git
 - MOM6: https://github.com/NCAR/MOM6.git
 - CESM: https://github.com/ESCOMP/cesm.git

Note: The LLVM IR files are generated using flang compiler built with (gnu/8.1.0).
