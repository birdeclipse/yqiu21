/****************************************************************************
 * execute.v
 ****************************************************************************/

/**
 * Module: execute
 * 
 * TODO: Add module documentation
 */
module execute(
	
	input	clk,
	input	reset,

	
	input			decode_ack_data_valid,
	output			execute_ack_data_stop,
	
	
	input	[4:0]		decode_dest_sel,
	input			imm_rs2_sel,
	input			comp_is_unsigned,
	input	[63:0]		sign_ex_imm,
	input	[5:0]		shift_amount,	
	input	[19:0]		U_imm,
	input	[19:0]		UJ_imm,
	input	[11:0]		SB_imm,
	
	input	[6:0]		op_code,
	input	[2:0]		funct3,
	input	[6:0]		funct7,
	input	[63:0]		PC,
	
	input	[63:0]		src1,
	input	[63:0]		src2,
		
	output	[4:0]		wb_rd_sel,
	output			wb_dest_enable,
	output			wb_dest_long_enable,
	output	[63:0]		wb_dest,
	
	output	[63:0]		branch_target,	
	output			branch_target_enable,
	
	output			execute_ack_pc_advance

);


`define OP_IMM			7'b0010_011
`define OP_IMM_32		7'b0011_011
`define OP_32			7'b0111_011
`define OP			7'b0110_011
`define LUI			7'b0110_111
`define AUIPC			7'b0010_111
`define JAL			7'b1101_111
`define JALR			7'b1100_111
`define BRANCH			7'b1100_011

`define OP_IS_ADD_SUB		3'b000
`define OP_IS_SLL		3'b001
`define OP_IS_SLT		3'b010
`define OP_IS_SLTU		3'b011
`define OP_IS_XOR		3'b100
`define OP_IS_SR		3'b101
`define OP_IS_OR		3'b110
`define OP_IS_AND		3'b111

`define BRANCH_IS_BEQ		3'b000
`define BRANCH_IS_BNE		3'b001
`define BRANCH_IS_BLT		3'b100
`define BRANCH_IS_BGE		3'b101
`define BRANCH_IS_BLTU		3'b110
`define BRANCH_IS_BGEU		3'b111

wire			instr_is_SUB;
wire			instr_is_SUBW;
wire [63:0]		op_1;
wire [63:0]		op_2;
wire [ 5:0]		shamt;	
	

wire [63:0]		ADD_RESULT;
wire [63:0]		SUB_RESULT;
wire [63:0]		ADD_SUB_RESULT;
			
wire [63:0]		XOR_RESULT;
wire [63:0]		OR_RESULT;
wire [63:0]		AND_RESULT;

wire [63:0]		SLL_RESULT;
wire [63:0]		SRL_RESULT;
wire [63:0]		SRA_RESULT;
wire [63:0]		SR_RESULT;
wire [63:0]		BRANCH_TEMP;

reg	 [63:0]		dest_temp;
reg			LT_FLAG;
reg			BGE_FLAG;
reg	 [63:0]		PC_relative_value;
reg	 [63:0]		branch_target_temp;
reg			branch_target_enable_temp;
reg			execute_ack_data_stop_next;
	
	
assign 	instr_is_SUB  	=  (funct3 == `OP_IS_ADD_SUB)&(op_code == `OP)&(funct7 == 7'b0100_000);
assign 	instr_is_SUBW  	= (funct3 == `OP_IS_ADD_SUB)&(op_code == `OP_32)&(funct7 == 7'b0100_000);

assign	op_1	=	src1;
assign	op_2	=	imm_rs2_sel?(sign_ex_imm):(src2);
assign	shamt	=	imm_rs2_sel?(shift_amount):({1'b0,(src2[4:0])});

assign	ADD_RESULT	=	op_1 + op_2;
assign	SUB_RESULT	=	op_1 - op_2;
assign	ADD_SUB_RESULT	=	(instr_is_SUB|instr_is_SUBW)?(SUB_RESULT):(ADD_RESULT);
assign	XOR_RESULT	=	op_1 ^ op_2;
assign	OR_RESULT	=	op_1 | op_2;
assign	AND_RESULT	=	op_1 & op_2;
assign	SLL_RESULT	=	op_1<<shamt;
assign	SRL_RESULT	=	op_1>>shamt;
assign	SRA_RESULT	=  	((op_1))>>>shamt;
assign	SR_RESULT	=	(funct7[5])?SRA_RESULT:SRL_RESULT;
assign	BRANCH_TEMP	=	PC	+	{{51{SB_imm[11]}},SB_imm,1'b0};//{{51{SB_imm[11]}},SB_imm,1'b0}



assign	wb_dest			= decode_ack_data_valid	?	dest_temp	:	64'b0;	
assign	wb_rd_sel 		= decode_ack_data_valid	?	decode_dest_sel	:	5'b0;
assign	wb_dest_enable 		= decode_ack_data_valid	&	( ((op_code == `OP_IMM)|(op_code == `OP_IMM_32)|(op_code == `OP_32)|(op_code == `OP)|(op_code == `LUI)|(op_code == `AUIPC)|(op_code == `JAL)|(op_code == `JALR)) );	
assign	wb_dest_long_enable	= decode_ack_data_valid	&	( ((op_code == `OP_IMM)|(op_code == `OP)|(op_code == `LUI)|(op_code == `AUIPC)|(op_code == `JAL)|(op_code == `JALR)) );

	
assign	branch_target		=	(decode_ack_data_valid)?branch_target_temp:64'b0;
assign	branch_target_enable	=	decode_ack_data_valid&branch_target_enable_temp;
assign	execute_ack_pc_advance	=	decode_ack_data_valid;




always@(*)begin

	case({op_1[63],op_2[63]})
		2'b01:
		begin
			if(comp_is_unsigned)
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
			if(comp_is_unsigned)
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
			if(op_1<op_2)
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
		`AUIPC:		PC_relative_value	=	PC + {{32{U_imm[19]}},U_imm,12'b0};
		`JAL,`JALR:	PC_relative_value	=	PC + 4;
		default:	PC_relative_value	=	PC;
	endcase
end

always@(*)begin
	case(op_code)
		`AUIPC:	
			begin
				branch_target_enable_temp = 1'b1;
				branch_target_temp	=	PC	+	{{32{U_imm[19]}},U_imm,12'b0};
			end
		`JAL:	
			begin
				branch_target_enable_temp = 1'b1;
				branch_target_temp	=	PC  + {{43{UJ_imm[19]}},UJ_imm,1'b0};
			end
		`JALR:
			begin
				branch_target_enable_temp = 1'b1;
				branch_target_temp	=	src1	+	sign_ex_imm;
			end
		`BRANCH:
			begin
				case(funct3)
				`BRANCH_IS_BEQ:	
					begin
						if(src1 == src2)
							begin
								branch_target_enable_temp	=	1'b1;
								branch_target_temp	= BRANCH_TEMP;
							end
						else
							begin
								branch_target_enable_temp	=	1'b0;
								branch_target_temp	= PC;										
							end
					end
				`BRANCH_IS_BNE:
					begin
						if(src1 != src2)
							begin
								branch_target_enable_temp	=	1'b1;
								branch_target_temp	= BRANCH_TEMP;
							end
						else
							begin
								branch_target_enable_temp	=	1'b0;
								branch_target_temp	= PC;										
							end
					end		
				`BRANCH_IS_BLT,`BRANCH_IS_BLTU:		
					begin
						if(LT_FLAG)
							begin
								branch_target_enable_temp	=	1'b1;
								branch_target_temp	= BRANCH_TEMP;						
							end
						else
							begin
								branch_target_enable_temp	=	1'b0;
								branch_target_temp	= PC;
							end
					end
				`BRANCH_IS_BGE,`BRANCH_IS_BGEU:
					begin
						if(BGE_FLAG)
							begin
								branch_target_enable_temp	=	1'b1;
								branch_target_temp	= BRANCH_TEMP;												
							end
						else
							begin
								branch_target_enable_temp	=	1'b0;
								branch_target_temp	= PC;										
							end
					end
				default:	
						begin
							branch_target_enable_temp	=	1'b0;
							branch_target_temp 	=	PC;
						end
				endcase
			end
		default: 
			begin
				branch_target_enable_temp = 1'b0;
				branch_target_temp	=	PC;
			end
	endcase
end

	
	
always@(*)begin

	case(op_code)
		`LUI					:	dest_temp	= {{32{U_imm[19]}},U_imm,12'b0};
		`AUIPC,`JAL,`JALR			:	dest_temp	= PC_relative_value;
		`OP_IMM	,`OP_IMM_32	,`OP_32	,`OP 	:
											begin
												case(funct3)
														`OP_IS_ADD_SUB 	: 	dest_temp 	= 	ADD_SUB_RESULT;
														`OP_IS_SLL	   	: 	dest_temp 	= 	SLL_RESULT;
														`OP_IS_SLT	   	: 	dest_temp	=	{63'b0,LT_FLAG};
														`OP_IS_SLTU	   	:	dest_temp	=	{63'b0,LT_FLAG};
														`OP_IS_XOR	   	:	dest_temp	=	XOR_RESULT;
														`OP_IS_SR		:	dest_temp  	= 	SR_RESULT;
														`OP_IS_OR		:	dest_temp	=	OR_RESULT;
														`OP_IS_AND		:	dest_temp	=	AND_RESULT;
												endcase	
											end	
		default :	dest_temp = 64'b0;
	endcase

end	




always@(*)begin
	execute_ack_data_stop_next	=	decode_ack_data_valid;
end

flop #(.Bits(1)) f0(
	.clk(clk),
	.reset(reset),
	
	.d(execute_ack_data_stop_next),
	.q(execute_ack_data_stop)
);



endmodule
