module pacman_movement (
	input clk,
	input reset,
	input ack,
	input start,
	input Left,
	input Right,
	input Up,
	input Down,
	input [15:0] score,
	input [9:0] hCount, vCount,
	input win,
	input lose,
	output pacmanFill
);

reg [9:0] pacX, pacY;
reg [49:0] counter;

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
// end

initial begin
	pacX = xIni;
	pacY = yIni;
	counter = 50'd0;
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


// movement state machine
always @(posedge reset) 
begin
	if (reset)
		begin
			pacX = xIni;
			pacY = yIni;
			counter = 50'd0;
		end
end 
endmodule