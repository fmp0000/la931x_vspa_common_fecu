% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function output_dram = runCASLinux(strSWPath, strRunPath, strCASPath, nAU, cleanflags, buildflags, ...
%                                     struct_input, struct_output, auprec, inputreg, traceon)
%
% DESCRIPTION:
%   Build and Run simulation on Linux
%
% INPUTS:
%   strSWPath: Base path for software
%
%   strRunPath: Base path for "run" directory for current project
% 
%   strCASPath: Base path to where the CAS is installed
% 
%   nAU: Number of AU
% 
%   cleanflags: String containing input arguments for "make clean"
% 
%   buildflags: String containing input arguments for "make"
% 
%   struct_input: Array of structures containing input vectors to the
%   simulation. Each structure element has the following fields
%       strAddr: String denoting the variable name that is being retrieved 
%       
%       strPrec: Precision of the variable being written. One of
%       {'half_fixed', 'single', 'uint', 'double'}
% 
%       strType: Data type of variable being written. One of {'real',
%       'complex'}
% 
%       data: Data vector
% 
%   struct_output: Array of structures containing output vectors to be
%   retrieved from the simulation. Each structure element has the following
%   fields 
%       strAddr: String denoting the variable name that is being retrieved 
%       
%       strPrec: Precision of the variable being retrieved. One of
%       {'half_fixed', 'single', 'uint', 'double'}
% 
%       strType: Data type of variable being retrieved. One of {'real',
%       'complex'}
% 
%       size: Size of data vector being retrieved
%
%   auprec: String containing precision of core. One of {'std', 'high'}
% 
%   inputreg: Array of integers to be passed to the simulator. The values
%   are mapped sequentially to the IP register set GP_OUT0, GP_OUT1, ...
%
%   traceon: 0 => Tracing OFF, 1 => Tracing ON
% 
%   runSim (Optional): 0 => only generates input data vectors. simulator is
%   not run; 1 => runs simulator (DEFAULT)
%
% OUTPUTS:
%   output_dram: Array of structures containing requested outputs. Each
%   structure element has the following fields
%       strAddr: String denoting variable name (identical to what was
%       passed in struct_output.strAddr)
% 
%       data: Data vector
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output_dram = runCASLinux(strSWPath, strRunPath, strCASPath, nAU, cleanflags, buildflags, ...
                                    struct_input, struct_output, auprec, inputreg, traceon, runSim)

if ~exist('runSim', 'var')
    runSim = 1;
end
output_dram = repmat(struct('strAddr', '', 'data', []), numel(struct_output), 1);

%% clean up run directory
sysCleanRunDir(strRunPath);

%% build & synchronize memory labels
curr_dir = pwd;

cd('../');
fprintf('** Building code **\n');
makestr = sprintf(' -s %s', cleanflags);
sysMakeClean(makestr, strRunPath, curr_dir);

makestr = sprintf(' -s %s', buildflags);
sysMake(makestr, strRunPath, curr_dir);

cd(strRunPath);
clear ruby_vardef;
ruby_vardef;

cd(curr_dir);

%% initialize and write data to dram
dramIn = dmemReadInitFile( fullfile( strRunPath, 'ruby_dmem.hex' ), MEM__data_start, 'random' );
for ii = 1:numel(struct_input)
    if ~isfield(struct_input(ii), 'ref')
        struct_input(ii).ref = 0;
    end
    
    if struct_input(ii).ref == 1
        continue;
    end
    
    eval(sprintf('inAddr = MEM_%s;', struct_input(ii).strAddr));

    if strcmp(struct_input(ii).strType, 'real')
        dramIn = dmemWriteReal(dramIn, inAddr, struct_input(ii).data, struct_input(ii).strPrec);
    else
        dramIn = dmemWriteComplex(dramIn, inAddr, struct_input(ii).data, struct_input(ii).strPrec);
    end
end
fname = sprintf('%s/test_input.dram', strRunPath);
dmemSaveHexFile(dramIn, fname);

if ~runSim
    return;
end

% copy required files to run directory
sysGetDefaultIpm(strSWPath, strRunPath, curr_dir);

%% generate iss script
fname = sprintf('%s/iss_script', strRunPath);
fid = fopen(fname, 'wt');
fprintf(fid, '// AUTO GENERATED TEST SCRIPT from MATLAB\n\n');

% set input parameters to pass to ISS
% fprintf(fid, 'randomize all\n\n');
for ii = 1:length(inputreg)
    fprintf(fid, 'set GP_OUT_%d %d\n', ii-1, inputreg(ii));
end
    
fprintf(fid, 'clear dram\n');
if strcmp(auprec, 'std')
    fprintf(fid, 'set standard_precision\n');
else
    fprintf(fid, 'set high_precision\n');
end

fprintf(fid, 'load pram ruby_pram.hex\n');
fprintf(fid, 'load labels ruby.plb\n');
fprintf(fid, 'disp hex\n');
fprintf(fid, 'overwrite dram 0 test_input.dram\n');
fprintf(fid, 'set rt_mode 0\n');
fprintf(fid, 'disp float\n');
fprintf(fid, 'print on\n');
if traceon
    fprintf(fid, 'trace on 1\n');
else
    fprintf(fid, 'trace off\n');
end
fprintf(fid, 'go\n');
fprintf(fid, 'display hex\n');
fprintf(fid, 'save dram vspa_dram_final.dram 0 131071\n');
fprintf(fid, 'exit\n');
fclose(fid);

curr_dir = pwd;
cd(strRunPath);

%% run ISS
fprintf('** Running ISS **\n');
sysRunIss(strCASPath, nAU, 'iss_script', 'iss.out', curr_dir);
cd(curr_dir);

%% extract assembly outputs
output_filename = sprintf('%s/vspa_dram_final.dram', strRunPath);
dramOut = dmemReadHexFile(output_filename, 0);
for ii = 1:numel(struct_output)
    eval(sprintf('outAddr = MEM_%s;', struct_output(ii).strAddr));

    output_dram(ii).strAddr = struct_output(ii).strAddr;
    if strcmp(struct_output(ii).strType, 'real')
        output_dram(ii).data = dmemReadReal(dramOut, outAddr, struct_output(ii).size, struct_output(ii).strPrec);
    else
        output_dram(ii).data = dmemReadComplex(dramOut, outAddr, struct_output(ii).size, struct_output(ii).strPrec);
    end
end


end
