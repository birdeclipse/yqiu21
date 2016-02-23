/****************************************************************************
 * regfile.v
 ****************************************************************************/

/**
 * Module: regfile
 * 
 * TODO: Add module documentation
 */
module regfile(
	input clk,
	input reset,

	input  [4:0] 		rs1_sel,
	input  [4:0] 		rs2_sel,
	
	input  [4:0] 		rd_sel,
	input				dest_enable,
	input				dest_long_enable,
	input  [63:0]		dest,
	
	output reg[63:0] 	rs1_data,
	output reg[63:0] 	rs2_data

);

reg	[63:0]	rf[31:0];
reg	[4:0]	reset_counter	=	5'b0;

always@(posedge clk)begin
	if(reset)
		begin
			rf[reset_counter]	<=	64'b0;
			reset_counter		<=	reset_counter+1'b1;
		end
	else
		begin
			if(dest_enable)
				begin
					if(dest_long_enable)
						rf[rd_sel]	<=	dest;
					else
						rf[rd_sel][31:0]	<=	dest[31:0];
				end
		end
end

always@(posedge clk)begin
	if(reset)
		begin
			rs1_data	<=	64'b0;
		end
	else
		begin
			if((rs1_sel	==	rd_sel)&(dest_enable))
				begin
					if(dest_long_enable)
						begin
							rs1_data	<=	dest;
						end
					else
						begin
							rs1_data	<=	{rf[rd_sel][63:32],dest[31:0]};
						end
				end
			else
				begin
					rs1_data	<=	rf[rs1_sel];		
				end
		end
end


always@(posedge clk)begin
	if(reset)
		begin
			rs2_data	<=	64'b0;
		end
	else
		begin
			if((rs2_sel	==	rd_sel)&(dest_enable))
				begin
					if(dest_long_enable)
						begin
							rs2_data	<=	dest;
						end
					else
						begin
							rs2_data	<=	{rf[rd_sel][63:32],dest[31:0]};
						end
				end
			else
				begin
					rs2_data	<=	rf[rs2_sel];		
				end
		end
end

endmodule