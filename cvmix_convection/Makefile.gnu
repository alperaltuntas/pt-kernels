# Makefile for KGEN-generated kernel

# Originally used compiler(s)
#FC_0 := /glade/u/apps/opt/intel/2019u2/compilers_and_libraries/linux/bin/intel64/ifort
FC_0 := mpif90
FC_FLAGS_SET_0 := -O2 -fconvert=big-endian -ffree-form -D_MPI

ALL_OBJS := cvmix_convection.o cvmix_kinds_and_types.o kernel_driver.o kgen_utils.o tprof_mod.o

build: ${ALL_OBJS}
	${FC_0} ${FC_FLAGS_SET_0} -o kernel.exe $^  

run: build
	mpirun -np 2 ./kernel.exe

cvmix_convection.o: cvmix_convection.F90 cvmix_kinds_and_types.o kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

cvmix_kinds_and_types.o: aux_modules/cvmix_kinds_and_types.F90 kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kernel_driver.o: aux_modules/kernel_driver.f90 cvmix_convection.o cvmix_kinds_and_types.o kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kgen_utils.o: aux_modules/kgen_utils.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

tprof_mod.o: aux_modules/tprof_mod.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

clean:
	rm -f kernel.exe *.mod ${ALL_OBJS}
