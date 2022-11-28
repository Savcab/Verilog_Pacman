module scoring_module (
	input clk,
	input reset,
	input ack,
    input start,
	input bright,
    input [9:0] pacX,
    input [9:0] pacY,
	input [9:0] hCount, vCount,
	input [479:0] maze [639:0],
	input [479:0] intersection [639:0],
    input [479:0] pellets [639:0],
	input [3:0] ghostFills,
	input pacmanFill,
	output reg [15:0] score,
	output reg [11:0] rgb,
	output winOut,
	output loseOut
    );

	reg [4:0] state;
    reg [15:0] score;


    // winning and losing conditions
	
	localparam
	INI = 4'b0001;
	STANDBY = 4'b0010;
	WIN = 4'b0100;
	LOSE = 4'b1000;
	


	always@ (posedge clk, posedge reset) begin
        begin: scoring_state_machine
            if (reset)
                begin
                    state <= INI;
                end
            else
                begin
                    case (state)
                        INI:
                            if (start) begin
                                state <= STANDBY;
                            end
                            score <= 0;
                            winOut <= 0;
                            loseOut <= 0;
                        STANDBY:
                            // state transitions
                            if (pacmanFill && (ghostFills[0] || ghostFills[1] || ghostFills[2] || ghostFills[3]))
                                state <= LOSE;
                            else if (score >= 36)
                                state <= WIN;
                            // RTL operations
                            if (pellets[pacX][pacY] == 1) begin
                                pellets[pacX][pacY] <= 0;
                                score <= score + 1;
                            end

                        WIN:
                            winOut <= 1;
                            if (ack)
                                state <= INI;
                        LOSE:
                            loseOut <= 1;
                            if (ack)
                                state <= INI;

                    endcase
                end
        end
	end

    
endmodule