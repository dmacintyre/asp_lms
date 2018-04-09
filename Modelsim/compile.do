
proc compile_all {} {
    vlib work
    
    vcom -2008 src/lms_pkg.vhd
    vcom -2008 src/lms.vhd
    vcom -2008 tb/lms_tb.vhd

}

proc rc {} {
    vsim -t 1fs lms_tb 
    set StdArithNoWarnings 0
    set NumericStdNoWarnings 0
    add wave -radix hex -group "testbench" sim:/lms_tb/*  
    run -all
}
