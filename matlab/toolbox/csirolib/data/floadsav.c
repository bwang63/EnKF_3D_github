/*
 * FLOADSAV.C: Fortran-callable C-Language routines for reading and
 * writing MATLAB binary MAT-files.
 * MSAVE and MLOAD do NOT do any of the type and machine conversions
 * possible with MATLAB itself.  Consequently, these programs should
 * be run on the same machine as MATLAB.
 * See FLOADXX.F and FSAVEXX.F for examples.
 *
 *    SUBROUTINE MOPEN (fname, mode, ierr)
 *    SUBROUTINE MCLOSE ( )
 *    SUBROUTINE MSAVE (type, mname, m, n, imagf, XR, XI)
 *    SUBROUTINE MLOAD (type, mname, m, n, imagf, XR, XI)
 *
 *    Input arguments for MOPEN:
 *
 *    fname     character* (<=24),
 *              the file name.
 *
 *    mode      character* (<=2),
 *              'r'   open for reading,
 *              'w'   truncate or create for writing,
 *              'a'   append: open or create for writing at end of file,
 *              'r+'  open for update (reading and writing),
 *              'w+'  truncate or create for update,
 *              'a+'  append; open or create for update at end of file.
 *
 *    Output argument for MOPEN:
 *
 *    ierr      integer.
 *              0     open successful,
 *              < 0   input strings too long,
 *              > 0   open fails, perhaps because file does not exist.
 *
 *
 *    Input arguments for MSAVE:
 *    Output argument for MLOAD:
 *
 *    type      integer.
 *              The only legal input value of "type" is:
 *
 *                 0  for PC's and other machines with Intel byte order,
 *              1000  for Sun's and other machines with Motorola byte order,
 *              2000  for VAX D-float, 3000 for VAX G-float.
 *
 *              MLOAD returns type >= 0 if it succeeds.
 *              MLOAD returns type = -1 if the file has been emptied.
 *              MLOAD returns type < -1 if any of the freads fail.
 *
 *    mname     character* (<=24),
 *              the matrix name.
 *
 *    m         integer,
 *              number of rows.
 *
 *    n         integer,
 *              number of columns.
 *
 *    imagf     integer,
 *              0        matrix is real,
 *              nonzero  matrix is not real.
 *
 *    XR        real*8 (m*n),
 *              the real part of the matrix,
 *              must be stored contiguously in memory.
 *
 *    XI        real*8 (m*n),
 *              the real part of the matrix,
 *              must be stored contiguously in memory,
 *              not referenced if imagf is zero.
 *
 * These routines follow Chapter 11 (The C-Fortran Interface)
 * of the Sun Fortran Programmer's Guide (Revision A, May, 1988).
 * Each Fortran character argument is referenced by its string
 * pointer, plus its length PASSED BY VALUE.  The lengths are
 * are placed at the end of the argument list, in the same order
 * as the character arguments themselves.
 *
 * Most Unix-based computers should be able to use these routines
 * with perhaps slight modifications.  This file known to work on
 * Sun and HP workstations.
 *
 * This version dated 2/13/90 by CBM.
 * Copyright (c) The MathWorks, Inc., 1989.
 */
#include <stdio.h>
#include <string.h>
#ifndef VMS
/*#include <io.h>*/
#endif
#include <errno.h>

typedef struct {
     long type;   /* type */
     long mrows;  /* row dimension */
     long ncols;  /* column dimension */
     long imagf;  /* flag indicating imag part */
     long namlen; /* name length (including NULL) */
} Fmatrix;

static FILE* fp = (FILE *) 0;

/* 
 * Choose computer type: 
 */

/* Define the following for non-386i Sun workstations: */
#undef SUN

/* Define the following for Sun386i workstations: */
#undef SUN386

/* Define the following for HP workstations: */
#undef HP

/* Define the following for PC's: */
#undef PC

/* Define the following for 386 PC's: */
#undef PC386

/* Define the following for SGI: */
#define SGI

#ifdef SUN
#define	MOPEN	mopen_
#define MCLOSE	mclose_
#define	MSAVE	msave_
#define	MLOAD	mload_
#define MTYPE   1000
#endif

#ifdef SUN386
#define	MOPEN	mopen_
#define MCLOSE	mclose_
#define	MSAVE	msave_
#define	MLOAD	mload_
#define MTYPE   0
#endif

#ifdef HP
#define	MOPEN	mopen
#define MCLOSE	mclose
#define	MSAVE	msave
#define	MLOAD	mload
#define MTYPE   1000
#endif

#ifdef PC
#define MTYPE   0
#endif

#ifdef PC386
#define	MOPEN	_mopen_
#define MCLOSE	_mclose_
#define	MSAVE	_msave_
#define	MLOAD	_mload_
#define MTYPE   0
#endif

#ifdef VMS
#include <descrip.h>
#define MOPEN	mopen
#define MCLOSE	mclose
#define MSAVE	msave
#define MLOAD	mload
#if CC$gfloat==1
#define MTYPE	3000
#else
#define MTYPE	2000
#endif
#endif /* VMS */

#ifdef SGI
#define	MOPEN	mopen_
#define MCLOSE	mclose_
#define	MSAVE	msave_
#define	MLOAD	mload_
#define MTYPE   1000
#endif

#ifdef apollo	/* APOLLO is predefined as apollo for all Apollos */
#define	MOPEN	mopen_
#define MCLOSE	mclose_
#define	MSAVE	msave_
#define	MLOAD	mload_
#define MTYPE   1000
#endif

/* MOPEN: Open MAT-file for read, write, or append. */

MOPEN(f_fname, f_mode, ierr, f_fname_len, f_mode_len)

char *f_fname, *f_mode;
long *ierr;
long f_fname_len, f_mode_len;	/*	Pass by value.	*/

{
	char c_fname[25], c_mode[3];

#ifdef VMS
	/* VMS doesn't pass FORTRAN strings like UNIX does.
	   It doesn't pass the lengths as parameters so f_fname_len
	   and f_mode_len aren't really passed, they are just dummy
	   parameters.  Here is where they are actually set. */

	f_fname_len = ((struct dsc$descriptor_s *)f_fname)->dsc$w_length;
	f_mode_len = ((struct dsc$descriptor_s *)f_mode)->dsc$w_length;
#endif

	if (f_fname_len > 24 || f_mode_len > 2)	{
		printf("\nError using MOPEN: ");
		printf("length(fname) > 24 or length(fmode) > 2\n");
		*ierr = -1;
		return;
	}
	
	strF2C(c_fname, f_fname, f_fname_len);
	strF2C(c_mode, f_mode, f_mode_len);

#ifdef PC
	if (strncmp(c_mode, "r", 1) == 0)
		strcpy(c_mode, "rb");
	if (strncmp(c_mode, "w", 1) == 0)
		strcpy(c_mode, "wb");
#endif /* PC */
#ifdef PC386
	if (strncmp(c_mode, "r", 1) == 0)
		strcpy(c_mode, "rb");
	if (strncmp(c_mode, "w", 1) == 0)
		strcpy(c_mode, "wb");
#endif /* PC386 */
#ifdef VMS
	{
	  char c_modetmp[5];

	  strcpy(c_modetmp,c_mode);
	  if (!strchr(c_mode, 'b'))
	    strcat(c_modetmp,"b");
	  fp = fopen(c_fname, c_modetmp, "rfm=var");
	}
#else
	fp = fopen(c_fname, c_mode);
#endif /* VMS */
	
	if (!fp) {
		printf("\nError using MOPEN: ");
		printf("Cannot open file %s with mode %s.\n",c_fname,c_mode);
		*ierr = 1;
		return;
	}
	
	*ierr = 0;
	return;
}


/* MCLOSE: Close the open MAT-file */

MCLOSE()

{
	if (fclose(fp)) {
		printf("\nError using MCLOSE: ");
		printf("fclose fails\n");
		return;
	}
	
	return;
}


/* MSAVE: Save one matrix to a MAT-file. */

MSAVE(type, f_name, mrows, ncols, imagf, preal, pimag, f_name_len)
			 
long *type;
char *f_name;
long *mrows, *ncols, *imagf;
double *preal, *pimag;
long f_name_len;	/*	Pass by value.	*/

{
	Fmatrix x;
	char c_name[25];
	int mn;

	strF2C(c_name, f_name, f_name_len);
	
	if (*type != MTYPE) {
		printf("\nWarning using MSAVE: ");
		printf("type = %d should be = %d\n",type,MTYPE);
	}
	x.type = MTYPE;
	x.mrows = *mrows;
	x.ncols = *ncols;
	x.imagf = *imagf;
	x.namlen = strlen(c_name) + 1;
	mn = x.mrows * x.ncols;

	if(fwrite(&x, sizeof(Fmatrix), 1, fp) !=1 )
		printf("Error writing Fmatrix.\n");
	if(fwrite(c_name, sizeof(char), (int)x.namlen, fp) != (int)x.namlen)
		printf("Error writing name.\n");
	if(fwrite((char *)preal, sizeof(double), mn, fp) != mn)
		printf("Error writing data.\n");
	if (*imagf) {
		fwrite((char *)pimag, sizeof(double), mn, fp);
	}
	
	return;
}


/* MLOAD: Load next matrix from MAT-file. */

MLOAD(type, f_name, mrows, ncols, imagf, preal, pimag, f_name_len)

long *type;
char *f_name;
long *mrows, *ncols, *imagf;
double *preal, *pimag;
long f_name_len;	/*	Pass by value.	*/

{
	Fmatrix x;
	char c_name[25];
	int mn;

	/*
	 * Get Fmatrix structure from file
	 * If file is empty, return negative type 
	 */
	if (fread((char *)&x, sizeof(Fmatrix), 1, fp) != 1) {
		*type = -1;
		return;
	}
	*type = x.type;
	*mrows = x.mrows;
	*ncols = x.ncols;
	*imagf = x.imagf;
	mn = x.mrows * x.ncols;
	if (*type != MTYPE) {
		printf("\nError using MLOAD: ");
		printf("type = %d should be = %d\n",type,MTYPE);
		*type = -2;
		return;
	}

	/*
	 * Get matrix name from file
	 */
	if (fread(c_name, sizeof(char), x.namlen, fp) != x.namlen) {
		printf("\nError using MLOAD: ");
		printf("fread of matrix name fails\n");
		*type = -3;
		return;
	}
	strC2F(f_name, f_name_len, c_name);
	
	/*
	 * Get Real part of matrix from file
	 */

	if (fread(preal, sizeof(double), mn, fp) != mn) {
		printf("\nError using MLOAD: ");
		printf("fread of real part fails\n");
		*type = -4;
		return;
	}

	/*
	 * Get Imag part of matrix from file, if it exists
	 */
	if (x.imagf) {
		if (fread(pimag, sizeof(double), mn, fp) != mn) {
			printf("\nError using MLOAD: ");
			printf("fread of imaginary part fails\n");
			*type = -5;
			return;
		}
	}
	return;
}


#ifdef VMS
/* strF2C: Convert Fortran string to C string. */

strF2C(c_str, f_str, f_str_len)

char *c_str;
struct dsc$descriptor_s *f_str;
long f_str_len;                    /* Dummy parameter, not used */

{
	int k;

	/* Find last nonblank */
	k = f_str->dsc$w_length;
	while (k > 0 && *(f_str->dsc$a_pointer + k - 1) == ' ') {
		k--;
	}

	/* Copy and terminate with a null */
	strncpy(c_str, f_str->dsc$a_pointer, k);
	*(c_str + k) = '\0';

	return;
}


/* strC2F: Convert C string to Fortran string. */

strC2F(f_str, f_str_len, c_str)

char *c_str;
long f_str_len;                    /* Dummy parameter, not used */
struct dsc$descriptor_s *f_str;

{
	int k;

	/* Blank entire Fortran storage */
	for (k = 0; k < f_str->dsc$w_length; k++) {
		*(f_str->dsc$a_pointer + k) = ' ';
	}

	/* Copy up to, but not including, null terminator. */
	strncpy(f_str->dsc$a_pointer, c_str, strlen(c_str));
	
	return;
}

#else

/* strF2C: Convert Fortran string to C string. */

strF2C(c_str, f_str, f_str_len)

char *c_str, *f_str;
long f_str_len;

{
	int k;

	/* Find last nonblank */
	k = f_str_len;
	while (k > 0 && *(f_str + k - 1) == ' ') {
		k--;
	}

	/* Copy and terminate with a null */
	strncpy(c_str, f_str, k);
	*(c_str + k) = '\0';
	
	return;
}


/* strC2F: Convert C string to Fortran string. */

strC2F(f_str, f_str_len, c_str)

char *f_str, *c_str;
long f_str_len;

{
	int k;

	/* Blank entire Fortran storage */
	for (k = 0; k < f_str_len; k++)	{
		*(f_str + k) = ' ';
	}

	/* Copy up to, but not including, null terminator. */
	strncpy(f_str, c_str, strlen(c_str));
	
	return;
}
#endif /* VMS */
