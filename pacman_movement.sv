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

// offset parameters (custom offset of screen + hCount / vCount blanking offset)
parameter OFFSETV1 = 10'd24 + 10'd34;
parameter OFFSETV2 = 10'd24 + 10'd44;
parameter OFFSETH1 = 10'd130 + 10'd144;
parameter OFFSETH2 = 10'd130 + 10'd144;

localparam
winningScore = 30,
xIni = 190 + OFFSETH1,
yIni = 318 + OFFSETV1;

// pixelSize = 21,

// Local wires for simplicity
wire leftCtrl, upCtrl, rightCtrl, downCtrl, cgLeft, cgUp, cgRight, cgDown;
reg [3:0] cgDirections;
reg [9:0] pacX, pacY;
reg [49:0] counter;

initial begin
	pacX = xIni;
	pacY = yIni;
	counter = 50'd0;
end

// reg[49:0] counter;

//	for coloring pacman
// assign pacmanFill = ((hCount <= pacX+(pixelSize/2)) && (hCount >= pacX-(pixelSize/2)+1)) 
// 						&& ((vCount <= pacY+(pixelSize/2)) && (vCount >= pacY-(pixelSize/2)+1));

// directionFill is the pixel right above that direction on pacman
// assign leftFill = (hCount == pacX-(pixelSize/2)) && (vCount <= pacY+(pixelSize/2)) && (vCount >= pacY-(pixelSize/2) + 1);
// assign upFill = (hCount <= pacX+(pixelSize/2)) && (hCount >= pacX-(pixelSize/2) + 1) && (vCount == pacY-(pixelSize/2));
// assign rightFill = (hCount == pacX+(pixelSize/2) + 1) && (vCount <= pacY+(pixelSize/2)) && (vCount >= pacY-(pixelSize/2) + 1);
// assign downFill = (hCount <= pacX+(pixelSize/2)) && (hCount >= pacX-(pixelSize/2) + 1) && (vCount == pacY+(pixelSize/2)+1);

// initial begin
// 	cgDirections <= 4'b1111;
// end

always@ (posedge clk, posedge reset) begin
	counter = counter + 50'b1;
	if (reset) begin
		pacX = xIni;
		pacY = yIni;
		counter = 50'd0;
	end else if (counter >= 50'd10000) begin
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
		if (pacY <= OFFSETV1) begin
			pacY = OFFSETV1;
		end

		if (pacY >= (10'd432 + OFFSETV1)) begin
			pacY = (10'd432 + OFFSETV1);
		end

		// 143 + 130 + 380 + 130 + 160
		// start bit 144 (legal 0), end bit 783 (legal 640)
		if (pacX <= OFFSETH1) begin
			pacX = OFFSETH1;
		end

		if (pacX >= (10'd380 + OFFSETH1)) begin
			pacX = (10'd380 + OFFSETH1);
		end

		counter = 50'd0;
	end
end

assign {cgLeft, cgUp, cgRight, cgDown} = cgDirections;

assign pacmanFill = ((hCount >= (pacX - 10'd8)) && (hCount <= (pacX + 10'd8))) 
						&& ((vCount >= (pacY - 10'd8)) && (vCount <= (pacY + 10'd8)));

assign leftCtrl = (Left && ~Up && ~Right && ~Down);
assign upCtrl = (~Left && Up && ~Right && ~Down);
assign rightCtrl = (~Left && ~Up && Right && ~Down);
assign downCtrl = (~Left && ~Up && ~Right && Down);
assign noCtrl = (~leftCtrl && ~upCtrl && ~rightCtrl && ~downCtrl);

endmodule