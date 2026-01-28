% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [result status] = sysMakeClean(options, build_dir, home_dir)
% Cleans build_dir using the make environment.  sysMakeClean needs to run
% in the directory that contains your makefile.  sysMakeClean generates a
% make command line that will set the make BUILDDIR = build_dir and that
% includes any other command-line options you specifyin the options
% input parameter.
%
% The build_dir path can be relative to the makefile directory or it can be
% absolute.
%
% If the make command fails, sysMakeClean issues an error.
%
% If the optional home_dir parameter is included and is not an empty
% string, then in such error cases, sysMakeClean will
% cd to home_dir before calling error().
%
% sysMakeClean is part of the dual-OS utilities and works in
%   either GLNXA64 or PCWIN environments.
%
% NOTE: This utility is PRELIMINARY and SUBJECT TO CHANGE.


if nargin < 3
   home_dir = '';
end

options = [options ' clean'];

sysMake(options, build_dir, home_dir);
