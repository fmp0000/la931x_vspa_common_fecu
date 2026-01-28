% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
function [x] = r_rcp_newton(a, iter, rcp_mode, iter_mode)
%Purpose:   Increace accurcy of r_rcp(a) where a is a real-SP array.
%Method:    Use Newton-Raphson iteration to refine the root of the function,
%                   f(x) = 1/x - a = 0, 
%           with a good initial guess x0. 
%           (1) x0 is obtained by calling r_rcp(a, rcp_mode)
%           (2) x(n+1)  = xn - f(xn)/f'(xn)
%                       = xn - (1/xn - a)/(-1/xn^2)
%                       = xn + (xn - a*xn^2)
%                       = 2*xn - a*xn^2
%                       = xn(2-a*xn)
%Input:     a: a real-SP array
%           iter: number of iterations
%           rcp_mode: {'lo','hi'}, used by r_rcp() to determined the size of look-up tables.
%           iter_mode: '2mad_b' is preferred. Other choices: {2mad_a, 3mad, 4mad}.
%Output:    xn: Represents 1/a in single precision.

%rcp use table-lookup to find 1/a where a belongs to [1,2)
x = r_rcp(a, rcp_mode);

%Newton-Raphson iteration
while (iter>0)
    switch iter_mode
        %Note that a*x ~= 1
        case '2mad_a'            
            %implement x = x(- x*a + 2)
            v = r_smad(-x, a, 2*ones(size(a)));
            x = r_smad(v, x, 0);
        case '2mad_b' %Current implementation
            %implement x = x(- x*a + 1) + x
            %Motivation: adding numbers in the same range to minimize roundoff error
            v = r_smad(-x, a, +ones(size(a)));
            x = r_smad(v, x, x); %if v < EPS_SP, x=x (which implies this implementation achieves EPS_SP, which is episilon of SP, given by 2^(-24))
        case '3mad'
            %implement x = (-(a*x) * x + x) + x
            v = r_smad(a, x, 0);
            v = r_smad(-v, x, x);
            x = r_smad(v, 1, x);
        case '4mad'            
            %implement x = 2*x - ( (a*x)*x )
            % - Produces a slightly larger error because more macs were used
            v = r_smad(a, x, 0);        
            u = r_smad(v, x, 0);
            v = r_smad(1, x, x);
            x = r_smad(1, v, -u);
        otherwise
            error('invalid iter_mode');
    end
    iter=iter-1;
end
