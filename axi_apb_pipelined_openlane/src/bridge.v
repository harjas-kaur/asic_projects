`timescale 1ns / 1ps

module bridge(
input clk, arvalid, res_n,
input [1:0] arburst,
input [3:0] arlen,
input [4:0] araddr,
output arready,
output reg [15:0] rdata,
output rresp, rlast,
input rready,
output rvalid,

input awvalid,
input [4:0] awaddr,
output awready,
input [3:0] awlen,
input [1:0] awburst,

input wvalid,
input [15:0] wdata,
output wready,
input wlast,

input bready,
output bvalid,
output bresp,

output [2:0] PADDR,
output reg [15:0] PWDATA,
input [15:0] PRDATA,
output PWRITE, PENABLE, PSEL1, PSEL2, PSEL3, PSEL4,
input PREADY
);

parameter IDLE = 4'b0000,
          SETUP_M = 4'b0001,
          SETUP_S = 4'b0010,
          ACCESS_S = 4'b0011,
          PREACCESS_M = 4'b0100,
          ACCESS_M = 4'b0101,
          WSETUP_M = 4'b0110,
          WPREACCESS_M = 4'b0111,
          WACCESS_M = 4'b1000,
          WTERMINATE = 4'b1001,
          WSETUP_S = 4'b1010,
          WACCESS_S = 4'b1011;

reg [3:0] current_state, next_state;

reg [1:0] DWREQ, DWREQ_next;
reg [12:0] burst, burst_next;
reg [4:0] addr, addr_next;
reg last, last_next;

reg [3:0] lenS, lenM;
reg [3:0] lenS_next, lenM_next;

reg [2:0] DADDR, DADDR_next;

integer i, i_next;

// ======================================================
// PIPELINE REGISTERS
// ======================================================

reg [4:0] awaddr_pipe;
reg [4:0] araddr_pipe;

reg awvalid_pipe;
reg arvalid_pipe;

reg [15:0] wdata_pipe;
reg wvalid_pipe;

reg [1:0] awburst_pipe;
reg [1:0] arburst_pipe;

reg [3:0] awlen_pipe;
reg [3:0] arlen_pipe;

// ======================================================
// INPUT PIPELINE STAGE
// ======================================================

always @(posedge clk or negedge res_n)
begin
    if(!res_n)
    begin
        awaddr_pipe <= 0;
        araddr_pipe <= 0;

        awvalid_pipe <= 0;
        arvalid_pipe <= 0;

        wdata_pipe <= 0;
        wvalid_pipe <= 0;

        awburst_pipe <= 0;
        arburst_pipe <= 0;

        awlen_pipe <= 0;
        arlen_pipe <= 0;
    end
    else
    begin
        awaddr_pipe <= awaddr;
        araddr_pipe <= araddr;

        awvalid_pipe <= awvalid;
        arvalid_pipe <= arvalid;

        wdata_pipe <= wdata;
        wvalid_pipe <= wvalid;

        awburst_pipe <= awburst;
        arburst_pipe <= arburst;

        awlen_pipe <= awlen;
        arlen_pipe <= arlen;
    end
end

// ======================================================
// STATE REGISTER
// ======================================================

always @(posedge clk or negedge res_n)
begin
    if(!res_n)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

// ======================================================
// DATA / CONTROL REGISTERS
// ======================================================

always @(posedge clk or negedge res_n)
begin
    if(!res_n)
    begin
        lenS <= 0;
        lenM <= 0;
        DADDR <= 0;
        i <= 0;

        addr <= 0;
        burst <= 0;
        DWREQ <= 0;
        last <= 0;
    end
    else
    begin
        lenS <= lenS_next;
        lenM <= lenM_next;
        DADDR <= DADDR_next;
        i <= i_next;

        addr <= addr_next;
        burst <= burst_next;
        DWREQ <= DWREQ_next;
        last <= last_next;
    end
end

// ======================================================
// NEXT STATE / COMBINATIONAL LOGIC
// ======================================================

always @(*)
begin

    next_state = current_state;

    lenS_next = lenS;
    lenM_next = lenM;
    DADDR_next = DADDR;
    i_next = i;

    addr_next = addr;
    burst_next = burst;
    DWREQ_next = DWREQ;
    last_next = last;

    PWDATA = 0;
    rdata = 0;

    case(current_state)

    // ==================================================
    // IDLE
    // ==================================================

    IDLE :
    begin

        DWREQ_next = 0;
        last_next = 0;

        if(arvalid_pipe)
        begin
            next_state = SETUP_M;
            DWREQ_next = 2'b01;
        end

        else if(awvalid_pipe)
        begin
            next_state = WSETUP_M;
        end

        else
            next_state = IDLE;
    end

    // ==================================================
    // WRITE MASTER SETUP
    // ==================================================

    WSETUP_M :
    begin

        if(awvalid_pipe)
        begin

            addr_next = awaddr_pipe;
            burst_next = awburst_pipe;

            lenS_next = awlen_pipe + 1;
            lenM_next = awlen_pipe + 1;

            DADDR_next = awaddr_pipe % 8;

            next_state = WPREACCESS_M;

        end
        else
            next_state = IDLE;
    end

    // ==================================================
    // WAIT FOR WVALID
    // ==================================================

    WPREACCESS_M :
    begin

        if(wvalid_pipe)
            next_state = WACCESS_M;
        else
            next_state = WPREACCESS_M;

    end

    // ==================================================
    // WRITE ACCESS MASTER
    // ==================================================

    WACCESS_M :
    begin

        if(lenM != 0)
        begin

            case(burst)

                2'b00 :
                    i_next = i;

                2'b01 :
                    i_next = i + 1;

                default :
                    i_next = i;

            endcase

            lenM_next = lenM - 1;

            if(wlast)
                next_state = WTERMINATE;
            else
                next_state = WPREACCESS_M;

        end
        else
            next_state = WTERMINATE;

    end

    // ==================================================
    // WRITE TERMINATE
    // ==================================================

    WTERMINATE :
    begin

        if(bready)
        begin
            DWREQ_next = 2'b11;
            next_state = WSETUP_S;
        end
        else
            next_state = WTERMINATE;

    end

    // ==================================================
    // WRITE SETUP SLAVE
    // ==================================================

    WSETUP_S :
    begin
        next_state = WACCESS_S;
    end

    // ==================================================
    // WRITE ACCESS SLAVE
    // ==================================================

    WACCESS_S :
    begin

        if(PREADY)
        begin

            if(lenS != 0)
            begin

                if(lenS == 1)
                    next_state = IDLE;
                else
                    next_state = WSETUP_S;

                i_next = i - 1;

                DADDR_next = DADDR + 1;

                lenS_next = lenS - 1;

            end
        end
        else
            next_state = IDLE;

    end

    // ==================================================
    // READ MASTER SETUP
    // ==================================================

    SETUP_M :
    begin

        if(arvalid_pipe)
        begin

            addr_next = araddr_pipe;
            burst_next = arburst_pipe;

            lenS_next = arlen_pipe;
            lenM_next = arlen_pipe + 1;

            DADDR_next = araddr_pipe % 8;

            next_state = SETUP_S;

        end
        else
            next_state = IDLE;

    end

    // ==================================================
    // READ SLAVE SETUP
    // ==================================================

    SETUP_S :
    begin

        if(PREADY)
            next_state = ACCESS_S;
        else
            next_state = SETUP_S;

    end

    // ==================================================
    // READ ACCESS SLAVE
    // ==================================================

    ACCESS_S :
    begin

        if(lenS != 0)
        begin

            case(burst)

                2'b00 :
                    DADDR_next = DADDR;

                2'b01 :
                    DADDR_next = DADDR + 1;

                default :
                    DADDR_next = DADDR;

            endcase

            lenS_next = lenS - 1;

            i_next = i + 1;

            next_state = SETUP_S;

        end
        else
            next_state = PREACCESS_M;

    end

    // ==================================================
    // PRE ACCESS MASTER
    // ==================================================

    PREACCESS_M :
    begin

        if(rready)
            next_state = ACCESS_M;
        else
            next_state = PREACCESS_M;

    end

    // ==================================================
    // ACCESS MASTER
    // ==================================================

    ACCESS_M :
    begin

        if(lenM != 0)
        begin

            if(lenM == 1)
            begin
                last_next = 1;
                next_state = IDLE;
            end
            else
                next_state = PREACCESS_M;

            i_next = i - 1;

            lenM_next = lenM - 1;

        end
        else
            next_state = IDLE;

    end

    default :
        next_state = IDLE;

    endcase
end

// ======================================================
// OUTPUT LOGIC
// ======================================================

assign arready = (current_state == SETUP_M);

assign PADDR = DWREQ[0] ? DADDR : 3'd0;

assign PSEL1 =
(current_state == SETUP_M ||
 current_state == SETUP_S ||
 current_state == ACCESS_S ||
 current_state == WSETUP_S ||
 current_state == WACCESS_S)
?
((addr >= 5'b00000 && addr <= 5'b00111) ? 1'b1 : 1'b0)
: 1'b0;

assign PSEL2 =
(current_state == SETUP_M ||
 current_state == SETUP_S ||
 current_state == ACCESS_S ||
 current_state == WSETUP_S ||
 current_state == WACCESS_S)
?
((addr >= 5'b01000 && addr <= 5'b01111) ? 1'b1 : 1'b0)
: 1'b0;

assign PSEL3 =
(current_state == SETUP_M ||
 current_state == SETUP_S ||
 current_state == ACCESS_S ||
 current_state == WSETUP_S ||
 current_state == WACCESS_S)
?
((addr >= 5'b10000 && addr <= 5'b10111) ? 1'b1 : 1'b0)
: 1'b0;

assign PSEL4 =
(current_state == SETUP_M ||
 current_state == SETUP_S ||
 current_state == ACCESS_S ||
 current_state == WSETUP_S ||
 current_state == WACCESS_S)
?
((addr >= 5'b11000 && addr <= 5'b11111) ? 1'b1 : 1'b0)
: 1'b0;

assign PWRITE = (DWREQ[1] && (PSEL1 || PSEL2 || PSEL3 || PSEL4));

assign PENABLE =
(current_state == SETUP_S ||
 current_state == ACCESS_S ||
 current_state == WACCESS_S);

assign rresp = (current_state == ACCESS_M);

assign rlast = (rresp && last);

assign rvalid = (current_state == ACCESS_M);

assign awready = (current_state == WSETUP_M);

assign wready = (current_state == WACCESS_M);

assign bvalid = (current_state == WTERMINATE);

assign bresp = (current_state == WTERMINATE);

endmodule