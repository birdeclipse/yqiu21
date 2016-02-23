
core_alu:
	verilator  --cc --trace --Wall ./rtl/core_alu.v ./rtl/flop.v  --exe tests/core_alu_tb.cpp -CFLAGS -DTRACE=1
	make -C obj_dir/ -f Vcore_alu.mk Vcore_alu

run: core_alu
	obj_dir/Vcore_alu
	gtkwave output.vcd &
	
clean:
	rm -rf obj_dir output.vcd


