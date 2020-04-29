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

clean:
	rm -rf *.mod *.o *~ main
