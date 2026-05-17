### 1. Setup Library Paths
set_db lib_search_path {/home/install/FOUNDRY/digital/90nm/dig/lib}
set_db library {slow.lib}

### Create reports directory
exec mkdir -p reports

### 2. Read ALL HDL Files
read_hdl { 
    scoring_unit.v gap_penalty_unit.v simd_pe.v simd_pe_array.v 
    dp_row_buffer.v direction_buffer.v max_score_tracker.v 
    simd_controller.v traceback_unit.v top_module.v 
}

### 3. Elaborate Top Module
elaborate top_simd_alignment

### 4. Apply 100MHz Constraints
read_sdc constraints.sdc

### 5. High-Effort Synthesis
set_db syn_generic_effort high
syn_generic

set_db syn_map_effort high
syn_map

set_db syn_opt_effort high
syn_opt

### 6. Export Results 
write_hdl > reports/top_simd_100mhz_netlist.v
write_sdc > reports/top_simd_100mhz_final.sdc

### 7. Generate Area, Power, and Timing Reports
report_timing > reports/synth_timing.rpt
report_area   > reports/synth_area.rpt
report_power  > reports/synth_power.rpt
report_qor    > reports/synth_qor.rpt

puts "Synthesis Finished successfully at 100MHz."

