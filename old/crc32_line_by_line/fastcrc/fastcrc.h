/*
 * Fast CRC include file.
 *
 * Version 1.00 (Unix)
 *
 * Copyright 1999 G. Adam Stanislav.
 * All rights reserved.
 *
 * You may use these routines in your programs freely
 * as long as you give me credit for them.
 *
 * See comments in fastcrc.asm for proper usage.
 */
#ifndef	FASTCRC_H
#define	FASTCRC_H

#include <sys/types.h>

typedef	u_int32_t	crc_t;

crc_t ecrc(crc_t const, unsigned char const);
crc_t pcrc(crc_t const, unsigned char const);
#ifdef	NOCRCMACROS
crc_t ecrcinit(void);
crc_t pcrcinit(void);
crc_t ecrcfinish(crc_t const);
#else
#define	ecrcinit()	(~0)
#define	pcrcinit()	(0)
#define	ecrcfinish(x)	(~x)
#endif
crc_t pcrcfinish(crc_t const, unsigned int const);
crc_t ecrcarray(unsigned char const * const, unsigned int const);
crc_t pcrcarray(unsigned char const * const, unsigned int const);
crc_t ecrcpartial(crc_t const, unsigned char const * const, unsigned int const);
crc_t pcrcpartial(crc_t const, unsigned char const * const, unsigned int const);
#endif

