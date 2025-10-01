set_property PACKAGE_PIN Y9 [get_ports clk50]
set_property IOSTANDARD LVCMOS33 [get_ports clk50]
create_clock -period 20.0 -name sys_clk -waveform {0 10} [get_ports clk50]


set_property PACKAGE_PIN R18 [get_ports RESET]
set_property IOSTANDARD LVCMOS33 [get_ports RESET]
