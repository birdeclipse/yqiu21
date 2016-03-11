
core:
	verilator  --cc --trace --Wall ./rtl/core.v ./rtl/icache.v ./rtl/fetch.v ./rtl/regfile.v ./rtl/decode.v ./rtl/execute.v ./rtl/flop.v ./rtl/sram.v -exe tests/low_performance_core_test.cpp -CFLAGS -DTRACE=1
	make -C obj_dir/ -f Vcore.mk Vcore

icache: 
	verilator  --cc --trace --Wall ./rtl/icache.v ./rtl/flop.v ./rtl/sram.v -exe tests/icache_test.cpp -CFLAGS -DTRACE=1
	make -C obj_dir/ -f Vicache.mk Vicache

run0: icache
	obj_dir/Vicache
	gtkwave output.vcd &	

run1: core
	obj_dir/Vcore
	gtkwave output.vcd &
	
clean:
	rm -rf obj_dir output.vcd


