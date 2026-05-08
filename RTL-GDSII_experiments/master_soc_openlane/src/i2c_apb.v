module i2c_apb(

    input wire clk,
    input wire rst_n,

    input wire psel,
    input wire penable,
    input wire pwrite,
    input wire [2:0] paddr,
    input wire [15:0] pwdata,

    output reg [15:0] prdata,

    inout wire sda,
    output wire scl
);

reg [7:0] slave_addr;
reg [7:0] tx_data;

wire clk2mhz_dummy;
wire rw;

i2c_master i2c_inst(

    .sda(sda),
    .scl(scl),

    .clk2mhz_dummy(clk2mhz_dummy),
    .rw(rw),

    .clk100mhz(clk),
    .res(~rst_n),

    .data_to_send(tx_data),
    .addr_to_send(slave_addr)
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        slave_addr <= 8'd0;
        tx_data <= 8'd0;
    end

    else begin
        if(psel && penable && pwrite) begin

            case(paddr)

                // Slave Address
                8'h00:
                    slave_addr <= pwdata[7:0];

                // TX Data
                8'h04:
                    tx_data <= pwdata[7:0];

            endcase
        end
    end
end

always @(*) begin
    prdata = 16'd0;

    case(paddr)

        8'h08:
            prdata = {15'd0, rw};

    endcase
end

endmodule