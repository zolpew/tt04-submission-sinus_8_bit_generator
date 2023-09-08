module sinus_wave_generator_chazim_ITS_8 #( parameter MAX_COUNT = 10_000_000 ) (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset   
   
    );

    reg [3:0] state, next_state; 
    reg signed [7:0] xi, yi;  
    reg signed [7:0] xs, ys;
    reg signed [7:0] alpha,zs,zi;
    reg [3:0] iter = 4'b0110; 
    reg done;
    
   
    
    localparam IDLE = 4'b0001;
    localparam SHIFT = 4'b0010;
    localparam SIGMANEG_ADDER = 4'b0100;
    localparam ADDER = 4'b1000;
    localparam FINISH = 4'b1100; 
    
          
always@*
    begin   
    case(state)    
        IDLE:begin
             
            if(zi >= alpha)begin
             next_state = SIGMANEG_ADDER;
             end
             
            else begin
             next_state = ADDER;
             end
        end
             
        SHIFT:begin
            if (iter > 4'b0000)begin
                if(zi > alpha)begin
                 next_state = SIGMANEG_ADDER;
                 end
                 
                else begin
                 next_state = ADDER;
                 end
     
                end          
            else begin next_state = FINISH; end
        end
        
        SIGMANEG_ADDER:begin     
            next_state = SHIFT; 
            end            

        ADDER:begin            
            next_state = SHIFT;
            end                        
          
        FINISH:begin
            next_state = FINISH;                 
        end
        
        default: next_state = IDLE; 
        
    endcase
   end
    
        
        
always@(posedge clk or negedge rst_n)
    if(!rst_n)begin
        state <= IDLE;  
        xi <= ui_in[7:0];
        yi <= 8'b00000000; 
        alpha <= uio_in[7:0];
        zi <= 8'b00000000; 
        xs <= 8'b00000000;;
        ys <= 8'b00000000;;
        iter <= 4'b0110;
        
        end
           
    else 
        state <= next_state ;
        
            
always@(posedge clk) 
    begin    
    if(state == IDLE)begin
       
       
        xs <= xi;
        ys <= yi;
        
        
        end
    
      
    if(state == SHIFT)begin
        xs <= xi >> 4'b0110 - iter; 
        ys <= yi >> 4'b0110 - iter;
        end
        
     
     
    if(state == SIGMANEG_ADDER)begin
    
        
        xi <= xi + ys;
        yi <= yi - xs;
        zi <= zi - zs; 
        iter <= iter - 4'b0001;
                       
        
        end           
        
    if(state == ADDER)begin
    
        xi <= xi - ys;
        yi <= yi + xs;
        zi <= zi + zs; 
        iter <= iter - 4'b0001;
        
        end
        
    if(state == FINISH)begin
     
        xi <= ui_in[7:0];
        yi <= 8'b00000000; 
        alpha <= uio_in[7:0];
        zi = 8'b00000000; 
        xs <= xi;
        ys <= yi;
        end
     
        
 end
always @* begin
        case(iter)
            4'b0110:begin
                zs = 8'b00101101;//
                end     
            4'b0101:begin
            
                zs = 8'b00011010;//
                end
               
               
           
            4'b0010:begin
                zs = 8'b00001110;//14  
                end
                
                
                        
            4'b0011:begin
            
                zs = 8'b00000111;//7
                end
                
                
                
                   
            4'b0010:begin
                zs = 8'b00000011;//3
                end
                
              
            4'b0001:begin
            
                zs = 8'b00000001;//1
                end
                          
       endcase
         
end 
    
    
assign uo_out[7:0] =  yi;
assign uio_out[7:0] =  state;


endmodule     



       
        
           
    



