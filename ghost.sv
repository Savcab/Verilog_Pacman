module ghost (
    input move_clk,
	input reset,
    input pacmanFill,
    input [9:0] xIni, yIni,
    input [1:0] direction,
    input [4:0] speed,
	input [9:0] hCount, vCount,
	output ghostFill,
    output touchPac
);

// offset parameters (custom offset of screen + hCount / vCount blanking offset)
parameter OFFSETV1 = 10'd24 + 10'd34;
parameter OFFSETV2 = 10'd24 + 10'd44;
parameter OFFSETH1 = 10'd130 + 10'd144;
parameter OFFSETH2 = 10'd130 + 10'd144;

localparam
ghostWidth = 21;

// Location of ghost
reg [9:0] ghostX, ghostY;

initial begin
    ghostX = xIni;
    ghostY = yIni;
end

// For coloring ghost
assign ghostFill = ((hCount >= (ghostX + OFFSETH1 - ((ghostWidth-1)/2))) && (hCount <= (ghostX + OFFSETH1 + ((ghostWidth-1)/2)))) && ((vCount >= (ghostY + OFFSETV1 - ((ghostWidth-1)/2))) && (vCount <= (ghostY + OFFSETV1 + ((ghostWidth-1)/2))));


// logic for touching pacman
assign touchPac = (ghostFill && pacmanFill);

always@ (posedge move_clk, posedge reset) begin
	if (reset) begin
		ghostX = xIni;
		ghostY = yIni;
	end else begin
        if (direction == 2'b00) begin
            ghostX <= ghostX - speed;
        end else if (direction == 2'b01) begin
            ghostY <= ghostY - speed;
        end else if (direction == 2'b10) begin
            ghostX <= ghostX + speed;
        end else if (direction == 2'b11) begin
            ghostY <= ghostY + speed;
        end
		
        //  Boundary logic
		// 34 + 24 + 432 + 24 + 44
		// start bit 35 (legal 0), end bit 515 (legal 480)
		if (ghostY <= 0) begin
			ghostY = 10'd432;
		end

		if (ghostY >= 10'd432) begin
			ghostY = 0;
		end

		// 143 + 130 + 380 + 130 + 160
		// start bit 144 (legal 0), end bit 783 (legal 640)
		if (ghostX <= 0) begin
			ghostX = 10'd380;
		end

		if (ghostX >= 10'd380) begin
			ghostX = 0;
		end
	end
end

endmodule