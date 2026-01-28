% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [result status] = sysRunIss(iss_path, auCount, script, outfile_name, home_dir)
% Runs the ISS in the current directory using the specified script and
% piping output to the specified output filename.  The ISS executable name
% is generated from the auCount.  If the output file exists, it is overwritten.
%
% If auCount = 0, then sysRunIss uses the linux default "vspa_iss".  This
% option is provided to support custom linux testing where you build the ISS using
% make directly.  Using auCount=0 in windows will generate an error!
%
% If the command fails, sysRunIss issues an error.
%
% If the optional home_dir parameter is included and is not an empty
% string, then in such error cases, sysRunIss will
% cd to home_dir before calling error().
%
% sysCleanRunDir is part of the dual-OS utilities and works in following
% environments (as returned by matlab's "computer" command:
%   GLNX86   (32-bit linux)
%   GLNXA64  (64-bit linux)
%   PCWIN    (windows).
%
% NOTE: This utility is PRELIMINARY and SUBJECT TO CHANGE.

if nargin < 5
   home_dir = '';
end

osId = computer;

if auCount ~= 0
    execName = ['vspa' sprintf('%d',auCount) 'au_cas'];
else
    execName = 'vspa_cas';
end

switch osId
    case {'GLNXA64', 'GLNX86'}
        if strcmp( iss_path, '' )
            cmdstr = sprintf('rm -f %s ; %s %s > %s',outfile_name, execName, script, outfile_name);
        else
            cmdstr = sprintf('rm -f %s ; %s/bin/%s %s > %s',outfile_name, iss_path, execName, script, outfile_name);
        end
    case {'PCWIN', 'PCWIN64'}
        script  = strrep(script,'/','\');
        if strcmp( iss_path, '' )
            cmdstr  = sprintf('%s %s > %s', execName, script, outfile_name);
        else
            cmdstr  = sprintf('"%s\\bin\\%s" %s > %s', iss_path, execName, script, outfile_name);
        end
    otherwise
        if ~isempty(home_dir)
            cd(home_dir);
        end
        error('Unrecognized Operating System!');
end

[result, status] =  system(cmdstr);
if (  result ~= 0  )
   if ~isempty(home_dir)
       cd(home_dir);
   end
   error( 'sysRunIss failed for the command string "%s" !\n%s', cmdstr, status );
end
