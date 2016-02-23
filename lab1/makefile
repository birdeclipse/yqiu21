
fmux:
	verilator  --cc --trace ./rtl/fmux.v ./rtl/flop.v --exe tests/fmux_tb.cpp -CFLAGS -DTRACE=1
	make -C obj_dir/ -f Vfmux.mk Vfmux

run: fmux
	obj_dir/Vfmux
	gtkwave output.vcd &
	
clean:
	rm -rf obj_dir output.vcd


