
all:
	ghdl -a arbiter.vhd
	ghdl -a arbiter2.vhd
	ghdl -a arbiter3.vhd
	ghdl -a --ieee=synopsys nondeterminism.vhd # dependency for [usb,gfx,cpu,memory,uart].vhd
	ghdl -a fifo.vhd
	ghdl -a axi.vhd
	ghdl -a --ieee=synopsys gfx.vhd
	ghdl -a pwr.vhd
	ghdl -a --ieee=synopsys mem.vhd
	ghdl -a -fexplicit l1cache.vhd
	ghdl -a -ieee=synopsys cpu.vhd
	ghdl -a pwd.vhd
	ghdl -a arbiter6.vhd
	ghdl -a arbiter61.vhd
	ghdl -a arbiter7.vhd
	ghdl -a axi.vhd
	ghdl -a --ieee=synopsys  gfx.vhd
	ghdl -a --ieee=synopsys audio.vhd
	ghdl -a --ieee=synopsys usb.vhd
	ghdl -a --ieee=synopsys uart.vhd
	ghdl -a --ieee=synopsys  top.vhd
	ghdl -e --ieee=synopsys  top
topnsim:
	ghdl -a --ieee=synopsys  top.vhd
	ghdl -e --ieee=synopsys  top
	./top --vcd=tb.vcd
clean:
	rm *.o
showtree:
	./top --no-run --disp-tree
simulate:
# TODO need to adjust parameters here
# see http://ghdl.readthedocs.io/en/latest/Simulation_and_runtime.html#simulation-and-runtime
	./top --disp-time --stop-time=1ps --stop-delta=2 --vcd=top.vcd
viewwave:
	gtkwave top.vcd
