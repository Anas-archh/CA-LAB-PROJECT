

# Clock constraint
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]

# I/O standards
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports zero]

# Seven-segment pins (unchanged)
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]

# Switch mapping
# B on rightmost 6 switches (sw[0]-sw[5])
set_property IOSTANDARD LVCMOS33 [get_ports {B[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[3]}]
set_property IOSTANDARD LVCMOS33  [get_ports {B[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {B[5]}]

set_property PACKAGE_PIN V17 [get_ports {B[0]}]
set_property PACKAGE_PIN V16 [get_ports {B[1]}]
set_property PACKAGE_PIN W16 [get_ports {B[2]}]
set_property PACKAGE_PIN W17 [get_ports {B[3]}]
set_property PACKAGE_PIN W15 [get_ports {B[4]}]
set_property PACKAGE_PIN V15 [get_ports {B[5]}]

# A on next 6 switches (sw[6]-sw[11])
set_property IOSTANDARD LVCMOS33 [get_ports {A[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {A[5]}]

set_property PACKAGE_PIN W14 [get_ports {A[0]}]
set_property PACKAGE_PIN W13 [get_ports {A[1]}]
set_property PACKAGE_PIN V2  [get_ports {A[2]}]
set_property PACKAGE_PIN T3  [get_ports {A[3]}]
set_property PACKAGE_PIN T2  [get_ports {A[4]}]
set_property PACKAGE_PIN R3  [get_ports {A[5]}]

# ALUctl on leftmost 4 switches (sw[12]-sw[15])
set_property IOSTANDARD LVCMOS33 [get_ports {ALUctl[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ALUctl[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ALUctl[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ALUctl[3]}]

set_property PACKAGE_PIN W2  [get_ports {ALUctl[0]}]
set_property PACKAGE_PIN U1  [get_ports {ALUctl[1]}]
set_property PACKAGE_PIN T1  [get_ports {ALUctl[2]}]
set_property PACKAGE_PIN R2  [get_ports {ALUctl[3]}]

# Clock and reset pins
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

set_property PACKAGE_PIN W5  [get_ports clk]
set_property PACKAGE_PIN U18 [get_ports reset]

# Zero output mapped to LED (example pin L1)
set_property IOSTANDARD LVCMOS33 [get_ports Zero]

set_property PACKAGE_PIN L1  [get_ports Zero]