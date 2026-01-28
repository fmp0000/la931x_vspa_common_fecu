// SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
// Copyright 2020 - 2025 the original authors

/*
 * Header file: prototypes
 *
 */

void swap(int *a, int *b);
int myadd(int a, int b);

void swap(int *a, int *b) {
    int c = *a;
    *a = *b;
    *b = c;
}

int myadd(int a, int b) { return (a + b); }
