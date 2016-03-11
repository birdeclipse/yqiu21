/* some User specified files */







#ifndef TRACE







#define TRACE







#endif







#include "Vicache.h"



#include "verilated.h"



#include "verilated_vcd_c.h"



#include "stdlib.h"



#include "time.h"



#include "stdint.h"







vluint64_t global_time = 0;







VerilatedVcdC* tfp = 0;







/*Number of simulation cyles*/



#define NUM_CYCLE ((vluint64_t)2048)



/*Half_Period (in ps) of a clock 100.000MHZ clock*/



#define HALF_PER_PS ((vluint64_t)5000)



/*Number of Reset Cycles*/



#define NUM_RESET_CYCLE ((vluint64_t)64)


const unsigned int rom [3][8]	= { {0x00150793,0x00158593,0x01000713,0x00000513,0x00a78533,0x00b50533,0x00179793,0x00159593},
									{0xfff70713,0xfe0716e3,0x4067d793,0x4075d593,0x00800713,0x40f50533,0x40b50533,0x4017d793},
									{0x4015d593,0xfff70713,0xfe0716e3,0x00008067,0x00000000,0x00000000,0x00000000,0x00000000} };

int main(int argc, char **argv, char **env) {

	/*User Variables begins here*/

	vluint64_t half_cycyle_count;

	uint16_t i;

	uint32_t wait_time;

	uint32_t pc_inc_time;
	
	uint64_t current_pc;

	/*User Variables ends here*/

	Verilated::commandArgs(argc, argv);

	/* init top verilog instance HERE!!!*/


	Vicache* top = new Vicache;

	/* init top verilog instance ENDS!!!*/

#ifdef TRACE

	// init trace dump

	Verilated::traceEverOn(true);
	
	tfp = new VerilatedVcdC;

	top->trace(tfp, 99);

	tfp->spTrace()->set_time_resolution ("1 ns");

	tfp->open("output.vcd");

#endif
	// initialize simulation inputs
	top->clk   = 0;
	top->reset = 1;
	srand(time(0));	
	current_pc = 0x0000000000000000;
	top->core_req_pc = 0x0000000000000000;
	top->core_req_pc_valid = 0;
	top->icache_ack_data_valid = 0;
	wait_time = 5;
	pc_inc_time = 0;

	

	for(i=0;i<8;i++){
		top->icache_ack_data[i]	= 0;
	}
	for(half_cycyle_count=0;half_cycyle_count<(NUM_CYCLE*2);half_cycyle_count++){

		top->reset = (half_cycyle_count<(NUM_RESET_CYCLE*2)?1:0);
		top->clk = top->clk^1;
		top->eval();
		if((top->reset == 0)&(top->clk == 1)){
			if(half_cycyle_count>((NUM_RESET_CYCLE+1)*2)){
				if((top->core_ack_insn_valid)&(pc_inc_time != 0)){
					if(top->core_ack_insn == rom [(top->icache_req_addr)%8][(current_pc&0x1f)/4]){

						printf("test pass!\n");
						
						printf("passed!! at %ld cycle\n",half_cycyle_count/2);
						
						printf("expected:%lx\n\n",rom [(top->icache_req_addr)%8][((current_pc&0x1f))/4]);
					}
					else{

						printf("test fail!\n");

						printf("failed!! at %ld cycle\n",half_cycyle_count/2);

						printf("expected:%x\n\n",rom [(top->icache_req_addr)%8][((current_pc&0x1f))/4]);

					}
				}	
				if(top->icache_req_addr_valid){

					for(i=0;i<8;i++){
						top->icache_ack_data[i]	= rom [(top->icache_req_addr)%8][i];/*wrapp it simple test*/
					}
					if(wait_time <= 0){
						top->icache_ack_data_valid	=	1;
						wait_time =	rand()%20+1;
					}
					else if(wait_time>0){
						top->icache_ack_data_valid	=	0;
						wait_time--;
					}
				}

				if((top->core_ack_insn_valid)){
					pc_inc_time++;
					if(pc_inc_time == 3){
						current_pc += 4; 
						top->core_req_pc =	(current_pc>>1);
						pc_inc_time	= 0;		
						top->core_req_pc_valid = 1;
					}
				}
				else{
					current_pc = current_pc;
					top->core_req_pc = (current_pc>>1);
					top->core_req_pc_valid = 1;	
				}
			}
		}
		/*Evaluate verilated model;*/
#ifdef TRACE

	if(tfp) tfp->dump(half_cycyle_count * HALF_PER_PS);


#endif

		/*Next half cycle;*/
		if(Verilated::gotFinish()){
			exit(0);
		}
	}
	top->final();

#ifdef TRACE

	tfp->close();

#endif

	exit(0);

}

