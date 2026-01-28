% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [result status] = sysCopyFile(src_file_name, run_dir, targ_file_name, home_dir)
% Copies the file specified by src_file_name as run_dir/targ_file_name.
% src_file_name may  include the path to the file either relative to the
%        current dir or% absolute.
%
% targ_file_name contains only the filename (no path).
%
% The run_dir can be relative to the current directory or absolute.
%
% If the command fails, sysCopyFile issues an error.
%
% If the optional home_dir parameter is included and is not an empty
% string, then in such error cases, sysCopyFile will
% cd to home_dir before calling error().
%
% sysCleanRunDir is part of the dual-OS utilities and works in following
% environments (as returned by matlab's "computer" command:
%   GLNX86   (32-bit linux)
%   GLNXA64  (64-bit linux)
%   PCWIN    (windows).
%
% NOTE: This utility is PRELIMINARY and SUBJECT TO CHANGE.

% convert src_file_name path slashes to those required by current OS
[srcFilePath,fileName,fileExt] = fileparts(src_file_name);
src_file_name = [fileName fileExt];

curdir = pwd;
cd(srcFilePath);
srcFilePath = pwd;   % gets version of path compatible with underlying OS
cd(curdir);

cd(run_dir);
run_dir = pwd;
cd(curdir);


if nargin < 4
   home_dir = '';
end

osId = computer;

switch osId
    case {'GLNXA64', 'GLNX86'}
        cmdstr = sprintf('\\cp -f %s/%s %s/%s', srcFilePath, src_file_name, run_dir, targ_file_name);
    case {'PCWIN', 'PCWIN64'}
        cmdstr = sprintf('copy /Y %s\\%s %s\\%s', srcFilePath, src_file_name, run_dir, targ_file_name);
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
   error( 'sysCopyFile failed for command string %s!\n%s', cmdstr, status );
end
