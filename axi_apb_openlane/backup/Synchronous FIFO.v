// Code your design here

module synchronous_fifo #(parameter fifo_depth=8, DATAWIDTH=8) (
  input clk, reset_n,
  input wr_en, r_en,
  input [DATAWIDTH-1:0] data_in,
  output reg [DATAWIDTH-1:0] data_out,
  output full, empty
);
  
  reg [2:0] w_ptr, r_ptr;
  reg [DATAWIDTH-1:0] fifo[fifo_depth];
  
  // Sreset
  always@(posedge clk) begin
    if(!reset_n) begin
      w_ptr <= 0; r_ptr <= 0;
      data_out <= 0;
    end
  end
  
  // write operation
  always@(posedge clk) begin
    if(wr_en & !full)begin
      fifo[w_ptr] <= data_in;
      w_ptr <= w_ptr + 1;
    end
  end
  
  // read operation 
  always@(posedge clk) begin
    if(r_en & !empty) begin
      data_out <= fifo[r_ptr];
      r_ptr <= r_ptr + 1;
    end
  end
  
  assign full = ((w_ptr+1'b1) == r_ptr);
  assign empty = (w_ptr == r_ptr);
endmodule


