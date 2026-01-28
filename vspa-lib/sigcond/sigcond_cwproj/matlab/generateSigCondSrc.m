% SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
% Copyright 2020 - 2025 the original authors
% function to generate source code
function generateSigCondSrc(filename, n_taps)

inclist(1).filename = 'sigcond.h';
macros(1).name = 'CUSTOMSIGCOND_IQDELFILTLEN';
macros(1).value = sprintf('%d', n_taps);
full_path_inputfilename = sprintf('../csvsrc/%s.txt', filename);

genVSPAFnfromtxtfile(full_path_inputfilename, '../Sources', filename, inclist, macros, 'CUSTOMSIGCOND_STUB');

return;
