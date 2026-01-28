% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% This script mexes the new bit-exact models.
%
% It assumes that you have run mex -setup and selected the correct compiler
% for your environment:
%     linux:    gcc
%     windows:  Visual Studio C++ (express is sufficient)

switch computer
    case { 'PCWIN', 'PCWIN64' }
        % Use default flags for Windows and compile in C++ mode:
        mex src\r_round.cpp    src\debug.cpp src\utility.cpp COMPFLAGS="$COMPFLAGS /D_YVALS"
        mex src\r_smac.cpp     src\debug.cpp src\utility.cpp COMPFLAGS="$COMPFLAGS /D_YVALS"
        mex src\r_smad.cpp     src\debug.cpp src\utility.cpp COMPFLAGS="$COMPFLAGS /D_YVALS"
        mex src\r_smam.cpp     src\debug.cpp src\utility.cpp COMPFLAGS="$COMPFLAGS /D_YVALS"
        mex src\r_dmac.cpp     src\debug.cpp src\utility.cpp COMPFLAGS="$COMPFLAGS /D_YVALS"
        mex src\r_dmad.cpp     src\debug.cpp src\utility.cpp COMPFLAGS="$COMPFLAGS /D_YVALS"
        mex src\r_dmam.cpp     src\debug.cpp src\utility.cpp COMPFLAGS="$COMPFLAGS /D_YVALS"
        mex src\r_dbl2cust.cpp src\debug.cpp src\utility.cpp COMPFLAGS="$COMPFLAGS /D_YVALS"
        mex src\r_cust2dbl.cpp src\debug.cpp src\utility.cpp COMPFLAGS="$COMPFLAGS /D_YVALS"
        mex src\r_recip.cpp    src\debug.cpp src\utility.cpp COMPFLAGS="$COMPFLAGS /D_YVALS"
    otherwise
        % Use default flags for Linux and compile in C++ mode:
        mex src/r_round.cpp    src/debug.cpp src/utility.cpp CFLAGS="\$CFLAGS"
        mex src/r_smac.cpp     src/debug.cpp src/utility.cpp CFLAGS="\$CFLAGS"
        mex src/r_smad.cpp     src/debug.cpp src/utility.cpp CFLAGS="\$CFLAGS"
        mex src/r_smam.cpp     src/debug.cpp src/utility.cpp CFLAGS="\$CFLAGS"
        mex src/r_dmac.cpp     src/debug.cpp src/utility.cpp CFLAGS="\$CFLAGS"
        mex src/r_dmad.cpp     src/debug.cpp src/utility.cpp CFLAGS="\$CFLAGS"
        mex src/r_dmam.cpp     src/debug.cpp src/utility.cpp CFLAGS="\$CFLAGS"
        mex src/r_dbl2cust.cpp src/debug.cpp src/utility.cpp CFLAGS="\$CFLAGS"
        mex src/r_cust2dbl.cpp src/debug.cpp src/utility.cpp CFLAGS="\$CFLAGS"
        mex src/r_recip.cpp    src/debug.cpp src/utility.cpp CFLAGS="\$CFLAGS"
end
