# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2020 - 2025 the original authors

# Launch configuration to debug/run
set TARGET "DECIMATOR_VSPA2_16AU_CAS"

# Project path
set cwProjPath [pwd]
set cwProjPath "${cwProjPath}\\.."

# Project configuration
set cwProjConf "HARNESS"

# Debug flag (0 or 1)                   
set DBG                    0                 
                                        
# Testcase range to run (inclusive)    
set TC_NUM_START           0
set TC_NUM_END           0
#set TC_NUM_END           107                            
