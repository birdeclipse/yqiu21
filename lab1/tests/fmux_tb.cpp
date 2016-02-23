
#include "Vfmux.h"
#include "verilated.h"
#include "verilated_vcd_c.h"


vluint64_t global_time = 0;
VerilatedVcdC* tfp = 0;

void advance_clock(Vfmux *top, int nclocks=1) {

  for( int i=0;i<nclocks;i++) {
    for (int clk=0; clk<2; clk++) {
#ifdef TRACE
      tfp->dump(global_time);
#endif

      top->clk = !top->clk;
      top->eval();

      global_time++;
      if (Verilated::gotFinish())  
        exit(0);
    }
  }

}

int main(int argc, char **argv, char **env) {
  int i;
  int clk;
  Verilated::commandArgs(argc, argv);
  // init top verilog instance
  Vfmux* top = new Vfmux;

#ifdef TRACE
  // init trace dump
  Verilated::traceEverOn(true);
  tfp = new VerilatedVcdC;

  top->trace(tfp, 99);
  tfp->open("output.vcd");
#endif

  // initialize simulation inputs
  top->clk = 1;
  top->a   = 1;
  top->b   = 0;

  top->sel = 1;

  
  for(i=0;i<20;i++){
	  advance_clock(top,1);
	  if((i+1)%5==0&i>0){
		  top->sel = top->sel^1;
	  }
	  if(i>=9){
		  top->b =	1;
	  }
	  if(i<10){
		  top->a = 1;
	  }
	  else{
		  if(i%2){	/*clock is odd*/
			  top->a = 1;
		  }
		  else{
			  top->a = 0;
		  }
		  
	  }
	  
	  
	  
  }
 /* advance_clock(top,1);
  top->sel = 0;
  advance_clock(top,1);
  top->sel = 1;
  advance_clock(top,1);
  top->a = !top->a;
  top->b = !top->b;
  advance_clock(top,1);
  top->sel = 0;
  advance_clock(top,1);*/

#ifdef TRACE
  tfp->close();
#endif

  exit(0);
}

