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
  
  wire start_int, stop_int, pause_int, mais_int, menos_int;
  //sinais end
  //------------
  //------------
  //botoes begin
  edge_detector stop_left     (.clock(clock), .reset(reset), .din(stop),  .rising(stop_int));
  edge_detector pause_center  (.clock(clock), .reset(reset), .din(pause), .rising(pause_int));
  edge_detector start_right   (.clock(clock), .reset(reset), .din(start), .rising(start_int));                        
  edge_detector mais_up       (.clock(clock), .reset(reset), .din(mais),  .rising(mais_int));                        
  edge_detector menos_down    (.clock(clock), .reset(reset), .din(menos), .rising(menos_int));                        
  //botoes end
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
            end
            'd2: begin  //  modo pausado
                if(pause_int == 'd1 && porta == 'd0) begin
                  EA <= 'd1;
                end
            end
          endcase
      end
  end
  //Máquina de estados end
  //------------

  //------------
  //Controle begin
    always@(posedge clock or posedge reset) begin
        if(reset)begin
          min_int <= 0;
          sec_int <= 0;
        end else begin
          if(EA == 'd0)begin // estado config
            case(presets) //TODO: Adicionar potencia
                //------------
                //SEM PRESETS begin
                'd0:begin // caso nenhum preset esteja ativo
                  if(sec_mod == 'd0 && min_mod == 'd0)begin //se o modo de adiçao é unidade 
                    if(mais_int == 'd1)begin
                      sec_int <= sec_int + 'd1;
                      if(sec_int >= 'd60) begin
                        sec_int <= 'd0;
                        min_int <= min_int + 'd1;
                      end
                    end
                  end else if(sec_mod == 'd1 && min_mod == 'd0)begin //se o modo de adiçao é dezena de seg
                    if(mais_int == 'd1)begin
                      sec_int <= sec_int + 'd10;
                    end
                  end else if(min_mod == 'd1)begin // se o modo de adição for unidade de minuto
                    if(mais_int == 'd1)begin 
                      min_int <= min_int + 'd1;
                    end                
                  end  else if(min_mod == 'd2) begin  // se o modo de adição for dezena de minuto
                    if(mais_int == 'd1)begin 
                      min_int <= min_int + 'd10;
                    end
                  end 
                end
                //SEM PRESETS end
                //------------
                //------------
                // PRESET 1 begin
                'd1: begin //preset: Oppenheimer
                  sec_int <= 'd59;
                  min_int <= 'd99;
                  potencia_int <= 'd10;
                end
                // PRESET 1 END
                //------------
                //------------
                // PRESET 2 BEGIN
                'd2: begin 

                end
                // PRESET 2 END
                //------------
                //------------
                // PRESET 3 BEGIN
                'd2: begin 

                end
                // PRESET 3 END
                //------------


            endcase

          end
          if(EA == 'd1)begin // estado cozinhando
          
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