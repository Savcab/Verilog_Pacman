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
	// input [479:0][639:0] maze,
	input bit[3:0] [431:0][379:0] intersection,
	input win,
	input lose,
	output reg [11:0] rgb,
	output pacmanFill
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


parameter YELLOW = 12'b1111_1111_0000;

localparam
xLowerBound = 0,
xUpperBound = 640,
yLowerBound = 0,
yUpperBound = 480,
speed = 5,
winningScore = 30,
pixelSize = 5,
xIni = 300,
yIni = 300;

// Local wires for simplicity
wire atIntersection, leftCtrl, upCtrl, rightCtrl, downCtrl, cgLeft, cgUp, cgRight, cgDown;
assign atIntersection = (intersection[pacY + YOFFSET][pacX + XOFFSET] != 4'b0000);
assign leftCtrl = (Left && ~Up && ~Right && ~Down);
assign upCtrl = (~Left && Up && ~Right && ~Down);
assign rightCtrl = (~Left && ~Up && Right && ~Down);
assign downCtrl = (~Left && ~Up && ~Right && Down);
assign noCtrl = (~leftCtrl && ~upCtrl && rightCtrl && downCtrl);
// 	cg stands for can go
//	intersection[i][j] is treated as {left, up, right, down}
assign cgLeft = (intersection[pacY + YOFFSET][pacX + XOFFSET][0] == 1);
assign cgUp = (intersection[pacY + YOFFSET][pacX + XOFFSET][1] == 1);
assign cgRight = (intersection[pacY + YOFFSET][pacX + XOFFSET][2] == 1);
assign cgDown = (intersection[pacY + YOFFSET][pacX + XOFFSET][3] == 1);

// assign cgLeft = (pacX - pixelSize > xLowerBound && maze[pacY][pacX-pixelSize] != 1);
// assign cgUp = (pacY - pixelSize > yLowerBound && maze[pacY-pixelSize][pacX] != 1);
// assign cgRight = (pacX + pixelSize < xUpperBound && maze[pacY][pacX+pixelSize] != 1);
// assign cgDown = (pacY + pixelSize < yUpperBound && maze[pacY+pixelSize][pacX] != 1);

//	for coloring pacman
assign pacmanFill = (hCount <= pacX+(pixelSize/2)) && (hCount >= pacX-(pixelSize/2)) 
						&& (vCount <= pacY+(pixelSize/2)) && (vCount >= pacY-(pixelSize/2));


// for coloring
always@ (*) begin
	if (~bright)
		rgb = 12'b0000_0000_0000;
	else if (pacmanFill)
		rgb = YELLOW;
end


// movement state machine
always @(posedge clk, posedge reset) 
  begin  : CU_n_DU
    if (reset)
       begin
         state <= INI;
	    end
    else
       begin
         (* full_case, parallel_case *)
		 // part of state transition for STILL, LEFT, RIGHT, UP, DOWN are the same
		if (state == STILL || state == LEFT || state == UP || state == RIGHT || state == DOWN) begin
			if (intersection[pacX+XOFFSET][pacY + YOFFSET] == 1) begin
				if (leftCtrl && cgLeft)
					state <= LEFT;
				else if (upCtrl && cgUp)
					state <= UP;
				else if (rightCtrl && cgRight)
					state <= RIGHT;
				else if (downCtrl && cgDown)
					state <= DOWN;
				else
					state <= STILL;
			end
			if (win)
				state <= WIN;
			if (lose) 
				state <= LOSE;
		end

         case (state)
	        INI	: 
	          begin
		         // state transition
		         if (start)
		           state <= STILL;
		         // RTL operations            	              
				 //INITIAL VALUES TO BE DETERMINED
				 pacX <= xIni;
				 pacY <= yIni;
	          end
	        STILL	:
				begin
					//state transition
					//no RTL operations
				end
			LEFT:
				begin
				// state transition
				if (noCtrl && atIntersection && cgLeft)
					state <= LEFT;
				// RTL operations
				if (cgLeft)
					pacX <= pacX - speed;
				end
			UP:
				begin
				// state transition
				if (noCtrl && atIntersection && cgUp)
					state <= UP;
				// RTL operations
				if (cgUp)
					pacY <= pacY - speed;
				end
			RIGHT:
				begin
				// state transition
				if (noCtrl && atIntersection && cgRight)
					state <= RIGHT;
				// RTL operations
				if (cgRight)
					pacX <= pacX + speed;
				end
			DOWN:
				begin
				// state transition
				if (noCtrl && atIntersection && cgDown)
					state <= DOWN;
				// RTL operations
				if (cgDown)
					pacY <= pacY + speed;
				end
			WIN:
				begin
				// state transition
				if (ack)
					state <= INI;
				// RTL operations
				end
			LOSE:
				begin
				// state transition
				if (ack)
					state <= INI;
				// RTL operations
				end
			
			
      endcase
    end 
  end 
endmodule  

