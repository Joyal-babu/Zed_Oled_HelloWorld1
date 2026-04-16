`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.04.2026 12:04:50
// Design Name: 
// Module Name: zed_oled_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module zed_oled_top(
    input  clock,                             // global clock from board 100MHz
    input  reset,                             // global rest from board - push button BUTNC
    output oled_vdd,                          // Power Supply for Logic                    
    output oled_vbat,                         // Power Supply for DC/DC Converter Circuit  
    output oled_resetn,                       // Power Reset for Controller and Driver     
    output oled_data_comm,                    // Data/Command Control                      
    output oled_sclock,                       // spi clock                                 
    output oled_sdata                         // spi data                                  
    );
    
    localparam char_string = "Hello World";
    localparam string_len  = 11;
    
    reg [6:0]char_addr = 0;
    reg char_addr_vld  = 0;
    reg string_fin     = 0;
    reg [1:0]state     = 0;
    
    integer strng_cntr;
    
    wire load_rom_addr; 
    
    localparam idle     = 2'd0,
               rom_addr = 2'd1,
               done     = 2'd2;


    zed_oled_control zed_oled_control_inst1(
        .clock(clock),                             
        .reset(reset),                             
        .char_addr(char_addr),
        .char_addr_vld(char_addr_vld),
        .string_fin(),
        .load_rom_addr(load_rom_addr),
        .oled_vdd(oled_vdd),                          
        .oled_vbat(oled_vbat),                         
        .oled_resetn(oled_resetn),                       
        .oled_data_comm(oled_data_comm),                    
        .oled_sclock(oled_sclock),                       
        .oled_sdata(oled_sdata)                         
    );
    
    always @(posedge clock)
    begin
        if(reset)
        begin
            char_addr     <= 0;
            char_addr_vld <= 0;
            strng_cntr    <= string_len;
            state         <= idle;
            string_fin    <= 0;
        end
        else
        begin
            case(state)
                idle: begin
                    if(load_rom_addr)
                    begin
                        char_addr     <= char_string[((strng_cntr*8)-1)-:8];      // the rom contains the bitmap of each character maped as the ascii code as address
                        char_addr_vld <= 1;
                        state         <= rom_addr;
                        string_fin    <= 0;
                    end
                    else
                    begin
                        char_addr     <= 0;
                        char_addr_vld <= 0;
                        state         <= idle;
                        string_fin    <= 0;
                    end  
                end
                
                rom_addr: begin
                    if(!load_rom_addr)
                    begin
                        char_addr     <= char_addr;
                        char_addr_vld <= 0;
                        if(strng_cntr > 1)
                        begin
                            strng_cntr <= strng_cntr - 1;
                            state      <= idle;
                        end
                        else
                            state      <= done;
                    end
                    else
                    begin
                        state         <= rom_addr;
                        char_addr_vld <= 1;
                        char_addr     <= char_addr;
                        strng_cntr    <= strng_cntr;
                    end
                end
                
                done: begin
                    state      <= done;
                    string_fin <= 1;
                end 
                
            endcase
        end
    end
    
endmodule
