/****************************************************************************
 * fetch.v
 ****************************************************************************/

/**
 * Module: fetch
 * 
 * TODO: Add module documentation
 */
module fetch(
	
	input	clk,
	input	reset,
	/*icache to fetch*/
	input	[31:0]		icache_ack_instr,
	input			icahce_ack_instr_valid,/*if cache hit generate this signal immediately*/
	
	
	/*branch and stall*/
	input	[63:0]		branch_target,
	input			branch_target_enable,
	
	input			fetch_stall,
	
	/*fetch to icache*/
	output	reg[63:0]	fetch_req_next_pc,
	output			fetch_req_next_pc_valid,
	input			icache_req_next_pc_rety,/*if cache miss ff signal one cycle after untill cache hit and PC use old data*/
	
	/**/
	output	[63:0]		fetch_ack_pc,
	output	[31:0]		fetch_ack_instr,
	output			fetch_ack_data_valid,
	input			decode_ack_data_stop,
	
	/*execute to fetch*/
	input			execute_ack_pc_advance

);



wire	[63:0]		program_counter;
reg	[63:0]		program_counter_next;

reg	[63:0]		fetch_ack_pc_next;




assign	fetch_req_next_pc_valid	=	(~fetch_stall);							/*always valid*/
assign	fetch_ack_instr		=	icache_ack_instr;
assign	fetch_ack_data_valid 	=	 icahce_ack_instr_valid;


always@(*)begin
	 if(branch_target_enable)
		begin
			fetch_req_next_pc	=	branch_target;
		end
	else if(execute_ack_pc_advance)
		begin
			fetch_req_next_pc	=	program_counter+4;
		end
	else if(icache_req_next_pc_rety|decode_ack_data_stop)
		begin
			fetch_req_next_pc	=	program_counter;
		end
	else
		begin
			fetch_req_next_pc	=	program_counter;
		end
end


always@(*)begin

	program_counter_next	=	fetch_req_next_pc;

end


always@(*)begin
	fetch_ack_pc_next	=	fetch_req_next_pc;
end


	
flop #(.Bits(64)) f2(
	
	.clk(clk),
	.reset(reset),

	.d(program_counter_next),
	.q(program_counter)
);		

	
flop #(.Bits(64)) f3(
	
	.clk(clk),
	.reset(reset),
	
	.d(fetch_ack_pc_next),
	.q(fetch_ack_pc)
);		


	
	
	
endmodule
