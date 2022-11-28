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
//function bit inBorder;
//    input [9:0] x, y, xMin, yMin, xMax, yMax;
//    output inbound;
//    inBorder = (x >= xMin && x <= xMax && y >= yMin && y <= yMax);
//endfunction

function bit inBorder (int x, int y, int xMin, int yMin, int xMax, int yMax);
    return (x >= xMin && x <= xMax && y >= yMin && y <= yMax);
endfunction

wire compA, compB, compC, compD, compE, compF, compG, compH, compI, compJ, compK, compL, compM, compN, compO, compP, compQ, compR, compS;

assign compA = inBorder(hCount, vCount, OFFSETH1 + 144, OFFSETV1 + 8, OFFSETH2 + 156, OFFSETV2 + 48);
assign compB = inBorder(hCount, vCount, OFFSETH1 + 224, OFFSETV1 + 8, OFFSETH2 + 236, OFFSETV2 + 48);
assign compC = inBorder(hCount, vCount, OFFSETH1 + 104, OFFSETV1 + 36, OFFSETH2 + 116, OFFSETV2 + 88);
assign compD = inBorder(hCount, vCount, OFFSETH1 + 264, OFFSETV1 + 36, OFFSETH2 + 276, OFFSETV2 + 88);
assign compE = inBorder(hCount, vCount, OFFSETH1 + 184, OFFSETV1 + 36, OFFSETH2 + 196, OFFSETV2 + 128);
assign compF = inBorder(hCount, vCount, OFFSETH1 + 36, OFFSETV1 + 88, OFFSETH2 + 48, OFFSETV2 + 128);
assign compG = inBorder(hCount, vCount, OFFSETH1 + 332, OFFSETV1 + 88, OFFSETH2 + 344, OFFSETV2 + 128);
assign compH = inBorder(hCount, vCount, OFFSETH1 + 104, OFFSETV1 + 156, OFFSETH2 + 116, OFFSETV2 + 264);
assign compI = inBorder(hCount, vCount, OFFSETH1 + 264, OFFSETV1 + 156, OFFSETH2 + 276, OFFSETV2 + 264);
assign compJ = inBorder(hCount, vCount, OFFSETH1 + 64, OFFSETV1 + 236, OFFSETH2 + 76, OFFSETV2 + 304);
assign compK = inBorder(hCount, vCount, OFFSETH1 + 304, OFFSETV1 + 236, OFFSETH2 + 316, OFFSETV2 + 304);
assign compL = inBorder(hCount, vCount, OFFSETH1 + 184, OFFSETV1 + 252, OFFSETH2 + 196, OFFSETV2 + 304);
assign compM = inBorder(hCount, vCount, OFFSETH1 + 104, OFFSETV1 + 292, OFFSETH2 + 116, OFFSETV2 + 356);
assign compN = inBorder(hCount, vCount, OFFSETH1 + 264, OFFSETV1 + 292, OFFSETH2 + 276, OFFSETV2 + 356);
assign compO = inBorder(hCount, vCount, OFFSETH1 + 36, OFFSETV1 + 344, OFFSETH2 + 48, OFFSETV2 + 384);
assign compP = inBorder(hCount, vCount, OFFSETH1 + 144, OFFSETV1 + 332, OFFSETH2 + 156, OFFSETV2 + 384);
assign compQ = inBorder(hCount, vCount, OFFSETH1 + 224, OFFSETV1 + 332, OFFSETH2 + 236, OFFSETV2 + 384);
assign compR = inBorder(hCount, vCount, OFFSETH1 + 332, OFFSETV1 + 344, OFFSETH2 + 344, OFFSETV2 + 384);
assign compS = inBorder(hCount, vCount, OFFSETH1 + 184, OFFSETV1 + 332, OFFSETH2 + 196, OFFSETV2 + 356);


//	for coloring wall
assign wallFill = compA || compB || compC || compD || compE|| compF || compG || compH || compI || compJ || compK || compL || compM || compN || compO || compP || compQ || compR || compS;


// for coloring
always@ (*) begin
    if (wallFill)
		rgb = WALLCOLOR;
end


endmodule  

