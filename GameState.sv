module GameState (input logic 			Clk,
													Reset,
						input logic          W_Pressed, A_Pressed, S_Pressed, D_Pressed, Space_Pressed,
						input logic [3:0]    gameTime,
						input logic [1:0]    pauseTime,
						input logic [1:0]    readyTime, DiveKickTime,
						input logic     		P1_Hit_Detected, P2_Hit_Detected,
						input logic [2:0]    POne_Score, PTwo_Score,
						output logic [3:0] 	gameState,
						output logic 			POne_Increment, PTwo_Increment
						);
						
	enum logic [3:0] {	Title,             	//4'b0000
								Char_Sel,				//4'b0001
								Stage_Sel,				//4'b0010
								Playing,					//4'b0011
								Pause_State,			//4'b0100
								Reset_State,			//4'b0101
								Pause_State_2,			//4'b0110
								Victory_State,			//4'b0111
								Ready_State,			//4'b1000
								DiveKick_State 		//4'b1001
							} State, Next_State;
	always_ff @ (posedge Clk)
	begin
		if(Reset)
			State <= Title;
		else
			State <= Next_State;
	end
	
	always_comb
	begin
		//default: stay in current state
		Next_State = State; 
		POne_Increment = 1'b0;
		PTwo_Increment = 1'b0;
		gameState = 4'b000;
		
		unique case (State)
			Title :
				if(Space_Pressed)
					Next_State = Ready_State; //temporary -> Next_State = Char_Sel;
			Ready_State :
				if(readyTime == 2'd1) //show the round number for 1 second
					Next_State = DiveKick_State;
			DiveKick_State : //show the divekick screen for half a second
				if(DiveKickTime == 2'd1) 
					Next_State = Playing;
			Playing : 
				if(gameTime == 4'd0000 || P1_Hit_Detected == 1'b1 || P2_Hit_Detected == 1'b1)//if collision or time out
					Next_State = Pause_State;
			Pause_State :
					Next_State = Pause_State_2;
			Pause_State_2 : 
				if(pauseTime == 3'd2)
					Next_State = Reset_State;
			Reset_State : // state to reset the game to the start positions.
				begin
				if(POne_Score == 3'd5 || PTwo_Score == 3'd5) // check scores before going to next state
					Next_State = Victory_State;
				if(Space_Pressed)
					Next_State = Ready_State;
				end
			Victory_State :
				begin
				if(W_Pressed)
					Next_State = Title;
				end
			default :
				Next_State = Title;
		endcase
		
		case (State)
			Title :
				gameState = 4'b0000;
			Playing :
				begin
				gameState = 4'b0011;
				end
			Pause_State : //increase the scores here
				begin
				if(P1_Hit_Detected == 1'b1)
					POne_Increment = 1'b1;
				if(P2_Hit_Detected == 1'b1)
					PTwo_Increment = 1'b1;
				gameState = 4'b0100;
				end
			Pause_State_2 :
				begin
					gameState = 4'b0110;
				end
			Reset_State :
				begin
					gameState = 4'b0101;
				end
			Victory_State :
				begin
					gameState = 4'b0111;
				end
			Ready_State :
				begin
					gameState = 4'b1000;
				end
			DiveKick_State :
				begin
					gameState = 4'b1001;
				end
			default: ;
		endcase
	end
endmodule