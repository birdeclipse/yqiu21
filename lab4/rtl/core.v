module core(

	input clk,
	input reset,

	// i cache interface
	input			icache_ack_data_valid,
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



wire[63:0]	fetch_ack_pc;
wire[31:0]	fetch_ack_instr;
wire		fetch_ack_data_valid;
wire		decode_ack_data_rety;







wire	[4:0]		decode_rs1_sel;
wire	[4:0]		decode_rs2_sel;


wire	[4:0]		decode_dest_sel;	
wire				imm_rs2_sel;
wire				comp_is_unsigned;
wire	[63:0]		sign_ex_imm;
wire	[5:0]		shift_amount;

wire	[19:0]		U_imm;
wire	[19:0]		UJ_imm;
wire	[11:0]		SB_imm;

wire	[6:0]		op_code;
wire	[2:0]		funct3;
wire	[6:0]		funct7;
wire	[63:0]		pc_latch;






wire				decode_ack_data_valid;
wire				execute_ack_data_rety;
wire [63:0] 		rs1_data;
wire [63:0]			rs2_data;

wire [4:0]			wb_rd_sel;
wire				wb_dest_enable;
wire				wb_dest_long_enable;
wire [63:0]			wb_dest;

wire [63:0]			branch_target;
wire				branch_target_enable;




reg [63:0] 	debug_pc_ex_next;
reg        	debug_dest_valid_next;
reg [63:0] 	debug_dest_next;
reg  [4:0] 	debug_dest_rd_next;
reg        	debug_dest_long_next;

always@(*)begin

	debug_pc_ex_next			=	pc_latch; /*wrong modified in the future*/
	debug_dest_valid_next		=	wb_dest_enable;
	debug_dest_next				=	wb_dest;
	debug_dest_rd_next			=	wb_rd_sel;
	debug_dest_long_next		=	wb_dest_long_enable;

end




flop #(.Bits(64+1+64+5+1)) DEBUG(
	
	.clk(clk),
	.reset(reset),
	
	.d({debug_pc_ex_next,debug_dest_valid_next,debug_dest_next,debug_dest_rd_next,debug_dest_long_next}),
	.q({debug_pc_ex,debug_dest_valid,debug_dest,debug_dest_rd,debug_dest_long})
);





fetch FETCH(
	
	.clk(clk),
	.reset(reset),
	
	
	.icache_ack_data_valid(icache_ack_data_valid),
	.icache_ack_data(icache_ack_data),

	.icache_req_addr(icache_req_addr_temp),
	.icache_req_addr_valid(icache_req_addr_valid),/*when miss*/	
	
	
	
	/*branch and stall*/
	.branch_target(branch_target),
	.branch_target_enable(branch_target_enable),
	
	.fetch_stall(1'b0),
	
	
	/**/
	.fetch_ack_pc(fetch_ack_pc),
	.fetch_ack_instr(fetch_ack_instr),
	.fetch_ack_data_valid(fetch_ack_data_valid),
	.decode_ack_data_rety(decode_ack_data_rety)

);








decode DECODE(
	
	.clk(clk),
	.reset(reset),
	

	.fetch_ack_pc(fetch_ack_pc),
	.fetch_ack_instr(fetch_ack_instr),
	.fetch_ack_data_valid(fetch_ack_data_valid),
	.decode_ack_data_rety(decode_ack_data_rety),

	.decode_rs1_sel(decode_rs1_sel),
	.decode_rs2_sel(decode_rs2_sel),

	
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
	.execute_ack_data_rety(execute_ack_data_rety)

);




regfile REGFILE(
	.clk(clk),
	.reset(reset),

	.rs1_sel(decode_rs1_sel),
	.rs2_sel(decode_rs2_sel),
	
	.rd_sel(wb_rd_sel),
	.dest_enable(wb_dest_enable),
	.dest_long_enable(wb_dest_long_enable),
	.dest(wb_dest),
	
	.rs1_data(rs1_data),
	.rs2_data(rs2_data)

);






execute EXECUTE(
	
	.clk(clk),
	.reset(reset),

	
	.decode_ack_data_valid(decode_ack_data_valid),
	.execute_ack_data_rety(execute_ack_data_rety),
	
	
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
	
	.src1(rs1_data),
	.src2(rs2_data),
	
	.wb_rd_sel(wb_rd_sel),
	.wb_dest_enable(wb_dest_enable),
	.wb_dest_long_enable(wb_dest_long_enable),
	.wb_dest(wb_dest),
	
	
	.branch_target(branch_target),	
	.branch_target_enable(branch_target_enable)

);





endmodule