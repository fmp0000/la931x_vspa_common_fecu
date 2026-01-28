% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function y_i = ch_sign(x_i, N)

y_i = x_i;
y_i.s = ~x_i.s;
y_i.val = bitset(y_i.val, N, y_i.s);

return;
