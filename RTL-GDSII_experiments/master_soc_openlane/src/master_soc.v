module master_soc(

    input clk,
    input rst_n,

    //==================================================
    // AXI Interface
    //==================================================

    input arvalid,
    input [1:0] arburst,
    input [3:0] arlen,
    input [4:0] araddr,

    input awvalid,
    input [4:0] awaddr,
    input [3:0] awlen,
    input [1:0] awburst,

    input wvalid,
    input [15:0] wdata,
    input wlast,

    input rready,
    input bready,

    output [15:0] rdata,
    output rvalid,
    output bvalid,

    //==================================================
    // SPI Physical Interface
    //==================================================

    output spi_cs_l,
    output spi_clk,
    output spi_data,
    inout  master_data,

    //==================================================
    // I2C Physical Interface
    //==================================================

    inout sda,
    output scl
);

    //==================================================
    // APB Signals
    //==================================================

    wire [2:0]  PADDR;
    wire [15:0] PWDATA;
    wire [15:0] PRDATA;

    wire PWRITE;
    wire PENABLE;

    wire PSEL1;
    wire PSEL2;
    wire PSEL3;
    wire PSEL4;

    //==================================================
    // Peripheral Read Data
    //==================================================

    wire [15:0] spi_prdata;
    wire [15:0] i2c_prdata;
//    wire [15:0] mem_prdata;

    //==================================================
    // APB Read Data Mux
    //==================================================

    assign PRDATA =
            PSEL2 ? spi_prdata :
            PSEL3 ? i2c_prdata :
           // PSEL4 ? mem_prdata :
            16'd0;

    //==================================================
    // AXI to APB Bridge
    //==================================================

    bridge DUT (

        .clk(clk),
        .res_n(rst_n),

        // AXI Read Address Channel
        .arvalid(arvalid),
        .arburst(arburst),
        .arlen(arlen),
        .araddr(araddr),

        // AXI Write Address Channel
        .awvalid(awvalid),
        .awaddr(awaddr),
        .awlen(awlen),
        .awburst(awburst),

        // AXI Write Data Channel
        .wvalid(wvalid),
        .wdata(wdata),
        .wlast(wlast),

        // AXI Response
        .rready(rready),
        .bready(bready),

        .rdata(rdata),
        .rvalid(rvalid),
        .bvalid(bvalid),

        // APB Interface
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),

        .PWRITE(PWRITE),
        .PENABLE(PENABLE),

        .PSEL1(PSEL1),
        .PSEL2(PSEL2),
        .PSEL3(PSEL3),
        .PSEL4(PSEL4),

        .PREADY(1'b1)
    );

    //==================================================
    // SPI APB Peripheral
    //==================================================

    spi_apb spi0 (

        .clk(clk),
        .rst_n(rst_n),

        .psel(PSEL2),
        .penable(PENABLE),
        .pwrite(PWRITE),

        .paddr(PADDR),
        .pwdata(PWDATA),

        .prdata(spi_prdata),

        .spi_cs_l(spi_cs_l),
        .spi_clk(spi_clk),
        .spi_data(spi_data),
        .master_data(master_data)
    );

    //==================================================
    // I2C APB Peripheral
    //==================================================

    i2c_apb i2c0 (

        .clk(clk),
        .rst_n(rst_n),

        .psel(PSEL3),
        .penable(PENABLE),
        .pwrite(PWRITE),

        .paddr(PADDR),
        .pwdata(PWDATA),

        .prdata(i2c_prdata),

        .sda(sda),
        .scl(scl)
    );

    //==================================================
    // APB Memory Peripheral
    //==================================================

//    apb mem0 (
//
//        .clk(clk),
//        .rst(~rst_n),
//
//        .psel(PSEL4),
//        .pen(PENABLE),
//        .pwrite(PWRITE),
//
//        .pwdata(PWDATA),
//        .paddr(PADDR),
//
//      .prdata(mem_prdata)
//    );

endmodule