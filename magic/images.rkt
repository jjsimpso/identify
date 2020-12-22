#lang magic

# PCX image files
# From: Dan Fandrich <dan@coneharvesters.com>
# updated by Joerg Jenderek at Feb 2013 by http://de.wikipedia.org/wiki/PCX
# http://web.archive.org/web/20100206055706/http://www.qzx.com/pc-gpe/pcx.txt
# GRR: original test was still too general as it catches xbase examples T5.DBT,T6.DBT with 0xa000000
# test for bytes 0x0a,version byte (0,2,3,4,5),compression byte flag(0,1), bit depth (>0) of PCX or T5.DBT,T6.DBT
0	ubelong&0xffF8fe00	0x0a000000
# for PCX bit depth > 0
>3	ubyte		>0
# test for valid versions
>>1	ubyte		<6
>>>1	ubyte		!1	PCX
>>>>1	ubyte		0	ver. 2.5 image data
>>>>1	ubyte		2	ver. 2.8 image data, with palette
>>>>1	ubyte		3	ver. 2.8 image data, without palette
>>>>1	ubyte		4	for Windows image data
>>>>1	ubyte		5	ver. 3.0 image data
>>>>4	uleshort	x	bounding box [%d,
>>>>6	uleshort	x	%d] -
>>>>8	uleshort	x	[%d,
>>>>10	uleshort	x	%d],
>>>>65	ubyte		>1	%d planes each of
>>>>3	ubyte		x	%d-bit
>>>>68	byte		1	colour,
>>>>68	byte		2	grayscale,
# this should not happen
>>>>68	default		x	image,
>>>>12	leshort		>0	%d x
>>>>>14	uleshort	x	%d dpi,
>>>>2	byte		0	uncompressed
>>>>2	byte		1	RLE compressed


#
# 137 P N G \r \n ^Z \n [4-byte length] I H D R [HEAD data] [HEAD crc] ...
#

# IHDR parser
0	name		png-ihdr
>0	belong		x		\b, %d x
>4	belong		x		%d,
>8	byte		x		%d-bit
>9	byte		0		grayscale,
>9	byte		2		\b/color RGB,
>9	byte		3		colormap,
>9	byte		4		gray+alpha,
>9	byte		6		\b/color RGBA,
#>10	byte		0		deflate/32K,
>12	byte		0		non-interlaced
>12	byte		1		interlaced

# Standard PNG image.
0	string		\x89PNG\x0d\x0a\x1a\x0a\x00\x00\x00\x0DIHDR	PNG image data
>16	use		png-ihdr

# Apple CgBI PNG image.
0	string		\x89PNG\x0d\x0a\x1a\x0a\x00\x00\x00\x04CgBI
>24	string  	\x00\x00\x00\x0DIHDR	PNG image data (CgBI)
!:mime	image/png
!:strength +10
>>32	use		png-ihdr

# possible GIF replacements; none yet released!
# (Greg Roelofs, newt@uchicago.edu)
#
# GRR 950115:  this was mine ("Zip GIF"):
0	string		GIF94z		ZIF image (GIF+deflate alpha)
!:mime	image/x-unknown
#
# GRR 950115:  this is Jeremy Wohl's Free Graphics Format (better):
#
0	string		FGF95a		FGF image (GIF+deflate beta)
!:mime	image/x-unknown
#
# GRR 950115:  this is Thomas Boutell's Portable Bitmap Format proposal
# (best; not yet implemented):
#
0	string		PBF		PBF image (deflate compression)
!:mime	image/x-unknown

# GIF
# Strength set up to beat 0x55AA DOS/MBR signature word lookups (+65)
0	string		GIF8		GIF image data
!:strength +80
!:mime	image/gif
!:apple	8BIMGIFf
>4	string		7a		\b, version 8%s,
>4	string		9a		\b, version 8%s,
>6	leshort		>0		%d x
>8	leshort		>0		%d
#>10	byte		&0x80		color mapped,
#>10	byte&0x07	=0x00		2 colors
#>10	byte&0x07	=0x01		4 colors
#>10	byte&0x07	=0x02		8 colors
#>10	byte&0x07	=0x03		16 colors
#>10	byte&0x07	=0x04		32 colors
#>10	byte&0x07	=0x05		64 colors
#>10	byte&0x07	=0x06		128 colors
#>10	byte&0x07	=0x07		256 colors



0	beshort		0xffd8		JPEG image data
!:mime	image/jpeg
!:apple	8BIMJPEG
!:strength *3
!:ext jpeg/jpg/jpe/jfif
>6	string		JFIF		\b, JFIF standard
>6	string		Exif		\b, Exif standard: [
>>12	default		x		\b]


# Targa - matches `povray', `ppmtotga' and `xv' outputs
# by Philippe De Muyter <phdm@macqel.be>
# URL: http://justsolve.archiveteam.org/wiki/TGA
# Reference: http://www.dca.fee.unicamp.br/~martino/disciplinas/ea978/tgaffs.pdf
# Update: Joerg Jenderek
# at 2, byte ImgType must be 1, 2, 3, 9, 10 or 11
#	,32 or 33 (both not observed)
# at 1, byte CoMapType must be 1 if ImgType is 1 or 9, 0 otherwise
#	or theoretically 2-128 reserved for use by Truevision or 128-255 may be used for developer applications
# at 3, leshort Index is 0 for povray, ppmtotga and xv outputs
# `xv' recognizes only a subset of the following (RGB with pixelsize = 24)
# `tgatoppm' recognizes a superset (Index may be anything)
#
# test of Color Map Type 0~no 1~color map
# and Image Type 1 2 3 9 10 11 32 33
# and Color Map Entry Size 0 15 16 24 32
0	ubequad&0x00FeC400000000C0	0
# Prevent conflicts with CRI ADX.
>(2.S-2) belong	!0x28632943
# skip more garbage like *.iso by looking for positive image type
>>2	ubyte			>0
# skip some compiled terminfo like xterm+tmux by looking for image type less equal 33
>>>2	ubyte			<34
# skip arches.3200 , Finder.Root , Slp.1 by looking for low pixel depth 1 8 15 16 24 32
>>>>16	ubyte			1
>>>>>0		use		tga-image
>>>>16	ubyte			8
>>>>>0		use		tga-image
>>>>16	ubyte			15
>>>>>0		use		tga-image
>>>>16	ubyte			16
>>>>>0		use		tga-image
>>>>16	ubyte			24
>>>>>0		use		tga-image
>>>>16	ubyte			32
>>>>>0		use		tga-image
#	display tga bitmap image information
0	name				tga-image
>2	ubyte		<34		Targa image data
!:mime	image/x-tga
!:apple	????TPIC
# normal extension .tga but some Truevision products used others:
# tpic (Apple),icb (Image Capture Board),vda (Video Display Adapter),vst (NuVista),win (UNSURE about that)
!:ext	tga/tpic/icb/vda/vst
# image type 1 2 3 9 10 11 32 33
>2	ubyte&0xF7	1		- Map
>2	ubyte&0xF7	2		- RGB
# alpha channel
>>17	ubyte&0x0F	>0		\bA
>2	ubyte&0xF7	3		- Mono
# type not found, but by http://www.fileformat.info/format/tga/corion.htm
# Compressed color-mapped data, using Huffman, Delta, and runlength encoding
>2	ubyte		32		- Color
# Compressed color-mapped data, using Huffman, Delta, and RLE. 4-pass quadtree- type process
>2	ubyte		33		- Color
# Color Map Type 0~no 1~color map
>1	ubyte		1		(
# first color map entry, 0 normal
>>3	uleshort	>0		\b%d-
# color map length 0 2 1dh 3bh d9h 100h
>>5	uleshort	x		\b%d)
# 8~run length encoding bit
>2	ubyte&0x08	8		- RLE
# gimp can create big pictures!
>12	uleshort	>0		%d x
>12	uleshort	=0		65536 x
# image height. 0 interpreted as 65536
>14	uleshort	>0		%d
>14	uleshort	=0		65536
# Image Pixel depth 1 8 15 16 24 32
>16	ubyte		x		x %d
# X origin of image. 0 normal
>8	uleshort	>0		+%d
# Y origin of image. 0 normal; positive for top
>10	uleshort	>0		+%d
# Image descriptor: bits 3-0 give the alpha channel depth, bits 5-4 give direction
>17	ubyte&0x0F	>0		- %d-bit alpha
# bits 5-4 give direction. normal bottom left
>17	ubyte		&0x20		- top
#>17	ubyte		^0x20		- bottom
>17	ubyte		&0x10		- right
#>17	ubyte		^0x10		- left
# some info say other bits 6-7 should be zero
# but data storage interleave by http://www.fileformat.info/format/tga/corion.htm
# 00 - no interleave;01 - even/odd interleave; 10 - four way interleave; 11 - reserved
#>17	ubyte&0xC0	0x00		- no interleave
>17	ubyte&0xC0	0x40		- interleave
>17	ubyte&0xC0	0x80		- four way interleave
>17	ubyte&0xC0	0xC0		- reserved
# positive length implies identification field
>0	ubyte		>0
>>18	string		x		"%s"
# last 18 bytes of newer tga file footer signature
>18	search/4261301/s	TRUEVISION-XFILE.\0
# extension area offset if not 0
>>&-8		ulelong			>0
# length of the extension area. normal 495 for version 2.0
>>>(&-4.l)	uleshort		0x01EF
# AuthorName[41]
>>>>&0		string			>\0		- author "%-.40s"
# Comment[324]=4 * 80 null terminated
>>>>&41		string			>\0		- comment "%-.80s"
# date
>>>>&365	ubequad&0xffffFFFFffff0000	!0
# Day
>>>>>&-6		uleshort		x		%d
# Month
>>>>>&-8		uleshort		x		\b-%d
# Year
>>>>>&-4		uleshort		x		\b-%d
# time
>>>>&371	ubequad&0xffffFFFFffff0000	!0
# hour
>>>>>&-8		uleshort		x		%d
# minutes
>>>>>&-6		uleshort		x		\b:%.2d
# second
>>>>>&-4		uleshort		x		\b:%.2d
# JobName[41]
>>>>&377		string			>\0		- job "%-.40s"
# JobHour Jobminute Jobsecond
>>>>&418	ubequad&0xffffFFFFffff0000	!0
>>>>>&-8		uleshort		x		%d
>>>>>&-6		uleshort		x		\b:%.2d
>>>>>&-4		uleshort		x		\b:%.2d
# SoftwareId[41]
>>>>&424		string			>\0		- %-.40s
# SoftwareVersionNumber
>>>>&424	ubyte				>0
>>>>>&40		uleshort/100		x		%d
>>>>>&40		uleshort%100		x		\b.%d
# VersionLetter
>>>>>&42		ubyte			>0x20		\b%c
# KeyColor
>>>>&468		ulelong			>0		- keycolor 0x%8.8x
# Denominator of Pixel ratio. 0~no pixel aspect
>>>>&474	uleshort			>0
# Numerator
>>>>>&-4		uleshort		>0		- aspect %d
>>>>>&-2		uleshort		x		\b/%d
# Denominator of Gamma ratio. 0~no Gamma value
>>>>&478	uleshort			>0
# Numerator
>>>>>&-4		uleshort		>0		- gamma %d
>>>>>&-2		uleshort		x		\b/%d
# ColorOffset
#>>>>&480	ulelong			x		- col offset 0x%8.8x
# StampOffset
#>>>>&484	ulelong			x		- stamp offset 0x%8.8x
# ScanOffset
#>>>>&488	ulelong			x		- scan offset 0x%8.8x
# AttributesType
#>>>>&492	ubyte			x		- Attributes 0x%x
## EndOfTGA

# Tag Image File Format, from Daniel Quinlan (quinlan@yggdrasil.com)
# The second word of TIFF files is the TIFF version number, 42, which has
# never changed.  The TIFF specification recommends testing for it.
0	string		MM\x00\x2a	TIFF image data, big-endian
!:strength +70
!:mime	image/tiff
>(4.L)	use		^tiff_ifd
0	string		II\x2a\x00	TIFF image data, little-endian
!:mime	image/tiff
!:strength +70
>(4.l)	use		tiff_ifd

0	name		tiff_ifd
>0	leshort		x		\b, direntries=%d
>2	use		tiff_entry

0	name		tiff_entry
# NewSubFileType
>0	leshort		0xfe
>>12	use		tiff_entry
>0	leshort		0x100
>>4	lelong		1
>>>12	use		tiff_entry
>>>8	leshort		x		\b, width=%d
>0	leshort		0x101
>>4	lelong		1
>>>8	leshort		x		\b, height=%d
>>>12	use		tiff_entry
>0	leshort		0x102
>>8	leshort		x		\b, bps=%d
>>12	use		tiff_entry
>0	leshort		0x103
>>4	lelong		1		\b, compression=
>>>8	leshort		1		\bnone
>>>8	leshort		2		\bhuffman
>>>8	leshort		3		\bbi-level group 3
>>>8	leshort		4		\bbi-level group 4
>>>8	leshort		5		\bLZW
>>>8	leshort		6		\bJPEG (old)
>>>8	leshort		7		\bJPEG
>>>8	leshort		8		\bdeflate
>>>8	leshort		9		\bJBIG, ITU-T T.85
>>>8	leshort		0xa		\bJBIG, ITU-T T.43
>>>8	leshort		0x7ffe		\bNeXT RLE 2-bit
>>>8	leshort		0x8005		\bPackBits (Macintosh RLE)
>>>8	leshort		0x8029		\bThunderscan RLE
>>>8	leshort		0x807f		\bRasterPadding (CT or MP)
>>>8	leshort		0x8080		\bRLE (Line Work)
>>>8	leshort		0x8081		\bRLE (High-Res Cont-Tone)
>>>8	leshort		0x8082		\bRLE (Binary Line Work)
>>>8	leshort		0x80b2		\bDeflate (PKZIP)
>>>8	leshort		0x80b3		\bKodak DCS
>>>8	leshort		0x8765		\bJBIG
>>>8	leshort		0x8798		\bJPEG2000
>>>8	leshort		0x8799		\bNikon NEF Compressed
>>>8	default		x
>>>>8	leshort		x		\b(unknown 0x%x)
>>>12	use		tiff_entry
>0	leshort		0x106		\b, PhotometricIntepretation=
>>8	clear           x
>>8	leshort		0		\bWhiteIsZero
>>8	leshort		1		\bBlackIsZero
>>8	leshort		2		\bRGB
>>8	leshort		3		\bRGB Palette
>>8	leshort		4		\bTransparency Mask
>>8	leshort		5		\bCMYK
>>8	leshort		6		\bYCbCr
>>8	leshort		8		\bCIELab
>>8	default		x
>>>8	leshort		x		\b(unknown=0x%x)
>>12	use		tiff_entry
# FillOrder
>0	leshort		0x10a
>>4	lelong		1
>>>12	use		tiff_entry
# DocumentName
>0	leshort		0x10d
>>(8.l)	string		x		\b, name=%s
>>>12	use		tiff_entry
# ImageDescription
>0	leshort		0x10e
>>(8.l)	string		x		\b, description=%s
>>>12	use		tiff_entry
# Make
>0	leshort		0x10f
>>(8.l)	string		x		\b, manufacturer=%s
>>>12	use		tiff_entry
# Model
>0	leshort		0x110
>>(8.l)	string		x		\b, model=%s
>>>12	use		tiff_entry
# StripOffsets
>0	leshort		0x111
>>12	use		tiff_entry
# Orientation
>0	leshort		0x112		\b, orientation=
>>8	leshort		1		\bupper-left
>>8	leshort		3		\blower-right
>>8	leshort		6		\bupper-right
>>8	leshort		8		\blower-left
>>8	leshort		9		\bundefined
>>8	default		x
>>>8	leshort		x		\b[*%d*]
>>12	use		tiff_entry
# XResolution
>0	leshort		0x11a
>>8	lelong		x		\b, xresolution=%d
>>12	use		tiff_entry
# YResolution
>0	leshort		0x11b
>>8	lelong		x		\b, yresolution=%d
>>12	use		tiff_entry
# ResolutionUnit
>0	leshort		0x128
>>8	leshort		x		\b, resolutionunit=%d
>>12	use		tiff_entry
# Software
>0	leshort		0x131
>>(8.l)	string		x		\b, software=%s
>>12	use		tiff_entry
# Datetime
>0	leshort		0x132
>>(8.l)	string		x		\b, datetime=%s
>>12	use		tiff_entry
# HostComputer
>0	leshort		0x13c
>>(8.l)	string		x		\b, hostcomputer=%s
>>12	use		tiff_entry
# WhitePoint
>0	leshort		0x13e
>>12	use		tiff_entry
# PrimaryChromaticities
>0	leshort		0x13f
>>12	use		tiff_entry
# YCbCrCoefficients
>0	leshort		0x211
>>12	use		tiff_entry
# YCbCrPositioning
>0	leshort		0x213
>>12	use		tiff_entry
# ReferenceBlackWhite
>0	leshort		0x214
>>12	use		tiff_entry
# Copyright
>0	leshort		0x8298
>>(8.l)	string		x		\b, copyright=%s
>>12	use		tiff_entry
# ExifOffset
>0	leshort		0x8769
>>12	use		tiff_entry
# GPS IFD
>0	leshort		0x8825		\b, GPS-Data
>>12	use		tiff_entry

#>0	leshort		x		\b, unknown=0x%x
#>>12	use		tiff_entry

0	string		MM\x00\x2b	Big TIFF image data, big-endian
!:mime	image/tiff
0	string		II\x2b\x00	Big TIFF image data, little-endian
!:mime	image/tiff

# PBMPLUS images
# The next byte following the magic is always whitespace.
# strength is changed to try these patterns before "x86 boot sector"
0	name		netpbm
>3	regex/s		=[0-9]{1,50}\ [0-9]{1,50}	Netpbm image data
>>&0	regex		=[0-9]{1,50} 			\b, size = %s x
>>>&0	regex		=[0-9]{1,50}			\b %s

0	search/1	P1
>0	regex/4		P1[\040\t\f\r\n]
>>0	use		netpbm
>>>0	string		x	\b, bitmap
!:strength + 45
!:mime	image/x-portable-bitmap

0	search/1	P2
>0	regex/4		P2[\040\t\f\r\n]
>>0	use		netpbm
>>>0	string		x	\b, greymap
!:strength + 45
!:mime	image/x-portable-greymap

0	search/1	P3
>0	regex/4		P3[\040\t\f\r\n]
>>0	use		netpbm
>>>0	string		x	\b, pixmap
!:strength + 45
!:mime	image/x-portable-pixmap

0	string		P4
>0	regex/4		P4[\040\t\f\r\n]
>>0	use		netpbm
>>>0	string		x	\b, rawbits, bitmap
!:strength + 45
!:mime	image/x-portable-bitmap

0	string		P5
>0	regex/4		P5[\040\t\f\r\n]
>>0	use		netpbm
>>>0	string		x	\b, rawbits, greymap
!:strength + 45
!:mime	image/x-portable-greymap

0	string		P6
>0	regex/4		P6[\040\t\f\r\n]
>>0	use		netpbm
>>>0	string		x	\b, rawbits, pixmap
!:strength + 45
!:mime	image/x-portable-pixmap

0	string		P7		Netpbm PAM image file
!:mime	image/x-portable-pixmap

# From: bryanh@giraffe-data.com (Bryan Henderson)
0	string		\117\072	Solitaire Image Recorder format
>4	string		\013		MGI Type 11
>4	string		\021		MGI Type 17
0	string		.MDA		MicroDesign data
>21	byte		48		version 2
>21	byte		51		version 3
0	string		.MDP		MicroDesign page data
>21	byte		48		version 2
>21	byte		51		version 3

# NIFF (Navy Interchange File Format, a modification of TIFF) images
# [GRR:  this *must* go before TIFF]
0	string		IIN1		NIFF image data
!:mime	image/x-niff

# Canon RAW version 1 (CRW) files are a type of Canon Image File Format
# (CIFF) file. These are apparently all little-endian.
# From: Adam Buchbinder <adam.buchbinder@gmail.com>
# URL: http://www.sno.phy.queensu.ca/~phil/exiftool/canon_raw.html
0	string		II\x1a\0\0\0HEAPCCDR	Canon CIFF raw image data
!:mime	image/x-canon-crw
>16	leshort		x	\b, version %d.
>14	leshort		x	\b%d

# Canon RAW version 2 (CR2) files are a kind of TIFF with an extra magic
# number. Put this above the TIFF test to make sure we detect them.
# These are apparently all little-endian.
# From: Adam Buchbinder <adam.buchbinder@gmail.com>
# URL: http://libopenraw.freedesktop.org/wiki/Canon_CR2
0	string		II\x2a\0\x10\0\0\0CR	Canon CR2 raw image data
!:mime	image/x-canon-cr2
>10	byte		x	\b, version %d.
>11	byte		x	\b%d

# ITC (CMU WM) raster files.  It is essentially a byte-reversed Sun raster,
# 1 plane, no encoding.
0	string		\361\0\100\273	CMU window manager raster image data
>4	lelong		>0		%d x
>8	lelong		>0		%d,
>12	lelong		>0		%d-bit

# Magick Image File Format
0	string		id=ImageMagick	MIFF image data

# Artisan
0	long		1123028772	Artisan image data
>4	long		1		\b, rectangular 24-bit
>4	long		2		\b, rectangular 8-bit with colormap
>4	long		3		\b, rectangular 32-bit (24-bit with matte)

# FIG (Facility for Interactive Generation of figures), an object-based format
0	search/1	#FIG		FIG image text
>5	string		x		\b, version %.3s

# PHIGS
0	string		ARF_BEGARF		PHIGS clear text archive
0	string		@(#)SunPHIGS		SunPHIGS
# version number follows, in the form m.n
>40	string		SunBin			binary
>32	string		archive			archive

# GKS (Graphics Kernel System)
0	string		GKSM		GKS Metafile
>24	string		SunGKS		\b, SunGKS

# CGM image files
0	string		BEGMF		clear text Computer Graphics Metafile

# MGR bitmaps  (Michael Haardt, u31b3hs@pool.informatik.rwth-aachen.de)
0	string	yz	MGR bitmap, modern format, 8-bit aligned
0	string	zz	MGR bitmap, old format, 1-bit deep, 16-bit aligned
0	string	xz	MGR bitmap, old format, 1-bit deep, 32-bit aligned
0	string	yx	MGR bitmap, modern format, squeezed

# Fuzzy Bitmap (FBM) images
0	string		%bitmap\0	FBM image data
>30	long		0x31		\b, mono
>30	long		0x33		\b, color

# facsimile data
1	string		PC\ Research,\ Inc	group 3 fax data
>29	byte		0		\b, normal resolution (204x98 DPI)
>29	byte		1		\b, fine resolution (204x196 DPI)
# From: Herbert Rosmanith <herp@wildsau.idv.uni.linz.at>
0	string		Sfff		structured fax file

# From: Joerg Jenderek <joerg.jen.der.ek@gmx.net>
# most files with the extension .EPA and some with .BMP
0	string		\x11\x06	Award BIOS Logo, 136 x 84
!:mime	image/x-award-bioslogo
0	string		\x11\x09	Award BIOS Logo, 136 x 126
!:mime	image/x-award-bioslogo
#0	string		\x07\x1f	BIOS Logo corrupted?
# http://www.blackfiveservices.co.uk/awbmtools.shtml
# http://biosgfx.narod.ru/v3/
# http://biosgfx.narod.ru/abr-2/
0	string		AWBM
>4	leshort		<1981		Award BIOS bitmap
!:mime	image/x-award-bmp
# image width is a multiple of 4
>>4	leshort&0x0003	0
>>>4		leshort	x		\b, %d
>>>6		leshort	x		x %d
>>4	leshort&0x0003	>0		\b,
>>>4	leshort&0x0003	=1
>>>>4		leshort	x		%d+3
>>>4	leshort&0x0003	=2
>>>>4		leshort	x		%d+2
>>>4	leshort&0x0003	=3
>>>>4		leshort	x		%d+1
>>>6		leshort	x		x %d
# at offset 8 starts imagedata followed by "RGB " marker

# PC bitmaps (OS/2, Windows BMP files)  (Greg Roelofs, newt@uchicago.edu)
# http://en.wikipedia.org/wiki/BMP_file_format#DIB_header_.\
# 28bitmap_information_header.29
0	string		BM
>14	leshort		12		PC bitmap, OS/2 1.x format
!:mime	image/x-ms-bmp
>>18	leshort		x		\b, %d x
>>20	leshort		x		%d
>14	leshort		64		PC bitmap, OS/2 2.x format
!:mime	image/x-ms-bmp
>>18	leshort		x		\b, %d x
>>20	leshort		x		%d
>14	leshort		40		PC bitmap, Windows 3.x format
!:mime	image/x-ms-bmp
>>18	lelong		x		\b, %d x
>>22	lelong		x		%d x
>>28	leshort		x		%d
>14	leshort		124		PC bitmap, Windows 98/2000 and newer format
!:mime	image/x-ms-bmp
>>18	lelong		x		\b, %d x
>>22	lelong		x		%d x
>>28	leshort		x		%d
>14	leshort		108		PC bitmap, Windows 95/NT4 and newer format
!:mime	image/x-ms-bmp
>>18	lelong		x		\b, %d x
>>22	lelong		x		%d x
>>28	leshort		x		%d
>14	leshort		128		PC bitmap, Windows NT/2000 format
!:mime	image/x-ms-bmp
>>18	lelong		x		\b, %d x
>>22	lelong		x		%d x
>>28	leshort		x		%d
# Too simple - MPi
#0	string		IC		PC icon data
#0	string		PI		PC pointer image data
#0	string		CI		PC color icon data
#0	string		CP		PC color pointer image data
# Conflicts with other entries [BABYL]
#0	string		BA		PC bitmap array data

# XPM icons (Greg Roelofs, newt@uchicago.edu)
0	search/1	/*\ XPM\ */	X pixmap image text
!:mime	image/x-xpmi

# Utah Raster Toolkit RLE images (janl@ifi.uio.no)
0	leshort		0xcc52		RLE image data,
>6	leshort		x		%d x
>8	leshort		x		%d
>2	leshort		>0		\b, lower left corner: %d
>4	leshort		>0		\b, lower right corner: %d
>10	byte&0x1	=0x1		\b, clear first
>10	byte&0x2	=0x2		\b, no background
>10	byte&0x4	=0x4		\b, alpha channel
>10	byte&0x8	=0x8		\b, comment
>11	byte		>0		\b, %d color channels
>12	byte		>0		\b, %d bits per pixel
>13	byte		>0		\b, %d color map channels

# image file format (Robert Potter, potter@cs.rochester.edu)
0	string		Imagefile\ version-	iff image data
# this adds the whole header (inc. version number), informative but longish
>10	string		>\0		%s

# Sun raster images, from Daniel Quinlan (quinlan@yggdrasil.com)
0	belong		0x59a66a95	Sun raster image data
>4	belong		>0		\b, %d x
>8	belong		>0		%d,
>12	belong		>0		%d-bit,
#>16	belong		>0		%d bytes long,
>20	belong		0		old format,
#>20	belong		1		standard,
>20	belong		2		compressed,
>20	belong		3		RGB,
>20	belong		4		TIFF,
>20	belong		5		IFF,
>20	belong		0xffff		reserved for testing,
>24	belong		0		no colormap
>24	belong		1		RGB colormap
>24	belong		2		raw colormap
#>28	belong		>0		colormap is %d bytes long

# SGI image file format, from Daniel Quinlan (quinlan@yggdrasil.com)
#
# See
#	http://reality.sgi.com/grafica/sgiimage.html
#
0	beshort		474		SGI image data
#>2	byte		0		\b, verbatim
>2	byte		1		\b, RLE
#>3	byte		1		\b, normal precision
>3	byte		2		\b, high precision
>4	beshort		x		\b, %d-D
>6	beshort		x		\b, %d x
>8	beshort		x		%d
>10	beshort		x		\b, %d channel
>10	beshort		!1		\bs
>80	string		>0		\b, "%s"

0	string		IT01		FIT image data
>4	belong		x		\b, %d x
>8	belong		x		%d x
>12	belong		x		%d
#
0	string		IT02		FIT image data
>4	belong		x		\b, %d x
>8	belong		x		%d x
>12	belong		x		%d
#
2048	string		PCD_IPI		Kodak Photo CD image pack file
>0xe02	byte&0x03	0x00		, landscape mode
>0xe02	byte&0x03	0x01		, portrait mode
>0xe02	byte&0x03	0x02		, landscape mode
>0xe02	byte&0x03	0x03		, portrait mode
0	string		PCD_OPA		Kodak Photo CD overview pack file

# FITS format.  Jeff Uphoff <juphoff@tarsier.cv.nrao.edu>
# FITS is the Flexible Image Transport System, the de facto standard for
# data and image transfer, storage, etc., for the astronomical community.
# (FITS floating point formats are big-endian.)
0	string	SIMPLE\ \ =	FITS image data
!:mime	image/fits
!:ext	fits/fts
>109	string	8		\b, 8-bit, character or unsigned binary integer
>108	string	16		\b, 16-bit, two's complement binary integer
>107	string	\ 32		\b, 32-bit, two's complement binary integer
>107	string	-32		\b, 32-bit, floating point, single precision
>107	string	-64		\b, 64-bit, floating point, double precision

# other images
0	string	This\ is\ a\ BitMap\ file	Lisp Machine bit-array-file

# From SunOS 5.5.1 "/etc/magic" - appeared right before Sun raster image
# stuff.
#
0	beshort		0x1010		PEX Binary Archive

# DICOM medical imaging data
# URL:		https://en.wikipedia.org/wiki/DICOM#Data_format
# Note:		"dcm" is the official file name extension
# 		XnView mention also "dc3" and "acr" as file name extension
128	string	DICM			DICOM medical imaging data
!:mime	application/dicom
!:ext dcm/dicom/dic

# XWD - X Window Dump file.
#   As described in /usr/X11R6/include/X11/XWDFile.h
#   used by the xwd program.
#   Bradford Castalia, idaeim, 1/01
#   updated by Adam Buchbinder, 2/09
# The following assumes version 7 of the format; the first long is the length
# of the header, which is at least 25 4-byte longs, and the one at offset 8
# is a constant which is always either 1 or 2. Offset 12 is the pixmap depth,
# which is a maximum of 32.
0	belong	>100
>8	belong	<3
>>12	belong	<33
>>>4	belong	7			XWD X Window Dump image data
!:mime	image/x-xwindowdump
>>>>100	string	>\0			\b, "%s"
>>>>16	belong	x			\b, %dx
>>>>20	belong	x			\b%dx
>>>>12	belong	x			\b%d

# PDS - Planetary Data System
#   These files use Parameter Value Language in the header section.
#   Unfortunately, there is no certain magic, but the following
#   strings have been found to be most likely.
0	string	NJPL1I00		PDS (JPL) image data
2	string	NJPL1I			PDS (JPL) image data
0	string	CCSD3ZF			PDS (CCSD) image data
2	string	CCSD3Z			PDS (CCSD) image data
0	string	PDS_			PDS image data
0	string	LBLSIZE=		PDS (VICAR) image data

# pM8x: ATARI STAD compressed bitmap format
#
# from Oskar Schirmer <schirmer@scara.com> Feb 2, 2001
# p M 8 5/6 xx yy zz data...
# Atari ST STAD bitmap is always 640x400, bytewise runlength compressed.
# bytes either run horizontally (pM85) or vertically (pM86). yy is the
# most frequent byte, xx and zz are runlength escape codes, where xx is
# used for runs of yy.
#
0	string	pM85		Atari ST STAD bitmap image data (hor)
>5	byte	0x00		(white background)
>5	byte	0xFF		(black background)
0	string	pM86		Atari ST STAD bitmap image data (vert)
>5	byte	0x00		(white background)
>5	byte	0xFF		(black background)

# From: Alex Myczko <alex@aiei.ch>
# http://www.atarimax.com/jindroush.atari.org/afmtatr.html
0	leshort	0x0296		Atari ATR image

# XXX:
# This is bad magic 0x5249 == 'RI' conflicts with RIFF and other
# magic.
# SGI RICE image file <mpruett@sgi.com>
#0	beshort	0x5249		RICE image
#>2	beshort	x		v%d
#>4	beshort	x		(%d x
#>6	beshort	x		%d)
#>8	beshort	0		8 bit
#>8	beshort	1		10 bit
#>8	beshort	2		12 bit
#>8	beshort	3		13 bit
#>10	beshort	0		4:2:2
#>10	beshort	1		4:2:2:4
#>10	beshort	2		4:4:4
#>10	beshort	3		4:4:4:4
#>12	beshort	1		RGB
#>12	beshort	2		CCIR601
#>12	beshort	3		RP175
#>12	beshort	4		YUV

# Adobe Photoshop
# From: Asbjoern Sloth Toennesen <asbjorn@lila.io>
0	string		8BPS Adobe Photoshop Image
!:mime	image/vnd.adobe.photoshop
>4   beshort 2 (PSB)
>18  belong  x \b, %d x
>14  belong  x %d,
>24  beshort 0 bitmap
>24  beshort 1 grayscale
>>12 beshort 2 with alpha
>24  beshort 2 indexed
>24  beshort 3 RGB
>>12 beshort 4 \bA
>24  beshort 4 CMYK
>>12 beshort 5 \bA
>24  beshort 7 multichannel
>24  beshort 8 duotone
>24  beshort 9 lab
>12  beshort >1
>>12  beshort x \b, %dx
>12  beshort 1 \b,
>22  beshort x %d-bit channel
>12  beshort >1 \bs

# XV thumbnail indicator (ThMO)
0	string		P7\ 332		XV thumbnail image data

# NITF is defined by United States MIL-STD-2500A
0	string	NITF	National Imagery Transmission Format
>25	string	>\0	dated %.14s

# GEM Image: Version 1, Headerlen 8 (Wolfram Kleff)
# Format variations from: Bernd Nuernberger <bernd.nuernberger@web.de>
# Update: Joerg Jenderek
# See http://fileformats.archiveteam.org/wiki/GEM_Raster
# For variations, also see:
#    http://www.seasip.info/Gem/ff_img.html (Ventura)
#    http://www.atari-wiki.com/?title=IMG_file (XIMG, STTT)
#    http://www.fileformat.info/format/gemraster/spec/index.htm (XIMG, STTT)
#    http://sylvana.net/1stguide/1STGUIDE.ENG (TIMG)
0       beshort     0x0001
# header_size
>2      beshort     0x0008
>>0     use gem_info
>2      beshort     0x0009
>>0     use gem_info
# no example for NOSIG
>2      beshort     24
>>0     use gem_info
# no example for HYPERPAINT
>2      beshort     25
>>0     use gem_info
16      string      XIMG\0
>0      use gem_info
# no example
16      string      STTT\0\x10
>0      use gem_info
# no example or description
16      string      TIMG\0
>0      use gem_info

0   name        gem_info
# version is 2 for some XIMG and 1 for all others
>0	beshort		<0x0003		GEM
# http://www.snowstone.org.uk/riscos/mimeman/mimemap.txt
!:mime	image/x-gem
# header_size 24 25 27 59 779 words for colored bitmaps
>>2	beshort		>9
>>>16	string		STTT\0\x10	STTT
>>>16	string		TIMG\0		TIMG
# HYPERPAINT or NOSIG variant
>>>16	string		\0\x80
>>>>2	beshort		=24		NOSIG
>>>>2	beshort		!24		HYPERPAINT
# NOSIG or XIMG variant
>>>16	default		x
>>>>16	string		!XIMG\0		NOSIG
>>16	string		=XIMG\0		XIMG Image data
!:ext	img/ximg
# to avoid Warning: Current entry does not yet have a description for adding a EXTENSION type
>>16	string		!XIMG\0		Image data
!:ext	img
# header_size is 9 for Ventura files and 8 for other GEM Paint files
>>2	beshort		9		(Ventura)
#>>2	beshort		8		(Paint)
>>12	beshort		x		%d x
>>14	beshort		x		%d,
# 1 4 8
>>4	beshort		x		%d planes,
# in tenths of a millimetre
>>8	beshort		x		%d x
>>10	beshort		x		%d pixelsize
# pattern_size 1-8. 2 for GEM Paint
>>6	beshort		!2		\b, pattern size %d

# GEM Metafile (Wolfram Kleff)
0	lelong		0x0018FFFF	GEM Metafile data
>4	leshort		x		version %d

#
# SMJPEG. A custom Motion JPEG format used by Loki Entertainment
# Software Torbjorn Andersson <d91tan@Update.UU.SE>.
#
0	string	\0\nSMJPEG	SMJPEG
>8	belong	x		%d.x data
# According to the specification you could find any number of _TXT
# headers here, but I can't think of any way of handling that. None of
# the SMJPEG files I tried it on used this feature. Even if such a
# file is encountered the output should still be reasonable.
>16	string	_SND		\b,
>>24	beshort	>0		%d Hz
>>26	byte	8		8-bit
>>26	byte	16		16-bit
>>28	string	NONE		uncompressed
# >>28	string	APCM		ADPCM compressed
>>27	byte	1		mono
>>28	byte	2		stereo
# Help! Isn't there any way to avoid writing this part twice?
>>32	string	_VID		\b,
# >>>48	string	JFIF		JPEG
>>>40	belong	>0		%d frames
>>>44	beshort	>0		(%d x
>>>46	beshort	>0		%d)
>16	string	_VID		\b,
# >>32	string	JFIF		JPEG
>>24	belong	>0		%d frames
>>28	beshort	>0		(%d x
>>30	beshort	>0		%d)

0	string	Paint\ Shop\ Pro\ Image\ File	Paint Shop Pro Image File

# "thumbnail file" (icon)
# descended from "xv", but in use by other applications as well (Wolfram Kleff)
0       string          P7\ 332         XV "thumbnail file" (icon) data

# taken from fkiss: (<yav@mte.biglobe.ne.jp> ?)
0       string          KiSS            KISS/GS
>4      byte            16              color
>>5     byte            x               %d bit
>>8     leshort         x               %d colors
>>10    leshort         x               %d groups
>4      byte            32              cell
>>5     byte            x               %d bit
>>8     leshort         x               %d x
>>10    leshort         x               %d
>>12    leshort         x               +%d
>>14    leshort         x               +%d

# Webshots (www.webshots.com), by John Harrison
0       string          C\253\221g\230\0\0\0 Webshots Desktop .wbz file

# Hercules DASD image files
# From Jan Jaeger <jj@septa.nl>
0       string  CKD_P370        Hercules CKD DASD image file
>8      long    x               \b, %d heads per cylinder
>12     long    x               \b, track size %d bytes
>16     byte    x               \b, device type 33%2.2X

0       string  CKD_C370        Hercules compressed CKD DASD image file
>8      long    x               \b, %d heads per cylinder
>12     long    x               \b, track size %d bytes
>16     byte    x               \b, device type 33%2.2X

0       string  CKD_S370        Hercules CKD DASD shadow file
>8      long    x               \b, %d heads per cylinder
>12     long    x               \b, track size %d bytes
>16     byte    x               \b, device type 33%2.2X

# Squeak images and programs - etoffi@softhome.net
0	string		\146\031\0\0	Squeak image data
0	search/1	'From\040Squeak	Squeak program text

# partimage: file(1) magic for PartImage files (experimental, incomplete)
# Author: Hans-Joachim Baader <hjb@pro-linux.de>
0		string	PaRtImAgE-VoLuMe	PartImage
>0x0020		string	0.6.1		file version %s
>>0x0060	lelong	>-1		volume %d
#>>0x0064 8 byte identifier
#>>0x007c reserved
>>0x0200	string	>\0		type %s
>>0x1400	string	>\0		device %s,
>>0x1600	string	>\0		original filename %s,
# Some fields omitted
>>0x2744	lelong	0		not compressed
>>0x2744	lelong	1		gzip compressed
>>0x2744	lelong	2		bzip2 compressed
>>0x2744	lelong	>2		compressed with unknown algorithm
>0x0020		string	>0.6.1		file version %s
>0x0020		string	<0.6.1		file version %s

# DCX is multi-page PCX, using a simple header of up to 1024
# offsets for the respective PCX components.
# From: Joerg Wunsch <joerg_wunsch@uriah.heep.sax.de>
0	lelong	987654321	DCX multi-page PCX image data

# Simon Walton <simonw@matteworld.com>
# Kodak Cineon format for scanned negatives
# http://www.kodak.com/US/en/motion/support/dlad/
0	lelong  0xd75f2a80	Cineon image data
>200	belong  >0		\b, %d x
>204	belong  >0		%d


# Bio-Rad .PIC is an image format used by microscope control systems
# and related image processing software used by biologists.
# From: Vebjorn Ljosa <vebjorn@ljosa.com>
# BOOL values are two-byte integers; use them to rule out false positives.
# http://web.archive.org/web/20050317223257/www.cs.ubc.ca/spider/ladic/text/biorad.txt
# Samples: http://www.loci.wisc.edu/software/sample-data
14	leshort <2
>62	leshort <2
>>54	leshort 12345		Bio-Rad .PIC Image File
>>>0	leshort >0		%d x
>>>2	leshort >0		%d,
>>>4	leshort =1		1 image in file
>>>4	leshort >1		%d images in file

# From Jan "Yenya" Kasprzak <kas@fi.muni.cz>
# The description of *.mrw format can be found at
# http://www.dalibor.cz/minolta/raw_file_format.htm
0	string	\000MRM			Minolta Dimage camera raw image data

# Summary: DjVu image / document
# Extension: .djvu
# Reference: http://djvu.org/docs/DjVu3Spec.djvu
# Submitted by: Stephane Loeuillet <stephane.loeuillet@tiscali.fr>
# Modified by (1): Abel Cheung <abelcheung@gmail.com>
0	string	AT&TFORM
>12	string	DJVM		DjVu multiple page document
!:mime	image/vnd.djvu
>12	string	DJVU		DjVu image or single page document
!:mime	image/vnd.djvu
>12	string	DJVI		DjVu shared document
!:mime	image/vnd.djvu
>12	string	THUM		DjVu page thumbnails
!:mime	image/vnd.djvu