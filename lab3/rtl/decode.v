/****************************************************************************
 * decode.v
 ****************************************************************************/

/**
 * Module: decode
 * 
 * TODO: Add module documentation
 */
module decode(
		
	input	clk,
	input	reset,
	

	input	[63:0]		fetch_ack_pc,
	input	[31:0]		fetch_ack_instr,
	input				fetch_ack_data_valid,
	output				decode_ack_data_stop,

	output	[4:0]		decode_rs1_sel,
	output	[4:0]		decode_rs2_sel,

	
	output	[4:0]		decode_dest_sel,	
	output				imm_rs2_sel,
	output				comp_is_unsigned,
	output	[63:0]		sign_ex_imm,
	output	[5:0]		shift_amount,
	
	output	[19:0]		U_imm,
	output	[19:0]		UJ_imm,
	output	[11:0]		SB_imm,
	
	output	[6:0]		op_code,
	output	[2:0]		funct3,
	output	[6:0]		funct7,
	output	[63:0]		pc_latch,
	
	output				decode_ack_data_valid,
	input				execute_ack_data_stop
			
		
);

`define OP_IMM				7'b0010_011
`define OP_IMM_32			7'b0011_011
`define OP_32				7'b0111_011
`define OP				7'b0110_011
`define LUI				7'b0110_111
`define AUIPC				7'b0010_111
`define JAL				7'b1101_111
`define JALR				7'b1100_111

`define BRANCH				7'b1100_011



`define OP_IS_ADD_SUB			3'b000
`define OP_IS_SLL			3'b001
`define OP_IS_SLT			3'b010
`define OP_IS_SLTU			3'b011

`define OP_IS_XOR			3'b100
`define OP_IS_SR			3'b101
`define OP_IS_OR			3'b110
`define OP_IS_AND			3'b111

`define BRANCH_IS_BEQ			3'b000
`define BRANCH_IS_BNE			3'b001
`define BRANCH_IS_BLT			3'b100
`define BRANCH_IS_BGE			3'b101
`define BRANCH_IS_BLTU			3'b110
`define BRANCH_IS_BGEU			3'b111

	



wire[31:0]	instr;
wire[11:0]	Imm12;
wire[4:0]	shamt;
wire		instr_is_SLTIU;
wire		instr_is_SLTU;
wire		instr_is_BGEU;
wire		instr_is_BLTU;



wire[4:0]	decode_dest_sel_next;	//	
wire		imm_rs2_sel_next;		//
wire		instr_is_unsigned;		//
wire[63:0]	sign_ex_imm_next;		//
wire[5:0]	shift_amount_next;		//
wire[19:0]	U_imm_next;				//
wire[19:0]	UJ_imm_next;			//
wire[11:0]	SB_imm_next;			//
wire[6:0]	op_code_next;			//
wire[2:0]	funct3_next;			//
wire[6:0]	funct7_next;			//
wire[63:0]	pc_latch_next;			//

reg		decode_ack_data_valid_next;





assign	decode_ack_data_stop		=	execute_ack_data_stop|decode_ack_data_valid;
assign	instr				=	fetch_ack_instr;
assign	Imm12				=  	instr[31:20];
assign	shamt				=	instr[24:20];
assign	instr_is_SLTIU			= 	(funct3_next == `OP_IS_SLTU)&(op_code_next == `OP_IMM);
assign	instr_is_SLTU 			= 	(funct3_next == `OP_IS_SLTU)&(op_code_next == `OP)&(funct7_next == 7'b0000_000);
assign	instr_is_BGEU			= 	(funct3_next == `BRANCH_IS_BGEU)&(op_code_next == `BRANCH);
assign	instr_is_BLTU 			= 	(funct3_next == `BRANCH_IS_BLTU)&(op_code_next == `BRANCH);





assign	decode_rs1_sel			=	(instr[19:15]);
assign	decode_rs2_sel			=	(instr[24:20]);

assign	decode_dest_sel_next		=	(instr[11: 7]);
assign	imm_rs2_sel_next		=	((op_code_next == `OP_IMM)|(op_code_next == `OP_IMM_32));
assign	instr_is_unsigned		=	(instr_is_BLTU|instr_is_BGEU|instr_is_SLTIU|instr_is_SLTU);
assign	sign_ex_imm_next		=	((instr_is_unsigned)?({52'b0,Imm12}):({{52{Imm12[11]}},Imm12}));
assign	shift_amount_next		=	({instr[25],shamt});

assign	U_imm_next			=	(instr[31:12]);
assign	UJ_imm_next			=	({instr[31],instr[19:12],instr[20],instr[30:21]});
assign	SB_imm_next			=	({instr[31],instr[7],instr[30:25],instr[11:8]});
assign	op_code_next			=	(instr[ 6: 0]);
assign	funct3_next			=  	(instr[14:12]);
assign 	funct7_next 			=  	(instr[31:25]);
assign	pc_latch_next			=	(fetch_ack_pc);



always@(*)begin
	
	decode_ack_data_valid_next	=	fetch_ack_data_valid&(!decode_ack_data_stop);

end



flop #(.Bits(1)) f0(
	.clk(clk),
	.reset(reset),
	
	.d(decode_ack_data_valid_next),
	.q(decode_ack_data_valid)
);


flop #(.Bits(210)) f1(
	.clk(clk),
	.reset(reset),
	
	.d({decode_dest_sel_next,imm_rs2_sel_next,instr_is_unsigned,sign_ex_imm_next,shift_amount_next,U_imm_next,UJ_imm_next,SB_imm_next,op_code_next,funct3_next,funct7_next,pc_latch_next}),
	.q({decode_dest_sel,imm_rs2_sel,comp_is_unsigned,sign_ex_imm,shift_amount,U_imm,UJ_imm,SB_imm,op_code,funct3,funct7,pc_latch})
);	
	
	
	

endmodule

