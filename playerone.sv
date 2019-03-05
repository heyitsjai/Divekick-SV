module  player_one ( input   Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz) (VGA_VS)
									  dive,					 // someone has pressed dive
									  kick,					 // someone has pressed kick
							        PlayerNum,
						   input  [3:0] GameState,
							input  [9:0] OtherPlayerX,
							output [9:0] PlayerX, PlayerY, //changed isball to output the player's current coordinates
							output [2:0] divekickstatus 		//(000 -> idle, 001 -> jumping, 010 -> kicking towards right, 011 -> kicking towards left, 100 -> falling)
              );
				  
	 parameter [9:0] P1_Ball_X_Center = 10'd213;  // Center position on the X axis for player 1
	 parameter [9:0] P2_Ball_X_Center = 10'd426;  // Center position on the X axis for player 1
    //parameter [9:0] Ball_Y_Center = 10'd240;  // Center position on the Y axis 
    parameter [9:0] Ball_X_Min = 10'd4;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd61;       // Topmost point on the Y axis *****MIGHT NEED TO CHANGE*****
    parameter [9:0] Ball_Y_Max = 10'd399;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd3;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step = 10'd3;      // Step size on the Y axis
    parameter [9:0] Ball_Height = 10'd44;     // Ball size (height)
	 parameter [9:0] Ball_Width = 10'd30; 	    // Rectangle width.
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 logic [2:0] whatdo, whatdo_in; // 3'b000 -> idle, 3'b001 -> jumping, 3'b010 -> kicking right, 3'b011 -> kicking left 3'b100 -> falling
    
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if(Reset || (GameState == 4'b0000) || (GameState == 4'b0101)) //for later when we add the reset state
		  //if(Reset)
        begin
				if(PlayerNum)
					Ball_X_Pos <= P2_Ball_X_Center;
				else
					Ball_X_Pos <= P1_Ball_X_Center;

				Ball_Y_Pos <= Ball_Y_Max - Ball_Height;
				Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
				whatdo <= 3'd0;
        end
        else if (GameState == 4'b0011)
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
				whatdo <= whatdo_in;
        end
		  else
		  begin
		      Ball_X_Pos <= Ball_X_Pos;
            Ball_Y_Pos <= Ball_Y_Pos;
            Ball_X_Motion <= Ball_X_Motion;
            Ball_Y_Motion <= Ball_Y_Motion;
				whatdo <= whatdo;
		  end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion;
        Ball_Y_Motion_in = Ball_Y_Motion;
		  whatdo_in = whatdo;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge && GameState == 4'b0011)
        begin
				if(dive && (Ball_Y_Pos + Ball_Height >= Ball_Y_Max)) //bottom of screen, jumping pressed
					begin
						Ball_X_Motion_in = 10'd0; //clear horizontal motion (for now)
						//Ball_Y_Motion_in = Ball_Y_Motion_in + (~10'd1) + 1; //start moving up
						Ball_Y_Motion_in = (~Ball_Y_Step) + 1'b1; //start moving up
						whatdo_in = 3'd1; //now jumping
					end
				else if (Ball_Y_Pos <= Ball_Y_Min + Ball_Height) //player is about to hit the top of the screen -> set motion to downwards. not dependent on dive or kick
					begin
						Ball_Y_Motion_in = Ball_Y_Step; //go straight down
					end
					//****** CHANGE NEXT ELSE IF TO KICK && JUMPCHECK?*********//
				else if (kick && whatdo == 3'd1 && (Ball_Y_Pos + Ball_Height < Ball_Y_Max )) //player is jumping and in midair -> start kicking
					begin
						if(Ball_X_Pos > OtherPlayerX) // if your character is more to the right than the opponent
							begin
							Ball_X_Motion_in = (~Ball_X_Step) + 1'b1; //kicking to the left
							whatdo_in = 3'd3;
							end
						else //character more to the left than opponent
							begin
							Ball_X_Motion_in = Ball_X_Step;
							whatdo_in = 3'd2; //now kicking to the right
							end
						//Ball_X_Motion_in = Ball_X_Step; //start moving diagonally forward (change to with respect to other player)
						Ball_Y_Motion_in = Ball_Y_Step;
					end
				else if (Ball_Y_Pos + Ball_Height >= Ball_Y_Max) //landed, not dependent on dive or kick
					begin
						Ball_X_Motion_in = 10'd0; //clear motion
						Ball_Y_Motion_in = 10'd0;
						whatdo_in = 3'd0;
					end
				else if ((whatdo == 3'd3) && (Ball_X_Pos - Ball_Width <= Ball_X_Min)) /*&& (Ball_Y_Pos + Ball_Height < Ball_Y_Max ))*/ //about to hit left wall & midair & kicking
					begin
						Ball_X_Motion_in = 10'd0;
						whatdo_in = 3'd4; //cancel your kick -> go into falling
					end
				else if ((whatdo == 3'd2) && (Ball_X_Pos + Ball_Width >= Ball_X_Max)) // && (Ball_Y_Pos + Ball_Height < Ball_Y_Max ))//about to hit right wall & midair
					//&& (Ball_X_Motion_in == Ball_X_Step)
					begin
						Ball_X_Motion_in = 10'd0;
						whatdo_in = 3'd4; //cancel your kick -> go into falling
					end
				
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
        end
        
    end
    assign PlayerX = Ball_X_Pos;
    assign PlayerY = Ball_Y_Pos;
	 assign divekickstatus = whatdo_in;

    
endmodule
