;; Copyright (c) 1999 G. Adam Stanislav
;; All rights reserved.
;;
;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:
;; 1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.
;; 2. Redistributions in binary form must reproduce the above copyright
;;    notice, this list of conditions and the following disclaimer in the
;;    documentation and/or other materials provided with the distribution.
;;
;; THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
;; ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
;; ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
;; FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;; DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
;; OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;; HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;; LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
;; OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
;; SUCH DAMAGE.
;;
;;	crc.asm v. 1.0, 1999-04-26


;; Fast CRC-32 routines for Unix running on i386 or better.
;;
;; Version 1.0 (Unix/nasm).
;;
;; These routines were originally written as a Windows 95 DLL.
;; Thanks to NASM, I have now ported them to Unix. I have changed
;; the names of the functions to start with "ecrc". This, to
;; make sure no confusion arises when other CRC libraries may
;; be present on the system. The 'e' stands for Ethernet, since
;; Ethernet uses this traditional CRC-32.
;;
;; I have added additional routines not found in the original
;; Windows DLL. These functions start with "pcrc". The 'p' stands
;; for POSIX 1003.2.
;;
;; Except for the initial 'e' or 'p', most function names and their
;; functionality are identical (but using two different polynomials).
;; I will, therefore, use a question mark in this comment section to
;; indicate 'e' or 'p'.
;;
;; If you have any comments, reach me at adam@whizkidtech.net.
;;
;; Note that to calculate 'e' CRC-32 of any string of bytes, you need to
;; start with an initial value of CRC = 0xFFFFFFFF (-1, 32-bits). For
;; 'p' CRC you need to start with CRC = 0.
;;
;; The ?crcinit() functions do nothing but return those values.
;;
;; Then, for each byte, you need to call ?crc(oldcrc, abyte).
;;
;; Finally, you need to "not" the result. This is accomplished
;; by calling ecrcfinish(lastcrc) with the traditional crc.
;;
;; With the POSIX crc, you need to need to include the size of
;; data in bytes in your crc calculation, and only then "not" it.
;; The pcrcfinish(lastcrc, numbytes) will do it for you.
;;
;; The ?crcinit and ecrcfinish functions really do not require
;; the power of assembly language. They are listed here for completeness
;; only. But in the enclosed fastcrc.h file they are declared as macros.
;; If you prefer not to use the macros, define NOCRCMACROS before
;; including fastcrc.h.
;;
;; Two additional functions are provided: ?crcpartial and ?crcarray.
;;
;; ?crcarray, calculates the CRC-32 of a complete array of bytes.
;; This one does NOT require the use of ?crcinit and ?crcfinish.
;; Use it when you have all the data you want to get CRC-32 of
;; in a single buffer.
;;
;; ?crcpartial is used when chunks of data are available at any one time.
;; You need to use ?crcinit before you call it for the first time, and
;; ?crcfinish after the last call.
;;
;; Note that each function seems to have four names. That is because
;; so many standards have evolved over the years. Pascal, Fortran, and
;; some other languages convert function names into capital letters,
;; push parameters from left to right, and expect the function to clean up
;; the stack.
;;
;; C and its derivatives push parameters from right to left and expect the
;; caller to clean up the stack. Plus, C used to prepend each function name
;; with an underscore. Some implementations still do, but C compilers for ELF
;; do not.
;;
;; And, of course, assembly language programs have no standards, but they
;; usually pass parameters in registers. I am using dotted names for that.
;;
;; The ENTRY and EXIT comments are for the sake of assembly language
;; programs that wish to call the "dotted" routines directly.
bits	32

section .text
align	16, db 0

; A look-up table is what makes this so fast.
crctable:
	dd	0x00000000
	dd	0x77073096
	dd	0xee0e612c
	dd	0x990951ba
	dd	0x076dc419
	dd	0x706af48f
	dd	0xe963a535
	dd	0x9e6495a3
	dd	0x0edb8832
	dd	0x79dcb8a4
	dd	0xe0d5e91e
	dd	0x97d2d988
	dd	0x09b64c2b
	dd	0x7eb17cbd
	dd	0xe7b82d07
	dd	0x90bf1d91
	dd	0x1db71064
	dd	0x6ab020f2
	dd	0xf3b97148
	dd	0x84be41de
	dd	0x1adad47d
	dd	0x6ddde4eb
	dd	0xf4d4b551
	dd	0x83d385c7
	dd	0x136c9856
	dd	0x646ba8c0
	dd	0xfd62f97a
	dd	0x8a65c9ec
	dd	0x14015c4f
	dd	0x63066cd9
	dd	0xfa0f3d63
	dd	0x8d080df5
	dd	0x3b6e20c8
	dd	0x4c69105e
	dd	0xd56041e4
	dd	0xa2677172
	dd	0x3c03e4d1
	dd	0x4b04d447
	dd	0xd20d85fd
	dd	0xa50ab56b
	dd	0x35b5a8fa
	dd	0x42b2986c
	dd	0xdbbbc9d6
	dd	0xacbcf940
	dd	0x32d86ce3
	dd	0x45df5c75
	dd	0xdcd60dcf
	dd	0xabd13d59
	dd	0x26d930ac
	dd	0x51de003a
	dd	0xc8d75180
	dd	0xbfd06116
	dd	0x21b4f4b5
	dd	0x56b3c423
	dd	0xcfba9599
	dd	0xb8bda50f
	dd	0x2802b89e
	dd	0x5f058808
	dd	0xc60cd9b2
	dd	0xb10be924
	dd	0x2f6f7c87
	dd	0x58684c11
	dd	0xc1611dab
	dd	0xb6662d3d
	dd	0x76dc4190
	dd	0x01db7106
	dd	0x98d220bc
	dd	0xefd5102a
	dd	0x71b18589
	dd	0x06b6b51f
	dd	0x9fbfe4a5
	dd	0xe8b8d433
	dd	0x7807c9a2
	dd	0x0f00f934
	dd	0x9609a88e
	dd	0xe10e9818
	dd	0x7f6a0dbb
	dd	0x086d3d2d
	dd	0x91646c97
	dd	0xe6635c01
	dd	0x6b6b51f4
	dd	0x1c6c6162
	dd	0x856530d8
	dd	0xf262004e
	dd	0x6c0695ed
	dd	0x1b01a57b
	dd	0x8208f4c1
	dd	0xf50fc457
	dd	0x65b0d9c6
	dd	0x12b7e950
	dd	0x8bbeb8ea
	dd	0xfcb9887c
	dd	0x62dd1ddf
	dd	0x15da2d49
	dd	0x8cd37cf3
	dd	0xfbd44c65
	dd	0x4db26158
	dd	0x3ab551ce
	dd	0xa3bc0074
	dd	0xd4bb30e2
	dd	0x4adfa541
	dd	0x3dd895d7
	dd	0xa4d1c46d
	dd	0xd3d6f4fb
	dd	0x4369e96a
	dd	0x346ed9fc
	dd	0xad678846
	dd	0xda60b8d0
	dd	0x44042d73
	dd	0x33031de5
	dd	0xaa0a4c5f
	dd	0xdd0d7cc9
	dd	0x5005713c
	dd	0x270241aa
	dd	0xbe0b1010
	dd	0xc90c2086
	dd	0x5768b525
	dd	0x206f85b3
	dd	0xb966d409
	dd	0xce61e49f
	dd	0x5edef90e
	dd	0x29d9c998
	dd	0xb0d09822
	dd	0xc7d7a8b4
	dd	0x59b33d17
	dd	0x2eb40d81
	dd	0xb7bd5c3b
	dd	0xc0ba6cad
	dd	0xedb88320
	dd	0x9abfb3b6
	dd	0x03b6e20c
	dd	0x74b1d29a
	dd	0xead54739
	dd	0x9dd277af
	dd	0x04db2615
	dd	0x73dc1683
	dd	0xe3630b12
	dd	0x94643b84
	dd	0x0d6d6a3e
	dd	0x7a6a5aa8
	dd	0xe40ecf0b
	dd	0x9309ff9d
	dd	0x0a00ae27
	dd	0x7d079eb1
	dd	0xf00f9344
	dd	0x8708a3d2
	dd	0x1e01f268
	dd	0x6906c2fe
	dd	0xf762575d
	dd	0x806567cb
	dd	0x196c3671
	dd	0x6e6b06e7
	dd	0xfed41b76
	dd	0x89d32be0
	dd	0x10da7a5a
	dd	0x67dd4acc
	dd	0xf9b9df6f
	dd	0x8ebeeff9
	dd	0x17b7be43
	dd	0x60b08ed5
	dd	0xd6d6a3e8
	dd	0xa1d1937e
	dd	0x38d8c2c4
	dd	0x4fdff252
	dd	0xd1bb67f1
	dd	0xa6bc5767
	dd	0x3fb506dd
	dd	0x48b2364b
	dd	0xd80d2bda
	dd	0xaf0a1b4c
	dd	0x36034af6
	dd	0x41047a60
	dd	0xdf60efc3
	dd	0xa867df55
	dd	0x316e8eef
	dd	0x4669be79
	dd	0xcb61b38c
	dd	0xbc66831a
	dd	0x256fd2a0
	dd	0x5268e236
	dd	0xcc0c7795
	dd	0xbb0b4703
	dd	0x220216b9
	dd	0x5505262f
	dd	0xc5ba3bbe
	dd	0xb2bd0b28
	dd	0x2bb45a92
	dd	0x5cb36a04
	dd	0xc2d7ffa7
	dd	0xb5d0cf31
	dd	0x2cd99e8b
	dd	0x5bdeae1d
	dd	0x9b64c2b0
	dd	0xec63f226
	dd	0x756aa39c
	dd	0x026d930a
	dd	0x9c0906a9
	dd	0xeb0e363f
	dd	0x72076785
	dd	0x05005713
	dd	0x95bf4a82
	dd	0xe2b87a14
	dd	0x7bb12bae
	dd	0x0cb61b38
	dd	0x92d28e9b
	dd	0xe5d5be0d
	dd	0x7cdcefb7
	dd	0x0bdbdf21
	dd	0x86d3d2d4
	dd	0xf1d4e242
	dd	0x68ddb3f8
	dd	0x1fda836e
	dd	0x81be16cd
	dd	0xf6b9265b
	dd	0x6fb077e1
	dd	0x18b74777
	dd	0x88085ae6
	dd	0xff0f6a70
	dd	0x66063bca
	dd	0x11010b5c
	dd	0x8f659eff
	dd	0xf862ae69
	dd	0x616bffd3
	dd	0x166ccf45
	dd	0xa00ae278
	dd	0xd70dd2ee
	dd	0x4e048354
	dd	0x3903b3c2
	dd	0xa7672661
	dd	0xd06016f7
	dd	0x4969474d
	dd	0x3e6e77db
	dd	0xaed16a4a
	dd	0xd9d65adc
	dd	0x40df0b66
	dd	0x37d83bf0
	dd	0xa9bcae53
	dd	0xdebb9ec5
	dd	0x47b2cf7f
	dd	0x30b5ffe9
	dd	0xbdbdf21c
	dd	0xcabac28a
	dd	0x53b39330
	dd	0x24b4a3a6
	dd	0xbad03605
	dd	0xcdd70693
	dd	0x54de5729
	dd	0x23d967bf
	dd	0xb3667a2e
	dd	0xc4614ab8
	dd	0x5d681b02
	dd	0x2a6f2b94
	dd	0xb40bbe37
	dd	0xc30c8ea1
	dd	0x5a05df1b
	dd	0x2d02ef8d

posixcrctable:
	dd	0x00000000
	dd	0x04c11db7
	dd	0x09823b6e
	dd	0x0d4326d9
	dd	0x130476dc
	dd	0x17c56b6b
	dd	0x1a864db2
	dd	0x1e475005
	dd	0x2608edb8
	dd	0x22c9f00f
	dd	0x2f8ad6d6
	dd	0x2b4bcb61
	dd	0x350c9b64
	dd	0x31cd86d3
	dd	0x3c8ea00a
	dd	0x384fbdbd
	dd	0x4c11db70
	dd	0x48d0c6c7
	dd	0x4593e01e
	dd	0x4152fda9
	dd	0x5f15adac
	dd	0x5bd4b01b
	dd	0x569796c2
	dd	0x52568b75
	dd	0x6a1936c8
	dd	0x6ed82b7f
	dd	0x639b0da6
	dd	0x675a1011
	dd	0x791d4014
	dd	0x7ddc5da3
	dd	0x709f7b7a
	dd	0x745e66cd
	dd	0x9823b6e0
	dd	0x9ce2ab57
	dd	0x91a18d8e
	dd	0x95609039
	dd	0x8b27c03c
	dd	0x8fe6dd8b
	dd	0x82a5fb52
	dd	0x8664e6e5
	dd	0xbe2b5b58
	dd	0xbaea46ef
	dd	0xb7a96036
	dd	0xb3687d81
	dd	0xad2f2d84
	dd	0xa9ee3033
	dd	0xa4ad16ea
	dd	0xa06c0b5d
	dd	0xd4326d90
	dd	0xd0f37027
	dd	0xddb056fe
	dd	0xd9714b49
	dd	0xc7361b4c
	dd	0xc3f706fb
	dd	0xceb42022
	dd	0xca753d95
	dd	0xf23a8028
	dd	0xf6fb9d9f
	dd	0xfbb8bb46
	dd	0xff79a6f1
	dd	0xe13ef6f4
	dd	0xe5ffeb43
	dd	0xe8bccd9a
	dd	0xec7dd02d
	dd	0x34867077
	dd	0x30476dc0
	dd	0x3d044b19
	dd	0x39c556ae
	dd	0x278206ab
	dd	0x23431b1c
	dd	0x2e003dc5
	dd	0x2ac12072
	dd	0x128e9dcf
	dd	0x164f8078
	dd	0x1b0ca6a1
	dd	0x1fcdbb16
	dd	0x018aeb13
	dd	0x054bf6a4
	dd	0x0808d07d
	dd	0x0cc9cdca
	dd	0x7897ab07
	dd	0x7c56b6b0
	dd	0x71159069
	dd	0x75d48dde
	dd	0x6b93dddb
	dd	0x6f52c06c
	dd	0x6211e6b5
	dd	0x66d0fb02
	dd	0x5e9f46bf
	dd	0x5a5e5b08
	dd	0x571d7dd1
	dd	0x53dc6066
	dd	0x4d9b3063
	dd	0x495a2dd4
	dd	0x44190b0d
	dd	0x40d816ba
	dd	0xaca5c697
	dd	0xa864db20
	dd	0xa527fdf9
	dd	0xa1e6e04e
	dd	0xbfa1b04b
	dd	0xbb60adfc
	dd	0xb6238b25
	dd	0xb2e29692
	dd	0x8aad2b2f
	dd	0x8e6c3698
	dd	0x832f1041
	dd	0x87ee0df6
	dd	0x99a95df3
	dd	0x9d684044
	dd	0x902b669d
	dd	0x94ea7b2a
	dd	0xe0b41de7
	dd	0xe4750050
	dd	0xe9362689
	dd	0xedf73b3e
	dd	0xf3b06b3b
	dd	0xf771768c
	dd	0xfa325055
	dd	0xfef34de2
	dd	0xc6bcf05f
	dd	0xc27dede8
	dd	0xcf3ecb31
	dd	0xcbffd686
	dd	0xd5b88683
	dd	0xd1799b34
	dd	0xdc3abded
	dd	0xd8fba05a
	dd	0x690ce0ee
	dd	0x6dcdfd59
	dd	0x608edb80
	dd	0x644fc637
	dd	0x7a089632
	dd	0x7ec98b85
	dd	0x738aad5c
	dd	0x774bb0eb
	dd	0x4f040d56
	dd	0x4bc510e1
	dd	0x46863638
	dd	0x42472b8f
	dd	0x5c007b8a
	dd	0x58c1663d
	dd	0x558240e4
	dd	0x51435d53
	dd	0x251d3b9e
	dd	0x21dc2629
	dd	0x2c9f00f0
	dd	0x285e1d47
	dd	0x36194d42
	dd	0x32d850f5
	dd	0x3f9b762c
	dd	0x3b5a6b9b
	dd	0x0315d626
	dd	0x07d4cb91
	dd	0x0a97ed48
	dd	0x0e56f0ff
	dd	0x1011a0fa
	dd	0x14d0bd4d
	dd	0x19939b94
	dd	0x1d528623
	dd	0xf12f560e
	dd	0xf5ee4bb9
	dd	0xf8ad6d60
	dd	0xfc6c70d7
	dd	0xe22b20d2
	dd	0xe6ea3d65
	dd	0xeba91bbc
	dd	0xef68060b
	dd	0xd727bbb6
	dd	0xd3e6a601
	dd	0xdea580d8
	dd	0xda649d6f
	dd	0xc423cd6a
	dd	0xc0e2d0dd
	dd	0xcda1f604
	dd	0xc960ebb3
	dd	0xbd3e8d7e
	dd	0xb9ff90c9
	dd	0xb4bcb610
	dd	0xb07daba7
	dd	0xae3afba2
	dd	0xaafbe615
	dd	0xa7b8c0cc
	dd	0xa379dd7b
	dd	0x9b3660c6
	dd	0x9ff77d71
	dd	0x92b45ba8
	dd	0x9675461f
	dd	0x8832161a
	dd	0x8cf30bad
	dd	0x81b02d74
	dd	0x857130c3
	dd	0x5d8a9099
	dd	0x594b8d2e
	dd	0x5408abf7
	dd	0x50c9b640
	dd	0x4e8ee645
	dd	0x4a4ffbf2
	dd	0x470cdd2b
	dd	0x43cdc09c
	dd	0x7b827d21
	dd	0x7f436096
	dd	0x7200464f
	dd	0x76c15bf8
	dd	0x68860bfd
	dd	0x6c47164a
	dd	0x61043093
	dd	0x65c52d24
	dd	0x119b4be9
	dd	0x155a565e
	dd	0x18197087
	dd	0x1cd86d30
	dd	0x029f3d35
	dd	0x065e2082
	dd	0x0b1d065b
	dd	0x0fdc1bec
	dd	0x3793a651
	dd	0x3352bbe6
	dd	0x3e119d3f
	dd	0x3ad08088
	dd	0x2497d08d
	dd	0x2056cd3a
	dd	0x2d15ebe3
	dd	0x29d4f654
	dd	0xc5a92679
	dd	0xc1683bce
	dd	0xcc2b1d17
	dd	0xc8ea00a0
	dd	0xd6ad50a5
	dd	0xd26c4d12
	dd	0xdf2f6bcb
	dd	0xdbee767c
	dd	0xe3a1cbc1
	dd	0xe760d676
	dd	0xea23f0af
	dd	0xeee2ed18
	dd	0xf0a5bd1d
	dd	0xf464a0aa
	dd	0xf9278673
	dd	0xfde69bc4
	dd	0x89b8fd09
	dd	0x8d79e0be
	dd	0x803ac667
	dd	0x84fbdbd0
	dd	0x9abc8bd5
	dd	0x9e7d9662
	dd	0x933eb0bb
	dd	0x97ffad0c
	dd	0xafb010b1
	dd	0xab710d06
	dd	0xa6322bdf
	dd	0xa2f33668
	dd	0xbcb4666d
	dd	0xb8757bda
	dd	0xb5365d03
	dd	0xb1f740b4

;; The traditional ('e') CRC-32 routines.

; crc_t ecrcinit(void);

align	16, db 0
global	ECRCINIT:function
global	_ecrcinit:function
global	ecrcinit:function
global	e.crc.init:function

ECRCINIT:
_ecrcinit:
ecrcinit:
e.crc.init:

	;; ENTRY:
	;;	Anything goes
	;;
	;; EXIT:
	;;	EAX = ~0

	mov	eax, -1	; return (~0)
	ret

; crc_t ecrcfinish(crc_t const crc);

align	16, db 0
global	ECRCFINISH:function
global	_ecrcfinish:function
global	ecrcfinish:function
global	e.crc.finish:function

ECRCFINISH:

	mov	eax, [esp+4]
	not	eax
	ret	4

align	16, db 0
_ecrcfinish:
ecrcfinish:

	mov	eax, [esp+4]

align	4
e.crc.finish:

	;; ENTRY:
	;;	EAX = crc
	;;
	;; EXIT:
	;;	EAX = ~crc

	not	eax
	ret

; crc_t ecrc(crc_t const oldcrc, unsigned char const abyte);

align 16, db 0
global	ECRC:function
global	_ecrc:function
global	ecrc:function
global	e.crc:function

ECRC:

	pop	ecx
	pop	edx
	and	edx, 0FFh
	pop	eax
	push	ecx
	jmp	short e.crc

align	16, db 0
_ecrc:
ecrc:

	mov	eax, [esp+4]
	movzx	edx, byte [esp+8]

align	4
e.crc:

	;; ENTRY:
	;;	EAX = old crc
	;;	EDX = a byte in DL, the rest of EDX = 0
	;;
	;; WARNING:
	;;	If you enter with the rest of EDX not equal 0,
	;;	you will get a wrong result, and possibly
	;;	cause an exception!
	;;
	;; EXIT:
	;;	EAX = new crc

	xor	dl, al
	shr	eax, 8
	xor	eax, [edx*4+crctable]
	ret

; crc_t ecrcarray(unsigned char const *bytearray, unsigned int const numbytes);

align	16, db 0
global	ECRCARRAY:function
global	_ecrcarray:function
global	ecrcarray:function
global	e.crc.array:function

ECRCARRAY:

	pop	eax
	pop	ecx
	pop	edx
	push	eax
	jmp	short e.crc.array

_ecrcarray:
ecrcarray:

	mov	ecx, [esp+8]
	mov	edx, [esp+4]

align	4
e.crc.array:

	;; ENTRY:
	;;	ECX = number of bytes in array
	;;	EDX = address of first byte in array
	;;
	;; EXIT:
	;;	EAX = crc of array

	mov	eax, -1	; Initialize CRC-32 to (~0)
	jecxz	.done		; Quit if nothing to do
	or	edx, edx	; Avoid null pointer
	je	.done

	push	ebx

.loop:

	movzx	ebx, byte [edx]
	xor	bl, al
	shr	eax, 8
	xor	eax, [ebx*4+crctable]
	inc	edx
	loop	.loop

	not	eax

	pop	ebx

.done:

	ret

; crc_t ecrcpartial(crc_t const oldcrc, unsigned char const *bytearray, unsigned int const numbytes);

align	16, db 0
global	ECRCPARTIAL:function
global	_ecrcpartial:function
global	ecrcpartial:function
global	e.crc.partial:function
ECRCPARTIAL:

	pop	eax
	pop	ecx
	pop	edx
	xchg	eax, [esp]
	jmp	short e.crc.partial

align	16, db 0
_ecrcpartial:
ecrcpartial:

	mov	eax, [esp+4]	; old CRC
	mov	edx, [esp+8]
	mov	ecx, [esp+12]

align	4
e.crc.partial:

	;; ENTRY:
	;;	EAX = old crc
	;;	ECX = number of bytes in partial array
	;;	EDX = address of first byte in partial array
	;;
	;; EXIT:
	;;	EAX = new crc

	jecxz	.done
	or	edx, edx
	je	.done

	push	ebx

.loop:
	movzx	ebx, byte [edx]
	xor	bl, al
	shr	eax, 8
	xor	eax, [ebx*4+crctable]
	inc	edx
	loop	.loop

	pop	ebx

.done:
	ret

;; The POSIX routines.

; crc_t pcrcinit(void);

align 16, db 0
global	PCRCINIT:function
global	_pcrcinit:function
global	pcrcinit:function
global	p.crc.init:function

PCRCINIT:
_pcrcinit:
pcrcinit:
p.crc.init:

	;; ENTRY:
	;;	Anything goes
	;;
	;; EXIT:
	;;	EAX = 0

	sub	eax, eax
	ret

; crc_t pcrcfinish(crc_t const crc, unsigned bytes);

align	16, db 0
global	PCRCFINISH:function
global	_pcrcfinish:function
global	pcrcfinish:function
global	p.crc.finish:function

PCRCFINISH:

	pop	edx
	pop	ecx
	pop	eax
	push	edx
	jmp	short p.crc.finish

align	16, db 0
_pcrcfinish:
pcrcfinish:

	mov	eax, [esp+4]
	mov	ecx, [esp+8]

align	4
p.crc.finish:

	;; ENTRY:
	;;	EAX = old crc
	;;	ECX = size of data in bytes
	;;
	;; EXIT:
	;;	EAX = final crc

	jecxz	.done

.loop:
	movzx	edx, cl
	rol	eax, 8
	xor	dl, al
	sub	al, al
	xor	eax, [edx*4+posixcrctable]
	shr	ecx, 8
	jnz	.loop

.done:
	not	eax
	ret

; crc_t pcrc(crc_t const oldcrc, unsigned char const abyte);

align 16, db 0
global	PCRC:function
global	_pcrc:function
global	pcrc:function
global	p.crc:function
PCRC:

	pop	ecx
	pop	edx
	and	edx, 0FFh
	pop	eax
	push	ecx
	jmp	short p.crc

align	16, db 0
_pcrc:
pcrc:

	mov	eax, [esp+4]
	movzx	edx, byte [esp+8]

align	4
p.crc:

	;; ENTRY:
	;;	EAX = old crc
	;;	EDX = a byte in DL, the rest of EDX = 0
	;;
	;; WARNING:
	;;	If you enter with the rest of EDX not equal 0,
	;;	you will get a wrong result, and possibly
	;;	cause an exception!
	;;
	;; EXIT:
	;;	EAX = new crc

	rol	eax, 8
	xor	dl, al
	sub	al, al
	xor	eax, [edx*4+posixcrctable]
	ret

; crc_t pcrcarray(unsigned char const *bytearray, unsigned int const numbytes);

align	16, db 0
global	PCRCARRAY:function
global	_pcrcarray:function
global	pcrcarray:function
global	p.crc.array:function
PCRCARRAY:

	pop	eax
	pop	ecx
	pop	edx
	push	eax
	jmp	short p.crc.array

align	16, db 0
_pcrcarray:
pcrcarray:

	mov	ecx, [esp+8]
	mov	edx, [esp+4]

align	4
p.crc.array:

	;; ENTRY:
	;;	ECX = number of bytes in array
	;;	EDX = address of first byte in array
	;;
	;; EXIT:
	;;	EAX = crc of array

	sub	eax, eax	; Initialize CRC-32 to 0
	jecxz	.done		; Quit if nothing to do
	or	edx, edx	; Avoid null pointer
	je	.done

	push	ebx
	push	ecx
	sub	ebx, ebx

.loop:
	mov	bl, [edx]
	rol	eax, 8
	xor	bl, al
	sub	al, al
	xor	eax, [ebx*4+posixcrctable]
	inc	edx
	loop	.loop

	pop	ecx

.add.length.of.buffer:
	mov	bl, cl
	rol	eax, 8
	xor	bl, al
	sub	al, al
	xor	eax, [ebx*4+posixcrctable]
	shr	ecx, 8
	jnz	.add.length.of.buffer

	pop	ebx

.done:
	not	eax
	ret

; crc_t pcrcpartial(crc_t const oldcrc, unsigned char const *bytearray, unsigned int const numbytes);

align	16, db 0
global	PCRCPARTIAL:function
global	_pcrcpartial:function
global	pcrcpartial:function
global	p.crc.partial:function

PCRCPARTIAL:

	pop	eax
	pop	ecx
	pop	edx
	xchg	eax, [esp]
	jmp	short p.crc.partial

align	16, db 0
_pcrcpartial:
pcrcpartial:

	mov	eax, [esp+4]	; old CRC
	mov	edx, [esp+8]
	mov	ecx, [esp+12]

align	4
p.crc.partial:

	;; ENTRY:
	;;	EAX = old crc
	;;	ECX = number of bytes in partial array
	;;	EDX = address of first byte in partial array
	;;
	;; EXIT:
	;;	EAX = new crc

	jecxz	.done
	or	edx, edx
	je	.done

	push	ebx
	sub	ebx, ebx

.loop:

	mov	bl, [edx]
	rol	eax, 8
	xor	bl, al
	sub	al, al
	xor	eax, [ebx*4+posixcrctable]
	inc	edx
	loop	.loop

	pop	ebx

.done:

	ret

align	16, db 0
	db	'Fast CRC v.1', 0Ah
	db	'Copyright (C) 1999 G. Adam Stanislav', 0Ah
	db	'All rights reserved.', 0
align 16, db 0

