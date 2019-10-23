# Makefile for KGEN-generated kernel

# Originally used compiler(s)
FC_0 := gfortran
FC_FLAGS_SET_0 := -fcray-pointer -fdefault-double-8 -fdefault-real-8 -ffree-line-length-none -fno-range-check -O0 -cpp

ALL_OBJS := MOM_EOS_Wright.o kernel_driver.o kgen_utils.o tprof_mod.o target_subroutine_mod.o

build: ${ALL_OBJS}
	${FC_0} ${FC_FLAGS_SET_0} -o kernel.exe $^  

run: build
	mpirun -np 2 ./kernel.exe

MOM_EOS_Wright.o: aux_modules/MOM_EOS_Wright.F90 kgen_utils.o tprof_mod.o target_subroutine_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kernel_driver.o: aux_modules/kernel_driver.f90 MOM_EOS_Wright.o kgen_utils.o tprof_mod.o target_subroutine_mod.o
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

kgen_utils.o: aux_modules/kgen_utils.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

tprof_mod.o: aux_modules/tprof_mod.f90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

target_subroutine_mod.o: target_subroutine.F90
	${FC_0} ${FC_FLAGS_SET_0} -c -o $@ $<

clean:
	rm -f kernel.exe *.mod ${ALL_OBJS} *.lst
