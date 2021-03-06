# Makefile for KGEN-generated kernel

# Originally used compiler(s)
#FC_0 := /glade/u/apps/opt/intel/2019u2/compilers_and_libraries/linux/bin/intel64/ifort
FC_0 := mpif90
FC_FLAGS_SET_0 := -qno-opt-dynamic-align -convert big_endian -assume byterecl -ftz -traceback -assume realloc_lhs -fp-model source -qopt-report -xCORE_AVX2 -no-fma -O2 -debug minimal -free -fpp -D_MPI

ALL_OBJS := hmix_gm.o kinds_mod.o hmix_gm_submeso_share.o blocks.o domain_size.o time_management.o grid.o io.o constants.o POP_KindsMod.o kernel_driver.o kgen_utils.o tprof_mod.o

build: ${ALL_OBJS}
	${FC_0} ${FC_FLAGS_SET_0} -o kernel.exe $^  

run: build
	mpirun -np 2 ./kernel.exe

hmix_gm.o: hmix_gm.F90 kinds_mod.o hmix_gm_submeso_share.o blocks.o domain_size.o time_management.o grid.o io.o constants.o POP_KindsMod.o kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kinds_mod.o: aux_modules/kinds_mod.F90 kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

hmix_gm_submeso_share.o: aux_modules/hmix_gm_submeso_share.F90 kgen_utils.o tprof_mod.o kinds_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

blocks.o: aux_modules/blocks.F90 kgen_utils.o tprof_mod.o kinds_mod.o domain_size.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

domain_size.o: aux_modules/domain_size.F90 kgen_utils.o tprof_mod.o kinds_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

time_management.o: aux_modules/time_management.F90 kgen_utils.o tprof_mod.o io.o domain_size.o grid.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

grid.o: aux_modules/grid.F90 kgen_utils.o tprof_mod.o POP_KindsMod.o io.o domain_size.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

io.o: aux_modules/io.F90 kgen_utils.o tprof_mod.o constants.o blocks.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

constants.o: aux_modules/constants.F90 kgen_utils.o tprof_mod.o kinds_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

POP_KindsMod.o: aux_modules/POP_KindsMod.F90 kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kernel_driver.o: aux_modules/kernel_driver.F90 hmix_gm.o kinds_mod.o hmix_gm_submeso_share.o blocks.o domain_size.o time_management.o grid.o io.o constants.o POP_KindsMod.o kgen_utils.o tprof_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kgen_utils.o: aux_modules/kgen_utils.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

tprof_mod.o: aux_modules/tprof_mod.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

clean:
	rm -f kernel.exe *.mod ${ALL_OBJS}
