`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module tb;
    reg clock, reset, start, stop, porta, pause, mais, menos, potencia, sec_mod;
    reg  [6:0] min, sec;
    reg  [1:0] min_mod;
    reg  [2:0] presets;
    wire [2:0] potencia_rgb;
    wire done;
    wire [7:0] an, dec_cat;

    localparam PERIOD = 2;  

    ctrl_microondas DUT (.clock(clock),     .reset(reset), 
                         .start(start),     .pause(pause), 
                         .stop(stop),        
                         .an(an),           .dec_cat(dec_cat),
                         .porta(porta),     .mais(mais),
                         .menos(menos),     .potencia(potencia),
                         .sec_mod(sec_mod), .min_mod(min_mod),
                         .presets(presets), .potencia_rgb(potencia_rgb)
                         );

    initial begin
        clock <= 1'b0;
        porta <= 'd0;
        presets <= 'd0;
        min_mod <= 'd1;
        sec_mod <= 'd0;
        potencia <= 'd0;
        mais <= 0;
        menos <=0;
        forever #1 clock <= ~clock;
    end

    initial
    begin
        reset <= 1'b1;
        start <= 1'b0;
        stop <= 1'b0;
        pause <= 1'b0;
        min <= 7'd3;
        sec <= 7'd62;
        #127
        reset <= 0'b0;
        #184
        start <= 1'b1;
        #700
        start <= 1'b0;
        #3850
        start <= 1'b1;
        #700
        start <= 1'b0;
        #6850
        pause <= 1'b1;
        #850
        pause <= 1'b0;
        #1850
        pause <= 1'b1;
        #705
        pause <= 1'b0;
        #700
        // stop<= 'b1;
        // #850
        // stop<= 'b0;
        porta <= 'b1;
        #500
        start <= 'b1;
        #200
        start <= 'b0;
        #1250
        porta <= 'b0;
        #1250
        start <= 'b1;
        #850
        start <= 'b0;
        #850
        stop <= 'b1;
        #850
        stop <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        sec_mod <= 'b1;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        min_mod <= 'd2;
        
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        //min_mod <= 'd1;
        #850
        //menos <= 'b1;
        #850
        //menos <= 'b0;
        #850
        //menos <= 'b1;
        #850
        //menos <= 'b0;
        min_mod <= 'd1;
        #850
        //menos <= 'b1;
        #850
        //menos <= 'b0;
        min_mod <= 'd2;
        sec_mod <= 'b1;
        #850
        //menos <= 'b1;
        #850
        //menos <= 'b0;
        #850
        //menos <= 'b1;
        #850
        //menos <= 'b0;
        #850
        //menos <= 'b1;
        #850
        //menos <= 'b0;
        #850
        //menos <= 'b1;
        #850
        //menos <= 'b0;
        #850
        //menos <= 'b1;
        #850
        //menos <= 'b0;
        #850
        //menos <= 'b1;
        #850
        //menos <= 'b0;
        #850
        //start <= 'b1;
        #850
        start <= 'b0;
        //min_mod <= 'd2;
        #2000
        potencia <= 'd1;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        potencia <= 'b0;
        #850
        start <= 'b1;
        #850
        start <= 'b0;
        #8500
        pause <= 'b1;
        #850
        pause <= 'b0;
        #850
        porta <= 'b1;
        #850
        porta <= 'b0;
        #850
        porta <= 'b1;
        #850
        porta <= 'b0;
        #850
        porta <= 'b1;
        #850
        porta <= 'b0;
        #850
        pause <= 'b1;
        #850
        pause <= 'b0;
        #850
        stop <= 'b1;
        #850
        stop <= 'b0;
        #850
        presets <= 'd1;
        #1700
        presets <= 'd2;
        #1700
        presets <= 'd4;
        #1700
        presets <= 'd0;
        #850 
        sec_mod <= 'd1;
        min_mod <= 'd0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        sec_mod <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        sec_mod <= 'b1;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        mais <= 'b1;
        #850
        mais <= 'b0;
        min_mod <= 'b1;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        min_mod <= 'b1;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        min_mod <= 'b0;
        sec_mod <= 'b1;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        menos <= 'b1;
        #850
        menos <= 'b0;
        #850
        min_mod <= 'd2;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        min_mod <= 'b0;
        sec_mod <= 'b1;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850 
        mais <= 'b1;
        #850
        mais <= 'b0;
        #850
        porta <= 'b1;
        #850
        start <= 'b1;
        

        



    end
endmodule