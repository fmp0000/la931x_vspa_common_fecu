% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y = r_mat_by_vec_chfx_chfx_rhfl(x , a , offset , L , M)
% DESCRIPTION:
%             multiplies a matrix by a vector y=X * a, where X is a matrix of size KxM and a is a vector Mx1.
%             i.e., y=a1*x1 + a2*x2 + ... + aM*xM, where ai is a scalar and xi is a vector of size Kx1.
% 
%   Input arguments:
%     x      : input buffer which concatinate x1, x2, ..., xM
%     a      : input buffer which contains the coefficients a1, a2, ..., aM
%     offset : offset between x1 and x2, x2 and x3, … etc. 
%              Note that offset has to be multiple of 32, i.e., each vector xi, where i={1,2,..., M}, has to be DMEM aligned 
%     L      : number of output DMEM lines (which is equal to DMEM line to store x1, x2, ...,xM). L = ceil(K/32)
%     M      : number of entries in the input buffer a (which is equal to the number of xi vectors).
%   Return values:
%     y :  output buffer 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = r_mat_by_vec_chfx_chfx_rhfl(x , a , offset , L , M)

x = r_half(x);
a = r_half_flt(a);
y = zeros(32*L , 1) + 1j * zeros(32*L , 1);
for ii = 1:M
    
    y = r_smad(a(ii) , x(1+(ii-1)*offset : (ii-1)*offset+32*L) , y);
    
end

y = r_half(y);

end
