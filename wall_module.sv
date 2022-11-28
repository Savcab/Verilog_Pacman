module wall_module (
	input clk,
	input reset,
	input ack,
	input start,
	input bright,
    input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output wallFill
);

wire wallFill;

localparam
OFFSETV1 = 24,
OFFSETV2 = 24,
OFFSETH1 = 130,
OFFSETH2 = 130,
WALLCOLOR = 12'b0000_0000_1111;

// function for making checking teh boundaries easier
function bit inBorder;
    input [9:0] x, y, xMin, yMin, xMax, yMax;
    output inbound;
    inbound = (x >= xMin && x <= xMax && y >= yMin && y <= yMax);
endfunction


assign compA = inBorder(hCount, vCount, );
assign compB = inBorder(hCount, vCount, );
assign compC = inBorder(hCount, vCount, );
assign compD = inBorder(hCount, vCount, );
assign compE = inBorder(hCount, vCount, );
assign compF = inBorder(hCount, vCount, );
assign compG = inBorder(hCount, vCount, );
assign compH = inBorder(hCount, vCount, );
assign compI = inBorder(hCount, vCount, );
assign compJ = inBorder(hCount, vCount, );
assign compK = inBorder(hCount, vCount, );
assign compL = inBorder(hCount, vCount, );
assign compM = inBorder(hCount, vCount, );
assign compO = inBorder(hCount, vCount, );
assign compP = inBorder(hCount, vCount, );
assign compQ = inBorder(hCount, vCount, );
assign compR = inBorder(hCount, vCount, );
assign compS = inBorder(hCount, vCount, );





//	for coloring wall
assign wallFill = inBorder(hCount, vCount, )
                    || 


// for coloring
always@ (*) begin
    if (wallFill)
		rgb = WALLCOLOR;
end


endmodule  

