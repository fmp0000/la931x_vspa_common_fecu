# SPDX-License-Identifier: (BSD-3-Clause OR GPL-2.0)
# Copyright 2017 - 2025   NXP Semiconductors

##
# @file         chip.tcl
# @brief        LA9310 chip interface.
# @author       NXP Semiconductors.

namespace eval chip {
    set version 1.0

    namespace export init
    namespace export rxphytimer

}

package provide chip $chip::version

proc chip::init {} {
}

namespace eval chip::dcs {
    # DCS clock rate in MHz:
    set freq 245.76
}

namespace eval chip::dcs::tx {
    # DCS clock rate in MHz:
    set freq 491.52
}

namespace eval chip::dcs::hs {
    # DCS high-speed clock rate in MHz:
    set freq 1966.08
}

namespace eval chip::vspa {
    # VSPA clock rate in MHz:
    set freq 614.4

    # AXI width in bits:
    set waxi 512
}

namespace eval chip::ptmr {
    namespace export disable
    namespace export enable
    namespace export status

    set PTMR_CTRL 0x08b19c00
    set PTMR_C0SC 0x08b19c04
    set PTMR_C0V  0x08b19c08

}

proc chip::ptmr::disable {} {
    # Disable the PHY timer:
    mem p:$chip::ptmr::PTMR_CTRL -s = 0x0
}

proc chip::ptmr::enable {} {
    # Disable the PHY timer:
    mem p:$chip::ptmr::PTMR_CTRL -s = 0x1
}

proc chip::ptmr::status {} {
    # Display PHY timer control register value:
    set stat [mem p:$chip::ptmr::PTMR_CTRL -s -np]
    puts "PHY Timer Control: $stat"
}

namespace eval chip::ptmr::comp {
    namespace export disable
    namespace export enable
    namespace export status
}

proc chip::ptmr::comp::disable {bank} {
    set bank [string tolower ${bank}]
    if {[scan ${bank} "axiq%d" b] != 1} {
        error "AXIQ: cannot find bank ${bank}!"
    }

    # Force comparator output to 0:
    mem p:[format "0x%08X" [expr $chip::ptmr::PTMR_C0SC + 0x18 * $b]] -s = [expr 0x1 << 2]
}

proc chip::ptmr::comp::enable {bank} {
    set bank [string tolower ${bank}]
    if {[scan ${bank} "axiq%d" b] != 1} {
        error "AXIQ: cannot find bank ${bank}!"
    }

    # Force comparator output to 1:
    mem p:[format "0x%08X" [expr $chip::ptmr::PTMR_C0SC + 0x18 * $b]] -s = [expr 0x2 << 2]
}

proc chip::ptmr::comp::status {bank} {
    set bank [string tolower ${bank}]
    if {[scan ${bank} "axiq%d" b] != 1} {
        error "AXIQ: cannot find bank ${bank}!"
    }

    # Display comparator control/status register value:
    set stat [mem p:[format "0x%08X" [expr $chip::ptmr::PTMR_C0SC + 0x18 * $b + 0x0]] -s -np]
    if {[expr $stat & 0x80000000] == 0x80000000} {
        puts "RX : $stat (output HIGH)"
    } elseif {[expr $stat & 0x80000000] == 0} {
        puts "RX : $stat (output LOW)"
    }
    set stat [mem p:[format "0x%08X" [expr $chip::ptmr::PTMR_C0SC + 0x18 * $b + 0x8]] -s -np]
    puts "TX : $stat"
}

namespace eval chip::axiq {
    namespace export connect

    namespace eval hs {
        namespace export connect
    }
}

proc chip::axiq::rxphytimer {bank} {
    # Check input arguments:
    set bank [string tolower ${bank}]
    if {[scan ${bank} "axiq%d" b] != 1} {
        error "AXIQ: cannot find bank ${bank}!"
    }

    set addr_phytimer_bank0 0x08b19c04
    set addr_phytimer [format 0x%08x [expr {0x08b19c04 + 0x18*$b}]]

    # Enable the PHY Timer Clock
    mem p:0x08b19c00 -s =0x1
    # Force the PHY Timer -> AXIQ "RX Allowed" signals HIGH
    mem p:$addr_phytimer -s =0x8
}

proc chip::axiq::connect { bank fifo {name ""} {sample_delay 0} } {
    # Check input arguments:
    set bank [string tolower ${bank}]
    set fifo [string tolower ${fifo}]
    if {[scan ${bank} "axiq%d" b] != 1} {
        error "AXIQ: cannot find bank ${bank}!"
    }
    if {([scan ${fifo} "rx%d" f] != 1) && ([scan ${fifo} "tx%d" f] != 1)} {
        error "AXIQ: cannot find FIFO ${fifo}!"
    }

    # DMA channel to connect:
    set chan [expr ${b} * 5 + ${f} + 1]

    # Connect DMA channel to file:
    if {[string compare $name ""] == 0} {
        dma_channel ${chan} [pwd]/${bank}_${fifo}
    } else {
        dma_channel ${chan} [pwd]/$name 0 $sample_delay
    }

    # AXIQ to DMA trigger period based on sampling rate:
    set T [expr $chip::vspa::freq/$chip::dcs::freq*16*$chip::vspa::waxi/32]

    # Set DMA trigger period:
    dma_trigger ${chan} 50000 [expr int(${T})] 50000
}

proc chip::axiq::hs::connect {fifo {name ""} {sample_delay 0}} {
    # Check input arguments:
    set fifo [string tolower ${fifo}]
    if {([scan ${fifo} "rx%d" f] != 1) && ([scan ${fifo} "tx%d" f] != 1)} {
        error "AXIQ: cannot find FIFO ${fifo}!"
    }

    # DMA channel to connect:
    set chan [expr 11 + ${f}]

    # Connect DMA channel to file:
    if {[string compare $name ""] == 0} {
        dma_channel ${chan} [pwd]/${fifo}
    } else {
        dma_channel ${chan} [pwd]/$name 0 $sample_delay
    }

    # AXIQ to DMA trigger period based on sampling rate:
    set T [expr $chip::vspa::freq/$chip::dcs::hs::freq*16*$chip::vspa::waxi/32]

    # Set DMA trigger period:
    dma_trigger ${chan} 50000 [expr int(${T})] 50000
}
