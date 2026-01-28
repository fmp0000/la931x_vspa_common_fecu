% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright it - 2025 the original authors
function y = r_nco(f, L, phaseCount)
% r_nco: Vspa Numerically Controlled Oscillator.
% y = nco(f,L,phase) synthesizes an array of complex sinusoid samples 
% congruent with the Vspa hardware implementation.  That is, for each 
% f/phaseCount pair it returns the Vspa nco hardware-precision version of 
% the vector
%
%   exp ( - 2*pi*j * f * (phaseCount:(phaseCount+L-1) )
% 
% INPUTS:
% f - (Nx1) or (1xN) Vector of normalized cyclic frequencies (cycles/sample) 
%     in matlab double precision.  Each f may be positive or negative.  
%     Typically, normalized frequencies are used in the range [-1/2, +1/2],
%     but r_nco will accept any normalized frequency and map it correctly
%     into that range.
%
% L - Number of NCO samples to synthesize.
%
% phaseCount - Optional vector of initial phases of complex sinusoids.
%         The phaseCount is a 32 bit integer (in matlab double form)  
%         matching the hardware nco_phase register at the start of the  
%         y vector.  If present, phaseCount must have same dimensions as f.
%
% OUTPUTS:
% y - Array of complex sinusoid samples precision-limited 
%     to match the Vspa NCO hardware.  Shape of the output is governed by
%     the shape of the f input:
%           for f (Nx1):  y is (NxL).  That is, the i'th row contains L   
%                         complex sinusoids corresponding to the i'th 
%                         freq / phase pair.
%           for f (1xN):  y is (LxN).  That is, the i'th column contains L   
%                         complex sinusoids corresponding to the i'th 
%                         freq / phase pair.
%           for f scalar: y is (1xL).
%

%% Handle argument defaults and verify input size matches
if nargin == 2
    phaseCount = zeros(size(f));
end

if size(f) ~= size(phaseCount)
    error('f and phase inputs must have same shape');
end
    
%% Map every input f into the range [0,1) which is the natural range for
%  conversion to the hardware frequency representation.
while sum(f < 0) > 0
    f = (f < 0 ) .* (f + 1) + (f >= 0) .* f;
end
while sum(f >= 1) > 0
    f = (f < 1 ) .* f       + (f >= 1) .* (f - 1);
end

%% Build persistent tables
persistent y_cos m_cos y_sin m_sin M Q
if isempty(y_cos)
    % Number of entries for each table
    M=8;
    x1 = 0:2^(-M):1;
    % Number of bits for each entry in the table
    Q=17;
    % Cosine Tables
    y_cos=round(cos(pi*x1/4)/2^(-Q));
    m_cos= round(diff([cos(pi*x1/4) sqrt(2)/2])/2^(-Q));
    % Sine Tables
    y_sin=round(sin(pi*x1/4)/2^(-Q));
    m_sin= round(diff([sin(pi*x1/4) sqrt(2)/2])/2^(-Q));
end
   
%% Manage frequency*phase product wrapping
%
%  The NCO hardware calculates
%     exp( - 2*pi*j  *  (deltaQ * i )/2^32 )
%  where 
%     deltaQ = floor(frequency in cycles/sample * 2^32)
%     i = [phase:phase+L-1];
%     phase is 32-bit integer
% 
%  Because this is manifestly periodic in the deltaQ*i product with period 
%  2^32, the hardware is able to calculate the deltaQ*i product and then 
%  discard all but the lowest 32 bits.  
%
%  We duplicate that functionality here, being careful to avoid using
%  the matlab double representation for intermediate results since it 
%  cannot handle the full-product bitwidth.
%
deltaQ = floor(f*2^32);
maskHi = hex2dec('ffff0000');
maskLo = hex2dec('0000ffff');
mask32 = hex2dec('ffffffff');

deltaQlo = bitand(deltaQ,maskLo);
deltaQhi = bitand(deltaQ,maskHi);
phaseLo  = bitand(phaseCount,maskLo);
phaseHi  = bitand(phaseCount,maskHi);

delPhaseProduct = (deltaQlo .* phaseHi  + deltaQhi .* phaseLo ) + deltaQlo .* phaseLo;
delPhaseProduct = bitand(delPhaseProduct,mask32);

%% Calculate the fractional-cycle vector used as input to look-up tables.
%
%  Since we have already limited the deltaQ*i product correctly to 32 bits, 
%  we are free to calculate the fractional cycle vector
%     (deltaQ * [phaseCount:phaseCount+L-1] )/2^32  
%  directly (without relying on mod's of doubles which struggle with
%  precision-limiting for large deltaQ*phaseCount).  
%
%  Of course, for some values of deltaQ, phaseCount, and L, the values in 
%  the vector will exceed 32-bits, but that is okay as long as we don't  
%  exceed the 52-bit mantissa of the matlab double.  That sets the upper 
%  limit on how big L can be (but it's a pretty big limit).
%
r = size(f,1);
c = size(f,2);
if r>=c
    transposeOutput = 1;
    x = (repmat( delPhaseProduct ,1,L)  + repmat(deltaQ ,1,L).*repmat(0:L-1,r,1) )/2^32;
else
    transposeOutput = 0;    
    x = (repmat( delPhaseProduct',1,L)  + repmat(deltaQ',1,L).*repmat(0:L-1,c,1) )/2^32;
end
x = x - floor(x);  % only need to keep the fractional cycle


%% Now look up the twiddle-factors corresponding to the fractional-cycle
phase_lsb = mod(round(x*2^(Q+3)),2^Q)';
oct = mod(floor(round(x*2^(Q+3))/2^Q),8)';
i=x';
q=x';
% Octant I
phase = phase_lsb(oct==0);
i(oct==0) = (2^(Q-M)*y_cos(1+floor(phase*2^(M-Q)))+m_cos(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
q(oct==0) = (2^(Q-M)*y_sin(1+floor(phase*2^(M-Q)))+m_sin(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
% Octant II
phase = 2^Q-phase_lsb(oct==1);
i(oct==1) = (2^(Q-M)*y_sin(1+floor(phase*2^(M-Q)))+m_sin(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
q(oct==1) = (2^(Q-M)*y_cos(1+floor(phase*2^(M-Q)))+m_cos(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
% Octant III
phase = phase_lsb(oct==2);
i(oct==2) = -(2^(Q-M)*y_sin(1+floor(phase*2^(M-Q)))+m_sin(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
q(oct==2) = (2^(Q-M)*y_cos(1+floor(phase*2^(M-Q)))+m_cos(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
% Octant IV
phase = 2^Q-phase_lsb(oct==3);
i(oct==3) = -(2^(Q-M)*y_cos(1+floor(phase*2^(M-Q)))+m_cos(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
q(oct==3) = (2^(Q-M)*y_sin(1+floor(phase*2^(M-Q)))+m_sin(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
% Octant V
phase = phase_lsb(oct==4);
i(oct==4) = -(2^(Q-M)*y_cos(1+floor(phase*2^(M-Q)))+m_cos(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
q(oct==4) = -(2^(Q-M)*y_sin(1+floor(phase*2^(M-Q)))+m_sin(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
% Octant VI
phase = 2^Q-phase_lsb(oct==5);
i(oct==5) = -(2^(Q-M)*y_sin(1+floor(phase*2^(M-Q)))+m_sin(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
q(oct==5) = -(2^(Q-M)*y_cos(1+floor(phase*2^(M-Q)))+m_cos(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
% Octant VII
phase = phase_lsb(oct==6);
i(oct==6) = (2^(Q-M)*y_sin(1+floor(phase*2^(M-Q)))+m_sin(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
q(oct==6) = -(2^(Q-M)*y_cos(1+floor(phase*2^(M-Q)))+m_cos(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
% Octant VIII
phase = 2^Q-phase_lsb(oct==7);
i(oct==7) = (2^(Q-M)*y_cos(1+floor(phase*2^(M-Q)))+m_cos(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);
q(oct==7) = -(2^(Q-M)*y_sin(1+floor(phase*2^(M-Q)))+m_sin(1+floor(phase*2^(M-Q))).*mod(phase',2^(Q-M)))/2^(2*Q-M);

y = complex(i,-q);
if transposeOutput
    y = y.';
end

















