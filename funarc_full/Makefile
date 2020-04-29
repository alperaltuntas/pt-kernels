# kgen
KGEN := /glade/work/altuntas/KGen/bin/kgen
CALLSITE := funarc_mod.f90

# compilers
CC = gcc 
FC = gfortran 
CFLAGS = 
FFLAGS = -ffree-line-length-none
LOGGING_PATH=$(CORVETTE_PATH)/logging

default: main

main: main.f90 funarc_mod
	$(FC) -c $(FFLAGS) main.f90
	$(FC) -o main main.o funarc_mod.o
  
funarc_mod: funarc_mod.f90
	$(FC) -c $(FFLAGS) funarc_mod.f90

kernel:
	${KGEN} \
    --cmd-clean "make clean" \
    --cmd-build "make" \
    --cmd-run "./main" \
    ${CALLSITE}

clean:
	rm -rf *.mod *.o *~ main kernel
clobber:
	rm -rf *.mod *.o *~ main kernel state kgen.log _kgen_compflag_cmdwrapper.sh strace.log include.ini model model.ini elapsedtime coverage papi
