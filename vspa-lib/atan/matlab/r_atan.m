% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [atan_v, coeff_v] = r_atan(inp, ctrl)
% 
% DESCRIPTION:
%   Computes the function atan() using one of:
%   1. polynomial fitting method. The fitting range is [-1,1].
%        P = polyfit(X,Y,N) returns N+1 polynomial coefficients
%        Y_approx = P(1)*X^N + P(2)*X^(N-1) +...+ P(N)*X^1 + P(N+1)*X^0
%   2. Taylor polynomial
%        atan(x) = x - x^3/3 + x^5/5 - x^7/7 + x^9/9 + ...
%   Either way atan() function is odd so the polynomial coefficients for
%   X^0,X^2,X^4,... are 0.
%
% INPUTS:
%   inp  - N x 1 real input vector in Matlab double precision
%        - conversion to given precision is performed inside this function
%
%   ctrl - control structure with the following fields:
%           -> inp_prec   - input precision for VSPA implementation
%           -> coeff_prec - coefficient precision for VSPA implementation
%           -> out_prec   - output precision for VSPA implementation
%           -> num_coeff  - number of effective (non-zero) coefficients 
%                         - minimum number of coefficients is 3
%                         - default number is 4
%           -> norm       - normalization flag (true/false):
%                            - false - the output is in radians
%                            - true  - the output is normalized to PI
%                            - default is true
%           -> range      - fitting range for 'poly_fit' method
%                            - default range is [-1,1]
%           -> method     - 'poly'     - for Taylor polynomial series
%                            - 'poly_fit' - for polynomial fitting
%                            - default method is 'poly_fit'
%        - the allowed precisions are:
%           -> 'half_fixed': 16 bit fixed point
%           -> 'half'      : 16 bit floating point
%           -> 'single'    : 32 bit floating point
%           -> 'double'    : 64 bit floating point
% OUTPUTS:
%   atan_v  - N x 1 atan values in VSPA precision (in radians)
%   coeff_v - num_coeff x 1 coefficients in VSPA precision
% 
% ATTENTION: The output by default is in radians and NORMALIZED TO PI.
%            If the output is desired in radians use the 'ctrl.norm = false' 
%            configuration.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function [atan_v, coeff_v] = r_atan(inp, ctrl)

% Default number of coefficients is 4 (if not given)
if ~isfield(ctrl, 'num_coeff')
	ctrl.num_coeff = 4;
end

% Minimum number of coefficients is 3
if ~(ctrl.num_coeff >= 3)
    error('Minimum number of coefficients is 3!');
end

% Default method is 'poly_fit' (if not given)
if ~isfield(ctrl, 'method')
    ctrl.method = 'poly_fit';
end

% Default normalization flag is true (if not given)
if ~isfield(ctrl, 'norm')
    ctrl.norm = true;
end

% --------------------------- VSPA implementation -------------------------
% Convert input tangent precision
tan_val_v = r_convert(inp, ctrl.inp_prec, 'input tangent value');

% Derive coefficients
if strcmp(ctrl.method, 'poly_fit')
    
    % Default fitting range
    if ~isfield(ctrl, 'range')
        ctrl.tan_range = linspace(-1, 1, 1000);
    end
    
    % For polyfit the inp must be within tan_range (explicit or default)
    % Allow deviation of 2^-15
    if ~(all(min(ctrl.tan_range - 2^-15)  <= inp) && all(inp <= max(ctrl.tan_range + 2^-15)))
        warning('Tangent value is out of the fitting range! Large error is expected!'); %#ok<WNTAG>
    end

    % Polynomial fitting
    N = 2 * ctrl.num_coeff - 1;
    coeff_m = polyfit(ctrl.tan_range, atan(ctrl.tan_range), N);
    coeff_m = coeff_m(1 : 2 : end);   
    
elseif strcmp(ctrl.method, 'poly')
    
    % Taylor polynomial
    idx     = (ctrl.num_coeff-1) : -1 : 0;
    coeff_m = (-1) .^ idx ./ (2 * idx + 1);
    
    % For half-fixed last coefficient is 1. Allow saturation to 1-2^(-15).
    if strcmp(ctrl.coeff_prec, 'half_fixed')
        coeff_m(end) = r_half(coeff_m(end));
    end
    
else 
    error('Atan method invalid!');
end

% For normalization scale the coefficients with PI
if (ctrl.norm == true)
    coeff_m = coeff_m ./ pi;
end

% Convert coefficient precision
coeff_v = r_convert(coeff_m, ctrl.coeff_prec, 'coefficient');
coeff_v = coeff_v(:);

% -------------------------------------------------------------------------
% Compute Y = c0 * X^7 + c1 * X^5 + c2 * X^3 + c3 * X
% 1. V = X^2           (mad)
% 2. V = X^2 * c0 + c1 (maf)
% 3. V = V * X^2 + c2  (maf)
%    .....................
% 4. V = V * X         (maf)
% -------------------------------------------------------------------------
X  = tan_val_v(:);
X2 = r_smad(X, X, 0);
V  = r_smad(X2, coeff_v(1), coeff_v(2));
for coeff_idx = 3 : ctrl.num_coeff
    V = r_smad(V, X2, coeff_v(coeff_idx));  % maf
end
V = r_smad(V, X, 0);

% Convert to output precision
atan_v = r_convert(V, ctrl.out_prec, 'output atan value');
atan_v = reshape(atan_v, size(inp));

return

