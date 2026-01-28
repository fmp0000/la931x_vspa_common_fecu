% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright NOTE - 2025 the original authors
function [cycleCounts]  = extract_cycle_counts(filepath, routineNames, maxLineCount)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% DESCRIPTION: 
%   Parses the ISS output file specified in the filepath string, and 
%   extracts the cycles between jsr and rts for each call to each 
%   routine specified in routineNames.   
%
%   NOTE this version of extract_cycle_counts cannot extract counts
%   from nested routines of interest of interest.  However, it does 
%   properly handle routines of interest that are inside routines not in 
%   routineNames list, or nested calls to routines that are not in 
%   routineNames list inside a routine of interest.
%   
%
% INPUTS
%   filepath: string with a path and filename to the iss output file to
%      be scanned for the extraction
%
%   routineNames:  a string or a (1xN) cell array of strings naming 
%      routines of interest.  For each call to each routine of interest, 
%      extract_cycle_counts will extract the cycles for that call and
%      append the count to a column vector of cycle counts maintained for
%      that routine.
%
%   maxLineCount:  optional integer specifying the maximum number of lines
%      from the ISS file to scan (useful to limit extraction times for
%      very big ISS files).   
%         if maxLineCount ==0 (default)
%            routine reads until the end of the ISS file
%         if maxLineCount ~=0
%            routine reads up to maxLineCount lines or the end-of-file,
%            whichever occurs first
% OUTPUTS
%
%   cycleCounts: {1xN} cell array of column vectors of cycle counts.
%      The i'th cell holds the vector of cycle counts for all the calls
%      found for the i'th routine in routineNames.
% 
% 
% NOTE: This utility is PRELIMINARY and SUBJECT TO CHANGE.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('maxLineCount','var')
    maxLineCount = 0;
end
if ~exist(filepath,'file')
    error( fprintf('cannot find the file %s',filepath) );
end
if isempty(routineNames)
    error( 'routineName must be a non-empty cell array or a single non-empty string' );
end
if ~iscell(routineNames)
    routineNames = { routineNames }; 
end

numRoutines = length(routineNames);
cycleCounts = cell(1,numRoutines);

% Open the ISS output file
fid = fopen(filepath, 'rt');
if ( ~ fid  )
    error( fprintf('cannot open the file %s for reading',filepath) );
end

% Scan through the ISS output file looking for routines of interest
insideRoutine = false;
jsrRegEx = 'jsr _(\w+)';
lineCount = 0;
while lineCount <= maxLineCount
    tline = fgetl(fid);
    if ~ischar(tline), break, end  % end-of-file
    
    if ~insideRoutine
        % Look for any jsr line
        [ match tok ] = regexp(tline, jsrRegEx, 'match', 'tokens');
        
        if ~isempty(match)
           % See if this jsr calls one of the routines in routineNames
           name = tok{1}{1};
           for kk = 1 : numRoutines
               [ matchName ] = regexp(name, routineNames{kk}, 'match');
               if ~isempty(matchName)

                  % We have a found a call to a routine of interest
                  % so we capture its start cycle, and break from the
                  % for-loop (no need to check other names in the list)
                  rtsRegEx = sprintf('_%s:\\s+.*\\s+rts;',name);
                  insideRoutine = true;
                  startCycle = extractCurrentCycle(tline);
                  nameIndex = kk;
                  break;  
                  
               end
           end
        end
        
    else
        % Look for the rts from the routine we are inside. 
        % (Note that the rtsRegEx includes the label of the routine we 
        % are inside, so any rts's we encounter for nested calls will
        % not trigger our match.)
        [ match tok ] = regexp(tline, rtsRegEx, 'match', 'tokens');
        if ~isempty(match)
           insideRoutine = false;
           endCycle = extractCurrentCycle(tline);
           cycleCount = (endCycle - startCycle + 1);
           
           if isempty( cycleCounts{nameIndex} )
               cycleCounts{nameIndex} = cycleCount;
           else
               cycleCounts{nameIndex} = [ cycleCounts{nameIndex}; cycleCount];
           end
        end
    end
    
    % Increment lineCount only for non-zero maxLineCounts.  
    % This makes the "while" loop run until end-of-file when maxLineCounts==0
    if maxLineCount
        lineCount = lineCount + 1;
    end
end
fclose(fid);
        

return;



%==========================================================================
% Local function extractCurrentCycle 
%   Extracts the current cycle count from a line of ISS output
%
%==========================================================================
function [ crntCycle  ] = extractCurrentCycle(line)
   [ match tok ] = regexp(line, 'CYC:\s+(\d+)\s+OP:', 'match', 'tokens');
   if isempty(match)
       error('ISS output line of intereset does not include CYC: specifier');
   end
   
   strCycles = tok{1}{1};
   crntCycle = sscanf(strCycles,'%d');
   
return;

