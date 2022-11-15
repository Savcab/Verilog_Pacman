module pacman_movement (
	input clk,
	input reset,
	input ack,
	input bright,
	input button,
	input [15:0] score,
	input [9:0] hCount, vCount,
	input [479:0] maze [639:0],
	output reg [11:0] rgb,
);

output Qi, Ql, Qdiv, Qdf, Qdnf;

reg [7:0] M [0:15]; 
reg [7:0] X;
reg [7:0] state;
reg [7:0] Max;
reg [3:0] I;
 
localparam 
INI = 	8'b00000001,
STILL = 8'b00000010,
LEFT = 	8'b00000100, 
RIGHT = 8'b00001000,
UP =  	8'b00010000;
DOWN =  8'b00100000;
WIN =   8'b01000000;
LOSE =  8'b10000000;

         
assign {Qdnf, Qdf, Qdiv, Ql, Qi} = state;

always @(posedge clk, posedge reset) 

  begin  : CU_n_DU
    if (reset)
       begin
         state <= INI;
          I <= 4'bXXXX;
	      Max <= 8'bXXXXXXXX;
	      X <= 8'bXXXXXXXX;	   // to avoid recirculating mux controlled by Reset 
	    end
    else
       begin
         (* full_case, parallel_case *)
         case (state)
	        INI	: 
	          begin
		         // state transitions in the control unit
		         if (Start)
		           state <= LD_X;
		         // RTL operations in the DPU (Data Path Unit)            	              
		           Max <= 0;
		           I <= 0;
	          end
	        LD_X	:  // ** TODO **  complete RTL Operations and State Transitions
	          begin
		         // state transitions in the control unit
				 if (M[I] > Max) begin
					state <= DIV;
				 end
				 if (I == 15 && Max == 0 && M[I] <= Max) begin
					state <= D_NF;
				 end
				 if (I == 15 && Max != 0 && M[I] <= Max) begin
					state <= D_F;
				 end
		       // RTL operations in the Data Path
			   X <= M[I];
			   if (M[I] <= Max) begin
				I <= I+1;
			   end
 	          end
	        
	        DIV :  // ** TODO **  complete RTL Operations and State Transitions
	          begin
	          // state transitions in the control unit
			  if (I != 15 && X <= 7) begin
				state <= LD_X;
			  end
			  if (Max == 0 && I == 15 && X < 7) begin
				state <= D_NF;
			  end
			  if (I == 15 && ((X == 7) || ((X < 7) && (Max != 0)))) begin
				state <= D_F;
			  end   
	          // RTL operations in the Data Path
			   	X <= X - 3'b111;
				if (X == 3'b111) begin
					Max <= M[I];
				end
				if (X <= 3'b111) begin
					I <= I + 1'b1;
				end
	          end
	        
	        D_F	:
	          begin  
		         // state transitions in the control unit
		         if (Ack)
		           state <= INI;
		       end    
	        D_NF :
	          begin  
		         // state transitions in the control unit
		         if (Ack)
		           state <= INI;
		       end    
      endcase
    end 
  end 
endmodule  

