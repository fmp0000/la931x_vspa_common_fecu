% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function dataBits_final = bits2hex(bits)
    dataBits_bin = dec2bin(bits);
    dataBits_bin_reshape = (reshape(dataBits_bin, 4, []).');
    dataBits_hex = dec2hex(bin2dec(dataBits_bin_reshape));
    dataBits_final = lower((reshape(dataBits_hex, 8, []).'));
    %dlmwrite(filename,dataBits_final,'delimiter','');
end
