set errorCount 0

project new ben_mem

project set "Manual Implementation Compile Order" true

project set family  spartan6
project set device  xc6slx16
project set package csg324
project set speed   -3

if { ![xfile add "./ben_mem/doc/pg058-blk-mem-gen.pdf" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/doc/pg058-blk-mem-gen.pdf' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/doc/blk_mem_gen_v7_3_vinfo.html" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/doc/blk_mem_gen_v7_3_vinfo.html' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/blk_mem_gen_v7_3_readme.txt" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/blk_mem_gen_v7_3_readme.txt' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/example_design/ben_mem_exdes.ucf" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/example_design/ben_mem_exdes.ucf' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/example_design/ben_mem_exdes.vhd" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/example_design/ben_mem_exdes.vhd' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/example_design/ben_mem_exdes.xdc" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/example_design/ben_mem_exdes.xdc' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/example_design/ben_mem_prod.vhd" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/example_design/ben_mem_prod.vhd' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/implement/implement.bat" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/implement/implement.bat' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/implement/implement.sh" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/implement/implement.sh' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/implement/planAhead_ise.bat" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/implement/planAhead_ise.bat' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/implement/planAhead_ise.sh" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/implement/planAhead_ise.sh' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/implement/planAhead_ise.tcl" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/implement/planAhead_ise.tcl' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/implement/xst.prj" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/implement/xst.prj' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/implement/xst.scr" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/implement/xst.scr' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/addr_gen.vhd" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/addr_gen.vhd' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/ben_mem_synth.vhd" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/ben_mem_synth.vhd' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/ben_mem_tb.vhd" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/ben_mem_tb.vhd' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/bmg_stim_gen.vhd" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/bmg_stim_gen.vhd' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/bmg_tb_pkg.vhd" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/bmg_tb_pkg.vhd' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/functional/simcmds.tcl" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/functional/simcmds.tcl' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/functional/simulate_isim.bat" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/functional/simulate_isim.bat' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/functional/simulate_mti.bat" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/functional/simulate_mti.bat' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/functional/simulate_mti.do" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/functional/simulate_mti.do' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/functional/simulate_mti.sh" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/functional/simulate_mti.sh' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/functional/simulate_ncsim.sh" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/functional/simulate_ncsim.sh' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/functional/simulate_vcs.sh" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/functional/simulate_vcs.sh' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/functional/ucli_commands.key" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/functional/ucli_commands.key' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/functional/vcs_session.tcl" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/functional/vcs_session.tcl' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/functional/wave_mti.do" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/functional/wave_mti.do' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/functional/wave_ncsim.sv" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/functional/wave_ncsim.sv' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/random.vhd" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/random.vhd' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/timing/simcmds.tcl" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/timing/simcmds.tcl' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/timing/simulate_isim.bat" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/timing/simulate_isim.bat' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/timing/simulate_mti.bat" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/timing/simulate_mti.bat' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/timing/simulate_mti.do" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/timing/simulate_mti.do' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/timing/simulate_mti.sh" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/timing/simulate_mti.sh' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/timing/simulate_ncsim.sh" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/timing/simulate_ncsim.sh' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/timing/simulate_vcs.sh" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/timing/simulate_vcs.sh' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/timing/ucli_commands.key" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/timing/ucli_commands.key' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/timing/vcs_session.tcl" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/timing/vcs_session.tcl' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/timing/wave_mti.do" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/timing/wave_mti.do' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem/simulation/timing/wave_ncsim.sv" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem/simulation/timing/wave_ncsim.sv' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem.ngc" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem.ngc' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem.veo" -view implementation -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem.veo' to ISE project."
   incr errorCount
}
if { ![xfile add "./ben_mem.v" -view all -origin_type created] } {
   puts "ERROR: Failed to add './ben_mem.v' to ISE project."
   incr errorCount
}

project set top "ben_mem"

project set "Project Generator" CoreGen
project set "Implementation Stop View" Structural

project save
project close

exit $errorCount
