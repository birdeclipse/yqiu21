
module fmux(
  input clk,
//  input reset,

  input a,
  input b,
  input sel,
  output out1
);

reg out1_next;

always @(a or b) begin
  if (sel)
    out1_next = a;
  else
    out1_next = b;
end

flop f(.clk(clk), .d(out1_next), .q(out1));

endmodule

