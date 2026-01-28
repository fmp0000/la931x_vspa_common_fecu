% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function dmemOut = dmemCreate(startAddr, numWords, checkSizeLimit)
% Dmem access utility for creating a dmem image structure used by other 
% dmem* layer utilities to write matlab data into the ISS DMEM.
% The output dmemOut image will start at the specified starting address 
% and contain storage for numWords of full-word (i.e. 32-bit word) memory.
%
% If (startAddr + numWords) exceeds the maximum size of DMEM (2^17 words),
% an error is issued.
%
% dmemCreate can be used to create total or partial DMEM images.  See the
% useage examples.
%
%  
% INPUTS:
%
%   startAddr:  full-word DMEM address (integer) pointing to the first word
%      in DMEM that the dmemOut structure will represent.
%      
%   numWords: integer specifying the number of full-word (i.e. 32-bit word) 
%      memory locations contained in dmemOut.
%
%
%  checkSizeLimit (optional): boolean flag to enable/disable dmemCreate's
%      check that startAddr+numWords fits into DMEM.  The default is true.
%      checkSizeLimit==false can be used to create dmemOut images larger
%      the DMEM limit (e.g. for DMA input files)
%
% OUTPUT:
%
%   dmemOut:  dmem* access layer structure representing DMEM from 
%       [ startAddr : (startAddr + numWords - 1) ].
%
% EXAMPLE USE:
%   A typical call to produce a complete DMEM image (covering all of DMEM
%   that the matlab testbench should access):
%
%       dram = dmemCreate( 0, MEM__r0data_bottom );
%
%   A typical call to produce a partial DMEM image, e.g. for updating a
%   specific buffer after a breakpoint:
%
%       dramXbuff = dmemCreate( MEM_x_buff, SIZ_x_buff );
%
%   Whenever you use dmemCreate(startAddr, numWords) to produce a DMEM 
%   image, you should use 
%        overwrite dram < 2 * startAddr> filename
%   to load the hex file for that image.
%
% SEE ALSO:
%      dmemWriteReal, dmemWriteComplex, dmemSaveHexFile,
%      dmemReadReal,  dmemReadComplex,  dmemReadHexFile
%     
% NOTE: This utility is PRELIMINARY and SUBJECT TO CHANGE.



% dmemIn struct - for internal use:  
%   base  ( full-word address pointing to first word )
%   data  ( vector holding storage data: one uint32 per memory location )

if nargin <3
    checkSizeLimit = false;
end

dmemOut = struct;
dmemOut.base = startAddr;
dmemOut.data = zeros(numWords,1);

if checkSizeLimit && ( startAddr + numWords > 2^17 )
    error('startAddr + numWords exceeds size of all DMEM');
end

return


    
    
    
    
    
    
