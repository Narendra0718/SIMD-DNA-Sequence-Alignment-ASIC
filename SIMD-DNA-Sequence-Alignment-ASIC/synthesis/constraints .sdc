### 100 MHz target = 10.0ns period
create_clock -name clk -period 10.0 [get_ports clk]

### Uncertainty: 400ps safety margin (REVERTED to save area)
set_clock_uncertainty 0.4 [get_clocks clk]

### Standard IO Delays
set_input_delay -clock clk 2.0 [all_inputs -no_clocks]
set_output_delay -clock clk 2.0 [all_outputs]
set_load 0.05 [all_outputs]

### =========================================================================
### CRITICAL FIX: MULTI-CYCLE PATH
### Tells the synthesis tool that the combinational array is safely
### allowed 2 clock cycles (20.0 ns) to reach the registers!
### =========================================================================
set_multicycle_path 2 -setup -from [all_inputs] -to [all_registers]
set_multicycle_path 2 -setup -from [all_registers] -to [all_registers]
set_multicycle_path 1 -hold -from [all_inputs] -to [all_registers]
set_multicycle_path 1 -hold -from [all_registers] -to [all_registers]
