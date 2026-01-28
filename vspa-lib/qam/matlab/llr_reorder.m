% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function llrOut= llr_reorder(llrIn,M)
%
% DESCRIPTION:
%   This function reorders llrs from VSPA order to natural order. Note the
%   reordering here only works for LTE/5G std, NOT Wifi std.
%
% INPUTS:
%   llrIn: input vector of llrs
%   M:     qam modulation order: 1: BPSK, 2: QPSK, 4: 16-QAM 6: 64-QAM, ...
%
% OUTPUTS:
%   llrOut:  Output vector of llrs
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function llrOut= llr_reorder(llrIn,M)

llrOut=zeros(size(llrIn));
llrs=reshape(llrIn,64,[])';
switch M
    case 8
        b0=llrs(1:4:end,1:2:end);
        b1=llrs(1:4:end,2:2:end);
        b2=llrs(2:4:end,1:2:end);
        b3=llrs(2:4:end,2:2:end);
        b4=llrs(3:4:end,1:2:end);
        b5=llrs(3:4:end,2:2:end);
        b6=llrs(4:4:end,1:2:end);
        b7=llrs(4:4:end,2:2:end);
        b0=b0';
        b1=b1';
        b2=b2';
        b3=b3';
        b4=b4';
        b5=b5';
        b6=b6';
        b7=b7';
        llrOut(1:8:end)=b0(:);
        llrOut(2:8:end)=b1(:);
        llrOut(3:8:end)=b2(:);
        llrOut(4:8:end)=b3(:);
        llrOut(5:8:end)=b4(:);
        llrOut(6:8:end)=b5(:);
        llrOut(7:8:end)=b6(:);
        llrOut(8:8:end)=b7(:);
    case 6
        b0=llrs(1:3:end,1:2:end);
        b1=llrs(1:3:end,2:2:end);
        b2=llrs(2:3:end,1:2:end);
        b3=llrs(2:3:end,2:2:end);
        b4=llrs(3:3:end,1:2:end);
        b5=llrs(3:3:end,2:2:end);
        b0=b0';
        b1=b1';
        b2=b2';
        b3=b3';
        b4=b4';
        b5=b5';
        llrOut(1:6:end)=b0(:);
        llrOut(2:6:end)=b1(:);
        llrOut(3:6:end)=b2(:);
        llrOut(4:6:end)=b3(:);
        llrOut(5:6:end)=b4(:);
        llrOut(6:6:end)=b5(:);
     case 4
        b0=llrs(1:2:end,1:2:end);
        b1=llrs(1:2:end,2:2:end);
        b2=llrs(2:2:end,1:2:end);
        b3=llrs(2:2:end,2:2:end);
        b0=b0';
        b1=b1';
        b2=b2';
        b3=b3';
        llrOut(1:4:end)=b0(:);
        llrOut(2:4:end)=b1(:);
        llrOut(3:4:end)=b2(:);
        llrOut(4:4:end)=b3(:);
    case 2
        llrOut=llrIn;
end

end
