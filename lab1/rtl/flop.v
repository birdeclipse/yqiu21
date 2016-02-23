
module flop(
  input clk,
  input d,
  output q
);
wire clk;
wire d;
reg q;

always @(posedge clk) begin
  q <= d;
end

endmodule

