module timer
(
  // Declaração das portas
  //------------
    input start, stop, pause, clock, reset,
    input [6:0] min, sec,
    output done,
    output [7:0] an, dec_cat
    
  //------------
);
    //constantes 
    parameter HALF_MS_COUNT = 50_000_000;
    parameter LIMITESEC = 7'd60;
    parameter LIMITEMIN = 7'd100;
    // Declaração dos sinais
    //------------
    reg [1:0] EA, PE;
    wire [3:0] sec_u, sec_d, min_u, min_d;
    reg [6:0] count_sec;
    reg [6:0] count_min;
    reg [26:0] clock_count;
    reg ck1seg, done_int;
    wire  stop_int, pause_int, start_int;
    //------------
    
    // Instanciação dos edge_detectors
    //------------
    edge_detector stop_left     (.clock(clock), .reset(reset), .din(stop), .rising(stop_int));
    edge_detector pause_center  (.clock(clock), .reset(reset), .din(pause), .rising(pause_int));
    edge_detector start_right   (.clock(clock), .reset(reset), .din(start), .rising(start_int));                        
    //------------
    // initial begin
    //     // count_sec <='b11111;
    //     // count_min <='b111111;
    //     // clock_count <= 'd11111;
    //     EA <= 'd0;
    //     ck1seg <= 0;
    // end
    // Divisor de clock para gerar o ck1seg
    always @(posedge clock or posedge reset)
    begin
        if(reset) begin
            ck1seg <= 0;
            clock_count <= 0;
        end
        else begin
            if (clock_count == HALF_MS_COUNT) begin
                clock_count <= 'd0;
                ck1seg <= ~ck1seg;
            end else begin
                clock_count <= clock_count + 'd1;
            end
        end
        
        // //clock_count <= clock_count + 'd1;
        // if(~reset) begin
                 
        //        // clock_count <= clock_count + 1;
        
        // end else begin
        //     ck1seg <= 0;
        //     clock_count <= 0;
        // end
    end
    

    // Máquina de estados para determinar o estado atual (EA)
    always @(posedge clock or posedge reset)
    begin
        if(reset) begin
            EA <= 'd0;
            done_int<= 'd0;
        end else begin
            case (EA)
                'd0: begin //idle recebendo valores
                    if(start_int == 'b1) begin
                        EA <= 'd1;
                    end
                    
                end

                'd1: begin // decrementando tempo
                    done_int <= 'd0;
                    if(pause_int == 'b1) begin
                        EA <= 'd2;
                    end
                    else if(stop_int == 'b1 || (count_sec == 'd0 && count_min == 'd0)) begin
                        EA <= 'd0;
                        done_int<= 'd1;
                    end 
                end
                    
                'd2: begin //pausado
                    if(pause_int == 'b1 || start_int == 'b1) begin
                        EA <= 'd1;
                    end
                    else if (stop_int == 'b1) begin
                        EA <= 'd0;
                        done_int<= 'd1;
                    end
                end
                //default: EA <= 'd0;
            endcase

        end
    end

    // Decrementador de tempo (minutos e segundos)
    always @(posedge ck1seg or posedge reset)
    begin
        if(reset) begin
            count_sec <= 'd0;
            count_min <= 'd0;    
        end else begin
            if(EA == 'd0) begin
                count_sec <= sec;
                count_min <= min;
                if(min >= LIMITEMIN) begin
                    count_min <= 'd99;
                end else begin
                    count_min <= min;
                end
                if(sec >= LIMITESEC) begin
                    count_sec <= 'd59;
                end 
            end

            if (EA == 'd1) begin
                if(count_sec == 'd0 && count_min >= 'd1) begin
                    count_sec <= 'd59;
                    count_min <= count_min - 'd1;
                end else  begin
                    count_sec <= count_sec - 'd1;
                end
            end
        end
            
    end
    
    assign  done = done_int;
    // Instanciação da display 7seg
    //------------
    dspl_drv_NexysA7 display(.clock(clock), .reset(reset), .an(an), .dec_cat(dec_cat),  
                             .d1({1'b1, sec_u[3:0], 1'b0}), 
                             .d2({1'b1, sec_d[3:0], 1'b0}), 
                             .d3({1'b1, min_u[3:0], 1'b0}), 
                             .d4({1'b1, min_d[3:0], 1'b0}), 
                             .d5(6'b0), 
                             .d6(6'b0), 
                             .d7(6'b0), 
                             .d8(6'b0));
    //------------
    assign sec_u = count_sec % 10;
    assign sec_d = count_sec / 10;
    assign min_u = count_min % 10;
    assign min_d = count_min / 10;
    
    // assign sec_u = 'd1;
    // assign sec_d = 'd1;
    // assign min_u = 'd1;
    // assign min_d = 'd1;
    
endmodule