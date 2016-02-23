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
	
	
	input				icache_ack_data_valid,
	input  [255:0] 		icache_ack_data,

	output [63-5:0] 	icache_req_addr,
	output        		icache_req_addr_valid,/*when miss*/	
	
	
	
	/*branch and stall*/
	input	[63:0]		branch_target,
	input				branch_target_enable,
	
	input				fetch_stall,
	
	
	/**/
	output	[63:0]		fetch_ack_pc,
	output	[31:0]		fetch_ack_instr,
	output				fetch_ack_data_valid,
	input				decode_ack_data_rety

);



wire[63:0]				program_counter;
reg	[63:0]				program_counter_next;

reg	[63:0]				fetch_ack_pc_next;



reg	[63:0]				fetch_req_next_pc;	
wire					fetch_req_next_pc_valid;
wire					icache_req_next_pc_rety;

wire[31:0]				icache_ack_instr;
wire					icahce_ack_instr_valid;			
wire					icache_ack_instr_rety;


assign	fetch_req_next_pc_valid	=	(~fetch_stall);							/*always valid*/




icache ICACHE(

	.clk(clk),
	.reset(reset),
		
	.icache_ack_data_valid(icache_ack_data_valid),
	.icache_ack_data(icache_ack_data),

	.icache_req_addr(icache_req_addr),
	.icache_req_addr_valid(icache_req_addr_valid),/*when miss*/
		
		
	/*pc interface*/
	.core_req_pc(program_counter[63:1]),
	.core_req_pc_valid(fetch_req_next_pc_valid),
	.icache_req_next_pc_rety(icache_req_next_pc_rety),

	/*Decoder interface*/
	.core_ack_insn(icache_ack_instr),
	.core_ack_insn_valid(icahce_ack_instr_valid)/*when hit*/
	
);







always@(*)begin
	 if(branch_target_enable)
		begin
			fetch_req_next_pc	=	branch_target;
		end
	else if(icache_req_next_pc_rety|decode_ack_data_rety|icache_ack_instr_rety)
		begin
			fetch_req_next_pc	=	program_counter;
		end
	else 
		begin
			fetch_req_next_pc	=	program_counter+4;
		end
end


always@(*)begin

	program_counter_next	=	fetch_req_next_pc;

end



always@(*)begin
	fetch_ack_pc_next	=	program_counter;
end






flop #(.Bits(64)) PC(
	
	.clk(clk),
	.reset(reset),
	
	.d(program_counter_next),
	.q(program_counter)
);


Fluid_Flop#(.Size(96))
Fetch(

    .clk		(clk),
    .reset		(reset),

    .din		({fetch_ack_pc_next,icache_ack_instr}),
    .dinValid	(icahce_ack_instr_valid&(~branch_target_enable)),
    .dinRetry	(icache_ack_instr_rety),

    .q			({fetch_ack_pc,fetch_ack_instr}),
    .qRetry		(decode_ack_data_rety),
    .qValid		(fetch_ack_data_valid)
    
);    







	
	
	
endmodule
