module GameEngine(input CLK, Reset,
						input logic [9:0] P1_X, P1_Y, P2_X, P2_Y,
												Player_One_Char_Height, 
												Player_One_Char_Width,
												Player_One_HB_Height,
												Player_One_HB_Width,
												Player_Two_Char_Height, 
												Player_Two_Char_Width,
												Player_Two_HB_Height,
												Player_Two_HB_Width,
						input logic [2:0] P1_Status, P2_Status,
						input logic [3:0] gameTime,
						output logic P1_Hit_Detected, P2_Hit_Detected //00 -> no win, 01 -> p1win, 10 -> p2 win, 11 -> tie
						);
						
logic [9:0] PlayerOneHurtTopHeight, PlayerOneHurtBotHeight, PlayerOneHurtLeftWidth, PlayerOneHurtRightWidth;
logic [9:0] PlayerTwoHurtTopHeight, PlayerTwoHurtBotHeight, PlayerTwoHurtLeftWidth, PlayerTwoHurtRightWidth;
logic [9:0] P1_DistfromCenter, P2_DistfromCenter;
always_comb
begin
	//default
	case (P1_Status)
		3'b000 : //idle
		begin
			PlayerOneHurtTopHeight  = 10'd21;
			PlayerOneHurtBotHeight  = 10'd44;
			PlayerOneHurtLeftWidth  = 10'd30;
			PlayerOneHurtRightWidth = 10'd30;
		end
		3'b001 : //jumping
		begin
			PlayerOneHurtTopHeight  = 10'd38;
			PlayerOneHurtBotHeight  = 10'd44;
			PlayerOneHurtLeftWidth  = 10'd28;
			PlayerOneHurtRightWidth = 10'd28;
		end
		3'b010 : //kicking towards right
		begin
			PlayerOneHurtTopHeight  = 10'd44;
			PlayerOneHurtBotHeight  = 10'd44;
			PlayerOneHurtLeftWidth  = 10'd27;
			PlayerOneHurtRightWidth = 10'd30;
		end
		3'b011 : //kicking towards the left
		begin
			PlayerOneHurtTopHeight  = 10'd44;
			PlayerOneHurtBotHeight  = 10'd44;
			PlayerOneHurtLeftWidth  = 10'd30;
			PlayerOneHurtRightWidth = 10'd27;
		end
		3'b100 : //falling, same as jumping
		begin
			PlayerOneHurtTopHeight  = 10'd38;
			PlayerOneHurtBotHeight  = 10'd44;
			PlayerOneHurtLeftWidth  = 10'd28;
			PlayerOneHurtRightWidth = 10'd28;
		end
		default :
		begin
			PlayerOneHurtTopHeight  = 10'd44;
			PlayerOneHurtBotHeight  = 10'd44;
			PlayerOneHurtLeftWidth  = 10'd30;
			PlayerOneHurtRightWidth = 10'd30;
		end
	endcase
	case (P2_Status)
		3'b000 : //idle
		begin
			PlayerTwoHurtTopHeight  = 10'd21;
			PlayerTwoHurtBotHeight  = 10'd44;
			PlayerTwoHurtLeftWidth  = 10'd30;
			PlayerTwoHurtRightWidth = 10'd30;
		end 
				3'b001 : //jumping
		begin
			PlayerTwoHurtTopHeight  = 10'd38;
			PlayerTwoHurtBotHeight  = 10'd44;
			PlayerTwoHurtLeftWidth  = 10'd28;
			PlayerTwoHurtRightWidth = 10'd28;
		end
		3'b010 : //kicking towards right
		begin
			PlayerTwoHurtTopHeight  = 10'd44;
			PlayerTwoHurtBotHeight  = 10'd44;
			PlayerTwoHurtLeftWidth  = 10'd27;
			PlayerTwoHurtRightWidth = 10'd30;
		end
		3'b011 : //kicking towards the left
		begin
			PlayerTwoHurtTopHeight  = 10'd44;
			PlayerTwoHurtBotHeight  = 10'd44;
			PlayerTwoHurtLeftWidth  = 10'd30;
			PlayerTwoHurtRightWidth = 10'd27;
		end
		3'b100 : //falling, same as jumping
		begin
			PlayerTwoHurtTopHeight  = 10'd38;
			PlayerTwoHurtBotHeight  = 10'd44;
			PlayerTwoHurtLeftWidth  = 10'd28;
			PlayerTwoHurtRightWidth = 10'd28;
		end
		default :
		begin
			PlayerTwoHurtTopHeight  = 10'd44;
			PlayerTwoHurtBotHeight  = 10'd44;
			PlayerTwoHurtLeftWidth  = 10'd30;
			PlayerTwoHurtRightWidth = 10'd30;
		end
	endcase
	
	P1_Hit_Detected = 1'b0;
	P2_Hit_Detected = 1'b0;
	P1_DistfromCenter = 10'd0;
	P2_DistfromCenter = 10'd0;
	//if(P1_X < P2_X) //player 1 on left
	if(P1_Status == 3'd2) //player one kicking towards the right
	begin
		if((P1_X <= (P2_X + PlayerTwoHurtRightWidth)) && ((P1_X + Player_One_HB_Width) >= (P2_X - PlayerTwoHurtLeftWidth)) && 
		   (P1_Y <= (P2_Y + PlayerTwoHurtBotHeight)) && ((P1_Y + Player_One_HB_Height) >= (P2_Y - PlayerTwoHurtTopHeight))) //check for collision with the hitbox facing right
			if(P1_Y <= P2_Y)
				P1_Hit_Detected = 1'b1; 
	end
	else if(P1_Status == 3'd3) //kicking towards the left
	begin
		if(((P1_X-Player_One_HB_Width) <= (P2_X + PlayerTwoHurtRightWidth)) && (P1_X >= (P2_X - PlayerTwoHurtLeftWidth)) && 
			(P1_Y <= (P2_Y + PlayerTwoHurtBotHeight)) && ((P1_Y + Player_One_HB_Height) >= (P2_Y - PlayerTwoHurtTopHeight)))
			if(P1_Y <= P2_Y)
				P1_Hit_Detected = 1'b1; 
	end	
	if(P2_Status == 3'd2) //p2 kicking towards the right
	begin
		if((P2_X <= (P1_X + PlayerOneHurtRightWidth)) && ((P2_X + Player_Two_HB_Width) >= (P1_X - PlayerOneHurtLeftWidth)) && 
		   (P2_Y <= (P1_Y + PlayerOneHurtBotHeight)) && ((P2_Y + Player_Two_HB_Height) >= (P1_Y - PlayerOneHurtTopHeight))) //check for collision with the hitbox facing right
			if(P2_Y <= P1_Y)
				P2_Hit_Detected = 1'b1; 
	end
	else if (P2_Status == 3'd3) //p2 kicking to left
	begin
		if(((P2_X-Player_Two_HB_Width) <= (P1_X + PlayerOneHurtRightWidth)) && (P2_X >= (P1_X - PlayerOneHurtLeftWidth)) && 
			(P2_Y <= (P1_Y + PlayerOneHurtBotHeight)) && ((P2_Y + Player_Two_HB_Height) >= (P1_Y - PlayerOneHurtTopHeight)))
			if(P2_Y <= P1_Y)
				P2_Hit_Detected = 1'b1; 
	end
	
	if(gameTime == 4'd0) //time ran out!!
	begin
		if(P1_X > 10'd320)
			P1_DistfromCenter = P1_X - 10'd320;
		else 
			P1_DistfromCenter = 10'd320 - P1_X;
			
		if(P1_Y > 10'd320)
			P2_DistfromCenter = P2_X - 10'd320;
		else 
			P2_DistfromCenter = 10'd320 - P2_X;
			
		if(P1_DistfromCenter < P2_DistfromCenter)
			P1_Hit_Detected = 1'b1;
		else if (P2_DistfromCenter < P1_DistfromCenter)
			P2_Hit_Detected = 1'b1;
	end
	
end
endmodule