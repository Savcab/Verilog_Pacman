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
	input ghostFills,
	input pacmanFill,
	output reg [15:0] score,
	output reg [11:0] rgb,
	output winOut,
	output loseOut,
    output [479:0] new_pellets [639:0]
    );

	reg [4:0] state;
    // inialize new_pellets
	for(int i = 0; i < $size(pellets) ; i++)
		for(int j = 0 ; j < $size(pellets[0]) ; j++)
            new_pellets[i][j] = pellets[i][j];

    // winning and losing conditions
	
	localparam
	INI = 4'b0001,
	STANDBY = 4'b0010,
	WIN = 4'b0100,
	LOSE = 4'b1000;

    assign win = (state == WIN || (state == STANDBY && score >= 36));
    assign lose = (state == LOSE || (state == STANDBY && pacmanFill && ghostFills));
    assign winOut = win;
    assign loseOut = lose;


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
                            begin
                            if (start)
                                state <= STANDBY;
                            score <= 0;
                            end
                        STANDBY:
                            begin
                            // state transitions
                            if (lose)
                                state <= LOSE;
                            else if (win)
                                state <= WIN;
                            // RTL operations
                            if (pellets[pacX][pacY] == 1) begin
                                new_pellets[pacX][pacY] <= 0;
                                score <= score + 1;
                            end
                            end
                        WIN:
                            begin
                            if (ack)
                                state <= INI;
                            end
                        LOSE:
                            begin
                            if (ack)
                                state <= INI;
                            end
                    endcase
                end
        end
	end

    
endmodule