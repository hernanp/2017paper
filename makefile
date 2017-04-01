
all:
# types and funs
	ghdl -a type_defs.vhd
	ghdl -a rand.vhd # dependency for [usb,gfx,cpu,memory,uart].vhd
# data structs
	ghdl -a arbiter.vhd
	ghdl -a arbiter2.vhd
	ghdl -a arbiter2_ack.vhd
	ghdl -a arbiter3.vhd
	ghdl -a fifo.vhd # dependency for [pwr,l1cache,axi].vhd
# modules
	ghdl -a gfx.vhd
	ghdl -a pwr.vhd # uses fifo
	ghdl -a mem.vhd
	ghdl -a -fexplicit l1_cache.vhd # uses fifo, arbiter2
	ghdl -a --ieee=synopsys cpu.vhd
	ghdl -a pwr.vhd
	ghdl -a arbiter6.vhd
	ghdl -a arbiter6_ack.vhd
	ghdl -a arbiter61.vhd
	ghdl -a arbiter7.vhd
	ghdl -a ic.vhd # uses fifo, arbiter2,6,61,7
	ghdl -a gfx.vhd
	ghdl -a audio.vhd
	ghdl -a usb.vhd
	ghdl -a uart.vhd
# simulation
	ghdl -a --ieee=synopsys top.vhd
	ghdl -e --ieee=synopsys top
topnsim:
	ghdl -a --ieee=synopsys top.vhd
	ghdl -e --ieee=synopsys top
	./top --vcd=tb.vcd
clean:
	rm *.o
showtree:
	./top --no-run --disp-tree
sim:
# TODO need to adjust parameters here
# see http://ghdl.readthedocs.io/en/latest/Simulation_and_runtime.html#simulation-and-runtime
	./top --stop-time=10000ps --vcd=top.vcd
viewwave:
	gtkwave top.vcd
docs:
	vhdocl *.vhd
gen_sm: # generate state machines
	graph-easy --input=doc/arbiter2.sm --output=doc/arbiter2.ascii
	graph-easy --input=doc/arbiter2_ack.sm --output=doc/arbiter2_ack.ascii
	graph-easy --input=doc/cpu.sm --output=doc/cpu.ascii
