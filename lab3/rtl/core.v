/****************************************************************************
 * core.v
 ****************************************************************************/
/**
 * Module: core
 * 
 * TODO: Add module documentation
 */
module core(
		
	input clk,
	input reset,

	// i cache interface
	input		icache_ack_data_valid,
	input  [255:0] 	icache_ack_data,
		
	output [63:0] 	icache_req_addr,
	output        	icache_req_addr_valid,

	// Debug interface
	output [63:0] 	debug_pc_ex,

	output        	debug_dest_valid,
	output [63:0] 	debug_dest,
	output  [4:0] 	debug_dest_rd,
	output        	debug_dest_long
	
);
wire	[63-5:0] icache_req_addr_temp;
assign	icache_req_addr = {icache_req_addr_temp,5'b0};
wire	[63:0]	fetch_req_next_pc;
wire		fetch_req_next_pc_valid;
wire		icache_req_next_pc_rety;


wire	[63:0]	fetch_ack_pc;
wire	[31:0]	fetch_ack_instr;
wire		fetch_ack_data_valid;
wire		decode_ack_data_stop;




wire	[31:0]	icache_ack_instr;			/*instruction*/
wire		icahce_ack_instr_valid;		/*instruction valid signal, use to determine whether the instruction is valid on ready or not*/


wire		decode_ack_data_valid;
wire		execute_ack_data_stop;

wire		execute_ack_pc_advance;



wire	[4:0]	decode_rs1_sel;
wire	[4:0]	decode_rs2_sel;
wire	[4:0]	decode_dest_sel;

wire	[4:0]	wb_rd_sel;
wire		wb_dest_enable;
wire		wb_dest_long_enable;
wire	[63:0]	wb_dest;

wire	[63:0]	rs1_data;
wire	[63:0]	rs2_data;

wire	[63:0]	sign_ex_imm;
wire		imm_rs2_sel;
wire		comp_is_unsigned;
wire	[5:0]	shift_amount;
wire	[19:0]	U_imm;
wire	[19:0]	UJ_imm;
wire	[11:0]	SB_imm;

wire	[6:0]	op_code;
wire	[6:0]	funct7;
wire	[2:0]	funct3;
wire	[63:0]	pc_latch;/*latch PC at decode stage*/

wire	[63:0]	branch_target;
wire		branch_target_enable;

assign	debug_pc_ex		=	fetch_req_next_pc;
assign	debug_dest_valid	=	wb_dest_enable;
assign	debug_dest		=	wb_dest;
assign	debug_dest_rd		=	wb_rd_sel;
assign	debug_dest_long		=	wb_dest_long_enable;

icache core_cache(
	.clk(clk),
	.reset(reset),
		
	/*test bench ROM interface*/
	.icache_ack_data_valid(icache_ack_data_valid),
	.icache_ack_data(icache_ack_data),
	
	.icache_req_addr(icache_req_addr_temp),
	.icache_req_addr_valid(icache_req_addr_valid),
	
	/*PC interface*/
	.core_req_pc(fetch_req_next_pc[63:1]),
	.core_req_pc_valid(fetch_req_next_pc_valid),
	.icache_req_next_pc_rety(icache_req_next_pc_rety),

	/*decode interface*/
	.core_ack_insn(icache_ack_instr),				
	.core_ack_insn_valid(icahce_ack_instr_valid)
);



fetch core_fetch(
	
	.clk(clk),
	.reset(reset),
	
	
	.icache_ack_instr(icache_ack_instr),	
	.icahce_ack_instr_valid(icahce_ack_instr_valid),	/*if low do not increment PC by 4*/
	
	.branch_target(branch_target),
	.branch_target_enable(branch_target_enable),
	
	.fetch_stall(1'b0),
	
	.fetch_req_next_pc(fetch_req_next_pc),
	.fetch_req_next_pc_valid(fetch_req_next_pc_valid),
	.icache_req_next_pc_rety(icache_req_next_pc_rety),

	.fetch_ack_pc(fetch_ack_pc),				/*This PC should be point to current instruction*/
	.fetch_ack_instr(fetch_ack_instr),			/*generate NOP(Bubble) if core_ack_instr_valid is low*/
	.fetch_ack_data_valid(fetch_ack_data_valid),
	.decode_ack_data_stop(decode_ack_data_stop),
	
	.execute_ack_pc_advance(execute_ack_pc_advance)

);




regfile core_reg_file(
	.clk(clk),
	.reset(reset),
	
	.rs1_sel(decode_rs1_sel),				/*given by the decode should be comb*/
	.rs2_sel(decode_rs2_sel),				/*given by the decode should be comb*/
	
	.rd_sel(wb_rd_sel),					/*write back*/
	.dest_enable(wb_dest_enable),				/**/
	.dest_long_enable(wb_dest_long_enable),			/**/
	.dest(wb_dest),
	
	
	.rs1_data(rs1_data),
	.rs2_data(rs2_data)	
);



decode core_decode(
		
	.clk(clk),
	.reset(reset),

	.fetch_ack_pc(fetch_ack_pc),	
	.fetch_ack_instr(fetch_ack_instr),
	.fetch_ack_data_valid(fetch_ack_data_valid),
	.decode_ack_data_stop(decode_ack_data_stop),
	
	
	.decode_rs1_sel(decode_rs1_sel),		/*given to the register file should be comb*/
	.decode_rs2_sel(decode_rs2_sel),		/*given to the register file should be comb*/

	.decode_dest_sel(decode_dest_sel),
	.imm_rs2_sel(imm_rs2_sel),
	.comp_is_unsigned(comp_is_unsigned),
	.sign_ex_imm(sign_ex_imm),
	.shift_amount(shift_amount),
	.U_imm(U_imm),
	.UJ_imm(UJ_imm),
	.SB_imm(SB_imm),
	.op_code(op_code),
	.funct3(funct3),
	.funct7(funct7),
	.pc_latch(pc_latch),
	.decode_ack_data_valid(decode_ack_data_valid),
	.execute_ack_data_stop(execute_ack_data_stop)
	
);
	




execute core_execute(
		
	.clk(clk),
	.reset(reset),
	
	
	.decode_ack_data_valid(decode_ack_data_valid),
	.execute_ack_data_stop(execute_ack_data_stop),

	.decode_dest_sel(decode_dest_sel),
	.imm_rs2_sel(imm_rs2_sel),
	.comp_is_unsigned(comp_is_unsigned),
	.sign_ex_imm(sign_ex_imm),
	.shift_amount(shift_amount),
	.U_imm(U_imm),
	.UJ_imm(UJ_imm),
	.SB_imm(SB_imm),
	
	.op_code(op_code),
	.funct3(funct3),
	.funct7(funct7),
	.PC(pc_latch),

		
	.src1(rs1_data),							/*bypassing:E->D if (wb_rd_sel)&(wb_dest_enable)&(decode_rs1_sel == wb_rd_sel)*/
	.src2(rs2_data),							/*bypassing:E->D if (wb_rd_sel)&(wb_dest_enable)&(decode_rs2_sel == wb_rd_sel)*/
	
	
	
		
	.wb_rd_sel(wb_rd_sel),							/*should be comb NOTE :  */
	.wb_dest_enable(wb_dest_enable),					/*should be comb*/
	.wb_dest_long_enable(wb_dest_long_enable),				/*should be comb*/
	.wb_dest(wb_dest),							/*should be comb*/
	
	
	.branch_target(branch_target),						/*should be comb*/
	.branch_target_enable(branch_target_enable),				/*should be comb*/
	.execute_ack_pc_advance(execute_ack_pc_advance)
		
);
	
	
	
	
	
	
	
	
	
	
	
	

endmodule


