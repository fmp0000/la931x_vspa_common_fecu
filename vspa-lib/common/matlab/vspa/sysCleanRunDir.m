% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [result status] = sysCleanRunDir(run_dir, home_dir)
% Cleans the directory specified by run_dir, including
% write-protected files and hidden files.  The system command
% used does not fail if run_dir is already empty.  The path run_dir must
% be either relative to the current directory or absolute.
%
% If sysCleanRunDir encounters problems, it issues an error.
%
% If the home_dir parameter is included and is not an empty
% string, then in such error cases, sysCleanRunDir will
% cd to home_dir before calling error().
%
% sysCleanRunDir is part of the dual-OS utilities and works in following
% environments (as returned by matlab's "computer" command:
%   GLNX86   (32-bit linux)
%   GLNXA64  (64-bit linux)
%   PCWIN    (windows).
%
% NOTE: This utility is PRELIMINARY and SUBJECT TO CHANGE.

if nargin < 2
   home_dir = '';
end

% convert run_dir path slashes to those required by current OS
curdir = pwd;
cd(run_dir);
run_dir = pwd;
cd(curdir);

osId = computer;

switch osId
    case {'GLNXA64', 'GLNX86'}
        cmdstr = sprintf('find %s -type f -name "*" -o -name ".*"  ! -name ".buildDirExists" | xargs rm -f',run_dir);
    case {'PCWIN', 'PCWIN64'}
        cmdstr = sprintf('del /Q /F %s\\*.*', run_dir);
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
   error( 'sysCleanRunDir failed for directory %s !\n%s', run_dir, status );
end
