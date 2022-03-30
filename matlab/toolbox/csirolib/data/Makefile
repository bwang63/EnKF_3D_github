
# organ/public/matlab/user_notes/Makefile
#
# For making f77 programs to read/write matlab format.
# Only example programs.  Users should modify as desired.
#

floadmat:	floadmat.f floadsav.o
	f77 -o floadmat floadmat.f floadsav.o

fsavemat:	fsavemat.f floadsav.o
	f77 -o fsavemat fsavemat.f floadsav.o

floadsav:	floadsav.c
	cc -c floadsav.c

clean:
	-rm *~ *% *.o
