/*
** git $Id$
** svn $Id: upwelling.h 1099 2022-01-06 21:01:01Z arango $
*******************************************************************************
** Copyright (c) 2002-2022 The ROMS/TOMS Group                               **
**   Licensed under a MIT/X style license                                    **
**   See License_ROMS.txt                                                    **
*******************************************************************************
**
** Options for Upwelling Test.
**
** Application flag:   UPWELLING
** Input script:       roms_upwelling.in
*/

#define UV_ADV
#define UV_COR
#define UV_LDRAG
#define UV_VIS2
#undef  MIX_GEO_UV
#define MIX_S_UV
#undef TS_U3HADVECTION
#undef TS_C4VADVECTION
#define  TS_MPDATA
#define DJ_GRADPS
#define TS_DIF2
#undef  TS_DIF4
#undef  MIX_GEO_TS
#define MIX_S_TS

#define SALINITY
#define SOLVE3D
#define SPLINES_VDIFF
#define SPLINES_VVISC
#undef AVERAGES
#undef DIAGNOSTICS_TS
#undef DIAGNOSTICS_UV

#undef ANA_GRID
#undef ANA_INITIAL
#undef ANA_SMFLUX
#define ANA_STFLUX
#define ANA_SSFLUX
#define ANA_BTFLUX
#define ANA_BSFLUX

#if defined GLS_MIXING || defined MY25_MIXING
# define KANTHA_CLAYSON
# define N2S2_HORAVG
#else
# define ANA_VMIX
#endif

#undef ANA_BIOLOGY
#define BIO_FENNEL

#ifdef BIO_FENNEL
# undef CARBON
# define DENITRIFICATION
# define BIO_SEDIMENT
# undef DIAGNOSTICS_BIO
# define ANA_SPFLUX
# define ANA_BPFLUX
# define ANA_SRFLUX
#endif
