open_project ./LED_Controller/LED_Controller.xpr
update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs 16
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
   error "ERROR: impl_1 failed"
}

write_hw_platform -fixed -include_bit -force -file ./design_1_wrapper.xsa