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
    reg [1:0] EA;
    reg [5:0] count_sec;
    reg [6:0] count_min;
    reg [26:0] clock_count;
    reg ck1seg;
    wire done_int, stop_int, pause_int, start_int;
    //------------
    
    // Instanciação dos edge_detectors
    //------------
    edge_detector stop_left     (.clock(clock), .reset(reset), .din(stop), .rising(stop_int));
    edge_detector pause_center  (.clock(clock), .reset(reset), .din(pause), .rising(pause_int));
    edge_detector start_right   (.clock(clock), .reset(reset), .din(start), .rising(start_int));                            
    //------------

    // Divisor de clock para gerar o ck1seg
    always @(posedge clock or posedge reset)
    begin
        if(~reset) begin
            // if (EA == 2'b01)
            if (EA == 'd1) begin
                if (clock_count == HALF_MS_COUNT) begin
                    clock_count <= 'd0;
                    ck1seg <= ~ck1seg;
                end
                else begin
                    clock_count <= clock_count + 'd1;
                end
            end
        else
            ck1seg <= 0;
            clock_count <= 'd0;
        end
    end

    // Máquina de estados para determinar o estado atual (EA)
    always @(posedge clock or posedge reset)
    begin
        if(~reset)
            case (EA)
                'd0: begin 
                    if(start_int == 'b1) begin
                        EA <= 'd1;
                    end
                    else begin
                        EA <= EA;
                    end
                end

                'd1: begin 
                    if(pause_int == 'b1) begin
                        EA <= 'd2;
                    end
                    else if(stop_int == 'b1 | (count_sec & count_min) == 'd0) begin
                        EA <= 'd0;
                    end
                    else begin
                        EA <= EA;
                        end
                end
                    
                'd2: begin 
                    if(pause_int == 'b1 | start_int == 'b1) begin
                        EA <= 'd1;
                    end
                    else if (stop_int == 'b1) begin
                        EA <= 'd0;
                    end
                end
                default: EA <= 'd0;
            endcase

        else begin
            EA <= 'd0;
        end
    end

    // Decrementador de tempo (minutos e segundos)
    always @(posedge ck1seg or posedge reset)
    begin
        //------------
        // COMPLETAR
        //------------
    end


    // Instanciação da display 7seg
    //------------
    // COMPLETAR
    //------------
    
endmodule