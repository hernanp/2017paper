ulimit -Ss unlimited
ghdl -a arbiter.vhd
ghdl -a arbiter2.vhd
ghdl -a arbiter3.vhd
ghdl -a --ieee=synopsys nondeterminism.vhd
ghdl -a std_fifo.vhd
ghdl -a --ieee=synopsys  CPU.vhd
ghdl -a AXI.vhd
ghdl -a gfx.vhd
ghdl -a PWR.vhd
ghdl -a --ieee=synopsys Memory.vhd
ghdl -a -fexplicit L1Cache.vhd 
ghdl -a --ieee=synopsys  top.vhd
ghdl -e --ieee=synopsys  top


\\./top --stop-time=5000ps  --wave=new.ghw 
./top --stop-time=15000ps  --vcd=new.vcd 
