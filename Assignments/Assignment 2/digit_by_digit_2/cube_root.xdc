set_property PACKAGE_PIN Y9 [get_ports clk]       
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]