module wall_module (
	input clk,
	input bright,
	input pacX, pacY,
    input [9:0] hCount, vCount,
	output reg [11:0] rgb,
	output wallFill
);

	// offset parameters (custom offset of screen + hCount / vCount blanking offset)
	parameter OFFSETV1 = 10'd24 + 10'd34;
	parameter OFFSETV2 = 10'd24 + 10'd34;
	parameter OFFSETH1 = 10'd130 + 10'd144;
	parameter OFFSETH2 = 10'd130 + 10'd144;

	// color parameters 
	parameter BLACK = 12'b0000_0000_0000;
	parameter WHITE = 12'b1111_1111_1111;
	parameter WALLCOLOR = 12'b0000_0000_1111; // aka blue
	parameter RED   = 12'b1111_0000_0000;
	parameter GREEN = 12'b0000_1111_0000;
	parameter YELLOW = 12'b1111_1111_0000;

	// general function for rectangle creation
	function bit inBorder (int xMin, int yMin, int xMax, int yMax);
		return ((hCount >= (xMin + OFFSETH1)) && (hCount <= (xMax + OFFSETH2))) && ((vCount >= (yMin + OFFSETV1)) && (vCount <= (yMax + OFFSETV2))) ? 1 : 0;
	endfunction

	function bit inBorderPacMan (int currX, int currY);
		return ((hCount >= (currX + OFFSETH1 - 10'd10)) && (hCount <= (currX + OFFSETH2 + 10'd10))) && ((vCount >= (currY + OFFSETV1 - 10'd10)) && (vCount <= (currY + OFFSETV2 + 10'd10))) ? 1 : 0;
	endfunction
	
	// WALL CODE //
	wire compA, compB, compC, compD, compE, compF, compG, compH, compI, compJ, compK, compL, compM, compN, compO, compP, compQ, compR, compS;
	wire comp1, comp2, comp3, comp4, comp5, comp6, comp7, comp8, comp9, comp10, comp11, comp12, comp13, comp14, comp15, comp16, comp17, comp18, comp19, comp20, comp21, comp22, comp23, comp24, comp25;
	wire pacManFill;

	// // GENERAL: Coloring Display //
	// always@ (*)
	// 	if (~bright)
	// 		rgb = BLACK; // force black if NOT bright
	// 	else if (wallFill == 1)
	// 		rgb = WALLCOLOR; // color of wall
	// 	else if (pacManFill == 1)
	// 		rgb = YELLOW;
	// 	else 
	// 		rgb = BLACK; // background color

	// assign pacman shape
	// assign pacManFill = inBorderPacMan(300, 300);

	// vertical wall components
	assign compA = inBorder(144, 8, 156, 48);
	assign compB = inBorder(224, 8, 236, 48);
	assign compC = inBorder(104, 36, 116, 88);
	assign compD = inBorder(264, 36, 276, 88);
	assign compE = inBorder(184, 36, 196, 128);
	assign compF = inBorder(36, 88, 48, 128);
	assign compG = inBorder(332, 88, 344, 128);
	assign compH = inBorder(104, 156, 116, 264);
	assign compI = inBorder(264, 156, 276, 264);
	assign compJ = inBorder(64, 236, 76, 304);
	assign compK = inBorder(304, 236, 316, 304);
	assign compL = inBorder(184, 252, 196, 304);
	assign compM = inBorder(104, 292, 116, 356);
	assign compN = inBorder(264, 292, 276, 356);
	assign compO = inBorder(36, 344, 48, 384);
	assign compP = inBorder(144, 332, 156, 384);
	assign compQ = inBorder(224, 332, 236, 384);
	assign compR = inBorder(332, 344, 344, 384);
	assign compS = inBorder(184, 332, 196, 356);

	// horizontal wall components 
	assign comp1 = inBorder(36, 36, 76, 48);
	assign comp2 = inBorder(304, 36, 344, 48);
	assign comp3 = inBorder(36, 76, 76, 88);
	assign comp4 = inBorder(116, 76, 156, 88);
	assign comp5 = inBorder(224, 76, 264, 88);
	assign comp6 = inBorder(304, 76, 344, 88);
	assign comp7 = inBorder(76, 116, 116, 128);
	assign comp8 = inBorder(144, 116, 184, 128);
	assign comp9 = inBorder(196, 116, 236, 128);
	assign comp10 = inBorder(264, 116, 304, 128);
	assign comp11 = inBorder(36, 224, 76, 236);
	assign comp12 = inBorder(304, 224, 344, 236);
	assign comp13 = inBorder(144, 252, 184, 264);
	assign comp14 = inBorder(196, 252, 236, 264);
	assign comp15 = inBorder(8, 264, 36, 276);
	assign comp16 = inBorder(344, 264, 372, 276);
	assign comp17 = inBorder(116, 292, 156, 304);
	assign comp18 = inBorder(224, 292, 264, 304);
	assign comp19 = inBorder(36, 304, 76, 316);
	assign comp20 = inBorder(304, 304, 344, 316);
	assign comp21 = inBorder(76, 344, 104, 356);
	assign comp22 = inBorder(276, 344, 304, 356);
	assign comp23 = inBorder(36, 384, 116, 396);
	assign comp24 = inBorder(144, 384, 236, 396);
	assign comp25 = inBorder(264, 384, 344, 396);

	// special components: box
	assign LZ = inBorder(36, 156, 76, 196);
	assign RZ = inBorder(304, 156, 344, 196);
	
	// special components: center pieces
	assign CLeft = inBorder(144, 156, 152, 224);
	assign CRight = inBorder(228, 156, 236, 224);
	assign CUp = inBorder(144, 156, 236, 164);
	assign CDown = inBorder(144, 216, 236, 224);

	// special components: border
	assign BLeft = inBorder(0, 0, 8, 432);
	assign BRight = inBorder(372, 0, 380, 432);
	assign BUp = inBorder(0, 0, 380, 8);
	assign BDown = inBorder(0, 424, 380, 432);

	// assigning boolean wires for coloring
	assign wallFill = compA || compB || compC || compD || compE|| compF || compG || compH || compI || compJ || compK || compL || compM || compN || compO || compP || compQ || compR || compS || comp1 || comp2 || comp3 || comp4 || comp5 || comp6 || comp7 || comp8 || comp9 || comp10 || comp11 || comp12 || comp13 || comp14 || comp15 || comp16 || comp17 || comp18 || comp19 || comp20 || comp21 || comp22 || comp23 || comp24 || comp25 || LZ || RZ || CLeft || CRight || CUp || CDown || BLeft || BRight || BUp || BDown;

endmodule  

