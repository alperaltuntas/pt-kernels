# Makefile for KGEN-generated kernel

# Originally used compiler(s)
#FC_0 := /glade/u/apps/opt/intel/2018u4/compilers_and_libraries/linux/bin/intel64/ifort
FC_0 := mpif90
FC_FLAGS_SET_0 := -fpp -fno-alias -auto -safe-cray-ptr -ftz -assume byterecl -i4 -r8 -nowarn -sox -traceback -g -O0 -check -check noarg_temp_created -check nopointer -warn -warn noerrors -fpe0 -ftrapuv -D_MPI

ALL_OBJS := MOM_EOS_Wright.o kernel_driver.o kgen_utils.o tprof_mod.o

build: ${ALL_OBJS}
	${FC_0} ${FC_FLAGS_SET_0} -o kernel.exe $^  

run: build
	mpirun -np 2 ./kernel.exe

MOM_EOS_Wright.o: MOM_EOS_Wright.F90 kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kernel_driver.o: kernel_driver.f90 MOM_EOS_Wright.o kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kgen_utils.o: kgen_utils.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

tprof_mod.o: tprof_mod.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

clean:
	rm -f kernel.exe *.mod ${ALL_OBJS}
