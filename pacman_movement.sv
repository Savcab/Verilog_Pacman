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
	input resetW,
	output pacmanFill,
	output reg [3:0] cgDirections
);

// offset parameters (custom offset of screen + hCount / vCount blanking offset)
parameter OFFSETV1 = 10'd24 + 10'd34;
parameter OFFSETV2 = 10'd24 + 10'd44;
parameter OFFSETH1 = 10'd130 + 10'd144;
parameter OFFSETH2 = 10'd130 + 10'd144;

localparam
winningScore = 30,
xIni = 190,
yIni = 318,
pacWidth = 17;

// Local wires for simplicity
wire leftCtrl, upCtrl, rightCtrl, downCtrl, cgLeft, cgUp, cgRight, cgDown;


// reg [3:0] cgDirections;
reg [9:0] pacX, pacY;
reg [49:0] counter;

initial begin
	pacX = xIni;
	pacY = yIni;
	counter = 50'd0;
	cgDirections = 4'b1111;
end

assign leftCtrl = (Left && ~Up && ~Right && ~Down);
assign upCtrl = (~Left && Up && ~Right && ~Down);
assign rightCtrl = (~Left && ~Up && Right && ~Down);
assign downCtrl = (~Left && ~Up && ~Right && Down);
assign noCtrl = (~leftCtrl && ~upCtrl && ~rightCtrl && ~downCtrl);

// For coloring pacman
assign pacmanFill = ((hCount >= ((pacX + OFFSETH1) - ((pacWidth-1)/2))) && (hCount <= (pacX + OFFSETH1 + ((pacWidth-1)/2)))) && ((vCount >= (pacY + OFFSETV1 - ((pacWidth-1)/2))) && (vCount <= (pacY + OFFSETV1 + ((pacWidth-1)/2))));
// directionFill is the pixel right above that direction on pacman
assign leftFill = (hCount == ((pacX + OFFSETH1) - ((pacWidth-1)/2) - 2)) && (vCount <= (pacY + OFFSETV1 + ((pacWidth-1)/2))) && (vCount >= (pacY + OFFSETV1 - ((pacWidth-1)/2)));
assign upFill = (hCount <= ((pacX + OFFSETH1) + ((pacWidth-1)/2))) && (hCount >= (pacX + OFFSETH1 - ((pacWidth-1)/2))) && (vCount == (pacY + OFFSETV1 - ((pacWidth-1)/2) - 2));
assign rightFill = (hCount == ((pacX + OFFSETH1) + ((pacWidth-1)/2) + 2)) && (vCount <= (pacY + OFFSETV1 + ((pacWidth-1)/2))) && (vCount >= (pacY + OFFSETV1 - ((pacWidth-1)/2)));
assign downFill = (hCount <= ((pacX + OFFSETH1) + ((pacWidth-1)/2))) && (hCount >= (pacX + OFFSETH1 - ((pacWidth-1)/2))) && (vCount == (pacY + OFFSETV1 + ((pacWidth-1)/2) + 2));

// Always check to see if a direction becomes unavailable
always@ (posedge clk) begin
	cgDirections = {leftFill, upFill, rightFill, downFill};
end

always@ (posedge clk, posedge reset) begin
	counter <= counter + 50'b1;
	if (reset || resetW) begin
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
		if (pacY <= 8) begin
			pacY = 8;
		end

		if (pacY >= 10'd432) begin
			pacY = 10'd432;
		end

		// 143 + 130 + 380 + 130 + 160
		// start bit 144 (legal 0), end bit 783 (legal 640)
		if (pacX <= 8) begin
			pacX = 8;
		end

		if (pacX >= 10'd380) begin
			pacX = 10'd380;
		end

		counter = 50'd0;
	end
end

endmodule