

/* some User specified files */

#include "Vcore_alu.h"

#include "verilated.h"

#include "verilated_vcd_c.h"

#include "stdlib.h"

#include "time.h"

#include "stdint.h"

vluint64_t global_time = 0;

VerilatedVcdC* tfp = 0;

#define Test_instr_Num 41

#define LUI  	 0x000000B7	/*LUI 	R1 	  #0*/
#define ADDI  	 0x00008113	/*ADDI 	R2 R1 #0*/
#define SLTI  	 0x0000A113	/*SLTI 	R2 R1 #0*/
#define SLTIU  	 0x0000B113	/*SLTIU R2 R1 #0*/
#define XORI  	 0x0000C113	/*XORI 	R2 R1 #0*/
#define ORI   	 0x0000E113	/*ORI   R2 R1 #0*/
#define ANDI	 0x0000F113	/*ANDI 	R2 R1 #0*/

#define SLLI     0x00309113	/*SLLI R2 R1 #3 */
#define SRLI     0x0030D113	/*SRLI R2 R1 #3 */
#define SRAI     0x4030D113	/*SRAI R2 R1 #3 */

#define ADD 	 0x00208133	/*ADD  R2 R1 R2 */
#define SUB 	 0x40208133	/*SUB  R2 R1 R2 */
#define SLL 	 0x00209133	/*SLL  R2 R1 R2 */
#define SLT 	 0x0020A133	/*SLT  R2 R1 R2 */
#define SLTU 	 0x0020B133	/*SLTU R2 R1 R2 */
#define XOR 	 0x0020C133	/*XOR  R2 R1 R2 */
#define SRL 	 0x0020D133	/*SRL  R2 R1 R2 */
#define SRA 	 0x4020D133	/*SRA  R2 R1 R2 */
#define OR 		 0x0020E133	/*OR   R2 R1 R2 */
#define AND 	 0x0020F133	/*AND  R2 R1 R2 */

#define SLLI_64  0x02109113	/*SLLI R2 R1 #33*/
#define SRLI_64  0x0210D113	/*SRLI R2 R1 #33*/
#define SRAI_64  0x4210D113	/*SRAI R2 R1 #33*/

#define ADDIW 	 0x70F0811B	/*ADDIW R2 R1 #1807*/
#define SLLIW 	 0x0030911B	/*SLLIW R2 R1 #3*/
#define SRLIW 	 0x0030D11B	/*SRLIW R2 R1 #3*/
#define SRAIW 	 0x4030D11B	/*SRAIW R2 R1 #3*/

#define ADDW 	 0x0020813B	/*ADDW R2 R1 R2*/
#define SUBW	 0x4020813B	/*SUBW R2 R1 R2*/
#define SLLW	 0x0020913B /*SLLW R2 R1 R2*/
#define SRLW	 0x0020D13B	/*SRLW R2 R1 R2*/
#define SRAW	 0x4020D13B	/*SRAW R2 R1 R2*/

#define AUIPC	 0x00000097	/*AUIPC R1 #0	*/
#define JAL		 0x000000EF	/*JAL   R1 0X0	*/
#define JALR	 0x00008167	/*JALR  R2 R1 0X0*/ 


#define BEQ		 0x00208263 /*BEQ R1 R2 #4*/
#define BNE		 0x00209263	/*BNE R1 R2 #4*/
#define BLT		 0x0020C263	/*BLT R1 R2 #4*/
#define BGE		 0x0020D263 /*BGE R1 R2 #4*/
#define BLTU	 0x0020E263 /*BLTU R1 R2 #4*/
#define BGEU	 0x0020F263 /*BGEU R1 R2 #4*/



const unsigned int rom [41]	= {	LUI,ADDI,SLTI,SLTIU,XORI,ORI,ANDI,SLLI,SRLI,SRAI,    									
								ADD,SUB,SLL,SLT,SLTU,XOR,SRL,SRA,OR,AND,SLLI_64, 									
								SRLI_64,SRAI_64,ADDIW,SLLIW,SRLIW,SRAIW,ADDW, 										
								SUBW,SLLW,SRLW,SRAW,AUIPC,JAL,JALR,BEQ,BNE,BLT,											
								BGE,BLTU,BGEU};

const char* instr_type[41]	= 	{	"/*LUI	R1 #0*/"	,"/*ADDI R2 R1 #0*/","/*SLTI R2 R1 #0*/","/*SLTIU R2 R1 #0*/",
									"/*XORI R2 R1 #0*/"	,"/*ORI   R2 R1 #0*/","/*ANDI 	R2 R1 #0*/","/*SLLI R2 R1 #3 */",
									"/*SRLI R2 R1 #3 */","/*SRAI R2 R1 #3 */","/*ADD  R2 R1 R2 */","/*SUB  R2 R1 R2 */",
									"/*SLL  R2 R1 R2 */","/*SLT  R2 R1 R2 */","/*SLTU R2 R1 R2 */","/*XOR  R2 R1 R2 */",
									"/*SRL  R2 R1 R2 */","/*SRA  R2 R1 R2 */","/*OR   R2 R1 R2 */","/*AND  R2 R1 R2 */",
									"/*SLLI R2 R1 #33*/","/*SRLI R2 R1 #33*/","/*SRAI R2 R1 #33*/","/*ADDIW R2 R1 #1807*/",
									"/*SLLIW R2 R1 #3*/","/*SRLIW R2 R1 #3*/","/*SRAIW R2 R1 #3*/","/*ADDW R2 R1 R2*/", "/*SUBW R2 R1 R2*/",
									"/*SLLW R2 R1 R2*/"	,"/*SRLW R2 R1 R2*/","/*SRAW R2 R1 R2*/","/*AUIPC R1 #0	*/","/*JAL   R1 0X0	*/",
									"/*JALR  R2 R1 0X0*/","/*BEQ R1 R2 #4*/","/*BNE R1 R2 #4*/","/*BLT R1 R2 #4*/","/*BGE R1 R2 #4*/",
									"/*BLTU R1 R2 #4*/","/*BGEU R1 R2 #4*/"
								};




uint32_t instr_gen(uint32_t number);

/*Number of simulation cyles*/

#define NUM_CYCLE ((vluint64_t)2048)

/*Half_Period (in ps) of a clock 100.000MHZ clock*/

#define HALF_PER_PS ((vluint64_t)5000)


/*Number of Reset Cycles*/

#define NUM_RESET_CYCLE ((vluint64_t)10)





int main(int argc, char **argv, char **env) {



	/*User Variables begins here*/

	

	vluint64_t half_cycyle_count;
	uint32_t num;
	uint32_t total_test_num;
	uint32_t fail_time;
	int64_t dest_expected_value;
	uint8_t dest_enable_expected_value;
	uint8_t dest_long_expected_value;
	
	int64_t branch_target_expected_value;
	uint8_t branch_target_enable_expected_value;


	/*User Variables ends here*/

	
	Verilated::commandArgs(argc, argv);

	
	/* init top verilog instance HERE!!!*/

	
	Vcore_alu* top = new Vcore_alu;


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
	top->reset = 1;
	
	top->clk   = 0;

	top->PC	   = 0x00000000;
	
	top->insn  = 0x00000000;
	
	top->src1  = 0x000000000341CF10;

	top->src2  = 0x00000000E0B0C0A0;
	
	fail_time  = 0;
	total_test_num = 0;
	srand(time(NULL));

	for(half_cycyle_count=0;half_cycyle_count<(NUM_CYCLE*2);half_cycyle_count++){
		
		top->reset = (half_cycyle_count<(NUM_RESET_CYCLE*2)?1:0);

		top->clk = top->clk^1;
		top->eval();
		if((top->reset == 0)&(top->clk == 1)){
			

			if(half_cycyle_count>((NUM_RESET_CYCLE+1)*2)){
				/*Do something to check the result here!*/
				printf("\n\n\n\nTesting %s instruction in Rom\n",instr_type[num]);
				if(	(dest_expected_value != top->dest)|(dest_enable_expected_value != top->dest_enable)|
					(dest_long_expected_value != top->dest_long)|(branch_target_expected_value != top->branch_target)|
					(branch_target_enable_expected_value != top->branch_target_enable)){
					fail_time++;
				}

				if(dest_expected_value != top->dest)
					printf("instruction %d :ERROR dest Value EXPECTED:%ld  ACTURAL: %ld \n",num+1,dest_expected_value,top->dest);
				else
					printf("instruction %d :PASSED dest Value EXPECTED:%ld  ACTURAL: %ld \n",num+1,dest_expected_value,top->dest);


				if(dest_enable_expected_value != top->dest_enable)
					printf("instruction %d :ERROR dest_enable EXPECTED:%u  ACTURAL: %u \n",num+1,dest_enable_expected_value,top->dest_enable);
				else
					printf("instruction %d :PASSED dest_enable EXPECTED:%u  ACTURAL: %u \n",num+1,dest_enable_expected_value,top->dest_enable);


				if(dest_long_expected_value != top->dest_long)
					printf("instruction %d :ERROR dest_long EXPECTED:%u  ACTURAL: %u \n",num+1,dest_long_expected_value,top->dest_long);
				else
					printf("instruction %d :PASSED dest_long EXPECTED:%u  ACTURAL: %u \n",num+1,dest_long_expected_value,top->dest_long);


				if(branch_target_expected_value != top->branch_target)
					printf("instruction %d :ERROR branch_target EXPECTED:%lx  ACTURAL: %lx \n",num+1,branch_target_expected_value,top->branch_target);
				else
					printf("instruction %d :PASSED branch_target EXPECTED:%lx  ACTURAL: %lx \n",num+1,branch_target_expected_value,top->branch_target);


				if(branch_target_enable_expected_value != top->branch_target_enable)
					printf("instruction %d :ERROR branch_target_enable EXPECTED:%u  ACTURAL: %u \n",num+1,branch_target_enable_expected_value,top->branch_target_enable);
				else
					printf("instruction %d :PASSED branch_target_enable EXPECTED:%u  ACTURAL: %u \n",num+1,branch_target_enable_expected_value,top->branch_target_enable);	
			}
			
			num = rand()%(Test_instr_Num-1);/*generate random number from 0 -40*/
			
			top->PC   = top->PC +4;

			top->insn = instr_gen(num);
			total_test_num++;

			top->src1 = rand()%0x0000000FFFFFFFFF;

			top->src2 = rand()%0x0000000FFFFFFFFF;
			
			switch(num+1){
				
				case 1:	{
					dest_expected_value = 0;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;
					break;
				}
				case 2:	{
					dest_expected_value = top->src1+0;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;
					break;					
				}
				case 3:{
					dest_expected_value = (top->src1<0);
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}
				case 4:{
					dest_expected_value = (((uint64_t)top->src1)<0);
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;
					break;
				}			
				case 5:{
					dest_expected_value = (top->src1)^(0x0000000000000000);
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}
				case 6:{
					dest_expected_value = (top->src1)|(0x0000000000000000);
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;							
					break;
				}				
				case 7:{
					dest_expected_value = (top->src1)&(0x0000000000000000);
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;
					break;
				}
				case 8:{
					dest_expected_value = (top->src1)<<3;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}				
				case 9:{
					dest_expected_value = ((uint64_t)top->src1)>>3;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}
				case 10:{
					dest_expected_value = top->src1>>3;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;
					break;
				}
				case 11:{
					dest_expected_value = top->src1+top->src2;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}
				case 12:{
					dest_expected_value = top->src1-top->src2;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}			
				case 13:{
					dest_expected_value = (top->src1)<<(top->src2&0x000000000000001f);
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}
				case 14:{
					dest_expected_value = top->src1<top->src2;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;		
					break;
				}				
				case 15:{
					dest_expected_value = (((uint64_t)top->src1)<((uint64_t)top->src2));
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}
				case 16:{
					dest_expected_value = top->src1^top->src2;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}						
				case 17:{
					dest_expected_value = ((uint64_t)top->src1)>>(top->src2&0x000000000000001f);
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}
				case 18:{
					dest_expected_value = (top->src1)>>(top->src2&0x000000000000001f);
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}
				case 19:{
					dest_expected_value = top->src1|top->src2;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;
					break;
				}
				case 20:{
					dest_expected_value = top->src1&top->src2;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}				
				case 21:{
					dest_expected_value = top->src1<<33;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}
				case 22:{
					dest_expected_value = ((uint64_t)top->src1)>>33;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}				
				case 23:{
					dest_expected_value = top->src1>>33;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}
				case 24:{
					dest_expected_value = (top->src1 + 1807);
					dest_enable_expected_value = 1;
					dest_long_expected_value =0;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;
				}						
				case 25:{
					dest_expected_value = top->src1<<3;
					dest_enable_expected_value = 1;
					dest_long_expected_value =0;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;					
				}
				case 26:{
					dest_expected_value = ((uint64_t)top->src1)>>3;
					dest_enable_expected_value = 1;
					dest_long_expected_value =0;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;						
				}
				case 27:{
					dest_expected_value = (top->src1)>>3;
					dest_enable_expected_value = 1;
					dest_long_expected_value =0;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;						
				}
				case 28:{
					dest_expected_value = (top->src1)+(top->src2);
					dest_enable_expected_value = 1;
					dest_long_expected_value =0;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;			
				}			
				case 29:{
					dest_expected_value = (top->src1)-(top->src2);
					dest_enable_expected_value = 1;
					dest_long_expected_value =0;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;						
				}
				case 30:{
					dest_expected_value = (top->src1)<<(top->src2&0x000000000000001f);
					dest_enable_expected_value = 1;
					dest_long_expected_value =0;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;						
				}				
				case 31:{
					dest_expected_value = ((uint64_t)top->src1)>>(top->src2&0x000000000000001f);
					dest_enable_expected_value = 1;
					dest_long_expected_value =0;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;						
				}
				case 32:{
					dest_expected_value = (top->src1)>>(top->src2&0x000000000000001f);
					dest_enable_expected_value = 1;
					dest_long_expected_value =0;
					
					branch_target_expected_value =top->PC;
					branch_target_enable_expected_value =0;	
					break;						
				}
				case 33:{
					dest_expected_value = top->PC+0;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value = top->PC+0;
					branch_target_enable_expected_value =1;
					break;					
				}
				case 34:{
					dest_expected_value = top->PC+4;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value = top->PC+0;
					branch_target_enable_expected_value =1;
					break;					
				}
				case 35:{
					dest_expected_value = top->PC+4;
					dest_enable_expected_value = 1;
					dest_long_expected_value =1;
					
					branch_target_expected_value = top->src1 + 0;
					branch_target_enable_expected_value =1;
					break;					
				}			
				case 36:{
					dest_expected_value = 0;
					dest_enable_expected_value = 0;
					dest_long_expected_value =0;
					
					branch_target_expected_value = (top->src1 == top->src2)?(top->PC + 4):(top->PC);
					branch_target_enable_expected_value =(top->src1 == top->src2)?1:0;
					break;					
				}			
				case 37:{
					dest_expected_value = 0;
					dest_enable_expected_value = 0;
					dest_long_expected_value =0;
					
					branch_target_expected_value = (top->src1 != top->src2)?(top->PC + 4):(top->PC);
					branch_target_enable_expected_value =(top->src1 != top->src2)?1:0;
					break;					
				}
				case 38:{
					dest_expected_value = 0;
					dest_enable_expected_value = 0;
					dest_long_expected_value =0;
					
					branch_target_expected_value = (top->src1 < top->src2)?(top->PC + 4):(top->PC);
					branch_target_enable_expected_value =(top->src1 < top->src2)?1:0;
					break;					
				}				
				case 39:{
					dest_expected_value = 0;
					dest_enable_expected_value = 0;
					dest_long_expected_value =0;
					
					branch_target_expected_value = (top->src1 >= top->src2)?(top->PC + 4):(top->PC);
					branch_target_enable_expected_value =(top->src1 >= top->src2)?1:0;
					break;					
				}
				case 40:{
					dest_expected_value = 0;
					dest_enable_expected_value = 0;
					dest_long_expected_value =0;
					
					branch_target_expected_value = (((uint64_t)top->src1) < ((uint64_t)top->src2))?(top->PC + 4):(top->PC);
					branch_target_enable_expected_value =(((uint64_t)top->src1) < ((uint64_t)top->src2))?1:0;
					break;					
				}					
				case 41:{
					dest_expected_value = 0;
					dest_enable_expected_value = 0;
					dest_long_expected_value =0;
					
					branch_target_expected_value = (((uint64_t)top->src1) >= ((uint64_t)top->src2))?(top->PC + 4):(top->PC);
					branch_target_enable_expected_value =(((uint64_t)top->src1) >= ((uint64_t)top->src2))?1:0;
					break;					
				}

				default: break;	
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
	if(fail_time == 0){
		printf("\n\n\n\nTESTED TOTAL %u number of instruction\n",total_test_num);
		printf("TEST PASSED ALL instruction Valid!!!! \n");
		printf("Congratulation!!!");
		printf("Author : Yuxun Qiu\n");
	}

	top->final();
	
#ifdef TRACE

	tfp->close();

#endif
	exit(0);

}



uint32_t instr_gen(uint32_t number){
	/*Generate R-type I-type U-type UJ-TYPE SB-TYPE*/
	uint32_t	instr;		
	instr = rom[number];
	return instr;
}
