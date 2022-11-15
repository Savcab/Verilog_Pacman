/*
File     : divider_timing_top_with_single_step.v (based on divider_top_with_single_step.v) 
Author   : Gandhi Puvvada
Revision  : 1.2, 2.0, 3.0 (to suit Nexys 4)
Date : Feb 15, 2008, 10/14/08, 2/22/2010, 2/12/2012, 2/17/2020
//  Revised: Yue (Julien) Niu, Gandhi Puvvada
//  Date: Mar 29, 2020 (changed 4-bit divider to 8-bit divider, added SCEN signle step control)
*/
module pacman_top
       (ClkPort,                                    // System Clock
        MemOE, MemWR, RamCS, QuadSpiFlashCS,
        BtnL, BtnU, BtnR, BtnD, BtnC,	             // the Left, Up, Right, Down, and Center buttons
        Sw0, Sw1, Sw2, Sw3, Sw4, Sw5, Sw6, Sw7,      // 16 Switches
		Sw8, Sw9, Sw10, Sw11, Sw12, Sw13, Sw14, Sw15,  
        Ld0, Ld1, Ld2, Ld3, Ld4, Ld5, Ld6, Ld7,      // 16 LEDs
		Ld8, Ld9, Ld10, Ld11, Ld12, Ld13, Ld14, Ld15, 
		An0, An1, An2, An3, An4, An5, An6, An7,      // 8 seven-LEDs
		Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp
		  );
                                    
	input    ClkPort;
	input    BtnL, BtnU, BtnD, BtnR, BtnC;
	input    Sw0, Sw1, Sw2, Sw3, Sw4, Sw5, Sw6, Sw7;
	input    Sw8, Sw9, Sw10, Sw11, Sw12, Sw13, Sw14, Sw15;
	output   Ld0, Ld1, Ld2, Ld3, Ld4,Ld5, Ld6, Ld7;
	output   Ld8, Ld9, Ld10, Ld11, Ld12,Ld13, Ld14, Ld15;
	output   An0, An1, An2, An3, An4, An5, An6, An7;
	output   Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	
	// ROM drivers: Control signals on Memory chips (to disable them) 	
	output 	MemOE, MemWR, RamCS, QuadSpiFlashCS;  

	// local signal declaration
	wire [9:0] pacX, pacY;
	wire Start, Ack, SCEN_Up, SCEN_Down, SCEN_Left, SCEN_Right;
	wire Done, Qi, Qc, Qd;
	wire [7:0] Quotient, Remainder;

	
	/*  LOCAL SIGNALS */
	wire		Reset, ClkPort;
	wire		board_clk, sys_clk;
	wire [2:0] 	ssdscan_clk;
	

// to produce divided clock
	reg [26:0]	DIV_CLK;
// SSD (Seven Segment Display)
	reg [3:0]	SSD;
	wire [3:0]	SSD7, SSD6, SSD5, SSD4, SSD3, SSD2, SSD1, SSD0;
	reg [6:0]  	SSD_CATHODES;
	
	
//------------	
// Disable the three memories so that they do not interfere with the rest of the design.
	assign {MemOE, MemWR, RamCS, QuadSpiFlashCS} = 4'b1111;
	
	
//------------
// CLOCK DIVISION

	// The clock division circuitary works like this:
	//
	// ClkPort ---> [BUFGP2] ---> board_clk
	// board_clk ---> [clock dividing counter] ---> DIV_CLK
	// DIV_CLK ---> [constant assignment] ---> sys_clk;
	
	BUFGP BUFGP1 (board_clk, ClkPort); 	

// As the ClkPort signal travels throughout our design,
// it is necessary to provide global routing to this signal. 
// The BUFGPs buffer these input ports and connect them to the global 
// routing resources in the FPGA.

	// BUFGP BUFGP2 (Reset, BtnC); In the case of Spartan 3E (on Nexys-2 board), we were using BUFGP to provide global routing for the reset signal. But Spartan 6 (on Nexys-3) does not allow this.
	assign Reset = BtnC;
	
//------------
	// Our clock is too fast (100MHz) for SSD scanning
	// create a series of slower "divided" clocks
	// each successive bit is 1/2 frequency
  always @(posedge board_clk, posedge Reset) 	
    begin							
        if (Reset)
		DIV_CLK <= 0;
        else
		DIV_CLK <= DIV_CLK + 1'b1;
    end
//------------	
	// In this design, we run the core design at full 50MHz clock!
	assign	sys_clk = board_clk;
	// assign	sys_clk = DIV_CLK[25];


	//------------         


	// The Switch values are the values of the X and Y inputs
	// Buttons are used to indicate start and ack signals
	// assign Xin   =  {Sw15, Sw14, Sw13, Sw12, Sw11, Sw10, Sw9, Sw8};
	// assign Yin   =  {Sw7,  Sw6,  Sw5,  Sw4,  Sw3,  Sw2,  Sw1, Sw0};

	
    // WILL NEED TO DECIDE ON THIS
	assign Start = BtnC; assign Ack = BtnC; // This was used in the divider_simple and also here
	

    // Make the movement buttons into SCEN
ee201_debouncer #(.N_dc(25)) ee201_debouncer_1 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnU), .DPB( ), .SCEN(SCEN_Up), .MCEN( ), .CCEN( ));
ee201_debouncer #(.N_dc(25)) ee201_debouncer_1 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnD), .DPB( ), .SCEN(SCEN_Down), .MCEN( ), .CCEN( ));
ee201_debouncer #(.N_dc(25)) ee201_debouncer_1 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnL), .DPB( ), .SCEN(SCEN_Left), .MCEN( ), .CCEN( ));
ee201_debouncer #(.N_dc(25)) ee201_debouncer_1 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnR), .DPB( ), .SCEN(SCEN_Right), .MCEN( ), .CCEN( ));


    // Maze register
    reg [479:0] maze [639:0];
    // Food register
    input [479:0] food [639:0];
    // Intersection register
    input [479:0] intersection [639:0];

    // Initialize maze with create wall module (TODO)
							
						
	// // instantiate the core divider design. Note the .SCEN(SCEN)
	// divider_timing divider (    .Xin(Xin), .Yin(Yin), 
	// 							.Start(Start), .Ack(Ack), 
	// 							.Clk(sys_clk), .Reset(Reset), .SCEN(SCEN), 
	// 							.Done(Done), .Quotient(Quotient), .Remainder(Remainder), .Qi(Qi), .Qc(Qc), .Qd(Qd));	
    pacman_movement ();
    
													

//------------
// OUTPUT: LEDS
	
	assign {Ld7, Ld6, Ld5, Ld4} = {Qi, Qc, Qd, Done};
	assign {Ld3, Ld2, Ld1, Ld0} = {Start, BtnU, Ack, BtnD}; // We do not want to put SCEN in place of BtnU here as the Ld2 will be on for just 10ns!

//------------
// SSD (Seven Segment Display)
	// reg [3:0]	SSD;
	// wire [3:0]	SSD3, SSD2, SSD1, SSD0;
	
	// The 8 SSDs display Xin, Yin, Quotient, and Reminder  
	assign SSD7 = Xin[7:4];
	assign SSD6 = Xin[3:0];	
	assign SSD5 = Yin[7:4];
	assign SSD4 = Yin[3:0];
	assign SSD3 = Quotient[7:4];
	assign SSD2 = Quotient[3:0];
	assign SSD1 = Remainder[7:4];
	assign SSD0 = Remainder[3:0];


	// need a scan clk for the seven segment display 
	
	// 100 MHz / 2^18 = 381.5 cycles/sec ==> frequency of DIV_CLK[17]
	// 100 MHz / 2^19 = 190.7 cycles/sec ==> frequency of DIV_CLK[18]
	// 100 MHz / 2^20 =  95.4 cycles/sec ==> frequency of DIV_CLK[19]
	
	// 381.5 cycles/sec (2.62 ms per digit) [which means all 4 digits are lit once every 10.5 ms (reciprocal of 95.4 cycles/sec)] works well.
	
	//                  --|  |--|  |--|  |--|  |--|  |--|  |--|  |--|  |   
    //                    |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 
	//  DIV_CLK[17]       |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|
	//
	//               -----|     |-----|     |-----|     |-----|     |
    //                    |  0  |  1  |  0  |  1  |     |     |     |     
	//  DIV_CLK[18]       |_____|     |_____|     |_____|     |_____|
	//
	//         -----------|           |-----------|           |
    //                    |  0     0  |  1     1  |           |           
	//  DIV_CLK[19]       |___________|           |___________|
	//
	
	assign ssdscan_clk = DIV_CLK[20:18];

	assign An0	=  !(~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 000
	assign An1	=  !(~(ssdscan_clk[2]) && ~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 001
	assign An2	=  !(~(ssdscan_clk[2]) &&  (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 010
	assign An3	=  !(~(ssdscan_clk[2]) &&  (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 011
	
	assign An4	=  !( (ssdscan_clk[2]) && ~(ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 100
	assign An5	=  !( (ssdscan_clk[2]) && ~(ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 101
	assign An6	=  !( (ssdscan_clk[2]) &&  (ssdscan_clk[1]) && ~(ssdscan_clk[0]));  // when ssdscan_clk = 110
	assign An7	=  !( (ssdscan_clk[2]) &&  (ssdscan_clk[1]) &&  (ssdscan_clk[0]));  // when ssdscan_clk = 111
	
	
	always @ (ssdscan_clk, SSD0, SSD1, SSD2, SSD3, SSD4, SSD5, SSD6, SSD7)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
				  3'b000: SSD = SSD0;
				  3'b001: SSD = SSD1;
				  3'b010: SSD = SSD2;
				  3'b011: SSD = SSD3;
				  3'b100: SSD = SSD4;
				  3'b101: SSD = SSD5;
				  3'b110: SSD = SSD6;
				  3'b111: SSD = SSD7;
		endcase 
	end

	// Following is Hex-to-SSD conversion
	always @ (SSD) 
	begin : HEX_TO_SSD
		case (SSD) // in this solution file the dot points are made to glow by making Dp = 0
		    //                                                                abcdefg,Dp
			4'b0000: SSD_CATHODES = 7'b0000001; // 0
			4'b0001: SSD_CATHODES = 7'b1001111; // 1
			4'b0010: SSD_CATHODES = 7'b0010010; // 2
			4'b0011: SSD_CATHODES = 7'b0000110; // 3
			4'b0100: SSD_CATHODES = 7'b1001100; // 4
			4'b0101: SSD_CATHODES = 7'b0100100; // 5
			4'b0110: SSD_CATHODES = 7'b0100000; // 6
			4'b0111: SSD_CATHODES = 7'b0001111; // 7
			4'b1000: SSD_CATHODES = 7'b0000000; // 8
			4'b1001: SSD_CATHODES = 7'b0000100; // 9
			4'b1010: SSD_CATHODES = 7'b0001000; // A
			4'b1011: SSD_CATHODES = 7'b1100000; // B
			4'b1100: SSD_CATHODES = 7'b0110001; // C
			4'b1101: SSD_CATHODES = 7'b1000010; // D
			4'b1110: SSD_CATHODES = 7'b0110000; // E
			4'b1111: SSD_CATHODES = 7'b0111000; // F    
			default: SSD_CATHODES = 7'bXXXXXXX; // default is not needed as we covered all cases
		endcase
	end	
	
	// reg [6:0]  SSD_CATHODES;
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg} = {SSD_CATHODES}; 
	// assign Dp = 1'b0; // For TA's solution
	assign Dp = 1'b1; // For Student's exercise
	
endmodule
