// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2016 - 2025   NXP Semiconductors

// =============================================================================
//! @file       CRC8_HT_SIGA.c
//! @brief      Functions for bitwise 8 bits CRC calculation.
//! @author     NXP Semiconductors
// =============================================================================
#include "stdint.h"

uint_fast8_t crc8_encode(uint32_t data1, uint32_t data2, uint32_t size) {
    uint_fast8_t crc;
    uint32_t gen_poly = 0xE0;
    uint32_t data_temp;
    int i;
    if (size == 34) {
        data_temp = data1 ^ 0x000000FF;
        for (i = 0; i < 2; i++) {
            if ((data_temp & 0x00000001) != 0) {
                data_temp >>= 1;
                if (((data2 >> i) & 0x00000001) != 0) {
                    data_temp += 0x80000000;
                }
                data_temp ^= gen_poly;
            } else {
                data_temp >>= 1;
                if (((data2 >> i) & 0x00000001) != 0) {
                    data_temp += 0x80000000;
                }
            }
        }
        for (i = 0; i < 32; i++) {
            if ((data_temp & 0x00000001) != 0) {
                data_temp >>= 1;
                data_temp ^= gen_poly;
            } else {
                data_temp >>= 1;
            }
        }
        crc = data_temp & 0xFF;
        crc ^= 0xFF;

    } else {
        data_temp = data1 ^ 0x000000FF;

        for (i = 0; i < size; i++) {
            if ((data_temp & 0x00000001) != 0) {
                data_temp >>= 1;
                data_temp ^= gen_poly;
            } else {
                data_temp >>= 1;
            }
        }
        crc = data_temp & 0xFF;
        crc ^= 0xFF;
    }

    return (crc);
}
