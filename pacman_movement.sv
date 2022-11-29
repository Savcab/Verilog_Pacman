module pacman_movement (
	input clk,
	input reset,
	input ack,
	input start,
	input bright,
	input Left,
	input Right,
	input Up,
	input Down,
	input [15:0] score,
	input [9:0] hCount, vCount,
	input win,
	input lose,
	output pacmanFill,
	output reg [49:0] counter
);


reg [7:0] state;
reg [9:0] pacX, pacY;
 
localparam 
INI = 	8'b00000001,
STILL = 8'b00000010,
LEFT = 	8'b00000100, 
RIGHT = 8'b00001000,
UP =  	8'b00010000,
DOWN =  8'b00100000,
WIN =   8'b01000000,
LOSE =  8'b10000000;

localparam
XOFFSET = 24,
YOFFSET = 130;

localparam
xLowerBound = 0,
xUpperBound = 640,
yLowerBound = 0,
yUpperBound = 480,
speed = 1,
winningScore = 30,
pixelSize = 20,
xIni = 300,
yIni = 300;

// Local wires for simplicity
wire leftCtrl, upCtrl, rightCtrl, downCtrl, cgLeft, cgUp, cgRight, cgDown;
assign leftCtrl = (Left && ~Up && ~Right && ~Down);
assign upCtrl = (~Left && Up && ~Right && ~Down);
assign rightCtrl = (~Left && ~Up && Right && ~Down);
assign downCtrl = (~Left && ~Up && ~Right && Down);
assign noCtrl = (~leftCtrl && ~upCtrl && ~rightCtrl && ~downCtrl);
// 	cg stands for can go
//	intersection[i][j] is treated as {left, up, right, down}
// assign cgLeft = (intersection[pacY + YOFFSET][pacX + XOFFSET][0] == 1);
// assign cgUp = (intersection[pacY + YOFFSET][pacX + XOFFSET][1] == 1);
// assign cgRight = (intersection[pacY + YOFFSET][pacX + XOFFSET][2] == 1);
// assign cgDown = (intersection[pacY + YOFFSET][pacX + XOFFSET][3] == 1);

// assign cgLeft = (pacX - pixelSize > xLowerBound && maze[pacY][pacX-pixelSize] != 1);
// assign cgUp = (pacY - pixelSize > yLowerBound && maze[pacY-pixelSize][pacX] != 1);
// assign cgRight = (pacX + pixelSize < xUpperBound && maze[pacY][pacX+pixelSize] != 1);
// assign cgDown = (pacY + pixelSize < yUpperBound && maze[pacY+pixelSize][pacX] != 1);
reg [3:0] cgDirections;
assign {cgLeft, cgUp, cgRight, cgDown} = cgDirections;
// reg[49:0] counter;

//	for coloring pacman
assign pacmanFill = ((hCount <= pacX+(pixelSize/2)) && (hCount >= pacX-(pixelSize/2)+1)) 
						&& ((vCount <= pacY+(pixelSize/2)) && (vCount >= pacY-(pixelSize/2)+1));
// directionFill is the pixel right above that direction on pacman
// assign leftFill = (hCount == pacX-(pixelSize/2)) && (vCount <= pacY+(pixelSize/2)) && (vCount >= pacY-(pixelSize/2) + 1);
// assign upFill = (hCount <= pacX+(pixelSize/2)) && (hCount >= pacX-(pixelSize/2) + 1) && (vCount == pacY-(pixelSize/2));
// assign rightFill = (hCount == pacX+(pixelSize/2) + 1) && (vCount <= pacY+(pixelSize/2)) && (vCount >= pacY-(pixelSize/2) + 1);
// assign downFill = (hCount <= pacX+(pixelSize/2)) && (hCount >= pacX-(pixelSize/2) + 1) && (vCount == pacY+(pixelSize/2)+1);

// initial begin
// 	cgDirections <= 4'b1111;
// 	state <= INI;
// end
reg pulse1, pulse2, pulse3, pulse4;
// reg pulse5, pulse6, pulse7, pulse8, pulse9, pulse10, pulse11, pulse12;

initial begin
	pacX = xIni;
	pacY = yIni;
	counter = 50'd0;
	state = INI;
	pulse1 = 0;
	pulse2 = 0;
	pulse3 = 0;
	pulse4 = 0;
end

// always@ (posedge clk) begin
// 	counter <= counter + 50'b1;
// 	if (counter >= 50'd500000) begin
// 		case (state)
// 			INI:
// 				begin
// 					// state transition
// 					if (leftCtrl)
// 						state <= LEFT;
// 					else if (rightCtrl)
// 						state <= RIGHT;
// 					else if (upCtrl)
// 						state <= UP;
// 					else if (downCtrl) begin
// 						state <= DOWN;
// 					end 
// 					// else 
// 				end
// 			LEFT:
// 				begin
// 					// state transition
// 					if (rightCtrl)
// 						state <= RIGHT;
// 					else if (upCtrl)
// 						state <= UP;
// 					else if (downCtrl) begin
// 						state <= DOWN;
// 					end
// 					// else 
// 					if (noCtrl) begin
// 						pacX <= pacX - 1;
// 					end
// 				end
// 			UP:
// 				begin
// 					if (rightCtrl)
// 						state <= RIGHT;
// 					else if (leftCtrl)
// 						state <= LEFT;
// 					else if (downCtrl) begin
// 						state <= DOWN;
// 					end
// 					// else 
// 					if (noCtrl) begin
// 						pacY <= pacY - 1;
// 					end
// 				end
// 			RIGHT:
// 				begin
// 					if (upCtrl)
// 						state <= UP;
// 					else if (leftCtrl)
// 						state <= LEFT;
// 					else if (downCtrl) begin
// 						state <= DOWN;
// 					end
// 					// else
// 					if (noCtrl) begin
// 						pacX <= pacX + 10'd1;
// 					end
// 				end
// 			DOWN:
// 				begin
// 					if (upCtrl)
// 						state <= UP;
// 					else if (leftCtrl)
// 						state <= LEFT;
// 					else if (rightCtrl) begin
// 						state <= RIGHT;
// 					end
// 					// else
// 					if (noCtrl) begin
// 						pacY <= pacY + 10'd1;
// 					end
// 				end
// 		endcase

// 		// 34 + 24 + 432 + 24 + 44
// 		// start bit 35 (legal 0), end bit 515 (legal 480)
// 		if (pacY >= 10'd490) begin
// 			pacY = 58;
// 		end

// 		// 143 + 130 + 380 + 130 + 160
// 		// start bit 144 (legal 0), end bit 783 (legal 640)
// 		if (pacX >= 10'd663) begin
// 			pacX = 273;
// 		end

// 		counter = 50'd0;
// 	end
// end


always@ (posedge clk) begin
	pulse1 = ~pulse1;
end
always@ (posedge pulse1) begin
	pulse2 = ~pulse2;
end
always@ (posedge pulse2) begin
	pulse3 = ~pulse3;
end
always@ (posedge pulse3) begin
	pulse4 = ~pulse4;
end
always@ (posedge pulse4) begin
	// counter <= counter + 50'b1;
end


always@ (posedge clk) begin
	counter <= counter + 50'b1;
	if (counter >= 50'd10000) begin
		if (leftCtrl) begin
			pacX = pacX - 10'd1;
		end else if (rightCtrl) begin
			pacX = pacX + 10'd1;
		end else if (upCtrl) begin
			pacY = pacY - 10'd1;
		end else if (downCtrl) begin
			pacY = pacY + 10'd1;
		end else begin end
		
		// 34 + 24 + 432 + 24 + 44
		// start bit 35 (legal 0), end bit 515 (legal 480)
		if (pacY <= 10'd58) begin
			pacY = 58;
		end

		if (pacY >= 10'd490) begin
			pacY = 490;
		end

		// 143 + 130 + 380 + 130 + 160
		// start bit 144 (legal 0), end bit 783 (legal 640)
		if (pacX <= 10'd273) begin
			pacX = 273;
		end

		if (pacX >= 10'd663) begin
			pacX = 663;
		end

		counter = 50'd0;
	end
end
// // for detect if can go a certain direction
// 	always@ (posedge clk) begin
// 		counter <= counter + 50'b1;
// 		// if (leftFill && wallFill) 
// 		// 	cgLeft <= 0;
// 		// else if (upFill && wallFill)
// 		// 	cgUp <= 0;
// 		// else if (rightFill && wallFill)
// 		// 	cgRight <= 0;
// 		// else if (downFill && wallFill)
// 		// 	cgDown <= 0;
		
// 		if (counter >= 50'd5000) begin
// 			cgDirections = 4'b1111;
// 			counter = 50'd0;

// 			if (state == STILL || state == LEFT || state == UP || state == RIGHT || state == DOWN) begin
// 				if (leftCtrl && cgLeft)
// 					state <= LEFT;
// 				else if (upCtrl && cgUp)
// 					state <= UP;
// 				else if (rightCtrl && cgRight)
// 					state <= RIGHT;
// 				else if (downCtrl && cgDown)
// 					state <= DOWN;
// 				if (win)
// 					state <= WIN;
// 				if (lose)
// 					state <= LOSE;
// 			end
// 			case (state)
// 				INI:
// 				begin
// 					// state transition
// 					if (start)
// 						state <= STILL;
// 					// RTL operations
// 					pacX <= xIni;
// 					pacY <= yIni;
// 				end
// 				STILL:
// 					begin
// 					end
// 				LEFT:
// 					begin
// 						if (~cgLeft)
// 							state <= STILL;
// 						pacX <= pacX - speed;
// 					end
// 				UP:
// 					begin
// 						if (~cgUp)
// 							state <= STILL;
// 						pacY <= pacY - speed;
						
// 					end

// 				RIGHT:
// 					begin
// 						if (~cgRight)
// 							state <= STILL;
// 						pacX <= pacX + speed;
// 					end
// 				DOWN:
// 					begin
// 						if (~cgDown)
// 							state <= STILL;
// 						pacY <= pacY + speed;
// 					end
// 				WIN:
// 					begin
// 						if (ack)
// 							state <= INI;
// 					end
// 				LOSE:
// 					begin
// 						if(ack)
// 							state <= INI;
// 					end

// 			endcase


// 		end
// 	end


// movement state machine
always @(posedge clk, posedge reset) 
begin
	if (reset)
		begin
			state <= INI;
		end
	// else 
	// 	begin
	// 	if (state == STILL || state == LEFT || state == UP || state == RIGHT || state == DOWN) begin
	// 		if (leftCtrl && cgLeft)
	// 			state <= LEFT;
	// 		else if (upCtrl && cgUp)
	// 			state <= UP;
	// 		else if (rightCtrl && cgRight)
	// 			state <= RIGHT;
	// 		else if (downCtrl && cgDown)
	// 			state <= DOWN;
	// 		else
	// 			state <= STILL;
	// 		if (win)
	// 			state <= WIN;
	// 		if (lose)
	// 			state <= LOSE;
	// 	end
	// 	case (state)
	// 		INI:
	//           begin
	// 	         // state transition
	// 	         if (start)
	// 	           state <= STILL;
	// 	         // RTL operations
	// 			 pacX <= xIni;
	// 			 pacY <= yIni;
	//           end
	// 		STILL:
	// 			begin
	// 			end
	// 		LEFT:
	// 			begin
	// 				if (~cgLeft)
	// 					state <= STILL;
	// 			end
	// 		UP:
	// 			begin
	// 				if (~cgUp)
	// 					state <= STILL;
	// 			end

	// 		RIGHT:
	// 			begin
	// 				if (~cgRight)
	// 					state <= STILL;
	// 			end
	// 		DOWN:
	// 			begin
	// 				if (~cgDown)
	// 					state <= STILL;
	// 			end
	// 		WIN:
	// 			begin
	// 				if (ack)
	// 					state <= INI;
	// 			end
	// 		LOSE:
	// 			begin
	// 				if(ack)
	// 					state <= INI;
	// 			end

	// 	endcase
	// end
end




//   begin  : CU_n_DU
//     if (reset)
//        begin
//          state <= INI;
// 	    end
//     else
//        begin
// 		 // part of state transition for STILL, LEFT, RIGHT, UP, DOWN are the same
// 		if (state == STILL || state == LEFT || state == UP || state == RIGHT || state == DOWN) begin
// 			if (intersection[pacX+XOFFSET][pacY + YOFFSET] == 1) begin
// state == DOWN) begin
// 			if (intersection[pacX+XOFFSET][pacY + YOFFSET] == 1) begin
// state == DOWN) begin
// 			if (intersection[pacX+XOFFSET][pacY + YOFFSET] == 1) begin
// state == DOWN) begin
// 			if (intersection[pacX+XOFFSET][pacY + YOFFSET] == 1) begin
//  state == DOWN) begin
// 			if (intersection[pacX+XOFFSET][pacY + YOFFSET] == 1) begin
// 				if (leftCtrl && cgLeft)
// 					state <= LEFT;
// 				else if (upCtrl && cgUp)
// 					state <= UP;
// 				else if (rightCtrl && cgRight)
// 					state <= RIGHT;
// 				else if (downCtrl && cgDown)
// 					state <= DOWN;
// 				else
// 					state <= STILL;
// 			end
// 			if (win)
// 				state <= WIN;
// 			if (lose) 
// 				state <= LOSE;
// 		end

//          case (state)
// 	        INI	: 
// 	          begin
// 		         // state transition
// 		         if (start)
// 		           state <= STILL;
// 		         // RTL operations            	              
// 				 //INITIAL VALUES TO BE DETERMINED
// 				 pacX <= xIni;
// 				 pacY <= yIni;
// 	          end
// 	        STILL	:
// 				begin
// 					//state transition
// 					//no RTL operations
// 				end
// 			LEFT:
// 				begin
// 				// state transition
// 				if (noCtrl && atIntersection && cgLeft)
// 					state <= LEFT;
// 				// RTL operations
// 				if (cgLeft)
// 					pacX <= pacX - speed;
// 				end
// 			UP:
// 				begin
// 				// state transition
// 				if (noCtrl && atIntersection && cgUp)
// 					state <= UP;
// 				// RTL operations
// 				if (cgUp)
// 					pacY <= pacY - speed;
// 				end
// 			RIGHT:
// 				begin
// 				// state transition
// 				if (noCtrl && atIntersection && cgRight)
// 					state <= RIGHT;
// 				// RTL operations
// 				if (cgRight)
// 					pacX <= pacX + speed;
// 				end
// 			DOWN:
// 				begin
// 				// state transition
// 				if (noCtrl && atIntersection && cgDown)
// 					state <= DOWN;
// 				// RTL operations
// 				if (cgDown)
// 					pacY <= pacY + speed;
// 				end
// 			WIN:
// 				begin
// 				// state transition
// 				if (ack)
// 					state <= INI;
// 				// RTL operations
// 				end
// 			LOSE:
// 				begin
// 				// state transition
// 				if (ack)
// 					state <= INI;
// 				// RTL operations
// 				end
			
			
//       endcase
//     end 
endmodule