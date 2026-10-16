# Posit(8,1): out-of-context synthesis and placed/routed implementation.
# Vivado Tcl console: source C:/FPGA/Posit_8_1_vivado/posit_synth/vivado/synth/build.tcl
# Or in Vivado batch: vivado -mode batch -source build.tcl -tclargs 10.0
# Run independently from the original Vivado project to avoid modifying its runs.
set period [lindex $argv 0]
if {$period eq ""} { set period 10.0 }
set part xc7vx485tffg1157-1
set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here .. ..]]
set reports [file join $here reports]
file mkdir $reports

read_vhdl -vhdl2008 [list \
    [file join $root rtl decoder_posit.vhd] \
    [file join $root rtl sign_and_exponent_PU.vhd] \
    [file join $root rtl mantissa_multiplier.vhd] \
    [file join $root rtl normalization.vhd] \
    [file join $root rtl posit_component_packing.vhd] \
    [file join $root rtl posit_rounding.vhd] \
    [file join $root rtl posit_multiplier_top.vhd] \
    [file join $here posit_mul_synth_wrapper.vhd]]

synth_design -top posit_mul_synth_wrapper -part $part -mode out_of_context
create_clock -name sys_clk -period $period [get_ports clk]
opt_design
place_design
phys_opt_design
route_design

report_utilization -file [file join $reports utilization.rpt]
report_utilization -hierarchical -file [file join $reports utilization_hier.rpt]
report_timing_summary -file [file join $reports timing.rpt]
report_timing -max_paths 10 -delay_type max -file [file join $reports paths.rpt]
report_power -file [file join $reports power.rpt]

set paths [get_timing_paths -delay_type max -max_paths 1]
if {[llength $paths] > 0} {
    set wns [get_property SLACK [lindex $paths 0]]
    set delay [expr {$period - $wns}]
    set fmax [expr {1000.0 / $delay}]
} else {
    set wns "NA"
    set delay "NA"
    set fmax "NA"
}
set luts [llength [get_cells -hierarchical -filter {PRIMITIVE_GROUP == LUT}]]
set ffs [llength [get_cells -hierarchical -filter {PRIMITIVE_GROUP == FLOP_LATCH}]]
set carry [llength [get_cells -hierarchical -filter {REF_NAME == CARRY4}]]
set dsps [llength [get_cells -hierarchical -filter {REF_NAME =~ DSP48*}]]
set slice_luts "?"
regexp {Slice LUTs\*?\s*\|\s*(\d+)} [report_utilization -return_string] -> slice_luts
set dyn_power "?"
regexp {Dynamic \(W\)\s*\|\s*([0-9.]+)} [report_power -return_string] -> dyn_power
puts "-----------------------------------------------------------"
puts "Posit (8,1) | $part | period $period ns"
puts "WNS: $wns ns | delay: $delay ns | Fmax estimate: $fmax MHz"
puts "Slice LUTs: $slice_luts | LUT cells: $luts | CARRY4: $carry"
puts "DSP: $dsps | FFs (includes wrapper): $ffs"
puts "Dynamic power: $dyn_power W (vectorless estimate)"
puts "Reports: $reports"
puts "-----------------------------------------------------------"
