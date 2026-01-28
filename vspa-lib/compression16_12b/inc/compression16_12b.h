// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2025  NXP

#ifndef COMP16_12BIT_H_
#define COMP16_12BIT_H_

#define COMP16_12BIT_BLOCK_SIZE 3072 // bytes, 24 lines

/********************************************************************************
 * Compress 16bit into 12bit by removing the 4 LSB
 * nb:	    number of input blocks, each block is with size of COMP16_12BIT_BLOCK_SIZE
 * buf_16b:	input buffer base address, line aligned, buffer size must be nb*COMP16_12BIT_BLOCK_SIZE
 *          input data format is 16-bit half fixed.
 * buf_12b:	output buffer base address, line aligned, buffer size must be nb*(COMP16_12BIT_BLOCK_SIZE/16*12)
 *          output data format is unsigned short integer (2's complement)
 *          buf_12b can be same as buf_16b for in-place compression
 *
 * Algorithm (compression):
 *   Input, unsigned short buf_16b[N][24][64], will be compressed into output, unsigned short buf_12b[N][18][64]
 *   VSPA will convert input data from half_fixed to 2's complement. Host doesn't need this step
 *   buf_12b[n][i][j] = (buf_16b[n][i][j] & 0xFFF0) | ((buf_16b[n][i/3+18][j] >> (4+(i%3)*4)) & 0xF);
 *   n ranges from 0 to N-1, i from 0 to 17, j from 0 to 63
 *   Example:
 *   		 input                          output
 *   LINE0:  0xabcd 0xefgh .... 			0xabcK 0xefgO ....
 *   LINE1:  0xijkl 0xmnop .... 			0xijkJ 0xmnoN ....
 *   LINE2:  0xqrst 0xuvwx					0xqrsI 0xuvwM ....
 *   ....									....
 *   LINE17: 0xABCD 0xEFGH ....				0xABCQ 0xEFGU ....
 *   LINE18: 0xIJKL 0xMNOP ....
 *   ....
 *   LINE23: 0xQRST 0xUVWX ....
 *
 * cycle count: ~200 per block, 0.26 per sample.
 *********************************************************************************/
void comp16_12b(unsigned short *buf_12b, unsigned short *buf_16b, unsigned int nb);

/********************************************************************************
 * De-compress 12bit into 16bit by adding 4 LSB of 0
 * nb:	    number of input blocks, each block is with size of COMP16_12BIT_BLOCK_SIZE/16*12
 * buf_12b:	input buffer base address, line aligned, buffer size must be nb*(COMP16_12BIT_BLOCK_SIZE/16*12)
 *          input data format is unsigned short integer (2's complement)
 * buf_16b:	output buffer base address, line aligned, buffer size must be nb*COMP16_12BIT_BLOCK_SIZE
 *          output data format is 16-bit half fixed.
 *          buf_16b can overlap with buf_12b for in-place compression by putting input data at the end of
 *          output buffer, for example, for nb=1, input data is 2304, output data size is 3072, a single buffer
 *          of size 3072 can be used for in-pace de-compression by putting input data from offset 768 bytes
 *          of the buffer, and output data can be put from beginning of the buffer. For nb=2, put input data from
 *          offset 768*2 and output data from beginning, etc.
 *
 * Algorithm (decompression):
 *   To de-compress buf_12b[N][18][64] back to unsigned short buf_16b[N][24][64]:
 *   buf_16b[n][i][j] = buf_12b[n][i][j] & 0xFFF0;
 *   n ranges from 0 to N-1, i from 0 to 17, j from 0 to 63
 *
 *   buf_16b[n][i][j] = ((buf_12b[n][(i-18)*3 + 0][j] & 0xF) << 4) |
 *                     ((buf_12b[n][(i-18)*3 + 1][j] & 0xF) << 8) |
 *                     ((buf_12b[n][(i-18)*3 + 2][j] & 0xF) << 12);
 *   n ranges from 0 to N-1, i from 18 to 23, j from 0 to 63
 *   VSPA will convert output data from 2's complement to half_fixed. Host doesn't need this step
 *********************************************************************************/
void decomp12_16b(unsigned short *buf_16b, unsigned short *buf_12b, unsigned int nb);

#endif
