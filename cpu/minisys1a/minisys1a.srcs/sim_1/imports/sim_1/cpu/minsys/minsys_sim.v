
module minsys_sim();

    reg rst;
    reg board_clk;
    
    initial begin
        forever begin
            #5
            board_clk = ~board_clk;
        end
    end
    
    
    reg[23:0] switches_in;
    reg[4:0] buttons_in;
    reg[3:0] keyboard_cols_in;
    wire[7:0] led_rld_out;
    wire[7:0] led_yld_out;
    wire[7:0] led_gld_out;
    reg start_S3;
    reg rx;
    reg tx;
    
    system my_minisys(
        .board_rst                (rst),
        .board_clk          (board_clk),
        .switches_in        (switches_in),
        .buttons_in         (buttons_in),
        .keyboard_cols_in   (keyboard_cols_in),
        .led_RLD_out        (led_rld_out),
        .led_YLD_out        (led_yld_out),
        .led_GLD_out        (led_gld_out),
        .rx                 (rx)
        // .pc_out             (pc),
        // .clk_debug          (clk_out),
        // .ins_out            (ins),
        // .bus_bug_addr       (bus_addr),
        // .bus_bug_read_data  (bus_read_data),
        // .bus_bug_write_data (bus_write_data),
        // .mem_addr_debug_out (mem_addr_debug_out),
        // .dataA              (dataA),
        // .dataB              (dataB)
    );
    
    
    initial begin
        assign switches_in = {24'h123456};
        assign buttons_in = {5'b00000};
        assign keyboard_cols_in = {4'h0};
        assign start_S3 = 0;
        assign rx = 0;
        assign tx = 0;
        rst <= 1'b1;
        board_clk <= 1'b0;
        #1000
        rst <= 1'b0;
    end 

endmodule