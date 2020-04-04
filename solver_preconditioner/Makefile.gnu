# Makefile for KGEN-generated kernel

# Originally used compiler(s)
#FC_0 := /usr/local/intel-cluster-19.0.1/bin/ifort
FC_0 := gfortran
FC_FLAGS_SET_0 := -O0 -fconvert=big-endian -ffree-form -cpp

ALL_OBJS := POP_SolversMod.o POP_IOUnitsMod.o POP_KindsMod.o kernel_driver.o kgen_utils.o tprof_mod.o

build: ${ALL_OBJS}
	${FC_0} ${FC_FLAGS_SET_0} -o kernel.exe $^  

run: build
	mpirun -np 2 ./kernel.exe

POP_SolversMod.o: POP_SolversMod.F90 POP_IOUnitsMod.o POP_KindsMod.o kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

POP_IOUnitsMod.o: aux_modules/POP_IOUnitsMod.F90 kgen_utils.o tprof_mod.o POP_KindsMod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

POP_KindsMod.o: aux_modules/POP_KindsMod.F90 kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kernel_driver.o: aux_modules/kernel_driver.f90 POP_SolversMod.o POP_IOUnitsMod.o POP_KindsMod.o kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kgen_utils.o: aux_modules/kgen_utils.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

tprof_mod.o: aux_modules/tprof_mod.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

clean:
	rm -f kernel.exe *.mod ${ALL_OBJS}
