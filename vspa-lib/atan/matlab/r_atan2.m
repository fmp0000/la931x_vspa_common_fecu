% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [atan2_v, coeff_v, atan2_m] = r_atan2(inp, ctrl)
% 
% DESCRIPTION:
%   This function performs FULL CIRCLE PHASE EXTRACTION for each element of
%   the complex input array in both Matlab and VSPA precision.
%
% INPUTS:
%   inp  - N x 1 complex input vector in Matlab double precision
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
%   atan2_v - N x 1 phase values in VSPA precision
%   coeff_v - num_coeff x 1 polynomial coefficients in VSPA precision
%   atan2_m - N x 1 phase values in Matlab precision
% 
% ATTENTION: The output by default is in radians and NORMALIZED TO PI.
%            If the output is desired in radians use the 'ctrl.norm = false' 
%            configuration.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
function [atan2_v, coeff_v, atan2_m] = r_atan2(inp, ctrl)

% Default normalization flag is true (if not given)
if ~isfield(ctrl, 'norm')
    ctrl.norm = true;
end

% -------------------------- Matlab implementation ------------------------
atan2_m = atan2(imag(inp), real(inp));

% Normalize to PI if necessary
if ctrl.norm
    atan2_m = atan2_m ./ pi;
end

% --------------------------- VSPA implementation -------------------------
% Convert input precision
real_v = r_convert(real(inp(:)), ctrl.inp_prec, 'input complex value');
imag_v = r_convert(imag(inp(:)), ctrl.inp_prec, 'input complex value');

% Compute 1/real and 1/imag
real_rcp_v = r_rcp(real_v);
imag_rcp_v = r_rcp(imag_v);

% Compute tangent (X) and inverse of tangent (1/X)
tan_v     = r_smad(imag_v, real_rcp_v, zeros(size(imag_v)));
tan_rcp_v = r_smad(real_v, imag_rcp_v, zeros(size(imag_v)));

% Compute mask_inv_X = mask(|1/X| < 1) = binary(1 - |1/X|)
tan_rcp_diff_v = r_smad(-abs(tan_rcp_v), r_single(1), r_single(1));
mask_tan_rcp_v = ones(size(tan_rcp_diff_v));
mask_tan_rcp_v(tan_rcp_diff_v < 0) = 0;
mask_tan_rcp_v = r_single(mask_tan_rcp_v);

% Compute X' = X + mask_inv_X * (-X) + mask_inv_X * (-1/X)
tan_p_v = r_smad(-tan_v,     mask_tan_rcp_v, tan_v);
tan_p_v = r_smad(-tan_rcp_v, mask_tan_rcp_v, tan_p_v);

% Compute atan(X') (normalized to PI)
atan_ctrl = ctrl;
atan_ctrl.inp_prec  = 'single';
atan_ctrl.out_prec  = 'single';
atan_ctrl.norm      = true;
[atan_p_v, coeff_v] = r_atan(tan_p_v, atan_ctrl);

% Half circle phase correction term (normalized to pi/2)
% A_half / (pi/2) = sign(X) * mask_inv_X
sign_tan_v = ones(size(tan_v));
sign_tan_v(tan_v < 0) = -1;
sign_tan_v = r_single(sign_tan_v);

add_half_norm = r_smad(sign_tan_v, mask_tan_rcp_v, 0);

% Full circle phase correction term (normalized to pi)
% A_full / (pi) = (-mask(real)) * sign(imag) + sign(imag)
mask_re_v = ones(size(real_v));
mask_re_v(real_v < 0) = 0;
mask_re_v = r_single(mask_re_v);

sign_im_v = ones(size(imag_v));
sign_im_v(imag_v < 0) = -1;
sign_im_v((1 ./ imag_v) ==  Inf) =  1;      % Make a distinction between +/-0
sign_im_v((1 ./ imag_v) == -Inf) = -1;
sign_im_v = r_single(sign_im_v);

add_full_norm = r_smad(-mask_re_v, sign_im_v, sign_im_v); 

% Total phase correction term (normalized to pi)
% A_total / (pi) = A_half / (pi/2) * 0.5 + A_full / (pi)
add_total_norm = r_smad(add_half_norm, r_single(0.5), add_full_norm);

% Perform total phase correction to obtain phase / pi
phase = r_smad(atan_p_v, r_single(1), add_total_norm);

% Denormalize output to PI if required
if (~ctrl.norm)
    phase = r_smad(phase, r_single(pi), 0);
end
    
% If output precision is 'half_fixed':
% - verify that normalization flag is true, otherwise saturation will occur
% - allow saturation of values in the [-1, -HF16_MAX] and [HF16_MAX, 1] ranges 
% since the saturation error will be around 2^(-15) = 3e-05.
if strcmp(ctrl.out_prec, 'half_fixed')
    if (~ctrl.norm)
        error('Without normalization the half-fixed output phase will saturate!');
    end
    HF16_MAX = 1 - 2^(-15);
    phase((      -1 <= phase) & (phase <= -HF16_MAX)) = -HF16_MAX;
    phase((HF16_MAX <= phase) & (phase <=         1)) =  HF16_MAX;
end

% Final output
phase = r_convert(phase, ctrl.out_prec, 'atan2 output');
atan2_v = reshape(phase, size(inp));

return

