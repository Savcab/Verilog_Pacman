module goal (
	input clk,
    input [9:0] hCount, vCount,
	output goalFill
);

	// offset parameters (custom offset of screen + hCount / vCount blanking offset)
	parameter OFFSETV1 = 10'd24 + 10'd34;
	parameter OFFSETV2 = 10'd24 + 10'd34;
	parameter OFFSETH1 = 10'd130 + 10'd144;
	parameter OFFSETH2 = 10'd130 + 10'd144;

	// general function for rectangle creation
	function bit inBorder (int xMin, int yMin, int xMax, int yMax);
		return ((hCount >= (xMin + OFFSETH1)) && (hCount <= (xMax + OFFSETH2))) && ((vCount >= (yMin + OFFSETV1)) && (vCount <= (yMax + OFFSETV2))) ? 1 : 0;
	endfunction

	assign goalFill = inBorder(156, 8, 224, 48);

endmodule  

