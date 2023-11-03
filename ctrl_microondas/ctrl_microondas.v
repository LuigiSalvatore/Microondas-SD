module ctrl_microondas
( 
  input clock, reset,
  input start, stop, pause, porta, mais, menos, potencia, sec_mod,
  input [1:0] min_mod,
  input [2:0] presets,

  
  output [2:0] potencia_rgb,
  output[7:0] an, dec_cat
  
);
  
	//------------
  //sinais begin
  reg [1:0] EA, potencia_int;
  reg [6:0] min_int, sec_int,potencia_out;
  reg [2:0] potencia_rgb_int;
  integer incremento;
  
  wire [7:0] dec_cat_timer, pot_cat;

  wire start_int, stop_int, pause_int, mais_int, menos_int, done_int, done_timer, pause_timer, preset_neg, preset_edge;
  assign done = done_int;
  assign potencia_rgb = potencia_rgb_int;
  
  assign preset_neg = (presets == 'd0) ? 'b1 : 'b0;
  assign dec_cat = (an[5] =='b0)? pot_cat:
                    dec_cat_timer;
  assign pot_cat = (potencia_int == 'd1) ? 8'b11101111 :
                   (potencia_int == 'd2) ? 8'b11111101 :
                   (potencia_int == 'd3) ? 8'b01111111 :
                   'b11111111;
    
  assign pause_timer = (pause_int && EA == 'd1) || (porta == 'd1 && (EA  == 'd1))||(pause_int && porta =='d0 && EA == 'd2);
  
  
  always@(posedge clock or posedge reset) begin 
    if(reset)begin 
        potencia_rgb_int<= 'b000;
    end else begin
        if(potencia_int == 'd1 && EA == 'd1)begin 
          potencia_rgb_int <= 'b001;
        end
        if(potencia_int == 'd2 && EA == 'd1)begin 
          potencia_rgb_int <= 'b010;
        end
        if(potencia_int == 'd3 && EA == 'd1)begin 
          potencia_rgb_int <= 'b100;
        end
        if(EA == 'd0 || EA == 'd2)begin 
          potencia_rgb_int <= 'b000;
        end
    end
  end
  //sinais end
  //------------
  //------------
  //botoes begin
  edge_detector stop_left     (.clock(clock), .reset(reset), .din(stop),  .rising(stop_int));
  edge_detector pause_center  (.clock(clock), .reset(reset), .din(pause), .rising(pause_int));
  edge_detector start_right   (.clock(clock), .reset(reset), .din(start), .rising(start_int));                        
  edge_detector mais_up       (.clock(clock), .reset(reset), .din(mais),  .rising(mais_int));                        
  edge_detector menos_down    (.clock(clock), .reset(reset), .din(menos), .rising(menos_int));
  edge_detector_no_count timer_done    (.clock(clock), .reset(reset), .din(done_timer), .rising(done_int));
  edge_detector_no_count preset_detect    (.clock(clock), .reset(reset), .din(preset_neg), .rising(preset_edge));
  //botoes end
  //------------
  //------------
  //Timer begin
  timer timer_int (.clock(clock), .reset(reset), .start(start_int && porta == 'd0), .stop(stop_int), .pause(pause_timer ),
                   .min(min_int), .sec(sec_int), .done(done_timer), .an(an), .dec_cat(dec_cat_timer));
  //Timer end
  //------------
  //------------
  //Máquina de estados begin
  always@(posedge clock or posedge reset) begin
      if(reset) begin
          EA <= 'd0;
      end else begin
          case(EA)
            'd0: begin  //  modo config
                if(start_int == 'd1 && porta == 'd0) begin
                  EA <= 'd1;
                end
                if(preset_edge == 'd1) begin
                  EA <= 'd3;
                end
            end
            'd1: begin  //  modo cozinhando
                if(pause_int == 'd1 || porta== 'd1) begin
                  EA <= 'd2;
                end
                if(stop_int ==  'd1) begin
                  EA <= 'd3;
                end
                if(done_int == 'd1) begin 
                  EA <= 'd3;
                end
                if(sec_int == 'd0 && min_int == 'd0) begin
                  EA <= 'd0;
                end
            end
            'd2: begin  //  modo pausado
                if((pause_int == 'd1 || start_int == 'd1) && porta == 'd0) begin
                  EA <= 'd1;
                end
                if(stop_int == 'd1)begin 
                EA <= 'd3;
                end
            end
            'd3: begin
                EA <= 'd0;
            end
          endcase
      end
  end
  //Máquina de estados end
  //------------
    always@(posedge clock or posedge reset) begin
      if(reset)begin
          incremento <= 0;
          
        end else begin

          
          if((sec_mod == 'd0 && min_mod == 'd0)||(min_mod == 'd1)) begin
            incremento <= 1;
          end else if((sec_mod == 'd1 && min_mod == 'd0)||(min_mod >='d2)) begin
            incremento <= 10;
          
          end
        end
    end
  //------------
  //Controle begin
    always@(posedge clock or posedge reset) begin
        if(reset)begin
          min_int <= 0;
          sec_int <= 0;
          //incremento <= 0;
          // mais_int <= 0;
          // menos_int <= 0;
          potencia_int <= 2;
        end else begin
          if(EA == 'd0)begin // estado config
            case(presets)
                //------------
                //SEM PRESETS begin
                'd0:begin // caso nenhum preset esteja ativo
                  if(potencia == 'd0)begin //mexendo no tempo
                   if(min_int > 99) begin 
                        min_int <= 'd99;
                      end 
                    if(min_mod == 'd0) begin //adicionando segundos
                       if(mais_int == 'd1) begin
                         sec_int <= sec_int + incremento;
                         if(sec_int == 'd59 && incremento == 'd1)begin
                            sec_int <= 'd0;
                            min_int <= min_int + 'd1;
                         end
                         if(sec_int >= 'd50 && incremento == 'd10)begin
                            sec_int <= sec_int % 50;
                            min_int <= min_int + 'd1;
                         end
                       end

                       if(menos_int == 'd1)begin 
                         sec_int <= sec_int - incremento;
                        
                          if(sec_int =='d0 && incremento == 'd1 && min_int == 'd0) begin
                              sec_int <= 'd0;
                          end
                          if(sec_int == 'd0 && incremento == 'd1 && min_int >= 'd1) begin 
                              sec_int <= 'd59;
                              min_int <= min_int - 1;
                          end
                          if(sec_int <= 9 && incremento == 'd10 && min_int >= 'd1 )begin 
                            min_int <= min_int - 1;
                            sec_int <= 'd50 + sec_int;
                          end else if(sec_int <= 10 && incremento == 'd10 && min_int == 0)begin 
                            sec_int <= 'd0;
                          end
                        end
                    end
                    if(min_mod == 'd1 || min_mod == 'd2 || min_mod == 'd3)begin
                      
                      if(mais_int == 'd1) begin
                          min_int <= min_int + incremento;
                      end
                      if(menos_int == 'd1)begin 
                          min_int <= min_int - incremento;
                            if(min_int <= 'd10 && incremento == 'd10)begin 
                              min_int <= 'd0;
                            end else if( min_int <= 'd1 && incremento == 'd1)begin 
                              min_int <= 'd0;
                            end
                      end
                    end    
                  end else if(potencia == 'd1) begin // mexendo na potencia
                    
                    if(mais_int == 'd1 && potencia_int <= 2)begin
                      potencia_int <= potencia_int + 'd1;
                    end
                    if (menos_int == 'd1 && potencia_int >= 2) begin
                      potencia_int <= potencia_int - 'd1;
                    end
                  end
                end  
                    

                
                //SEM PRESETS end
                //------------
                //------------
                // PRESET 1 begin
                'd1: begin // morte lenta
                  min_int <= 'd99;
                  sec_int <= 'd30;
                  potencia_int <= 'd1;

                end
                // PRESET 1 END
                //------------
                //------------
                // PRESET 2 BEGIN
                'd2: begin //bife suculento
                  min_int <= 'd3;
                  sec_int <= 'd30;
                  potencia_int <= 'd2;

                end
                // PRESET 2 END
                //------------
                //------------
                // PRESET 3 BEGIN
                'd4: begin // pipoca doce
                  min_int <= 'd1;
                  sec_int <= 'd15;
                  potencia_int <= 'd3;

                end
                // PRESET 3 END
                //------------


            endcase

          end
          if(EA == 'd1)begin // estado cozinhando
              if(done_int=='d1)begin 
                sec_int <= 0;
                min_int <= 0;
              end
          end
          if(EA == 'd2)begin // estado pausado

          end
          if(EA == 'd3) begin
                sec_int <= 0;
                min_int <= 0;
          end
        end
    end
  //Controle end
  //------------




  

  //Instanciação do timer
  //timer timer_int (.clock(clock), .reset(reset), .start(start))
endmodule