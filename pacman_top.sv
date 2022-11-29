module pacman_top
       (ClkPort,                                    // System Clock
        MemOE, MemWR, RamCS, QuadSpiFlashCS,
        BtnL, BtnU, BtnR, BtnD, BtnC,	             // the Left, Up, Right, Down, and Center buttons
        Sw0, Sw1, Sw2, Sw3, Sw4, Sw5, Sw6, Sw7,      // 16 Switches
		Sw8, Sw9, Sw10, Sw11, Sw12, Sw13, Sw14, Sw15,  
        Ld0, Ld1, Ld2, Ld3, Ld4, Ld5, Ld6, Ld7,      // 16 LEDs
		Ld8, Ld9, Ld10, Ld11, Ld12, Ld13, Ld14, Ld15, 
		An0, An1, An2, An3, An4, An5, An6, An7,      // 8 seven-LEDs
		Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp,
		hSync, vSync,
		vgaR, vgaG, vgaB
		  );
                                    
	input    ClkPort;
	input    BtnL, BtnU, BtnD, BtnR, BtnC;
	input    Sw0, Sw1, Sw2, Sw3, Sw4, Sw5, Sw6, Sw7;
	input    Sw8, Sw9, Sw10, Sw11, Sw12, Sw13, Sw14, Sw15;
	// VGA outputs
	output hSync, vSync;
	output [3:0] vgaR, vgaG, vgaB;

	output   Ld0, Ld1, Ld2, Ld3, Ld4,Ld5, Ld6, Ld7;
	output   Ld8, Ld9, Ld10, Ld11, Ld12,Ld13, Ld14, Ld15;
	output   An0, An1, An2, An3, An4, An5, An6, An7;
	output   Ca, Cb, Cc, Cd, Ce, Cf, Cg, Dp;
	
	// ROM drivers: Control signals on Memory chips (to disable them) 	
	output 	MemOE, MemWR, RamCS, QuadSpiFlashCS;  

	// local signal declaration
	wire [9:0] pacX, pacY;
	wire Start, Ack, CCEN_Up, CCEN_Down, CCEN_Left, CCEN_Right, SCEN_Center;
	wire[15:0] score;
	wire[11:0] rgb;
	assign vgaR = rgb[11:8];
	assign vgaG = rgb[7:4];
	assign vgaB = rgb[3:0];

	// signal for display controller
	wire bright;
	wire [9:0] hc, vc;

	
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
	// assign move_clk = DIV_CLK[19];

	
    // Make the movement buttons into SCEN
ee354_debouncer #(.N_dc(25)) debouncer_up 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnU), .DPB( ), .SCEN(), .MCEN( ), .CCEN(CCEN_Up));
ee354_debouncer #(.N_dc(25)) debouncer_down
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnD), .DPB( ), .SCEN(), .MCEN( ), .CCEN(CCEN_Down));
ee354_debouncer #(.N_dc(25)) debouncer_left 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnL), .DPB( ), .SCEN(), .MCEN( ), .CCEN(CCEN_Left));
ee354_debouncer #(.N_dc(25)) debouncer_right 
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnR), .DPB( ), .SCEN(), .MCEN( ), .CCEN(CCEN_Right));
ee354_debouncer #(.N_dc(25)) debouncer_center
        (.CLK(sys_clk), .RESET(Reset), .PB(BtnC), .DPB( ), .SCEN(SCEN_Center), .MCEN( ), .CCEN());

	assign Start = SCEN_Center; assign Ack = SCEN_Center;

	// display
	assign {Ld4, Ld3, Ld2, Ld1, Ld0} = {BtnC, CCEN_Left, CCEN_Up, CCEN_Right, CCEN_Down};


    // Maze register
    ////reg [479:0][639:0] maze;
    // Food register
    ////reg [479:0][639:0] food;

	// Win and lose signal
	wire win, lose;

	// All the fill signals
	wire pacmanFill, wallFill;
	wire pX, pY;


    // Initialize maze with create wall module 
	wall_module wall(.clk(sys_clk), .bright(bright), .pacX(pX), .pacY(pY), .hCount(hc), .vCount(vc), .rgb(rgb), .wallFill(wallFill));
						
	// Initialize display controller
	display_controller dc(.clk(sys_clk), .hSync(hSync), .vSync(vSync), .wallFill(wallFill), .pacmanFill(pacmanFill), .bright(bright), .rgb(rgb), .hCount(hc), .vCount(vc));
	
	
	// Initialize pacman movement module
    pacman_movement pacman(.clk(sys_clk), .reset(Reset), .ack(Ack), .start(Start), .bright(bright), .Left(CCEN_Left), .Right(CCEN_Right),
							.Up(CCEN_Up), .Down(CCEN_Down), .score(score), .hCount(hc), .vCount(vc), .win(win), .lose(lose), .pacmanFill(pacmanFill));

	// assume for now there are 4 ghosts


	// Initialize first ghost
	// Initialize second ghost
	// Initialize third ghost
	// Initialize the fourth ghost
	

	// Initialize the score module
	// scoring scoring_module(.clk(sys_clk), .reset(Reset), .ack(Ack), .start(Start), .winIn(win), .loseIn(lose), .winOut(win), .loseOut(lose), ..., .ghostFills(ghostFills));


//------------
// // OUTPUT: LEDS

// //------------
// // SSD (Seven Segment Display)
	
// 	// The 8 SSDs to show the score
	assign SSD7 = score[15:12];
	assign SSD6 = score[11:8];	
	assign SSD5 = score[7:4];
	assign SSD4 = score[3:0];


// 	// need a scan clk for the seven segment display 
	
// 	// 100 MHz / 2^18 = 381.5 cycles/sec ==> frequency of DIV_CLK[17]
// 	// 100 MHz / 2^19 = 190.7 cycles/sec ==> frequency of DIV_CLK[18]
// 	// 100 MHz / 2^20 =  95.4 cycles/sec ==> frequency of DIV_CLK[19]
	
// 	// 381.5 cycles/sec (2.62 ms per digit) [which means all 4 digits are lit once every 10.5 ms (reciprocal of 95.4 cycles/sec)] works well.
	
// 	//                  --|  |--|  |--|  |--|  |--|  |--|  |--|  |--|  |   
//     //                    |  |  |  |  |  |  |  |  |  |  |  |  |  |  |  | 
// 	//  DIV_CLK[17]       |__|  |__|  |__|  |__|  |__|  |__|  |__|  |__|
// 	//
// 	//               -----|     |-----|     |-----|     |-----|     |
//     //                    |  0  |  1  |  0  |  1  |     |     |     |     
// 	//  DIV_CLK[18]       |_____|     |_____|     |_____|     |_____|
// 	//
// 	//         -----------|           |-----------|           |
//     //                    |  0     0  |  1     1  |           |           
// 	//  DIV_CLK[19]       |___________|           |___________|
// 	//
	
	assign ssdscan_clk = DIV_CLK[20:19];

	assign An4 = !(~ssdscan_clk[1] && ~ssdscan_clk[0]); // when ssdscan_clk = 00
	assign An5 = !(~ssdscan_clk[1] && ssdscan_clk[0]); // when ssdscan_clk = 01
	assign An6 = !(ssdscan_clk[1] && ~ssdscan_clk[0]); // when ssdscan_clk = 10
	assign An7 = !(ssdscan_clk[1] && ssdscan_clk[0]); //when ssdscan_clk = 11
	
	
	always @ (ssdscan_clk, SSD4, SSD5, SSD6, SSD7)
	begin : SSD_SCAN_OUT
		case (ssdscan_clk) 
				2'b00: SSD = SSD4;
				2'b01: SSD = SSD5;
				2'b10: SSD = SSD6;
				2'b11: SSD = SSD7;
		endcase 
	end

// 	// Following is Hex-to-SSD conversion
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
	
	assign {Ca, Cb, Cc, Cd, Ce, Cf, Cg} = {SSD_CATHODES}; 
	// assign Dp = 1'b0; // For TA's solution
	assign Dp = 1'b1; // For Student's exercise
	
endmodule
