## Clock input: 100 MHz oscillator
set_property PACKAGE_PIN Y9 [get_ports clk]        # GCLK on ZedBoard
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

## Reset input: center push button
set_property PACKAGE_PIN P16 [get_ports reset]     # BTNC
set_property IOSTANDARD LVCMOS18 [get_ports reset]

## Optional: Map outputs to LEDs (for quick visual check)
set_property PACKAGE_PIN T22 [get_ports {number_out[0]}]  # LD0
set_property PACKAGE_PIN T21 [get_ports {number_out[1]}]  # LD1
set_property PACKAGE_PIN U22 [get_ports {number_out[2]}]  # LD2
set_property PACKAGE_PIN U21 [get_ports {number_out[3]}]  # LD3
set_property PACKAGE_PIN V22 [get_ports {number_out[4]}]  # LD4
set_property PACKAGE_PIN W22 [get_ports {number_out[5]}]  # LD5
set_property PACKAGE_PIN U19 [get_ports {number_out[6]}]  # LD6
set_property PACKAGE_PIN U14 [get_ports {number_out[7]}]  # LD7
set_property IOSTANDARD LVCMOS33 [get_ports {number_out[*]}]
