//
// The goal of this task is to implement a RISC V ALU
//
// The RISC V ISA is explained in http://riscv.org/spec/riscv-spec-v2.0.pdf 
//
// For lab2, you should implement all the arirthmetic and control flow
// instructions from RV32I and RV64I (NOT LD/ST. not fences, not syscalls, or RD*)
// The list is in page 50-51.
//
// You should have a core_alu_tb.cpp that runs in verilator (start with class
// sample3). The testbench should test all the instructions.
//
// The ALU should take 1 cycle to perform the operation. This means that it
// has just flops that are already instantiated, no more.
//
// All the code should be synthesizable, you can use Verilog 2001. This means
// that no implicit lathes, no directives non-synthesizable like # or
// initial...
//
// The TA will evaluate the correctness running his own core_alu_tb.cpp
// testbench that will test several instructions. The grade will depend 
// on the compilation, being synthesizable, and the % of test passing.
//
//
module core_alu(

input clk,
input reset, 						/* reset is active high (1 == reset, 0 == no reset)*/

/*I add 64 BITS pc ADDRESS BUS*/

input [63:0] PC,					/* Current PC value*/

input [31:0] insn, 					/* raw 32bit encoding of the RISC V instruction to execute*/

input [63:0] src1, 					/* data in src1. E.g: add R1,R2,R3 -> R1 = R2+R3. src1 has the contents of R2*/
input [63:0] src2, 					/* data in src2*/

output reg dest_enable, 			/* True, if a value must be written to the destination register file*/
output reg dest_long, 				/* true, the destination is 64bits, otherwise 32bits*/
output reg [63:0] dest, 			/* value of the operation result (some may not have result like branches or nops)*/

output reg branch_target_enable, 	/* True, when the following instruction is something different from PC+4*/
output reg [63:0] branch_target 	/* target address when branch_target_enable is true*/

);
/* verilator lint_off UNUSED */

wire dest_enable_next;
wire dest_long_next;
wire [63:0] dest_next;
reg	 [63:0] dest_next_temp;


wire branch_target_enable_next;
wire [63:0] branch_target_next;

reg	 [63:0]	branch_target_next_temp;
reg	branch_target_enable_next_temp;


// INSERT YOUR LAB CODE HERE!!
`define FUNCT7_IS_32BASE0	7'b0000_000
`define FUNCT7_IS_32BASE1	7'b0100_000
`define FUNCT7_IS_64BASE0	7'b0000_001
`define FUNCT7_IS_64BASE1	7'b0100_001

`define OP_IMM				7'b0010_011
`define OP_IMM_32			7'b0011_011
`define OP_32				7'b0111_011
`define OP					7'b0110_011
`define LUI					7'b0110_111
`define AUIPC				7'b0010_111
`define JAL					7'b1101_111
`define JALR				7'b1100_111

`define BRANCH				7'b1100_011



`define OP_IS_ADD_SUB		3'b000
`define OP_IS_SLL			3'b001
`define OP_IS_SLT			3'b010
`define OP_IS_SLTU			3'b011

`define OP_IS_XOR			3'b100
`define OP_IS_SR			3'b101
`define OP_IS_OR			3'b110
`define OP_IS_AND			3'b111

`define BRANCH_IS_BEQ		3'b000
`define BRANCH_IS_BNE		3'b001
`define BRANCH_IS_BLT		3'b100
`define BRANCH_IS_BGE		3'b101
`define BRANCH_IS_BLTU		3'b110
`define BRANCH_IS_BGEU		3'b111


wire [31:0] 	instr;
wire [6:0] 		funct7;
wire [4:0]		rs_2;
wire [4:0] 		rs_1;
wire [2:0] 		funct3;
wire [4:0]		rd;
wire [6:0] 		op_code;
wire [11:0]		Imm12;
wire [4:0]		shamt;
wire [19:0]		U_imm;
wire [19:0]		UJ_imm;
wire [11:0]		SB_imm;


/*rv32I begin*/

/*Some of the Basic ALU Operation*/
wire instr_is_LUI;
wire instr_is_ADDI;
wire instr_is_SLTI;
wire instr_is_SLTIU;
wire instr_is_XORI;
wire instr_is_ORI;
wire instr_is_ANDI;
wire instr_is_SLLI;
wire instr_is_SRLI;
wire instr_is_SRAI;
wire instr_is_ADD;
wire instr_is_SUB;
wire instr_is_SLL;
wire instr_is_SLT;
wire instr_is_SLTU;
wire instr_is_XOR;
wire instr_is_SRL;
wire instr_is_SRA;
wire instr_is_OR;
wire instr_is_AND;

/*64bit*/
wire instr_is_SLLI_64;
wire instr_is_SRLI_64;
wire instr_is_SRAI_64;

wire instr_is_ADDIW;
wire instr_is_SLLIW;
wire instr_is_SRLIW;
wire instr_is_SRAIW;
wire instr_is_ADDW;
wire instr_is_SUBW;
wire instr_is_SLLW;
wire instr_is_SRLW;
wire instr_is_SRAW;

wire instr_is_AUIPC;


wire instr_is_JAL;
wire instr_is_JALR;
wire instr_is_BEQ;
wire instr_is_BNE;
wire instr_is_BLT;
wire instr_is_BGE;
wire instr_is_BLTU;
wire instr_is_BGEU;


/*EXECTION WIRE*/
wire instr_is_reg_imm;	/*指令是否是imm籿*/



/*ADD SUB WIRE*/
wire [63:0] 	sign_ex_imm;	/*imm value exten sign*/
wire [63:0]		imm_src2_sel;	/*是用imm12 还是src2*/
wire [63:0]		add_result;		/*加法结果*/
wire [63:0]		sub_result;		/*减法结果*/
reg	 [63:0]		add_sub_result;
/*END*/
/*smaller than  WIRE*/
wire 			instr_is_unsigned;
wire [63:0]		comp_1;			/*比较敿1*/
wire [63:0]		imm_temp;		/*temp*/
wire [63:0]		comp_2;			/*比较敿2*/

/*END*/

/*basic logic wire*/
wire [63:0]		XOR_RESULT;
wire [63:0]		OR_RESULT;
wire [63:0]		AND_RESULT;

/*end*/

/*shift*/

wire [ 5:0]		shift_amount;

/*end*/



/**/
reg				LT_FLAG;
reg				BGE_FLAG;
reg	 [63:0]		PC_Relative_value;
wire [63:0]		Branch_temp;
/**/

assign  instr   =  insn;
assign 	funct7  =  instr[31:25];
assign	rs_2	=  instr[24:20];
assign 	rs_1	=  instr[19:15];
assign 	funct3  =  instr[14:12];
assign 	rd		=  instr[11: 7];
assign 	op_code =  instr[ 6: 0];
assign	Imm12	=  instr[31:20];
assign  shamt	=  instr[24:20];
assign	U_imm	=  instr[31:12];
assign	UJ_imm	= {instr[31],instr[19:12],instr[20],instr[30:21]};
assign	SB_imm	= {instr[31],instr[7],instr[30:25],instr[11:8]};


assign instr_is_reg_imm = (op_code == `OP_IMM)|(op_code == `OP_IMM_32);

/*32 bits add*/
assign instr_is_ADDI =  (funct3 == `OP_IS_ADD_SUB)&(op_code == `OP_IMM);
assign instr_is_ADD  =  (funct3 == `OP_IS_ADD_SUB)&(op_code == `OP)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_SUB  =  (funct3 == `OP_IS_ADD_SUB)&(op_code == `OP)&(funct7 == `FUNCT7_IS_32BASE1); 
/*64 bits ADDi*/
assign instr_is_ADDIW = (funct3 == `OP_IS_ADD_SUB)&(op_code == `OP_IMM_32);
assign instr_is_ADDW  = (funct3 == `OP_IS_ADD_SUB)&(op_code == `OP_32)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_SUBW  = (funct3 == `OP_IS_ADD_SUB)&(op_code == `OP_32)&(funct7 == `FUNCT7_IS_32BASE1);

/*smaller than*/
assign instr_is_SLTI  = (funct3 == `OP_IS_SLT)&(op_code == `OP_IMM);
assign instr_is_SLTIU = (funct3 == `OP_IS_SLTU)&(op_code == `OP_IMM);
assign instr_is_SLT   = (funct3 == `OP_IS_SLT)&(op_code == `OP)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_SLTU  = (funct3 == `OP_IS_SLTU)&(op_code == `OP)&(funct7 == `FUNCT7_IS_32BASE0);


/*basic Logic Arithmetic*/
assign instr_is_XORI = 	(funct3 == `OP_IS_XOR)&(op_code == `OP_IMM);
assign instr_is_ORI  =  (funct3 == `OP_IS_OR)&(op_code == `OP_IMM);
assign instr_is_ANDI = 	(funct3 == `OP_IS_AND)&(op_code == `OP_IMM);
assign instr_is_XOR  =  (funct3 == `OP_IS_XOR)&(op_code == `OP)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_OR	 =  (funct3 == `OP_IS_OR)&(op_code == `OP)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_AND  =  (funct3 == `OP_IS_AND)&(op_code == `OP)&(funct7 == `FUNCT7_IS_32BASE0);

/*32 BITS SHIFT*/
assign instr_is_SLLI =  (funct3 == `OP_IS_SLL)&(op_code == `OP_IMM)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_SRLI =  (funct3 == `OP_IS_SR)&(op_code == `OP_IMM)&(funct7 == `FUNCT7_IS_32BASE0); 
assign instr_is_SRAI =  (funct3 == `OP_IS_SR)&(op_code == `OP_IMM)&(funct7 == `FUNCT7_IS_32BASE1);

assign instr_is_SLL  =	(funct3 == `OP_IS_SLL)&(op_code == `OP)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_SRL  =  (funct3 == `OP_IS_SR)&(op_code == `OP)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_SRA  =  (funct3 == `OP_IS_SR)&(op_code == `OP)&(funct7 == `FUNCT7_IS_32BASE1);


/*64 BITS SHIFT*/
assign instr_is_SLLI_64 = (funct3 == `OP_IS_SLL)&(op_code == `OP_IMM)&(funct7 ==`FUNCT7_IS_64BASE0);
assign instr_is_SRLI_64 = (funct3 == `OP_IS_SR)&(op_code == `OP_IMM)&(funct7 == `FUNCT7_IS_64BASE0);
assign instr_is_SRAI_64 = (funct3 == `OP_IS_SR)&(op_code == `OP_IMM)&(funct7 == `FUNCT7_IS_64BASE1);

assign instr_is_SLLIW = (funct3 == `OP_IS_SLL)&(op_code == `OP_IMM_32)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_SRLIW = (funct3 == `OP_IS_SR)&(op_code == `OP_IMM_32)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_SRAIW =	(funct3 == `OP_IS_SR)&(op_code == `OP_IMM_32)&(funct7 == `FUNCT7_IS_32BASE1);

assign instr_is_SLLW  =	(funct3 == `OP_IS_SLL)&(op_code == `OP_32)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_SRLW  =	(funct3 == `OP_IS_SR)&(op_code == `OP_32)&(funct7 == `FUNCT7_IS_32BASE0);
assign instr_is_SRAW  =	(funct3 == `OP_IS_SR)&(op_code == `OP_32)&(funct7 == `FUNCT7_IS_32BASE1);

/*Pure load imm to reg*/
assign instr_is_LUI =  (op_code == `LUI);


/*branch target value*/
assign instr_is_AUIPC = (op_code == `AUIPC);
assign instr_is_JAL = (op_code == `JAL);
assign instr_is_JALR = (funct3 == 3'b000)&(op_code == `JALR);
assign instr_is_BEQ =  (funct3 == `BRANCH_IS_BEQ)&(op_code == `BRANCH);
assign instr_is_BNE =  (funct3 == `BRANCH_IS_BNE)&(op_code == `BRANCH);
assign instr_is_BLT =  (funct3 == `BRANCH_IS_BLT)&(op_code == `BRANCH);
assign instr_is_BGE =  (funct3 == `BRANCH_IS_BGE)&(op_code == `BRANCH);
assign instr_is_BLTU = (funct3 == `BRANCH_IS_BLTU)&(op_code == `BRANCH);
assign instr_is_BGEU = (funct3 == `BRANCH_IS_BGEU)&(op_code == `BRANCH);







assign sign_ex_imm  = {{52{Imm12[11]}},Imm12};
assign imm_src2_sel	= instr_is_reg_imm?(sign_ex_imm):src2;
assign add_result 	= src1+imm_src2_sel;
assign sub_result 	= src1-imm_src2_sel;


assign	XOR_RESULT	=	src1^imm_src2_sel;
assign	OR_RESULT	=	src1|imm_src2_sel;
assign	AND_RESULT	=	src1&imm_src2_sel;
assign  shift_amount	= 	instr_is_reg_imm?	{instr[25],shamt}:{1'b0,(src2[4:0])};


assign	comp_1			= src1;
assign	instr_is_unsigned	= (instr_is_BLTU|instr_is_BGEU|instr_is_SLTIU|instr_is_SLTU);
assign  imm_temp		= (instr_is_unsigned)?	({52'b0,Imm12})	:	({{52{Imm12[11]}},Imm12});
assign	comp_2			= instr_is_reg_imm? imm_temp:src2;




assign	Branch_temp		= 	PC	+{{51{SB_imm[11]}},SB_imm,1'b0};

assign 	dest_enable_next	=	((op_code == `OP_IMM)|(op_code == `OP_IMM_32)|(op_code == `OP_32)|(op_code == `OP)|(op_code == `LUI)|(op_code == `AUIPC)|(op_code == `JAL)|(op_code == `JALR));					/*基本上都enable，后面改＿*/
assign 	dest_long_next 		=	((op_code == `OP_IMM)|(op_code == `OP)|(op_code == `LUI)|(op_code == `AUIPC)|(op_code == `JAL)|(op_code == `JALR));/*Those are instruction that need 64 bits output*/
assign 	dest_next		=	dest_next_temp;


assign 	branch_target_next	=	branch_target_next_temp;
assign 	branch_target_enable_next 	= 	branch_target_enable_next_temp;



always@(*)begin

	if(instr_is_SUB|instr_is_SUBW)
		add_sub_result	=	sub_result;
	else
		add_sub_result	=	add_result;
end





always@(*)begin

	case({comp_1[63],comp_2[63]})
		2'b01:
				begin
					if(instr_is_unsigned)
						begin
							LT_FLAG		= 	1'b1;
							BGE_FLAG	= 	1'b0;
						end
					else
						begin
							LT_FLAG		= 	1'b0;
							BGE_FLAG	= 	1'b1;												
						end
				end
		2'b10:
				begin
					if(instr_is_unsigned)
						begin
							LT_FLAG		= 	1'b0;
							BGE_FLAG	= 	1'b1;	
						end
					else
						begin
							LT_FLAG		= 	1'b0;
							BGE_FLAG	= 	1'b1;													
						end
				end
		default:
				begin
					if(comp_1<comp_2)
						begin
							LT_FLAG		=	1'b1;
							BGE_FLAG	=	1'b0;						
						end
					else
						begin
							LT_FLAG		=	1'b0;
							BGE_FLAG	=	1'b1;												
						end
				end
	endcase

end




always@(*)begin
	case(op_code)
		`AUIPC:		PC_Relative_value	=	PC +{{32{U_imm[19]}},U_imm,12'b0};
		`JAL,`JALR:	PC_Relative_value	=	PC +4;
		default:	PC_Relative_value	=	PC;
	endcase
end



always@(*)begin


	case(op_code)
		`AUIPC:	
				begin
					branch_target_enable_next_temp = 1'b1;
					branch_target_next_temp	=	PC	+	{{32{U_imm[19]}},U_imm,12'b0};
				end
		`JAL:	
				begin
					branch_target_enable_next_temp = 1'b1;
					branch_target_next_temp	=	PC  + {{43{UJ_imm[19]}},UJ_imm,1'b0};
				end
		`JALR:
				begin
					branch_target_enable_next_temp = 1'b1;
					branch_target_next_temp	=	src1	+	sign_ex_imm;
				end
		`BRANCH:
				begin
					case(funct3)
						`BRANCH_IS_BEQ:	begin
									if(src1 == src2)
										begin
											branch_target_enable_next_temp	=	1'b1;
											branch_target_next_temp	= Branch_temp;
										end
									else
										begin
											branch_target_enable_next_temp	=	1'b0;
											branch_target_next_temp	= PC;										
										end
								end
						`BRANCH_IS_BNE:
								begin
									if(src1 != src2)
										begin
											branch_target_enable_next_temp	=	1'b1;
											branch_target_next_temp	= Branch_temp;
										end
									else
										begin
											branch_target_enable_next_temp	=	1'b0;
											branch_target_next_temp	= PC;										
										end
								end
								
								
						`BRANCH_IS_BLT,`BRANCH_IS_BLTU:		
								begin
									if(LT_FLAG)
										begin
											branch_target_enable_next_temp	=	1'b1;
											branch_target_next_temp	= Branch_temp;						
										end
									else
										begin
											branch_target_enable_next_temp	=	1'b0;
											branch_target_next_temp	= PC;
										end
								end
						`BRANCH_IS_BGE,`BRANCH_IS_BGEU:
								begin
									if(BGE_FLAG)
										begin
											branch_target_enable_next_temp	=	1'b1;
											branch_target_next_temp	= Branch_temp;												
										end
									else
										begin
											branch_target_enable_next_temp	=	1'b0;
											branch_target_next_temp	= PC;										
										end
								end
						default:	
								begin
									branch_target_enable_next_temp	=	1'b0;
									branch_target_next_temp 	=	PC;
								end
					endcase
				end
		default: 
				begin
					branch_target_enable_next_temp = 1'b0;
					branch_target_next_temp	=	PC;
				end
	endcase


end



always@(*)begin

	case(op_code)
		`LUI							 	:	dest_next_temp	= {{32{U_imm[19]}},U_imm,12'b0};
		`AUIPC,`JAL,`JALR				 	:	dest_next_temp	= PC_Relative_value;
		`OP_IMM	,`OP_IMM_32	,`OP_32	,`OP 	:
											begin
												case(funct3)
														`OP_IS_ADD_SUB 	: 	dest_next_temp 	= 	add_sub_result;
														`OP_IS_SLL	   	: 	dest_next_temp 	= 	src1<<shift_amount;
														`OP_IS_SLT	   	: 	dest_next_temp	=	{63'b0,LT_FLAG};
														`OP_IS_SLTU	   	:	dest_next_temp	=	{63'b0,LT_FLAG};
														`OP_IS_XOR	   	:	dest_next_temp	=	XOR_RESULT;
														`OP_IS_SR		:	dest_next_temp  = 	funct7[5]?((signed'(src1))>>>shift_amount):(src1>>shift_amount);
														`OP_IS_OR		:	dest_next_temp	=	OR_RESULT;
														`OP_IS_AND		:	dest_next_temp	=	AND_RESULT;
												endcase	
											end	
		default :	dest_next_temp = 64'b0;
	endcase

end




flop #(.Bits(64+1)) f1(
.clk(clk),
.reset(reset),
.d({branch_target_next,branch_target_enable_next}),
.q({branch_target ,branch_target_enable })
);

flop #(.Bits(64+1+1)) f2(
.clk(clk),
.reset(reset),
.d({dest_next,dest_long_next,dest_enable_next}),
.q({dest ,dest_long ,dest_enable })
);

endmodule
