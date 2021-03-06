## Testbench check
icache test : make run0 
core test: make run1 


## Hierarchy:
core.v:
|\
| \_icache.v_
|	\_sram_data
|	\_sram_tag
|	\_sram_tag_valid
|\
| \_fetch_
|	\_flop.v_
|	\_flop.v_
|
|\
| \_decode.v_
|	\_flop.v_
|	\_flop.v_
|\
| \_regfile.v_
|
|
|\
| \_execute.v_
|	\_flop.v



## icache function
icache module handles the instruction request from fetch module: 

1.  if cache hit:
The value that stores in the icache will be sent to fetch logic immediately(1 cycle);

2.  if cache miss:
The icache module will generate an "icache_req_next_pc_rety" signal to ask the fetch module to keep the previous PC,
then icache will generate an data request to the testbench to retrieve the data,
once "icache_ack_data_valid" is asseted, the "icache_ack_data" will be stored in the sram along with its tag and tag valid;


## Fetch,Decode,Execute module
## <“valid “and “stop”>
The fetch, decode, execute modules uses pair of “valid “and “stop” signals to work properly. 
Since there is only one instruction is being executed in the pipeline, 
it is important to prevent the instructions not being executed multiple times and the PC is incremented in the correct way.

## <fetch_ack_data_valid> <decode_ack_data_stop> <decode_ack_data_valid> <execute_ack_data_stop>

If stop signal is asserted, (indicating the next stage pipeline is not ready),
then the valid signal of previous stage will be de- asserted immediately, 
until stop signal is de-asserted;

## PC increment and branch 
The PC is automatically incremented by 4 once one “valid” instruction has been executed and
“execute_ack_pc_advance”is send to fetch logic to Increment the PC;
For  branch  instruction  and  PC-relative  instruction,  “branch_target”,  “branch_target_enable”,  is  asserted  to change the PC value;
 
 
 
## program to test
## the result should be 128010 for the first iteration  
 
long int test_loop(long int a , long int b){
	long int i  = 	0;
	long int result	=	0;

	a++;
	b++;

	for (i=0; i<16;i++){
		result += a;
		result += b;
		a = a<<1;
		b = b<<1;
	}
	a= (a>>6);
	b= (b>>7);
	for (i=0;i<8;i++){
		result -= a;
		result -= b;
		a = a>>1;
		b = b>>1;
	}

	return result;
}
 
0:	00150793	addi	a5,a0,1
4:	00158593	addi	a1,a1,1
8:	01000713	li	a4,16
c:	00000513	li	a0,0

//0000000000000010 <.L2>:
10:	00a78533	add	a0,a5,a0
14:	00b50533	add	a0,a0,a1
18:	00179793	slli	a5,a5,0x1
1c:	00159593	slli	a1,a1,0x1
20:	fff70713	addi	a4,a4,-1
24:	fe0716e3	bnez	a4,10 <.L2>
28:	4067d793	srai	a5,a5,0x6
2c:	4075d593	srai	a1,a1,0x7
30:	00800713	li	a4,8

//0000000000000034 <.L3>:
34:	40f50533	sub	a0,a0,a5
38:	40b50533	sub	a0,a0,a1
3c:	4017d793	srai	a5,a5,0x1
40:	4015d593	srai	a1,a1,0x1
44:	fff70713	addi	a4,a4,-1
48:	fe0716e3	bnez	a4,34 <.L3>
4c:	00008067	ret	

