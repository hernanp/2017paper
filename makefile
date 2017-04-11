
.PHONY: all test clean sim

all:
# types and funs
	ghdl -a defs.vhd
	ghdl -a util.vhd
	ghdl -a --ieee=synopsys rand.vhd # dependency for [usb,gfx,cpu,memory,uart].vhd
	ghdl -a test.vhd # Test configuration
# data structs
	ghdl -a arbiter.vhd
	ghdl -a arbiter2.vhd
	ghdl -a arbiter2_ack.vhd
	ghdl -a arbiter3.vhd
	ghdl -a fifo.vhd # dependency for [pwr,cache,ic].vhd
# modules
	ghdl -a pwr.vhd # uses fifo
	ghdl -a mem.vhd
	ghdl -a -fexplicit cache.vhd # uses fifo, arbiter2
	ghdl -a --ieee=synopsys cpu.vhd
	ghdl -a pwr.vhd
	ghdl -a arbiter6.vhd
	ghdl -a arbiter6_ack.vhd
	ghdl -a arbiter61.vhd
	ghdl -a arbiter7.vhd
	ghdl -a --ieee=synopsys ic.vhd # uses fifo, arbiter2,6,61,7
	ghdl -a --ieee=synopsys gfx.vhd
	ghdl -a audio.vhd
	ghdl -a usb.vhd
	ghdl -a uart.vhd
# simulation
	ghdl -a --ieee=synopsys top.vhd
	ghdl -e --ieee=synopsys top
topnsim:
	ghdl -a --ieee=synopsys top.vhd
	ghdl -e --ieee=synopsys top
	./top --vcd=top.vcd
clean:
	rm *.o *.vcd
rand:
	python rand.py # use opts -n and -c to set count and max
showtree:
	./top --no-run --disp-tree
sim:
	./top --stop-time=10000ps --vcd=top.vcd
# TODO need to adjust parameters here
# see http://ghdl.readthedocs.io/en/latest/Simulation_and_runtime.html#simulation-and-runtime
wave:
	gtkwave top.vcd
html_docs:
	vhdocl *.vhd
sm_docs: # generate state machines
	graph-easy --input=doc/arbiter2_sm.txt --output=doc/arbiter2.ascii
	graph-easy --input=doc/arbiter2_ack_sm.txt --output=doc/arbiter2_ack.ascii
	graph-easy --input=doc/cpu_sm.txt --output=doc/cpu.ascii
flow_docs:
	graph-easy --input=doc/pwr_flow.txt --output=doc/pwr_flow.ascii
	graph-easy --input=doc/up_r_flow.txt --output=doc/up_r_flow.ascii
	graph-easy --input=doc/dn_r_flow.txt --output=doc/dn_r_flow.ascii
deps_docs:
	graph-easy --input=doc/deps.txt --output=doc/deps.ascii
test_docs:
	graph-easy --input=doc/cpu1_r_test.txt --output=doc/cpu1_r_test.ascii
	sed -i.old '1s;^;#cpu1_r_test\n\n;' doc/cpu1_r_test.ascii
	graph-easy --input=doc/cpu2_w_test.txt --output=doc/cpu2_w_test.ascii
	sed -i.old '1s;^;#cpu2_w_test\n\n;' doc/cpu2_w_test.ascii
	graph-easy --input=doc/gfx_r_test.txt --output=doc/gfx_r_test.ascii
	sed -i.old '1s;^;#gfx_r_test\n\n;' doc/gfx_r_test.ascii
	graph-easy --input=doc/ic_pwr_test.txt --output=doc/ic_pwr_test.ascii
	sed -i.old '1s;^;#ic_pwr_test\n\n;' doc/ic_pwr_test.ascii
	rm doc/*.old
block_docs:
	graph-easy --input=doc/cpu_block.txt --output=doc/cpu_block.ascii
	sed -i.old '1s;^;#ic_pwr_test\n\n;' doc/cpu_block.ascii
	graph-easy --input=doc/top_block.txt --output=doc/top_block.ascii
	sed -i.old '1s;^;#ic_pwr_test\n\n;' doc/top_block.ascii
	rm doc/*.old
