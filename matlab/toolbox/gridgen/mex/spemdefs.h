c  precision stuff
#define DOUBLE		/* for double precision on non-crays */

#ifdef cray
#undef DOUBLE
#define BIGREAL    real
#define SMALLREAL  real
#define BIGCOMPLEX complex
#else
#ifdef DOUBLE
#define BIGREAL    real*8
#define BIGCOMPLEX complex*16
#else
#define BIGREAL    real*4
#define BIGCOMPLEX complex
#endif  /DOUBLE */
#define SMALLREAL  real*4
#endif  /* cray */
