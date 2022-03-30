/*	@(#)gshhs.c	1.1  05/18/99
 *
 * PROGRAM:	gshhs.c
 * AUTHOR:	Paul Wessel (wessel@soest.hawaii.edu)
 * CREATED:	JAN. 28, 1996
 * PURPOSE:	To extract ASCII data from binary shoreline data
 *		as described in the 1996 Wessel & Smith JGR Data Analysis Note.
 * VERSION:	1.1 (Byte flipping added)
 *		1.2 18-MAY-1999:
 *		   Explicit binary open for DOS systems
 *		   POSIX.1 compliant
 */

#include "gshhs.h"

main (int argc, char **argv)
{
	double w, e, s, n, area, lon, lat;
	char source;
	FILE	*fp;
	int	k, max_east = 270000000;
	struct	POINT p;
	struct GSHHS h;
        
	if (argc != 2) {
		fprintf (stderr, "usage:  gshhs gshhs_[f|h|i|l|c].b > ascii.dat\n");
		exit (EXIT_FAILURE);
	}
	
	if ((fp = fopen (argv[1], "rb")) == NULL ) {
		fprintf (stderr, "gshhs:  Could not find file %s.\n", argv[1]);
		exit (EXIT_FAILURE);
	}
		
	while (fread((void *)&h, (size_t)sizeof (struct GSHHS), (size_t)1, fp) == 1) {

#ifdef FLIP
		h.id = swabi4 ((unsigned int)h.id);
		h.n = swabi4 ((unsigned int)h.n);
		h.level = swabi4 ((unsigned int)h.level);
		h.west = swabi4 ((unsigned int)h.west);
		h.east = swabi4 ((unsigned int)h.east);
		h.south = swabi4 ((unsigned int)h.south);
		h.north = swabi4 ((unsigned int)h.north);
		h.area = swabi4 ((unsigned int)h.area);
		h.greenwich = swabi2 ((unsigned int)h.greenwich);
		h.source = swabi2 ((unsigned int)h.source);
#endif
		w = h.west  * 1.0e-6;
		e = h.east  * 1.0e-6;
		s = h.south * 1.0e-6;
		n = h.north * 1.0e-6;
		source = (h.source == 1) ? 'W' : 'C';
		area = 0.1 * h.area;

		printf ("P %6d%8d%2d%2c%13.3lf%10.5lf%10.5lf%10.5lf%10.5lf\n", h.id, h.n, h.level, source, area, w, e, s, n);

		for (k = 0; k < h.n; k++) {

			if (fread ((void *)&p, (size_t)sizeof(struct POINT), (size_t)1, fp) != 1) {
				fprintf (stderr, "gshhs:  Error reading file %s for polygon %d, point %d.\n", argv[1], h.id, k);
				exit (EXIT_FAILURE);
			}
#ifdef FLIP
			p.x = swabi4 ((unsigned int)p.x);
			p.y = swabi4 ((unsigned int)p.y);
#endif
			lon = (h.greenwich && p.x > max_east) ? p.x * 1.0e-6 - 360.0 : p.x * 1.0e-6;
			lat = p.y * 1.0e-6;
			printf ("%10.5lf%10.5lf\n", lon, lat);
		}
		max_east = 180000000;	/* Only Eurasiafrica needs 270 */
	}
		
	fclose (fp);

	exit (EXIT_SUCCESS);
}
