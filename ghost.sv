module ghost (
    input move_clk,
    input reset,
    input [9:0] xIni, yIni,
    input [4:0] speed,
    input [9:0] hCount, vCount,
    input resetW, 
    output ghostFill
);

// offset parameters (custom offset of screen + hCount / vCount blanking offset)
parameter OFFSETV1 = 10'd24 + 10'd34;
parameter OFFSETV2 = 10'd24 + 10'd44;
parameter OFFSETH1 = 10'd130 + 10'd144;
parameter OFFSETH2 = 10'd130 + 10'd144;
parameter GHOST_WIDTH = 10'd23;

// Location of ghost
reg [9:0] ghostX, ghostY;
reg [49:0] counter;
reg [1:0] direction;

initial begin
    ghostX = xIni;
    ghostY = yIni;
    counter = 50'd0;
    direction = 2'b11;
end

// For coloring ghost
assign ghostFill = ((hCount >= (ghostX + OFFSETH1 - ((GHOST_WIDTH-1)/2))) && (hCount <= (ghostX + OFFSETH1 + ((GHOST_WIDTH-1)/2)))) && ((vCount >= (ghostY + OFFSETV1 - ((GHOST_WIDTH-1)/2))) && (vCount <= (ghostY + OFFSETV1 + ((GHOST_WIDTH-1)/2))));

always@ (posedge move_clk, posedge reset) begin
    counter <= counter + 50'b1;
    if (reset || resetW) begin
        ghostX = xIni;
        ghostY = yIni;
    end else if (counter >= 50'd500000) begin
        if (direction == 2'b00) begin // left
            ghostX <= ghostX - speed;
        end else if (direction == 2'b01) begin // up
            ghostY <= ghostY - speed;
        end else if (direction == 2'b10) begin // right
            ghostX <= ghostX + speed;
        end else if (direction == 2'b11) begin // down
            ghostY <= ghostY + speed;
        end

        //  Boundary logic
        // 34 + 24 + 432 + 24 + 44
        // start bit 35 (legal 0), end bit 515 (legal 480)
        if (ghostY <= 10'd90) begin
            ghostY = 10'd90;
            direction = 2'b11;
        end

        if (ghostY >= 10'd322) begin
            ghostY = 10'd322;
            direction = 2'b01;
        end

        // 143 + 130 + 380 + 130 + 160
        // start bit 144 (legal 0), end bit 783 (legal 640)
        if (ghostX <= 10'd116) begin
            ghostX = 10'd116;
            direction = 2'b10;
        end

        if (ghostX >= 10'd140) begin
            ghostX = 10'd140;
            direction = 2'b00;
        end

        counter = 50'd0;
    end
end

endmodule