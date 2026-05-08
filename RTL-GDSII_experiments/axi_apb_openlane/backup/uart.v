
`include "Fifo_buffer.v"
`include "baudrate_generator.v"
`include "uart_rx.v"
`include "uart_tx.v"
module top_uart
   #( // Default setting:
      // 19,200 baud, 8 data bits, 1 stop bit, 2^2 FIFO
      parameter DBIT = 8,     // # data bits
                SB_TICK = 16, // # ticks for stop bits, 16/24/32
                              // for 1/1.5/2 stop bits
                DVSR = 163,   // baud rate divisor
                              // DVSR = 50M/(16*baud rate)
                DVSR_BIT = 8, // # bits of DVSR
                FIFO_W = 2    // # addr bits of FIFO
                              // # words in FIFO=2^FIFO_W
   )
   (
    input wire clk, reset,
    input wire rd_uart, wr_uart, 
    input wire [7:0] w_data,
    output wire tx_full, rx_empty, 
    output wire [7:0] r_data
   );

   // signal declaration
   wire tick, rx_done_tick, tx_done_tick;
   wire tx_empty, tx_fifo_not_empty;
   wire [7:0] tx_fifo_out, rx_data_out;
   wire tx,rx;

   //body
   baudrate_generator  #(.M(DVSR), .N(DVSR_BIT)) baud_gen_unit
      (.clk(clk), .reset(reset),  .s_tick(tick));

   uart_rx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_rx_unit
      (.clk(clk), .reset(reset), .rx(tx), .s_tick(tick),
       .rx_done_tick(rx_done_tick), .dout(rx_data_out));

   Fifo_buffer #(.W(DBIT), .N(FIFO_W)) fifo_rx_unit
      (.clk(clk), .reset(reset), .rd(rd_uart),
       .wr(rx_done_tick), .data_w(rx_data_out),
       .empty(rx_empty), .full(), .data_r(r_data));
       
       

   Fifo_buffer #(.W(DBIT), .N(FIFO_W)) fifo_tx_unit
      (.clk(clk), .reset(reset), .rd(tx_done_tick),
       .wr(wr_uart), .data_w(w_data), .empty(tx_empty),
       .full(tx_full), .data_r(tx_fifo_out));
   uart_tx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) uart_tx_unit
      (.clk(clk), .reset(reset), .tx_start(tx_fifo_not_empty),
       .s_tick(tick), .din(tx_fifo_out),
       .tx_done_tick(tx_done_tick), .tx(tx));
   assign tx_fifo_not_empty = ~tx_empty;
endmodule
`timescale 1ns / 1ps

module uart_rx
//Truyen tham so so databits, so ticks for stop bit
#(parameter DBIT=8, SB_TICK=16)
 (input wire clk, reset,//clk va reset
  input wire rx, s_tick,//rx: bit truyen
  output reg rx_done_tick,//bit tra ve tin hieu da truyen xong
  output wire [7:0] dout,//dataout
  output reg check_parity
    );
    
//Khai bao cac ma trang thai
    localparam [2:0]
    idle=3'b000,
    start=3'b001,
    data=3'b010,
    parity=3'b011,
    stop=3'b100;

//Khai bao cai tin hieu
reg[2:0] state_reg, state_next; //Thanh ghi trang thai va trang thai tiep
reg[3:0] s_reg, s_next; //dem so tick
reg[2:0] n_reg, n_next;
reg[7:0] b_reg, b_next;//bit truyen
reg xor_parity;



//Cap nhat trang thai sau moi clock
always @(posedge clk, posedge reset)
    if(reset)
        begin 
            state_reg <=idle; //Trang thai ban dau: idle
            s_reg <=0;//S_tick=0
            n_reg <=0;//So biet da truyen
            b_reg <=0;// bit tin hieu truyen
           
         end
       else
        begin
            state_reg <=state_next;
            s_reg <=s_next;
            n_reg <=n_next;
            b_reg <= b_next;
        
         end
        
       
always @*
    begin
    //data path funtion, tr?ng thai defaut
        state_next=state_reg;
        rx_done_tick=1'b0;
        s_next=s_reg;
        n_next=n_reg;
        b_next=b_reg;
    
        
        
        //FSM
        case(state_reg)
        idle:
            if(~rx)
                begin
                    state_next=start;
                    s_next=0;
                  end
          start:
            if(s_tick)//
                if(s_reg==7)//Bo dem 
                    begin
                        state_next=data;
                        s_next=0;
                        n_next=0;
                    end
                else
                    s_next=s_reg +1;
             data:
             if(s_tick)
                if(s_reg==15)
                    begin
                        s_next=0;
                        b_next={rx,b_reg[7:1]};
			
                        if(n_reg==(DBIT-1))//
                            state_next=parity; 
                         else
                            n_next=n_reg+1;
                       end
                    else
                        s_next=s_reg+1;
		      parity:
		      begin
		       if(s_tick)
                if(s_reg==15)
                    begin
                           s_next=0;
		                  xor_parity=dout[0]^dout[1]^dout[2]^dout[3]^dout[4]^dout[5]^dout[6]^dout[7];
		                  check_parity=(xor_parity ==rx);
		                  if(check_parity==1'b1)
		                      state_next=stop;
		                  else
		                  	  state_next=idle;
		                 
		         end
                   else
                        s_next=s_reg+1;
		     end
		          
                   
              stop:
                if(s_tick)
                    if(s_reg==(SB_TICK-1))
                        begin
            
                            rx_done_tick=1'b1;
                            state_next=idle;
                         end
                      else
                        s_next=s_reg+1;
                    endcase
                    end
                    
                    begin
                    assign dout=b_reg; 
   
end
endmodule

`timescale 1ns / 1ps
module uart_tx
   #(
     parameter DBIT = 8,     // # data bits
               SB_TICK = 16  // # ticks for stop bits
   )
   (
    input wire clk, reset,
    input wire tx_start, s_tick,
    input wire [7:0] din,
    output reg tx_done_tick,
    output wire tx
   );

   // symbolic state declaration
   localparam [2:0]
      idle      = 3'b000,
      start     = 3'b001,
      data      = 3'b010,
      parity      = 3'b011,
      stop   = 3'b100;

   // signal declaration
   reg [2:0] state_reg, state_next;
   reg [3:0] s_reg, s_next;
   reg [2:0] n_reg, n_next;
   reg [8:0] b_reg, b_next;
   reg p;
   reg tx_reg, tx_next;
   


   // body
   // FSMD state & data registers
   always @(posedge clk, posedge reset)
      if (reset)
         begin
            state_reg <= idle;
            s_reg <= 0;
            n_reg <= 0;
            b_reg <= 0;
            tx_reg <= 1'b1;
         end
      else
         begin
            state_reg <= state_next;
            s_reg <= s_next;
            n_reg <= n_next;
            b_reg <= b_next;
            tx_reg <= tx_next;
         end

   // FSMD next-state logic & functional units
   always @*
   begin
      p = din[0] ^ din[1] ^ din[2] ^ din[3] ^ din[4] ^ din[5] ^ din[6] ^ din[7];
      state_next = state_reg;
      tx_done_tick = 1'b0;
      s_next = s_reg;
      n_next = n_reg;
      b_next = b_reg;
      tx_next = tx_reg ;
      case (state_reg)
         idle:
            begin
               tx_next = 1'b1;
               if (tx_start)
                  begin
                     state_next = start;
                     s_next = 0;
                     b_next = {p,din};
                  end
            end
         start:
            begin
               tx_next = 1'b0;
               if (s_tick)
                  if (s_reg==15)
                     begin
                        state_next = data;
                        s_next = 0;
                        n_next = 0;
                     end
                  else
                     s_next = s_reg + 1;
            end
         data:
            begin
               tx_next = b_reg[0];
               if (s_tick)
                  if (s_reg==15)
                     begin
                        s_next = 0;
                        b_next = b_reg >> 1;
                        if (n_reg==(DBIT-1))
                           state_next = parity ;
                        else
                           n_next = n_reg + 1;
                       state_next = data;
                     end
                  else
                     s_next = s_reg + 1;
            end
         parity:
            begin
                tx_next = b_reg[0];
                if(s_tick==1)
                    if(s_reg==15)
                        begin
                            state_next = stop;
                            s_next = 0;
                        end
                    else
                       s_next = s_reg + 1; 
            end
         stop:
            begin
               tx_next = 1'b1;
               if (s_tick)
                  if (s_reg==(SB_TICK-1))
                     begin
                        state_next = idle;
                        tx_done_tick = 1'b1;
                     end
                  else
                     s_next = s_reg + 1;
            end
      endcase
   end
   // output
   assign tx = tx_reg;

endmodule

`timescale 1ns / 1ps

module Fifo_buffer
  #(
       parameter W = 8, // so bit m?i h�ng
                 N = 2 // s? bit ??a ch�
   ) 
   (
       input wire wr, rd, clk, reset,
       input wire [W-1:0] data_w,
       output wire full, empty,
       output wire [W-1:0] data_r    
   );
       //signal declaration
       reg [7:0] array [2**N - 1 : 0];
       reg [N-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
       reg [N-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
       wire wr_en, r_en;
       reg empty_next, full_next;
       reg empty_reg, full_reg;
       
       // body
       // write operation
       always@(posedge clk)
             if(wr_en)
                array[w_ptr_reg] <= data_w;
       // read  operation
           /*  if(r_en)
                data_r <= array[r_ptr_reg]; */
       assign data_r = array[r_ptr_reg];  
       // note
       assign wr_en =  ~full_reg  & wr;
       /*assign r_en  =  ~empty_reg & rd; */ // cannot be used in case 11
       
       //fifo control logic
       //register for read and write pointers
       always@(posedge clk, posedge reset)
          begin
             if(reset)
                begin
                   r_ptr_reg <= 0;
                   w_ptr_reg <= 0;
                   full_reg <=  1'b0;
                   empty_reg <= 1'b1;
                end
             else 
                begin
                   r_ptr_reg <= r_ptr_next;
                   w_ptr_reg <= w_ptr_next;
                   full_reg <= full_next;
                   empty_reg <= empty_next;
                end
             end
       //register for read and write
       //next state logic
       always @*
          begin
             // keep default value
             r_ptr_next = r_ptr_reg;
             w_ptr_next = w_ptr_reg;
             full_next = full_reg;
             empty_next = empty_reg;
             // increment the pointers
             r_ptr_succ = r_ptr_reg + 1;
             w_ptr_succ = w_ptr_reg + 1;
      
             // read and write case
             case({rd, wr})
               /* 2'b00: begin
                          r_ptr_next = r_ptr_reg;
                          w_ptr_next = w_ptr_reg;
                          full_next  = full_reg;
                          empty_next = empty_reg; 
                       end */
               2'b01:  
                          if(~full_reg) // not full
                             begin
                                w_ptr_next = w_ptr_succ;
                                empty_next = 1'b0;
                                if(w_ptr_next == r_ptr_reg)
                                   full_next = 1'b1;
                               /* else
                                   full_next = 1'b0; */ // not necessary as full_reg will keep its previous value
                              end
                       
              2'b10:   
                          if(~empty_reg)
                             begin
                                r_ptr_next = r_ptr_succ;
                                full_next = 1'b0;
                                if(r_ptr_next == w_ptr_reg)
                                   empty_next = 1'b1;
                            /*    else
                                    empty_next = 1'b1; */
                              end
                       
              2'b11:   begin
                          r_ptr_next = r_ptr_succ;
                          w_ptr_next = w_ptr_succ;
                       end
           endcase
         end
       //output    
       assign empty = empty_reg;
       assign full  = full_reg;     
endmodule

`timescale 1ns / 1ps

module baudrate_generator
    #(  
          parameter N = 8,
                    M = 163       
     )
    (
          input wire clk, reset,
          output wire s_tick
    );

 reg  [N-1:0] r_reg,r_next;
 
 always@(posedge clk, posedge reset)
 begin
    if(reset)
       r_reg <= 8'b0;
    else
       r_reg <= r_next;
 end

always @*
begin
   if(r_reg <= M)
      r_next = r_reg + 1;
   else 
      r_next = 0;
end

assign s_tick = (r_reg == (M)) ? 1'b1 : 1'b0;


endmodule
