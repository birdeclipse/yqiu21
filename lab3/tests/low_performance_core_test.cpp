/* some User specified files */

#ifndef TRACE

#define TRACE

#endif

#include "Vcore.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "stdlib.h"
#include "time.h"
#include "stdint.h"


vluint64_t global_time = 0;
VerilatedVcdC* tfp = 0;


//  long int test_loop(long int a , long int b){
//	long int i  = 	0;
//	long int result	=	0;
//	a++;
//	b++;
//	for (i=0; i<16;i++){
//		result += a;
//		result += b;
//		a = a<<1;
//		b = b<<1;
//	}
//	a= (a>>6);
//	b= (b>>7);
//	for (i=0;i<8;i++){
//		result -= a;
//		result -= b;
//		a = a>>1;
//		b = b>>1;
//	}
//	return result;
//}


//0000000000000000 <test_loop>:

//   0:	00150793          	addi	a5,a0,1
//   4:	00158593          	addi	a1,a1,1
//   8:	01000713          	li	a4,16
//   c:	00000513          	li	a0,0

//0000000000000010 <.L2>:

//  10:	00a78533          	add	a0,a5,a0
//  14:	00b50533          	add	a0,a0,a1
//  18:	00179793          	slli	a5,a5,0x1
//  1c:	00159593          	slli	a1,a1,0x1
//  20:	fff70713          	addi	a4,a4,-1
//  24:	fe0716e3          	bnez	a4,10 <.L2>
//  28:	4067d793          	srai	a5,a5,0x6
//  2c:	4075d593          	srai	a1,a1,0x7
//  30:	00800713          	li	a4,8



//0000000000000034 <.L3>:

//  34:	40f50533          	sub	a0,a0,a5
//  38:	40b50533          	sub	a0,a0,a1
//  3c:	4017d793          	srai	a5,a5,0x1
//  40:	4015d593          	srai	a1,a1,0x1
//  44:	fff70713          	addi	a4,a4,-1
//  48:	fe0716e3          	bnez	a4,34 <.L3>
//  4c:	00008067          	ret







const unsigned int rom [3][8]	= { 
					{0x00150793,0x00158593,0x01000713,0x00000513,0x00a78533,0x00b50533,0x00179793,0x00159593},
					{0xfff70713,0xfe0716e3,0x4067d793,0x4075d593,0x00800713,0x40f50533,0x40b50533,0x4017d793},
					{0x4015d593,0xfff70713,0xfe0716e3,0x00008067,0x00000000,0x00000000,0x00000000,0x00000000} 
				};



uint32_t instr_gen(uint32_t number);

/*Number of simulation cyles*/
#define NUM_CYCLE ((vluint64_t)1280)
/*Half_Period (in ps) of a clock 100.000MHZ clock*/
#define HALF_PER_PS ((vluint64_t)5000)
/*Number of Reset Cycles*/
#define NUM_RESET_CYCLE ((vluint64_t)64)


int main(int argc, char **argv, char **env) {

	/*User Variables begins here*/

	vluint64_t half_cycyle_count;
	uint16_t i;
	uint32_t wait_time;	
	uint16_t stop_flag;
	/*User Variables ends here*/
	Verilated::commandArgs(argc, argv);
	/* init top verilog instance HERE!!!*/
	Vcore* top = new Vcore;
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
	srand(time(NULL));	
	stop_flag = 0;
    
    
    	printf("\n\n\n\n\n\n\n\n\n\n\n\n\n");
    	printf("\f");
    	printf("*****************************************************************************\n");
    	printf("Author: YUXUN QIU\n");
    	printf("TESTBENCH for RISCV LOW PERFORMANCE CORE\n");
    	printf("*****************************************************************************\n");
    	printf("The C program is \n");
    
    	printf("long int test_loop(long int a , long int b){ \n");
    	printf("long int i  = 	0;\n");
    	printf("long int result	=	0;\n");
    	printf("a++;\n");
    	printf("b++;\n");
    	printf("for (i=0; i<16;i++){\n");
    	printf("result += a;\n");
    	printf("result += b;\n");
    	printf("a = a<<1;\n");
    	printf("b = b<<1;\n");
    	printf("}\n");
    	printf("a= (a>>6);\n");
    	printf("b= (b>>7);\n");
    	printf("for (i=0;i<8;i++){\n");
    	printf("result -= a;\n");
    	printf("result -= b;\n");
    	printf("a = a>>1;\n");
	printf("b = b>>1;\n");
	printf("}\n");
	printf("return result;\n");
	printf("}\n");
 	printf("The answer should be 12810");
    
	for(half_cycyle_count=0;half_cycyle_count<(NUM_CYCLE*2);half_cycyle_count++){

		top->reset = (half_cycyle_count<(NUM_RESET_CYCLE*2)?1:0);
		top->clk = top->clk^1;
		top->eval();
		if((top->reset == 0)&(top->clk == 1)){
			if(half_cycyle_count>((NUM_RESET_CYCLE+1)*2)){
                
				if(stop_flag >0){
					stop_flag ++;
				}
				if(stop_flag == 8){
					break;
				}

			/*Do something to check the result here!*/

				if(top->icache_req_addr_valid){

					for(i=0;i<8;i++){

					top->icache_ack_data[i]	=	rom [(top->icache_req_addr)>>5][i];

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

				else{

					for(i=0;i<8;i++){

						top->icache_ack_data[i]	=	rom [(top->icache_req_addr)>>5][i];

					}

					top->icache_ack_data_valid	=	0;

				}
				if((top->debug_dest_valid == 1)&(top->debug_dest == 128010)&(top->debug_dest_rd == 10)&(top->debug_dest_long == 1)){/*nearly finished*/
					printf("\n Program executed succesully the expected output value is %ld\n",top->debug_dest);
				}
				
				if((top->debug_dest==0x0000000000000050)&(top->debug_dest_long==1)&(top->debug_dest_valid ==1)&(top->debug_pc_ex == 0x0000000000000000)){
					printf("\n finished!! at %ld us\n",half_cycyle_count/2*10);
					stop_flag++;
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




