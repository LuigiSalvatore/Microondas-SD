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
  reg [6:0] min_int, sec_int;
  reg [2:0] potencia_rgb_int;
  integer incremento_sec, incremento_min;
  
  wire start_int, stop_int, pause_int, mais_int, menos_int, done_int, done_timer, pause_timer;
  assign done = done_int;
  assign potencia_rgb = potencia_rgb_int;
  assign pause_timer = pause_int || (porta == 'd1 && EA  == 'd1);
  
  
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
  //botoes end
  //------------
  //------------
  //Timer begin
  timer timer_int (.clock(clock), .reset(reset), .start(start_int), .stop(stop_int), .pause(pause_timer),
                   .min(min_int), .sec(sec_int), .done(done_timer), .an(an), .dec_cat(dec_cat));
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
            end
            'd1: begin  //  modo cozinhando
                if(pause_int == 'd1 || porta== 'd1) begin
                  EA <= 'd2;
                end
                if(stop_int ==  'd1) begin
                  EA <= 'd0;
                end
                if(done_int == 'd1) begin 
                  EA <= 'd0;
                  
                end
            end
            'd2: begin  //  modo pausado
                if((pause_int == 'd1 || start_int == 'd1) && porta == 'd0) begin
                  EA <= 'd1;
                end
            end
          endcase
      end
  end
  //Máquina de estados end
  //------------
    always@(posedge clock or posedge reset) begin
      if(reset)begin
          incremento_sec <= 'd0;
          incremento_min <= 'd0;
      end
      else begin
        case (min_mod) 
        'd0: begin
          incremento_min <= 'd0;
          if(sec_mod == 0 )
          incremento_sec <= 'd1;
          else
          incremento_sec <= 'd10;
        end
        'd1: begin
          incremento_min <= 'd1;
          incremento_sec <= 'd0;
        end
        'd4:begin
          incremento_min <= 'd1;
          incremento_sec <= 'd0;
        end
        default:begin 
          incremento_min <= 'd0;
          incremento_sec <= 'd0;
        end
        endcase
      end
        // end else begin
        //   if((sec_mod == 'd0 && min_mod == 'd0)||(min_mod == 'd1)) begin
        //     incremento <= 1;
        //   end else if((sec_mod == 'd1 && min_mod == 'd0)||min_mod =='d2) begin
        //     incremento <= 10;
          
        //   end
        // end
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
                  if (mais_int) begin
                    sec_int <= sec_int + incremento_sec;
                    min_int <= min_int + incremento_min;
                    if(sec_int > d59)begin //se passar de 59 segundos, add 1 minuto
                      sec_int <= sec_int % 60;
                      min_int <= min_int + 'd1;
                    end
                    else if (min_int >'d99)
                      min_int <= 'd99;
                  end
                  else if (menos_int) begin
                    sec_int <= sec_int - incremento_sec;
                    min_int <= min_int - incremento_min;
                  end
                  if(sec_int < d0)begin //se passar de 0 segundos, sub 1 minuto
                      sec_int <= d59;
                      min_int <= min_int - 'd1;
                  end
                    else if (min_int <='d0)
                      min_int <= 'd0;
                  end
                end
//
                    // if(sec_int >= 'd60)begin
                    //   sec_int <= sec_int % 60;
                    //   min_int <= min_int + 'd1;
                    // end
                    // if(sec_int >= 0 && incremento == 'd1 && min_int >= 'd1 && min_mod == 'd0 && (mais_int || menos_int))begin 
                    //   min_int <= min_int - 1;
                    //   sec_int <= 'd59;
                    // end else if(sec_int == 0 && incremento == 'd1 && min_int == 0 && (mais_int || menos_int))begin 
                    //   sec_int <= 'd0;
                    // end
                    // if(min_int <= 'd0 && incremento == 'd1) begin 
                    //   min_int <= 'd0;
                    // end else if (min_int >= 'd99)
/*
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
                        
                            if(sec_int == 'd0 && incremento == 'd1 && min_int >= 'd1) begin 
                                sec_int <= 'd59;
                                min_int <= min_int - 1;
                            end
                          if(sec_int <= 10 && incremento == 'd10 && min_int >= 'd1 )begin 
                            min_int <= min_int - 1;
                            sec_int <= 'd50 + sec_int;
                          end else if(sec_int <= 10 && incremento == 'd10 && min_int == 0)begin 
                            sec_int <= 'd0;
                          end
                        end
                    end
                    if(min_mod == 'd1 || min_mod == 'd2)begin 
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
                end
                  */
//   

                
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
                'd3: begin // pipoca doce
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
        end
    end
  //Controle end
  //------------




  

  //Instanciação do timer
  //timer timer_int (.clock(clock), .reset(reset), .start(start))
endmodule