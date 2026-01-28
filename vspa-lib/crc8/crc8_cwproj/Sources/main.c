// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2020 - 2025 the original authors

/*
% bitwise_CRC8 calculates the CRC8 bitwise based on generator
% polynomial 0x107 for input data stream
*/

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include <vspa/intrinsics.h>

#include "vcpu.h"
#include "ippu.h"
#include "host.h"

#include "CRC8.h"

volatile uint32_t size, data1, data2;
volatile uint_fast8_t crc;

void main(void) {
    host_reset();
    crc = crc8_encode(data1, data2, size);
    __asm volatile("fnop .asmvol");
    __asm volatile("fnop .asmvol");
    __asm volatile("fnop .asmvol");

    __swbreak();

    __done();
}
