// The following `define` are only for convenience and to make the code more readable. 
`include "apb_defines.svh" // For macros

module APB_Master (
        //the followin signals are from the External System 
        //the system signals names will begin with letter S
        //note : we will act as the external system in the testbench
        input SWRITE,
        input [`APB_ADDR_WIDTH-1:0] SADDR, 
        input [`APB_DATA_WIDTH-1:0] SWDATA, 
        input [`APB_STRB_WIDTH-1:0] SSTRB,
        input [`APB_PROT_WIDTH-1:0] SPROT,
        input transfer,   //to indicate the beginning of the transfer

        //the followin signals are Master signals
        output reg PSEL, PENABLE, PWRITE,
        output reg [`APB_ADDR_WIDTH-1:0] PADDR,
        output reg [`APB_DATA_WIDTH-1:0] PWDATA,
        output reg [`APB_STRB_WIDTH-1:0] PSTRB,
        output reg [`APB_PROT_WIDTH-1:0] PPROT,
        input PCLK, PRESETn,
        input  PREADY,
        input PSLVERR
    );
    //defining our states
    localparam  IDLE = 2'b00,
                SETUP = 2'b01,
                ACCESS = 2'b10;
    (* fsm_encoding = "one_hot" *)
    reg [1:0] ns, cs ; //next state, current state

    //state memory 
    always @(posedge PCLK, negedge PRESETn)
    begin
        if(~PRESETn) 
            cs <= IDLE;
        else 
            cs <= ns;
    end

    //next state logic
    always @(*) begin
        case(cs)
            IDLE : begin
                if(transfer)
                    ns = SETUP;
                else
                    ns = IDLE;
            end
            SETUP : ns = ACCESS; //The bus only remains in the SETUP state for one clock cycle and always moves to the ACCESS state on the next rising edge of the clock
            ACCESS : begin
                if(PREADY && !transfer)
                    ns = IDLE;
                else if(PREADY && transfer)
                    ns = SETUP;
                else
                    ns = ACCESS;
            end
            default : ns = IDLE;
        endcase
    end

    //output logic
    always @(*) begin
        if(~PRESETn)
            begin
                PSEL = 0;
                PENABLE = 0;
                PWRITE = 0;
                PADDR = 0;
                PWDATA = 0;
                PSTRB = 0;
                PPROT = 0;
            end
        else begin
            case(cs)
                IDLE : begin
                    PSEL = 0;
                    PENABLE = 0;
                end
                SETUP : begin
                    PSEL = 1;
                    PENABLE = 0;   //signals are sent to slave in setup state
                    PWRITE = SWRITE;
                    PADDR = SADDR;
                    PWDATA = SWDATA;
                    PSTRB = SSTRB;
                    PPROT = SPROT;
                end
                ACCESS : begin
                    PSEL = 1;
                    PENABLE = 1;
                end
            endcase
        end
    end
endmodule