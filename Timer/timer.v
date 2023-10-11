module timer
(
  // Declaração das portas
  //------------
  // COMPLETAR
  //------------
);

    // Declaração dos sinais
    //------------
    // COMPLETAR
    //------------
    
    // Instanciação dos edge_detectors
    //------------
    // COMPLETAR
    //------------

    // Divisor de clock para gerar o ck1seg
    always @(posedge clock or posedge reset)
    begin
        //------------
        // COMPLETAR
        //------------
    end

    // Máquina de estados para determinar o estado atual (EA)
    always @(posedge clock or posedge reset)
    begin
        //------------
        // COMPLETAR
        //------------
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