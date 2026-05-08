module spi_apb(

    input wire clk,
    input wire rst_n,

    input wire psel,
    input wire penable,
    input wire pwrite,
    input wire [2:0] paddr,
    input wire [15:0] pwdata,

    output reg [15:0] prdata,

    output wire spi_cs_l,
    output wire spi_clk,
    output wire spi_data,
    inout wire master_data
);

reg [15:0] tx_data;
wire [4:0] counter;

spi_2 spi_inst(

    .clk(clk),
    .reset(~rst_n),

    .datain(tx_data),
    .dataout(16'd0),

    .spi_cs_l(spi_cs_l),
    .spi_clk(spi_clk),
    .spi_data(spi_data),

    .master_data(master_data),

    .counter(counter)
);

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        tx_data <= 16'd0;

    else begin
        if(psel && penable && pwrite) begin

            case(paddr)

                8'h00:
                    tx_data <= pwdata;

            endcase
        end
    end
end

always @(*) begin
    prdata = 16'd0;

    case(paddr)

        // Transmission counter
        8'h04:
            prdata = {11'd0, counter};

    endcase
end

endmodule