module core_top_test();


reg 		clk = 0;
reg 		reset = 1;
reg			icache_ack_data_valid = 0;

reg	[255:0] rom [2:0];
initial begin
	rom[0] = 256'h001595930017979300b5053300a7853300000513010007130015859300150793;
	rom[1] = 256'h4017d79340b5053340f50533008007134075d5934067d793fe0716e3fff70713;
	rom[2] = 256'h0000000000000000000000000000000000008067fe0716e3fff707134015d593;
end


reg	[255:0] icache_ack_data = 256'h001595930017979300b5053300a7853300000513010007130015859300150793;
reg	[4:0]	ram_counter = 4'd8;


wire[63:0]	icache_req_addr;
wire        icache_req_addr_valid;/*when miss*/	

wire [63:0] 	debug_pc_ex;

wire        	debug_dest_valid;
wire [63:0] 	debug_dest;
wire [4:0] 		debug_dest_rd;
wire        	debug_dest_long;




core core_top_test(

	.clk(clk),
	.reset(reset),

	// i cache interface
	.icache_ack_data_valid(icache_ack_data_valid),
	.icache_ack_data(icache_ack_data),
		
	.icache_req_addr(icache_req_addr),
	.icache_req_addr_valid(icache_req_addr_valid),

	// Debug interface
	.debug_pc_ex(debug_pc_ex),
    
	.debug_dest_valid(debug_dest_valid),
	.debug_dest(debug_dest),
	.debug_dest_rd(debug_dest_rd),
	.debug_dest_long(debug_dest_long)

);



initial begin
    #640  reset =0;

end

always clk = #5 ~clk;


always@(*)begin

	icache_ack_data		<=	rom [icache_req_addr[63:5]];

end


always@(posedge clk)begin
	if(reset)
		begin
			icache_ack_data_valid	<=	1'b0;
		end
	else 
		begin
			if(icache_req_addr_valid)
				begin
					if(icache_ack_data_valid)
						begin
							icache_ack_data_valid 	<= 1'b0;
						end
					else
						begin
							icache_ack_data_valid	<=	(ram_counter == 4'd0);
						end
					if(ram_counter == 4'd0)
						begin
							ram_counter	<= $random();	
						end
					else
						ram_counter	<=	ram_counter -1;
				end
			else
				begin
					icache_ack_data_valid	<=	1'b0;
				end
		end
end




endmodule