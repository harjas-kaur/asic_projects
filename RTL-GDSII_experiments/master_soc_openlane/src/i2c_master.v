`timescale 1ns / 1ps

module i2c_master(
    inout sda,
    output scl,
    output clk2mhz_dummy,
    output rw,

    input clk100mhz,
    input res,

    input [7:0] data_to_send,
    input [7:0] addr_to_send
);

parameter [3:0]
    idle               = 4'b0000,
    start_init         = 4'b0001,
    start              = 4'b0010,
    address_send       = 4'b0011,
    slave_ack_init     = 4'b0100,
    slave_ack          = 4'b0101,
    data_send_init_wait= 4'b0110,
    data_send_init     = 4'b0111,
    data_send          = 4'b1000,
    data_ack_init      = 4'b1001,
    data_ack           = 4'b1010,
    stop_init          = 4'b1011,
    stop               = 4'b1100,
    data_read_init     = 4'b1101,
    data_read          = 4'b1110;

//--------------------------------------------------
// Registers
//--------------------------------------------------

reg [3:0] state = idle;

reg clk2mhz;

reg sda_h = 0;
reg scl_h = 0;

reg sda_mode = 1;
reg scl_mode = 1;

reg scl_toggle = 0;

wire [7:0] addr_to_send_store;
wire [7:0] data_to_send_store;

reg [7:0] data_read_store;

integer count = 0;
integer bit_count = 7;

integer count_ack_wait = 4;
integer count_sda_wait = 2;

//--------------------------------------------------
// Input Storage
//--------------------------------------------------

assign addr_to_send_store = addr_to_send;
assign data_to_send_store = data_to_send;

//--------------------------------------------------
// Assignments
//--------------------------------------------------

assign rw = addr_to_send_store[0];

assign sda = sda_mode ? 1'bz : sda_h;

assign scl =
    scl_mode ? 1'bz :
    scl_toggle ? clk2mhz :
    scl_h;

assign clk2mhz_dummy = clk2mhz;

//--------------------------------------------------
// 2 MHz Clock Generator
//--------------------------------------------------

always @(posedge clk100mhz)
begin

    count <= count + 1;

    if(count <= 24)
        clk2mhz <= 0;
    else
        clk2mhz <= 1;

    if(count == 49)
        count <= 0;
end

//--------------------------------------------------
// FSM
//--------------------------------------------------

always @(posedge clk2mhz or posedge res)
begin

    if(res)
    begin

        state <= idle;

        bit_count <= 7;

        count_ack_wait <= 4;
        count_sda_wait <= 2;

        sda_mode <= 1;
        sda_h <= 1;

        scl_mode <= 1;
        scl_h <= 1;

        scl_toggle <= 0;
    end

    else
    begin

        case(state)

        //------------------------------------------
        // IDLE
        //------------------------------------------

        idle:
        begin

            sda_mode <= 1;
            sda_h <= 1;

            scl_mode <= 1;
            scl_h <= 1;

            bit_count <= 7;

            if(addr_to_send_store != 0)
                state <= start_init;
            else
                state <= idle;
        end

        //------------------------------------------
        // START
        //------------------------------------------

        start_init:
        begin

            sda_mode <= 0;
            sda_h <= 0;

            scl_mode <= 1;
            scl_h <= 1;

            state <= start;
        end

        start:
        begin

            sda_mode <= 0;
            sda_h <= 0;

            scl_mode <= 0;
            scl_h <= 0;

            state <= address_send;
        end

        //------------------------------------------
        // ADDRESS SEND
        //------------------------------------------

        address_send:
        begin

            scl_toggle <= 1;

            sda_h <= addr_to_send_store[bit_count];

            if(bit_count == 0)
            begin
                bit_count <= 7;
                state <= slave_ack_init;
            end
            else
            begin
                bit_count <= bit_count - 1;
                state <= address_send;
            end
        end

        //------------------------------------------
        // SLAVE ACK
        //------------------------------------------

        slave_ack_init:
        begin

            sda_mode <= 1;
            sda_h <= 1;

            state <= slave_ack;
        end

        slave_ack:
        begin

            count_ack_wait <= count_ack_wait - 1;

            if(count_ack_wait == 0)
            begin

                count_ack_wait <= 4;

                if(sda == 0)
                begin

                    if(rw == 0)
                        state <= data_send_init_wait;
                    else
                        state <= data_read_init;
                end

                else
                    state <= idle;
            end
        end

        //------------------------------------------
        // DATA SEND
        //------------------------------------------

        data_send_init_wait:
        begin

            count_sda_wait <= count_sda_wait - 1;

            if(count_sda_wait == 0)
            begin

                sda_mode <= 1;
                sda_h <= 1;

                count_sda_wait <= 2;

                state <= data_send_init;
            end
        end

        data_send_init:
        begin

            sda_mode <= 0;
            sda_h <= 0;

            state <= data_send;
        end

        data_send:
        begin

            sda_h <= data_to_send_store[bit_count];

            if(bit_count == 0)
            begin

                bit_count <= 7;
                state <= data_ack_init;
            end

            else
            begin

                bit_count <= bit_count - 1;
                state <= data_send;
            end
        end

        //------------------------------------------
        // DATA ACK
        //------------------------------------------

        data_ack_init:
        begin

            sda_mode <= 1;
            sda_h <= 1;

            state <= data_ack;
        end

        data_ack:
        begin

            count_ack_wait <= count_ack_wait - 1;

            if(count_ack_wait == 0)
            begin

                count_ack_wait <= 4;

                if(sda == 0)
                    state <= stop_init;
                else
                    state <= data_send_init;
            end
        end

        //------------------------------------------
        // DATA READ
        //------------------------------------------

        data_read_init:
        begin

            sda_mode <= 1;
            sda_h <= 1;

            state <= data_read;
        end

        data_read:
        begin

            data_read_store[bit_count] <= sda;

            if(bit_count == 0)
            begin

                bit_count <= 7;
                state <= stop_init;
            end

            else
            begin

                bit_count <= bit_count - 1;
                state <= data_read;
            end
        end

        //------------------------------------------
        // STOP
        //------------------------------------------

        stop_init:
        begin

            count_sda_wait <= count_sda_wait - 1;

            if(count_sda_wait == 0)
            begin

                count_sda_wait <= 2;
                state <= stop;
            end
        end

        stop:
        begin

            sda_mode <= 1;
            sda_h <= 1;

            scl_toggle <= 0;

            scl_mode <= 1;
            scl_h <= 1;

            state <= idle;
        end

        //------------------------------------------

        default:
        begin
            state <= idle;
        end

        endcase
    end
end

endmodule