module sync_fifo_TB;
  reg clk, reset_n;
  reg wr_en, r_en;
  reg [7:0] data_in;
  wire [7:0] data_out;
  wire full, empty;
  
  synchronous_fifo s_fifo(clk, reset_n, wr_en, r_en, data_in, data_out, full, empty);
  
  always #5 clk = ~clk;
  initial begin
    clk = 0; reset_n = 0;
    wr_en = 0; r_en = 0;
    #3 reset_n = 1;
    drive(20);
    $finish;
  end
  
  task write();
    if(!full) begin
      wr_en = 1;
      data_in = $random;
     end
    else $display("FIFO Full");
  endtask 
  
  task read();
    if(!empty) begin
      r_en = 1;
     end
    else $display("FIFO Empty");
  endtask
  
  task drive(int delay);
    wr_en = 0; r_en = 0;
    fork
      begin
        repeat(10) begin @(posedge clk) write(); end
        wr_en = 0;
      end
      begin
        #delay;
        repeat(10) begin @(posedge clk) read(); end
        r_en = 0;
      end
    join
  endtask
  
  initial begin 
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
endmodule
