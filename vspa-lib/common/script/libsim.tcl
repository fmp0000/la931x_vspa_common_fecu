# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2012 - 2025   Freescale Semiconductor Ltd

# ==============================================================================
#! @file            libsim.tcl
#! @brief           Library of Tcl functions for VSPA simulation.
# ==============================================================================

# ------------------------------------------------------------------------------
#! @brief           Initialize the debugger configuration.
#! @return          Void.
#!
#! This function initializes the debugger configuration for subsequent use
#! of the Tcl library libsim.
#!
# ------------------------------------------------------------------------------
proc sim_init_config {} {
    config runControlSync on
    config hexPrefix 0x
    config binPrefix 0b
    config showCommas off
    config hexPadding on
    config decPadding off
    config memReadMax 1073741824
    config memAccess 32
    display off all
    config echoCmd off
}

# ------------------------------------------------------------------------------
#! @brief           Configure the VCPU/IPPU data RAM partitioning.
# ------------------------------------------------------------------------------
proc sim_dram_config { vcpu ippu } {
    set_dmem_partition $vcpu $ippu
}

# ------------------------------------------------------------------------------
#! @brief           Clear memory.
#!
#! This procedure clears @a size 32-bit words in memory
#! starting from address @a addr, using the memory space @a space.
#! If the argument @a space is not specified, the memory space
#! defaults to VCPU data memory.
#!
#! @param[in]       base    specifies the memory base address.
#! @param[in]       size    specfies the number of 32-bit words to clear.
#! @param[in]       space   optional - specifies the memory space.
#!                          -  x: VCPU program memory
#!                          -  m: VCPU data memory (default)
#!                          -  r: VCPU register file
#!                          - ip: IP register map
#!                          - ix: IPPU program memory
#!                          - im: IPPU data memory
#!                          -  s: SoC debug address space
#!                          -  p: AXI address space
#! @return          void.
# ------------------------------------------------------------------------------
proc sim_dram_clear { base size {space "m"} } {
    mem $space:$base [expr $size] =0
}

# ------------------------------------------------------------------------------
#! @brief           Randomize memory.
#!
#! This procedure randomizes @a size 32-bit words in memory
#! starting from address @a addr, using the memory space @a space.
#! If the argument @a space is not specified, the memory space
#! defaults to VCPU data memory.
#!
#! @param[in]       addr    specifies the memory address.
#! @param[in]       size    specfies the number of 32-bit words to randomize.
#! @param[in]       space   optional - specifies the memory space.
#!                          -  x: VCPU program memory
#!                          -  m: VCPU data memory (default)
#!                          -  r: VCPU register file
#!                          - ip: IP register map
#!                          - ix: IPPU program memory
#!                          - im: IPPU data memory
#!                          -  s: SoC debug address space
#!                          -  p: AXI address space
#! @return          void.
# ------------------------------------------------------------------------------
proc sim_dram_rand { addr size {space "m"} } {
    for { set ptr $addr } { $ptr < [expr $addr+$size] } { incr ptr } {
        mem $space:$ptr=[expr { int( 2147483647 * rand() ) }]
    }
}

# ------------------------------------------------------------------------------
#! @brief           Swap bytes in a 32-bit word.
#! @param[in]       val 32-bit word to be byte-swapped.
#! @return          byte-swapped version of @a word.
# ------------------------------------------------------------------------------
proc swap32 { val } {

    set b0 0
    set b1 0
    set b2 0
    set b3 0

    scan [format "%8.8x" [expr $val]] "%2x%2x%2x%2x" b3 b2 b1 b0
    return [format "0x%8.8x" [expr ($b0<<24)|($b1<<16)|($b2<<8)|$b3]]
}

# ------------------------------------------------------------------------------
#! @brief           Read a 32-bit word in data memory.
#! @param[in]       addr data memory location (32-bit word address).
#! @param[in]       space   optional - specifies the AXI memory space.
#!                          -  x: VCPU program memory
#!                          -  m: VCPU data memory (default)
#!                          -  r: VCPU register file
#!                          - ip: IP register map
#!                          - ix: IPPU program memory
#!                          - im: IPPU data memory
#!                          -  s: SoC debug address space
#!                          -  p: AXI address space
#! @return          the value at data memory location @a addr.
#! @note						run proc sim_init_config (libsim.tcl) prior to using this
# ------------------------------------------------------------------------------
proc sim_dram_read { addr {space "m"} } {
    set dmem [mem $space:$addr %x -np]
    return [swap32 $dmem]
}

# ------------------------------------------------------------------------------
#! @brief           Write a 32-bit word in data memory.
#! @param[in]       addr data memory location (32-bit word address).
#! @param[in]       value specifies the value to write.
#! @param[in]       space   optional - specifies the AXI memory space.
#!                          -  x: VCPU program memory
#!                          -  m: VCPU data memory (default)
#!                          -  r: VCPU register file
#!                          - ip: IP register map
#!                          - ix: IPPU program memory
#!                          - im: IPPU data memory
#!                          -  s: SoC debug address space
#!                          -  p: AXI address space
#! @return          void.
#! @note						run proc sim_init_config (libsim.tcl) prior to using this
# ------------------------------------------------------------------------------
proc sim_dram_write { addr value {space "m"} } {
    mem $space:$addr =[swap32 $value]
}

# ------------------------------------------------------------------------------
#! @brief           Load an ASCII hex file to data memory.
#! @param[in]       fhex    specifies the data file path and name.
#! @param[in]       addr    specifies the memory address.
#! @param[in]       space   optional - specifies the AXI memory space.
#!                          -  x: VCPU program memory
#!                          -  m: VCPU data memory (default)
#!                          -  r: VCPU register file
#!                          - ip: IP register map
#!                          - ix: IPPU program memory
#!                          - im: IPPU data memory
#!                          -  s: SoC debug address space
#!                          -  p: AXI address space
#! @return          void.
# ------------------------------------------------------------------------------
proc sim_dram_load { fhex addr {space "m"} } {

    if { ![file isfile $fhex] } {
        error "$fhex is not a file."
    }
    if { [catch {set fidhex [open $fhex {RDONLY}]} msg] } {
        error $msg
    }
    set dataHex [read -nonewline $fidhex]
    close $fidhex

    set binFile [format "%s.bin" [file rootname $fhex]]
    if { [catch {set fidbin [open $binFile {WRONLY CREAT}]} msg] } {
        error $msg
    }
    fconfigure $fidbin -translation binary

    set count 0
    foreach val $dataHex {
        puts -nonewline $fidbin [binary format i* [scan $val "%x\n"]]
        incr count
    }
    close $fidbin
    if { [catch {restore -b $binFile $space:$addr} msg] } {
        error $msg
    }
    puts [format "Loaded %li words to 0x%X from $fhex" $count $addr]
    file delete $binFile
}

# ------------------------------------------------------------------------------
#! @brief           Save data memory to an ASCII hex file.
#! @param[in]       fhex    specifies the data file path and name.
#! @param[in]       addr    specifies the VSPA memory address.
#! @param[in]       size    specifies the number of 32-bit words to save.
#! @param[in]       space   optional - specifies the VSPA memory address space.
#!                          -  x: VCPU program memory
#!                          -  m: VCPU data memory (default)
#!                          -  r: VCPU register file
#!                          - ip: IP register map
#!                          - ix: IPPU program memory
#!                          - im: IPPU data memory
#!                          -  s: SoC debug address space
#!                          -  p: AXI address space
#! @return          void.
# ------------------------------------------------------------------------------
proc sim_dram_save { fhex addr size {space "m"} } {
    set binFile [format "%s.bin" [file rootname $fhex]]
    file delete $binFile
    if { ![string compare $space "p"] } {
        set size [expr 4*$size]
    }
    if { [catch {save -b $space:$addr..[format %08x [expr $addr+$size-1]] $binFile -o} msg] } {
        error $msg
    }
    if { [catch {set fidbin [open $binFile {RDONLY}]} msg] } {
        error $msg
    }
    fconfigure $fidbin -translation binary
    set contents [read $fidbin]
    close $fidbin

    file delete $fhex
    if { [catch {set fidhex [open $fhex {WRONLY CREAT}]} msg] } {
        error $msg
    }
    file delete $binFile
    binary scan $contents i* values
    foreach val $values {
        puts $fidhex [format 0x%08x $val]
    }
    close $fidhex
}

# ------------------------------------------------------------------------------
#! @brief           Save a tcl list to an ASCII hex file.
#! @param[in]       file_name Specifies the name of the file to save.
#! @return          Void.
# ------------------------------------------------------------------------------
proc sim_list_save { file_name theList } {

    # Open the output file for writing:
    if { [file exists $file_name] } {
            file delete $file_name
    }
    if { [catch {set file_hex [open $file_name {WRONLY CREAT}]} msg] } {
        puts $msg
    } else {

        # Parse each value in data memory:
        foreach val $theList {
            if { [string length $val] > 0 } {
                #puts $file [format "%8x" $val]
                # 'val' is in so-called little-endian, so convert it to so-called
                # big-endian to get something in 'true' little-endian, i.e. with
                # a format in which 1 equals 1, not 16777216.
                #scan $val "%08x" hex
                #puts $file_hex [sim_swap32 $val]
                puts $file_hex $val
           }
        }
        close $file_hex
    }
}

# ------------------------------------------------------------------------------
#! @brief           Get next memory address aligned to a specified byte boundary.
#! @param[in]       byte addr in hex
#! @param[in]       number of bytes that define boundary alignment
#! @return          the hex byte address that is now aligned to the num byte
#!                  boundary specified
# ------------------------------------------------------------------------------
proc sim_address_align { byteAddrHex numBytesToAlignBy } {

    # convert to decimal
    set byteAddrDec [format "%d" [expr $byteAddrHex]]

    # get modulo of addr and boundary
    set remainder [expr $byteAddrDec % [expr $numBytesToAlignBy]]

    # number of boundaries (this is a floor operation when 2 integers are used)
    set numBoundaries [expr $byteAddrDec/$numBytesToAlignBy]

    # if not on specified boundary, advance to next boundary
    if { $remainder > 0 } {
    		set byteAddrDec [expr [expr $numBoundaries+1]*$numBytesToAlignBy]
    }

    # convert back to hex
    set byteAddrHex [format "0x%x" $byteAddrDec]

    return $byteAddrHex
}

# ------------------------------------------------------------------------------
#! @brief           Configure a DMA channel.
#! @param[in]       channel Specifies the DMA channel number.
#! @param[in]       filestem Specifies the stem for the DMA files.
#! @return          Void.
# ------------------------------------------------------------------------------
proc sim_dma_config { channel filestem } {
    dma_channel $channel $filestem
}

# ------------------------------------------------------------------------------
#! @brief           Configure the external trigger for a DMA channel.
#! @param[in]       channel Specifies the DMA channel number.
#! @param[in]       delay Specifies the number of VCPU cycles before the first trigger.
#! @param[in]       period Specifies the trigger period in VCPU cycles
#! @param[in]       count Specifies the number of triggers to generate
#! @return          Void.
# ------------------------------------------------------------------------------
proc sim_dma_trigger { channel delay period count } {
    dma_trigger [expr $channel] [expr $delay] [expr $period] [expr $count]
}

# ------------------------------------------------------------------------------
#! @brief           Read from an IP register.
#! @param[in]       ipreg Specifies the IP register name.
#! @return          The IP register value.
# ------------------------------------------------------------------------------
proc sim_ipreg_read { ipreg } {
    return [format "0x%08X" [display $ipreg -np]]
}

# ------------------------------------------------------------------------------
#! @brief           Write to an IP register.
#! @param[in]       ipreg Specifies the IP register name.
#! @param[in]       value Specifies the value to write.
#! @return          Void.
# ------------------------------------------------------------------------------
proc sim_ipreg_write { ipreg value } {
    reg $ipreg=[format "%08x" [expr $value]]
}

# ------------------------------------------------------------------------------
#! @brief           Compare two ASCII hex files.
#! @param[in]       file_out Specifies the name of the data file to check.
#! @param[in]       file_ref Specifies the name of the reference data file.
#! @param[in]       args (optional) ... offsets
#!                  1st arguement = offset for the output file
#!                  2nd arguement = offset for the reference file
#!                      either offset specifies a number of lines to 'skip'
#!                      before beginning the comparison of the 2 files
#!                      this may be used to jump over known dummy data
#! @return          Void.
#!                  example call to this fx. (you can specify 0, 1, or 2 args as offsets)
#!                    (no offsets)
#!                    sim_file_compare "C:\\test\\cfr_WR.dma" "C:\\test\\cfr_WR_ML.dma"
#!                    (with 100 line offset to output file, 20 line offset to input file)
#!                    sim_file_compare "C:\\test\\cfr_WR.dma" "C:\\test\\cfr_WR_ML.dma" 100 20
# ------------------------------------------------------------------------------
proc sim_file_compare { file_out file_ref args } {

        set lines_remaining_out 0
        set lines_remaining_ref 0
        set lines_matched 0
        set err_flag 0
        set offset_out -1
        set offset_ref -1
        set num_line_out 1
        set num_line_ref 1

    # Open file_out for reading:
    if { [catch {set fout [open $file_out {RDONLY}]} msg] } {
        puts $msg
        puts "FAIL"
        return 0
    } else {

        # Open file_ref for reading:
        if { [catch {set fref [open $file_ref {RDONLY}]} msg] } {
            close $fout
            puts $msg
            puts "FAIL"
            return 0
        } else {

            #if an offset, advance the line counter - out file
            if { [ lindex $args 0 ] > -1 } {
                set offset_out [ lindex $args 0 ]
                #advance offset for out file
                while { [gets $fout line_out] >= 0 } {
                    incr num_line_out
                    if { $num_line_out > $offset_out } {
                        break
                    }
                }
            }
            #if an offset, advance the line counter - reference file
            if { [ lindex $args 1 ] > -1 } {
                set offset_ref [ lindex $args 1 ]
                #advance offset for ref file
                while { [gets $fref line_red] >= 0 } {
                    incr num_line_ref
                    if { $num_line_ref > $offset_ref } {
                        break
                    }
                }
            }

            # Parse each line:
            while { [gets $fout line_out] >= 0 } {
                if { [gets $fref line_ref] >= 0 } {

                    scan $line_out "0x%x" hex_out
                    scan $line_ref "0x%x" hex_ref

                    if { [expr $hex_out] != [expr $hex_ref] } {
                        puts [format "FAIL - mismatch reference line  %i: expected 0x%08x" $num_line_ref $hex_ref]
                        puts [format "FAIL - mismatch output line     %i: got 0x%08x" $num_line_out $hex_out]

                        set err_flag 1
                        incr lines_remaining_out
                        incr lines_remaining_ref
                        break
                    }
                    incr lines_matched
                } else {
                    puts [format "WARN - %s is longer than %s" $file_out $file_ref]
                    incr lines_remaining_out
                    break;
                }
                incr num_line_ref
                incr num_line_out
            }

#            #find remaining reference lines if mismatched file sizes
#            while { [gets $fref line_ref] >= 0 } {
#                incr lines_remaining_ref
#            }
#            while { [gets $fout line_out] >= 0 } {
#                incr lines_remaining_out
#            }
#
#            #Output Message
#            if { $offset_out > 0 } {
#                puts "Line offset out file = $offset_out"
#            }
#            if { $offset_ref > 0 } {
#                puts "Line offset ref file = $offset_ref"
#            }
#            puts "Lines Matched = $lines_matched"
#            if { $lines_remaining_out > 0 } {
#                puts "Lines remaining out file = $lines_remaining_out"
#            }
#            if { $lines_remaining_ref > 0 } {
#                puts "Lines remaining ref file = $lines_remaining_ref"
#            }
            close $fout
            close $fref
        }
        if { $err_flag == 0 } {
            if { $lines_matched == 0 } {
                puts "FAIL"
                return 0
            } else {
                puts "PASS"
                return 1
            }
        } else {
            puts "FAIL"
            return 0
        }
    }
}

# ------------------------------------------------------------------------------
#! @brief           Compare two data files.
#! @param[in]       fvsp specifies the data file path and name obtained from CW.
#! @param[in]       fref specifies the data file path and name obtained from Matlab.
#! @param[in]       size number of words to compare.
#! @param[in]       ovsp optional - offset in data file from CW.
#! @param[in]       oref optional - offset in data file from Matlab.
#! @retval          0    Indicates files are different.
#! @retval          1    Indicates files are identical.
# ------------------------------------------------------------------------------
proc sim_file_match { fvsp fref size {ovsp 0} {oref 0} } {
    # Attempt to open reference output file in read-only mode:
    if { [catch {set fidref [open $fref {RDONLY}]} msg] } {
        puts $msg
        close $fidvsp
        return 0
    }

    # Attempt to open test output file in read-only mode:
    if { [catch {set fidvsp [open $fvsp {RDONLY}]} msg] } {
        puts $msg
        return 0
    }

    # Skip <ovsp> lines from test output file:
    set offset [expr $ovsp]
    while { $offset > 0 } {
        if { [eof $fidvsp] } {
            puts [format "$fvsp: end of file before offset %d!" [expr $ovsp]]
            return 0
        }
        gets $fidvsp dummy
        incr offset -1
    }

    # Skip <oref> lines from reference output file:
    set offset [expr $oref]
    while { $offset > 0 } {
        if { [eof $fidref] } {
            puts [format "$fref: end of file before offset %d!" [expr $oref]]
            return 0
        }
        gets $fidref dummy
        incr offset -1
    }

    # Loop over <size> lines:
    set eflag 0
    set count 0
    while { $count < [expr $size] } {

        # Read hex value from test and reference output files:
        scan [gets $fidvsp] "0x%08x" hexvsp
        scan [gets $fidref] "0x%08x" hexref

        # Terminate loop earlier on end of file:
        if { [eof $fidvsp] || [eof $fidref] } {
            break
        }

        # Compare test and reference values:
        if { [expr $hexvsp] == [expr $hexref] } {
            incr count
            continue
        }

        # Compare 16-bit half-words, and compare only numbers
        # with absolute value greater than zero, to avoid mismatch on +/-0.

        # Least significant 16-bit half-word:
        if { ([expr [expr $hexvsp] & 0x0000FFFF] != [expr [expr $hexref] & 0x0000FFFF]) && \
            (([expr [expr $hexvsp] & 0x00007FFF] != 0) || ([expr [expr $hexref] & 0x00007FFF] != 0)) } {
            puts [format "FAIL: vsp\[%d\] = 0x%08x - ref\[%d\] = 0x%08x" [expr $count + [expr $ovsp]] $hexvsp [expr $count + [expr $oref]] $hexref ]
            set eflag 1
            break
        }

        # Most significant 16-bit half-word:
        if { ([expr [expr $hexvsp] & 0xFFFF0000] != [expr [expr $hexref] & 0xFFFF0000]) && \
            (([expr [expr $hexvsp] & 0x7FFF0000] != 0) || ([expr [expr $hexref] & 0x7FFF0000] != 0)) } {
            puts [format "FAIL: vsp\[%d\] = 0x%08x - ref\[%d\] = 0x%08x" [expr $count + [expr $ovsp]] $hexvsp [expr $count + [expr $oref]] $hexref ]
            set eflag 1
            break
        }

        # Increment line counter:
        incr count
    }
    close $fidref
    close $fidvsp

    # Return PASS/FAIL status:
    if { $eflag } {
        puts [format "FAIL \[%i/%i = %3.2f%% OK\]" $count [expr $size] [expr 100*[format "%f" $count]/[format "%f" [expr $size]]]]
        return 0
    } else {
        puts [format "PASS \[%i/%i = %3.2f%% OK\]" $count [expr $size] [expr 100*[format "%f" $count]/[format "%f" [expr $size]]]]
        return 1
    }
}

# ------------------------------------------------------------------------------
#! @brief           Swap endianness of a 32-bit data.
#! @param[in]       x The 32-bit integer to swap.
#! @return          Swapped version of @a x.
# ------------------------------------------------------------------------------
proc sim_swap32 { x } {

    # Initialize all bytes to 0:
    set b0 0
    set b1 0
    set b2 0
    set b3 0

    # Scan each byte:
    scan $x "0x%2x%2x%2x%2x" b3 b2 b1 b0

    # Return bytes in swapped form:
    return [format "%02x%02x%02x%02x" $b0 $b1 $b2 $b3]
}

# ------------------------------------------------------------------------------
#! @brief           Swap endianness of a 16-bit data.
#! @param[in]       x The 16-bit integer to swap.
#! @return          Swapped version of @a x.
# ------------------------------------------------------------------------------
proc sim_swap16 { x } {

    # Scan each byte:
    scan $x "0x%2x%2x" b1 b0

    # Set byte 0 to 0 if not scanned:
    if { ![info exists b0] } {
        set b0 0
    }

    # Set byte 1 to 0 if not scanned:
    if { ![info exists b1] } {
        set b1 0
    }

    # Return bytes in swapped form:
    return [format "%02x%02x" $b0 $b1]
}

# ------------------------------------------------------------------------------
#! @brief           Convert an ASCII hex file to a binary file.
#! @param[in]       fhex specifies the ASCII hex file path and name.
#! @param[in]       fbin specifies the binary file path and name.
#! @return          number of 32-bit words converted.
# ------------------------------------------------------------------------------
proc sim_file_hex2bin { fhex fbin } {

    # Attempt to open the ASCII file in read-only mode:
    if { [catch {set fidhex [open $fhex {RDONLY}]} msg] } {
        puts $msg
        return 0
    }

    # Delete the binary file if it already exists:
    if { [file exists $fbin] } {
        file delete $fbin
    }

    # Attempt to open the binary file in write mode:
    if { [catch {set fidbin [open $fbin {WRONLY CREAT}]} msg] } {
        close $fidhex
        puts $msg
        return 0
    }

    # Configure binary file to be accessed in binary mode:
    fconfigure $fidbin -translation binary

    # Read the ASCII file line by line, extract the value, write the value
    # in binary file:
    set count 0
    while { [gets $fidhex hex] >= 0 } {
        puts -nonewline $fidbin [binary format i [scan $hex "%08x"]]
        incr count
    }

    close $fidbin
    close $fidhex
    return $count
}

# ------------------------------------------------------------------------------
#! @brief           Template to load variables from individual files to memory.
#! @param[in]       testCaseName (optional): this is included in the saved files
#!                                      for each of the variables and the output reference file.
#!                                      variables loaded will be:
#!                                      var_tx<testCaseName>_<variableName>.hex
#!                                      use the same testCaseName that was used in the Matlab
#!                                      pat_gen_tx( getenv( 'VSPASW_BASE_PATH' ), <testCaseName> )
#!                          Modify below adding variable names and base path
#!                                  Change name of tcl script to reflect project
#!                                  (replace 'template' with name of project)
#! @return          Void.
# ------------------------------------------------------------------------------
proc sim_vars_load_template { args } {

    if {[llength $args] > 0} {
        set testCaseName "var_tx[ lindex $args 0 ]_"
    } else {
        set testCaseName "var_tx_"
    }

    set load_fx_var_addrs ""
    set load_fx_filenames ""

    #***************************************************************************
    #File Path: must be in "" (to ensure works if spaces in path)
    #                       (keep trailing '/') Use '/', do not use '\' !!!
    #                       path points to hex files.
    #***************************************************************************
    set basePath  "$::env(VSPASW_BASE_PATH)//dfe_release/tx/test_vectors/"

    set load_fx_filepath "${basePath}$testCaseName"
    #***************************************************************************
    # sim_add_var_and_path variableAddress filename
    # Variable Address: use same symbolic reference in C code.
    #                                   ex. for an int (et.al) prepend '&' for address
    #                                               for buffer, name alone represents address
    #                                               (replicate for as many as you have)
    #***************************************************************************

    sim_add_var_and_path &var_name
    sim_add_var_and_path srcBuf

    # load the list
    sim_list_vars_load
}
# ------------------------------------------------------------------------------
#! @brief           Load list of variables from individual files to memory.
#! @param[in]       none
#!                          Called by sim_vars_load_template
#! @return          Void.
# ------------------------------------------------------------------------------
proc sim_list_vars_load {} {
    upvar load_fx_var_addrs myVar_addrs
    upvar load_fx_filenames myFilenames

    set countVars 0

    foreach file $myFilenames {
        puts [lindex $myVar_addrs $countVars]
        puts $file
        set in_addr [evaluate #x [lindex $myVar_addrs $countVars]]

        sim_dram_load $file $in_addr
        incr countVars
    }
}
# ------------------------------------------------------------------------------
#! @brief           Add a variable address to list, file path to list2
#! @param[in]       symbolic address of the variable (see template)
#!
#!                                  Called by sim_vars_load_template
#! @return          Void.
# ------------------------------------------------------------------------------
proc sim_add_var_and_path { one_addr } {
    upvar load_fx_var_addrs myVar_addrs
    upvar load_fx_filenames myFilenames
    upvar load_fx_filepath myFilepath

    #trim any leading & if this is a 32 bit codeword
    set one_filename [ string trim $one_addr & ]
    #add the filename to the path (make the variable name)
    set path_and_file "${myFilepath}${one_filename}.hex"

    lappend myVar_addrs $one_addr
    lappend myFilenames $path_and_file
}

# ------------------------------------------------------------------------------
#! @brief           Are cores completed in the simulator
#! @param[in]       the index values of the cores (see 'switchtarget' cmd)
#!                                  No arguments will check all cores
#!
#! @return          1 if the requested cores are "Stopped"
#!                                  0  for not stopped
# ------------------------------------------------------------------------------
proc sim_core_completion { args } {

    config echoCmd off

    #Get the configuration of targets
    set switchtargetResult "\$[ switchtarget ]"

    set result "1"

    #1 line per target

    set lines [ split $switchtargetResult "\n" ]

    foreach singleLine $lines {

        #is this a full line
        if { [ string first "=" $singleLine ] != -1 } {

            set indexCore [ lindex $singleLine 1 ]

            set locEqual [ string first "=" $indexCore ]
            incr locEqual
            set num [ string range $indexCore $locEqual [string length $indexCore]]
            #remove whitespace
            set num [ string trim $num ]
            set num [ string trim $num {'*', ',', ' '} ]

            if { [ llength $args ] == 0  } {
                set match "Y"
            } elseif { [ lsearch $args $num ] != -1 } {
                set match "Y"
            } else {
                set match "N"
            }

            if { $match == "Y" } {

                set statusCore [ lindex $singleLine 2 ]

                set locEqual [ string first "=" $statusCore ]
                incr locEqual

                set status [ string range $statusCore $locEqual [string length $statusCore]]

                #remove whitespace
                set status [ string trim $status ]
                set status [ string trim $status {'*', ',' ,' ' } ]
                set status [ string trimright $status ]

                if { $status != "Stopped" } {
                    set result "0"
                }
            }
        }
    }

    config echoCmd on
    puts $result
    return $result
}

# ------------------------------------------------------------------------------
#! @brief       Get the address of a C variable.
#! @param[in]   var specifies the variable name.
#! @return      the hexadecimal address of the variable,
#!              zero-padded and prefixed with 0x.
# ------------------------------------------------------------------------------
proc varAddr { var } {
    return [format "0x%08x" [display &$var %x -np]]
}
