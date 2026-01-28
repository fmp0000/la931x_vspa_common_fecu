% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [result status] = sysGetDefaultIpm(sw_path, run_dir, home_dir)
% Copies the default .ipm from the sw_path tree into run_dir with forcing.
%
% If the command fails, sysGetDefaultIpm issues an error.
%
% If the optional home_dir parameter is included and is not an empty
% string, then in such error cases, sysGetDefaultIpm will
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
        cmdstr = sprintf('\\cp -f %s/common/tools/.ipm %s/.ipm', sw_path, run_dir);
    case {'PCWIN', 'PCWIN64'}
        cmdstr = sprintf('copy /Y "%s\\common\\tools\\.ipm" %s\\.ipm', sw_path, strrep( run_dir, '/', filesep ));
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
   error( 'sysGetDefaultIpm failed to copy the .ipm file to %s !\n%s', run_dir, status );
end
