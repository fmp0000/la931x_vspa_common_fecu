% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function output_dram = runCASWin(strCWProjPath, strCWPath, strCWWorkspacePath, strTCLSHPath, ...
%                                     strToolsPath, strDebugConfig, struct_input, struct_output, inputreg, runSim)
%
% DESCRIPTION:
%   Build and Run simulation on Windows Code Warrior
%
% INPUTS:
%   strCWProjPath: String containing base path for the code warrior project
%
%   strCWPath: String containing base path for directory containing code
%   warrior IDE executables
% 
%   strCWWorkspacePath: String containing base path for code warrior
%   workspace
% 
%   strTCLSHPath: String containing base path for TCL command shell
% 
%   strToolsPath: String containing base path for where common tcl scripts
%   are placed
% 
%   strDebugConfig: String containing name of project debug/launch
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
%   inputreg: Array of integers to be passed to the simulator. The values
%   are mapped sequentially to the IP register set GP_OUT0, GP_OUT1, ...
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
function output_dram = runCASWin(strCWProjPath, strCWPath, strCWWorkspacePath, strTCLSHPath, ...
                                    strToolsPath, strDebugConfig, struct_input, struct_output, inputreg, runSim)

if ~exist('runSim', 'var')
    runSim = 1;
end
output_dram = repmat(struct('strAddr', '', 'data', []), numel(struct_output), 1);

%% generate automation TCL script
fname = sprintf('%s/run/run_cw_sim.tcl', strCWProjPath);
fid = fopen(fname, 'wt');
fprintf(fid, '## AUTO GENERATED TCL SCRIPT from MATLAB\n\n');

fprintf(fid, 'source \"%s/cwautomation.tcl\"\n\n', strToolsPath);
fprintf(fid, 'set cwDir \"%s\"\n', strCWPath);
fprintf(fid, 'set cwWorkspace \"%s\"\n', strCWWorkspacePath);
fprintf(fid, 'set cwProj \"%s\"\n', strCWProjPath);

fprintf(fid, 'set MyBuildTarget {debug}\n');
fprintf(fid, 'puts \"Start building the project\"\n');
fprintf(fid, 'buildProject $cwDir $cwWorkspace $cwProj $MyBuildTarget\n');
fprintf(fid, 'puts \"Start running the application\"\n');
fprintf(fid, 'set execStatus [catch {exec $cwDir/cwide.exe -data $cwWorkspace -vmargsplus -Dcw.script=\"$cwProj/run/launch_cwproject.tcl\"} execError]\n');

fprintf(fid, '\n');
fclose(fid);

%% generate launching TCL script
fname = sprintf('%s/run/launch_cwproject.tcl', strCWProjPath);
fid = fopen(fname, 'wt');
fprintf(fid, '## AUTO GENERATED TCL SCRIPT from MATLAB\n\n');

fprintf(fid, 'source \"%s/libsim.tcl\"\n\n', strToolsPath);
fprintf(fid, 'set cwProj \"%s\"\n', strCWProjPath);
fprintf(fid, 'debug %s\n', strDebugConfig);
fprintf(fid, 'sim_init_config\n\n');

% load input files
for ii = 1:numel(struct_input)
    if ~isfield(struct_input(ii), 'ref')
        struct_input(ii).ref = 0;
    end
    if isempty(struct_input(ii).ref)
        struct_input(ii).ref = 0;
    end
    
    switch struct_input(ii).strPrec
        case {'half_fixed'}
            dmemSz = length(struct_input(ii).data)/2;
        case {'single', 'uint'}
            dmemSz = length(struct_input(ii).data);
        case {'double'}
            dmemSz = length(struct_input(ii).data)*2;
    end
    if strcmp(struct_input(ii).strType, 'real')
        dramIn = dmemCreate(0, dmemSz);
        dramIn = dmemWriteReal(dramIn, 0, struct_input(ii).data, struct_input(ii).strPrec);
    else
        dramIn = dmemCreate(0, dmemSz*2);
        dramIn = dmemWriteComplex(dramIn, 0, struct_input(ii).data, struct_input(ii).strPrec);
    end
    fname = sprintf('%s/test_vectors/input_data_%d.hex', strCWProjPath, ii);
    dmemSaveHexFile(dramIn, fname);
    
    if ~struct_input(ii).ref
        fprintf(fid, 'sim_dram_load \"$cwProj/test_vectors/input_data_%d.hex\" [evaluate #x %s]\n', ii, struct_input(ii).strAddr);
    end
end

% set input parameters to pass to simulator
pctStr = '%x';
for ii = 1:length(inputreg)
    fprintf(fid, 'reg GP_OUT%d=[format %s %d]\n', ii-1, pctStr, inputreg(ii));
end

fprintf(fid, '\ngo\n');

% save output files
for ii = 1:numel(struct_output)
    switch struct_output(ii).strPrec
        case {'half_fixed'}
            dmemSz = struct_output(ii).size/2;
        case {'single', 'uint'}
            dmemSz = struct_output(ii).size;
        case {'double'}
            dmemSz = struct_output(ii).size*2;
    end
    
    if strcmp(struct_output(ii).strType, 'complex')
        dmemSz = dmemSz*2;
    end
        
    fprintf(fid, 'sim_dram_save \"$cwProj/test_vectors/output_data_%d.hex\" [evaluate #x %s] %d\n', ii, struct_output(ii).strAddr, dmemSz);
end

fprintf(fid, '\nkill\n');
if runSim
    fprintf(fid, 'q\n');
end
fclose(fid);

%% run CW test bench
if ~runSim
    return;
end

strCmd = sprintf('%s/tclsh %s/run/run_cw_sim.tcl', strTCLSHPath, strCWProjPath);
system(strCmd);                                

%% generate output structure
for ii = 1:numel(struct_output)
    output_dram(ii).strAddr = struct_output(ii).strAddr;
    output_filename = sprintf('%s/test_vectors/output_data_%d.hex', strCWProjPath, ii);
    dramOut = dmemReadHexFile(output_filename, 0);
    
    if strcmp(struct_output(ii).strType, 'real')
        output_dram(ii).data = dmemReadReal(dramOut, 0, struct_output(ii).size, struct_output(ii).strPrec);
    else
        output_dram(ii).data = dmemReadComplex(dramOut, 0, struct_output(ii).size, struct_output(ii).strPrec);
    end
end

end
