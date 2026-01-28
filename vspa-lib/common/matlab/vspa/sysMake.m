% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [result status] = sysMake(options, build_dir, home_dir)
% Builds project code using the make environment.  sysMake needs to run
% in the directory that contains your makefile.  sysMake generates a make
% command line that will set the make BUILDDIR = build_dir and that includes
% any other options you specify.
%
% The build_dir path can be relative to the makefile directory or it can be
% absolute.
%
% If the make command fails, sysMake issues an error.
%
% If the optional home_dir parameter is included and is not an empty
% string, then in such error cases, sysMake will
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
        cmdstr = sprintf('make BUILDDIR=%s %s', build_dir, options);
    case {'PCWIN', 'PCWIN64'}
        % Check for a CYGWIN_HOME envvar.   If it does not exist,
        % we'll use the default cygwin install location.
        cygwin_home_dir = getenv('CYGWIN_HOME');
        if isempty(cygwin_home_dir)
           cygwin_home_dir = 'C:\\cygwin';
        end
		cmdstr = strrep( sprintf( '%s\\bin\\make BUILDDIR=%s %s', cygwin_home_dir, strrep( build_dir, '/', filesep ), options ), '\\', '\' );
    otherwise
        if ~isempty(home_dir)
            cd(home_dir);
        end
        error('Unrecognized Operating System!');
end

[result, status] =  system(cmdstr);
%fprintf('sysMake make output:\n%s',status);

if ( result ~= 0 )
   if ~isempty(home_dir)
       cd(home_dir);
   end
   error( 'sysMake failed with command line "%s" !\n%s', cmdstr, status );
end
