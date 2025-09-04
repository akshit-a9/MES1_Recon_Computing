# ZedBoard Pin Assignments
############################
# On-board Slide Switches  #
############################
set_property PACKAGE_PIN R18 [get_ports RESET]
set_property IOSTANDARD LVCMOS33 [get_ports RESET]

set_property PACKAGE_PIN  Y9 [get_ports CLK_IN]
set_property IOSTANDARD LVCMOS33 [get_ports CLK_IN]
create_clock -period 10 [get_ports CLK_IN]

############################
# On-board led             #
############################
set_property PACKAGE_PIN T22 [get_ports LED0]
set_property IOSTANDARD LVCMOS33 [get_ports LED0]
set_property PACKAGE_PIN T21 [get_ports LED1]
set_property IOSTANDARD LVCMOS33 [get_ports LED1]
set_property PACKAGE_PIN U22 [get_ports BIT_OUT]
set_property IOSTANDARD LVCMOS33 [get_ports BIT_OUT]

