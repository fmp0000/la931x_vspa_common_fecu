% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [result status] = sysCustomDualCommand(linuxCmdStr, winCmdStr, home_dir)
% Runs the linuxCmdStr or winCmdStr based on Operating System returned by
% 'computer'.
%
% If the command fails, sysCustomDualCommand issues an error.
%
% If the optional home_dir parameter is included and is not an empty
% string, then in such error cases, sysDualCommand will
% cd to home_dir before calling error().
%
% sysCleanRunDir is part of the dual-OS utilities and works in following
% environments (as returned by matlab's "computer" command:
%   GLNX86   (32-bit linux)
%   GLNXA64  (64-bit linux)
%   PCWIN    (windows).
%
% NOTE: This utility is PRELIMINARY and SUBJECT TO CHANGE.

if nargin < 3
   home_dir = '';
end

osId = computer;

switch osId
    case {'GLNXA64', 'GLNX86'}
        cmdstr = linuxCmdStr;
    case {'PCWIN', 'PCWIN64'}
        cmdstr = winCmdStr;
    otherwise
        if ~isempty(home_dir)
            cd(home_dir);
        end
        error('Unrecognized Operating System!');
end

[result, status] =  system(cmdstr);
if ( result ~= 0 )
   if ~isempty(home_dir)
       cd(home_dir);
   end
   error( 'sysDualCommand failed for the command %s !\n%s', cmdstr, status );
end
