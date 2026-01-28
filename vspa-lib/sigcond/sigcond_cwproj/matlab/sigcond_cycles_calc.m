% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% function sigcond_cycles_calc
function cyc = sigcond_cycles_calc(type, N, decrate)

if strcmp(type, 'sigcond3')
    L = ceil((N-192)/64);
    
    s1 = 36 + 12*L;
    s2 = 12 + 4*L;
    s3 = 18 + 6*L;
    if decrate == 8
        ovhead = 58;
        s4 = 12 + 2*max(1, floor(N/64)-6);
        s5 = 16 + 8*max(1, ceil(N/128)-2);
        s6 = 12*ceil(N/256);
    elseif decrate == 4
        ovhead = 52;
        s4 = 12 + 2*max(1, floor(N/64)-6);
        s5 = 8*ceil(N/128);
        s6 = 0;
    elseif decrate == 2
        ovhead = 44;
        s4 = 2*floor(N/64);
        s5 = 0;
        s6 = 0;
    end
    
    cyc = ovhead + s1 + s2 + s3 + s4 + s5 + s6;
else
    error('Type not supported');
end
