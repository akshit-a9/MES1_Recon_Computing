## Clock input (100 MHz)
set_property PACKAGE_PIN Y9 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

## Enable switch (SW0)
set_property PACKAGE_PIN F22 [get_ports enable_sw]
set_property IOSTANDARD LVCMOS33 [get_ports enable_sw]

## Reference output (for ILA)
set_property PACKAGE_PIN T22 [get_ports ref_clk_out]
set_property IOSTANDARD LVCMOS33 [get_ports ref_clk_out]

## Optional LED (for observing wave output)
set_property PACKAGE_PIN U14 [get_ports wave_led]
set_property IOSTANDARD LVCMOS33 [get_ports wave_led]
