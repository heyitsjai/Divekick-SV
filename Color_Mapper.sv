//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( //input              is_ball,            // Whether current pixel belongs to ball 
                       input Clk,                                       //   or background (computed in ball.sv)
							  input [9:0] PlayerOneX, PlayerOneY, PlayerTwoX, PlayerTwoY,
							  input [2:0] P1_DKS, P2_DKS,
							  input logic [3:0] GameState,
							  input logic [2:0] P1_Score, P2_Score,
							  input logic [3:0] Round_Time,
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
							  input logic P1_Hit, P2_Hit,
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
	 logic [18:0] Addr;
	 logic [3:0] SpriteData;
	 logic [3:0] TotalScore;
	 //frameRAM memory_contents(.read_address(Addr), .Clk(Clk), .data_Out(spriteData));
	 //Words&Letters
	 logic [3:0] memTitleScreen[10899:0];
	 logic [3:0] memWordPlayer[1781:0];
	 logic [3:0] memWordKO[2554:0];
	 logic [3:0] memWordVictory[8364:0];
	 logic [3:0] memWordRound[1691:0];
	 logic [3:0] memWordDiveKickStart[2483:0];
	 
	 //blue character sprites
	 logic [3:0] memBlueIdle[5279:0];
	 logic [3:0] memBlueDive[5279:0];
	 logic [3:0] memBlueKick[5279:0];
	 logic [3:0] memBlueIdleR[5279:0];
	 logic [3:0] memBlueDiveR[5279:0];
	 logic [3:0] memBlueKickR[5279:0];
	 
	 //red character sprites
	 logic [3:0] memRedIdle[5279:0];
	 logic [3:0] memRedDive[5279:0];
	 logic [3:0] memRedKick[5279:0];
	 logic [3:0] memRedIdleR[5279:0];
	 logic [3:0] memRedDiveR[5279:0];
	 logic [3:0] memRedKickR[5279:0];
	 
	 //numbers
	 logic [3:0] memNumOne[287:0];
	 logic [3:0] memNumTwo[287:0];
	 logic [3:0] memNumThree[287:0];
	 logic [3:0] memNumFour[287:0];
	 logic [3:0] memNumFive[287:0];
	 logic [3:0] memNumSix[287:0];
	 logic [3:0] memNumSeven[287:0];
	 logic [3:0] memNumEight[287:0];
	 logic [3:0] memNumNine[287:0];
	 logic [3:0] memNumZero[287:0];
	 
	 //score
	 logic [3:0] memCircleYellow[255:0];
	 logic [3:0] memCircleGrey[255:0];
	 
	 logic SpriteDataFound;
	 logic CharacterOverlap;
	 
	 assign TotalScore = P1_Score + P2_Score;
	 initial
	 begin
		//words
		$readmemh("sprite_bytes/DiveKick.txt", memTitleScreen);
		$readmemh("sprite_bytes/Player.txt", memWordPlayer);
		$readmemh("sprite_bytes/KO.txt", memWordKO);
		$readmemh("sprite_bytes/VICTORY.txt", memWordVictory);
		$readmemh("sprite_bytes/round.txt", memWordRound);
		$readmemh("sprite_bytes/divekickstart.txt", memWordDiveKickStart);
		
		
		//blue character sprites
		$readmemh("sprite_bytes/BlueIdle.txt", memBlueIdle);
		$readmemh("sprite_bytes/BlueDive.txt", memBlueDive);
		$readmemh("sprite_bytes/BlueKick.txt", memBlueKick);
		$readmemh("sprite_bytes/BlueIdleR.txt", memBlueIdleR);
		$readmemh("sprite_bytes/BlueDiveR.txt", memBlueDiveR);
		$readmemh("sprite_bytes/BlueKickR.txt", memBlueKickR);
		
		//red character sprites
		$readmemh("sprite_bytes/RedIdle.txt", memRedIdle);
		$readmemh("sprite_bytes/RedDive.txt", memRedDive);
		$readmemh("sprite_bytes/RedKick.txt", memRedKick);
		$readmemh("sprite_bytes/RedIdleR.txt", memRedIdleR);
		$readmemh("sprite_bytes/RedDiveR.txt", memRedDiveR);
		$readmemh("sprite_bytes/RedKickR.txt", memRedKickR);
		
		//number sprites
		$readmemh("sprite_bytes/Num1.txt", memNumOne);
		$readmemh("sprite_bytes/Num2.txt", memNumTwo);
		$readmemh("sprite_bytes/Num3.txt", memNumThree);
		$readmemh("sprite_bytes/Num4.txt", memNumFour);
		$readmemh("sprite_bytes/Num5.txt", memNumFive);
		$readmemh("sprite_bytes/Num6.txt", memNumSix);
		$readmemh("sprite_bytes/Num7.txt", memNumSeven);
		$readmemh("sprite_bytes/Num8.txt", memNumEight);
		$readmemh("sprite_bytes/Num9.txt", memNumNine);
		$readmemh("sprite_bytes/Num0.txt", memNumZero);
		
		//circles
		$readmemh("sprite_bytes/YellowCircle.txt", memCircleYellow);
		$readmemh("sprite_bytes/GreyCircle.txt", memCircleGrey);
		
	 end
	 
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    // Assign color based on is_ball signal
    always_comb
    begin
		//spriter arbiter (calculate address)
		SpriteData = 4'b0000;
		SpriteDataFound = 1'b0;
		CharacterOverlap = 1'b0;
		
		//draw title
		if(GameState == 4'b0000 && DrawX >= 10'd213 && DrawX <= 10'd430 && DrawY >= 10'd70 && DrawY < 10'd120)
		begin
			SpriteDataFound = 1'b1;
			SpriteData = memTitleScreen[(DrawX-10'd213) + (DrawY-10'd70)*218];
		end
		
		//draw the word player
		else if ((GameState > 4'b0000) && (DrawX >= 10'd20) && (DrawX <= 10'd100) && (DrawY >= 10'd20) && (DrawY <= 10'd41))
		begin
			SpriteDataFound = 1'b1;
			SpriteData = memWordPlayer[(DrawX-10'd20) + (DrawY-10'd20)*81];
		end
		
		//draw the word 1
		else if ((GameState > 4'b0000) && (DrawX >= 10'd102) && (DrawX <= 10'd117) && (DrawY >= 10'd20) && (DrawY <= 10'd37))
		begin
			SpriteDataFound = 1'b1;
			SpriteData = memNumOne[(DrawX-10'd102) + (DrawY-10'd20)*16];
		end
		
		//draw the word player
		else if ((GameState > 4'b0000) && (DrawX >= 10'd522 ) && (DrawX <= 10'd602) && (DrawY >= 10'd20) && (DrawY <= 10'd41))
		begin
			SpriteDataFound = 1'b1;
			SpriteData = memWordPlayer[(DrawX-10'd522) + (DrawY-10'd20)*81];
		end
		
		//draw the word 2
		else if ((GameState > 4'b0000) && (DrawX >= 10'd604) && (DrawX <= 10'd620) && (DrawY >= 10'd20) && (DrawY <= 10'd37))
		begin
			SpriteDataFound = 1'b1;
			SpriteData = memNumTwo[(DrawX-10'd604) + (DrawY-10'd20)*16];
		end
		
		//draw the five circles
		else if ((GameState > 4'b0000) && (DrawX >= 10'd20) && (DrawX <= 10'd35) && (DrawY >= 10'd43) && (DrawY <= 10'd58))//circle 1
		begin
			SpriteDataFound = 1'b1;
			if(P1_Score == 3'd5)
				SpriteData = memCircleYellow[(DrawX-10'd20) + (DrawY-10'd43)*16];
			else
				SpriteData = memCircleGrey[(DrawX-10'd20) + (DrawY-10'd43)*16];
		end
		else if ((GameState > 4'b0000) && (DrawX >= 10'd39) && (DrawX <= 10'd54) && (DrawY >= 10'd43) && (DrawY <= 10'd58)) //circle 2
		begin
			SpriteDataFound = 1'b1;
			if(P1_Score >= 3'd4)
				SpriteData = memCircleYellow[(DrawX-10'd39) + (DrawY-10'd43)*16];
			else
				SpriteData = memCircleGrey[(DrawX-10'd39) + (DrawY-10'd43)*16];
		end
		else if ((GameState > 4'b0000) && (DrawX >= 10'd58) && (DrawX <= 10'd73) && (DrawY >= 10'd43) && (DrawY <= 10'd58)) //circle 3
		begin
			SpriteDataFound = 1'b1;
			if(P1_Score >= 3'd3)
				SpriteData = memCircleYellow[(DrawX-10'd58) + (DrawY-10'd43)*16];
			else
				SpriteData = memCircleGrey[(DrawX-10'd58) + (DrawY-10'd43)*16];
		end
		else if ((GameState > 4'b0000) && (DrawX >= 10'd77) && (DrawX <= 10'd92) && (DrawY >= 10'd43) && (DrawY <= 10'd58)) //circle 4
		begin
			SpriteDataFound = 1'b1;
			if(P1_Score >= 3'd2)
				SpriteData = memCircleYellow[(DrawX-10'd77) + (DrawY-10'd43)*16];
			else
				SpriteData = memCircleGrey[(DrawX-10'd77) + (DrawY-10'd43)*16];
		end
		else if ((GameState > 4'b0000) && (DrawX >= 10'd96) && (DrawX <= 10'd111) && (DrawY >= 10'd43) && (DrawY <= 10'd58)) //circle 5
		begin
			SpriteDataFound = 1'b1;
			if(P1_Score >= 3'd1)
				SpriteData = memCircleYellow[(DrawX-10'd96) + (DrawY-10'd43)*16];
			else
				SpriteData = memCircleGrey[(DrawX-10'd96) + (DrawY-10'd43)*16];
		end
		//player 2 score
		else if ((GameState > 4'b0000) && (DrawX >= 10'd522) && (DrawX <= 10'd537) && (DrawY >= 10'd43) && (DrawY <= 10'd58))//circle 1
		begin
			SpriteDataFound = 1'b1;
			if(P2_Score >= 3'd1)
				SpriteData = memCircleYellow[(DrawX-10'd522) + (DrawY-10'd43)*16];
			else
				SpriteData = memCircleGrey[(DrawX-10'd522) + (DrawY-10'd43)*16];
		end
		else if ((GameState > 4'b0000) && (DrawX >= 10'd541) && (DrawX <= 10'd556) && (DrawY >= 10'd43) && (DrawY <= 10'd58)) //circle 2
		begin
			SpriteDataFound = 1'b1;
			if(P2_Score >= 3'd2)
				SpriteData = memCircleYellow[(DrawX-10'd541) + (DrawY-10'd43)*16];
			else
				SpriteData = memCircleGrey[(DrawX-10'd541) + (DrawY-10'd43)*16];
		end
		else if ((GameState > 4'b0000) && (DrawX >= 10'd560) && (DrawX <= 10'd575) && (DrawY >= 10'd43) && (DrawY <= 10'd58)) //circle 3
		begin
			SpriteDataFound = 1'b1;
			if(P2_Score >= 3'd3)
				SpriteData = memCircleYellow[(DrawX-10'd560) + (DrawY-10'd43)*16];
			else
				SpriteData = memCircleGrey[(DrawX-10'd560) + (DrawY-10'd43)*16];
		end
		else if ((GameState > 4'b0000) && (DrawX >= 10'd579) && (DrawX <= 10'd594) && (DrawY >= 10'd43) && (DrawY <= 10'd58)) //circle 4
		begin
			SpriteDataFound = 1'b1;
			if(P2_Score >= 3'd4)
				SpriteData = memCircleYellow[(DrawX-10'd579) + (DrawY-10'd43)*16];
			else
				SpriteData = memCircleGrey[(DrawX-10'd579) + (DrawY-10'd43)*16];
		end
		
		else if ((GameState > 4'b0000) && (DrawX >= 10'd598) && (DrawX <= 10'd613) && (DrawY >= 10'd43) && (DrawY <= 10'd58)) //circle 5
		begin
			SpriteDataFound = 1'b1;
			if(P2_Score == 3'd5)
				SpriteData = memCircleYellow[(DrawX-10'd598) + (DrawY-10'd43)*16];
			else
				SpriteData = memCircleGrey[(DrawX-10'd598) + (DrawY-10'd43)*16];
		end
		//draw player 1
		else if ((GameState > 4'b0000) && (DrawX >= (PlayerOneX - 10'd30)) && (DrawX  < (PlayerOneX + 10'd30)) && (DrawY >= (PlayerOneY- 10'd44)) && (DrawY <= (PlayerOneY + 10'd44)))
		begin
			SpriteDataFound = 1'b1;
			case (P1_DKS)
				3'b000 : //idle
				begin
					if(PlayerOneX < PlayerTwoX)
						SpriteData = memBlueIdle[(DrawX-(PlayerOneX-10'd30)) + (DrawY-(PlayerOneY-10'd44))*19'd60];
					else
						SpriteData = memBlueIdleR[(DrawX-(PlayerOneX-10'd30)) + (DrawY-(PlayerOneY-10'd44))*19'd60];
				end
				3'b001 : //dive
				begin
					if(PlayerOneX < PlayerTwoX)
						SpriteData = memBlueDive[(DrawX-(PlayerOneX-10'd30)) + (DrawY-(PlayerOneY-10'd44))*19'd60];
					else
						SpriteData = memBlueDiveR[(DrawX-(PlayerOneX-10'd30)) + (DrawY-(PlayerOneY-10'd44))*19'd60];
				end
				3'b010 : //kick left
				begin
						SpriteData = memBlueKick[(DrawX-(PlayerOneX-10'd30)) + (DrawY-(PlayerOneY-10'd44))*19'd60];
				end
				3'b011 : //maybe kick right? - change 
				begin
						SpriteData = memBlueKickR[(DrawX-(PlayerOneX-10'd30)) + (DrawY-(PlayerOneY-10'd44))*19'd60];
				end
				3'b100:
				begin
					if(PlayerOneX < PlayerTwoX)
						SpriteData = memBlueDive[(DrawX-(PlayerOneX-10'd30)) + (DrawY-(PlayerOneY-10'd44))*19'd60];
					else
						SpriteData = memBlueDiveR[(DrawX-(PlayerOneX-10'd30)) + (DrawY-(PlayerOneY-10'd44))*19'd60];
				end
			endcase
			
			if((DrawX >= (PlayerTwoX - 10'd29)) && (DrawX < (PlayerTwoX + 10'd30)) && (DrawY >= (PlayerTwoY- 10'd44)) && (DrawY <= (PlayerTwoY + 10'd44)))
			begin
				if (SpriteData == 4'b0000) 
				begin
				unique case (P2_DKS)
				3'b000 :
				begin
					if(PlayerTwoX < PlayerOneX)
						SpriteData = memRedIdle[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
					else
						SpriteData = memRedIdleR[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				end
				3'b001 :
				begin
					if(PlayerTwoX < PlayerOneX)
						SpriteData = memRedDive[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
					else
						SpriteData = memRedDiveR[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				end
				3'b010 :
				begin
				//	if(PlayerTwoX < PlayerOneX)
						SpriteData = memRedKick[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				//	else
					//	SpriteData = memRedKickR[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				end
				3'b011 :
				begin
					//if(PlayerTwoX < PlayerOneX)
					//	SpriteData = memRedDive[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
					//else
						SpriteData = memRedKickR[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				end
				3'b100 :
				begin
					if(PlayerTwoX < PlayerOneX)
						SpriteData = memRedDive[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
					else
						SpriteData = memRedDiveR[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				end
			endcase
			end
			end
		end
		// Player 2
		else if ((GameState > 4'b0000) && (DrawX >= (PlayerTwoX - 10'd30)) && (DrawX < (PlayerTwoX + 10'd30)) && (DrawY >= (PlayerTwoY- 10'd44)) && (DrawY <= (PlayerTwoY + 10'd44)))
		begin
			SpriteDataFound = 1'b1;
			unique case (P2_DKS)
				3'b000 :
				begin
					if(PlayerTwoX < PlayerOneX)
						SpriteData = memRedIdle[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
					else
						SpriteData = memRedIdleR[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				end
				3'b001 :
				begin
					if(PlayerTwoX < PlayerOneX)
						SpriteData = memRedDive[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
					else
						SpriteData = memRedDiveR[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				end
				3'b010 :
				begin
				//	if(PlayerTwoX < PlayerOneX)
						SpriteData = memRedKick[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				//	else
					//	SpriteData = memRedKickR[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				end
				3'b011 :
				begin
					//if(PlayerTwoX < PlayerOneX)
					//	SpriteData = memRedDive[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
					//else
						SpriteData = memRedKickR[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				end
				3'b100 :
				begin
					if(PlayerTwoX < PlayerOneX)
						SpriteData = memRedDive[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
					else
						SpriteData = memRedDiveR[(DrawX-(PlayerTwoX-10'd30)) + (DrawY-(PlayerTwoY-10'd44))*19'd60];
				end
			endcase
		end
		//10's place
		else if ((GameState > 4'b0000) && (DrawX >= 10'd304) && (DrawX <= 10'd319) && (DrawY >= 10'd20) && (DrawY <= 10'd37)) //10's place
		begin
			SpriteDataFound = 1'b1;
			if(Round_Time >= 4'd10)
				SpriteData = memNumOne[(DrawX-(10'd304)) + (DrawY-10'd20)*16];
			else
				SpriteData = memNumZero[(DrawX-(10'd304)) + (DrawY-10'd20)*16];
		end
		//1's place
		else if ((GameState > 4'b0000) && (DrawX >= 10'd321) && (DrawX <= 10'd336) &&(DrawY >= 10'd20) && (DrawY <= 10'd37))
		begin
			SpriteDataFound = 1'b1;
			case (Round_Time)
				4'b0000 : 
					SpriteData = memNumZero[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b1010 :
					SpriteData = memNumZero[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b0001 :
					SpriteData = memNumOne[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b1011 :
					SpriteData = memNumOne[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b0010 :
					SpriteData = memNumTwo[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b1100 :
					SpriteData = memNumTwo[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b0011 :
					SpriteData = memNumThree[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b1101 :
					SpriteData = memNumThree[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b0100 :
					SpriteData = memNumFour[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b1110 :
					SpriteData = memNumFour[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b0101 :
					SpriteData = memNumFive[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b1111 :
					SpriteData = memNumFive[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b0110 :
					SpriteData = memNumSix[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b0111 :
					SpriteData = memNumSeven[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b1000 :
					SpriteData = memNumEight[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
				4'b1001 :
					SpriteData = memNumNine[(DrawX-(10'd321)) + (DrawY-10'd20)*16];
			endcase
		end
		//draw ko during pause
		else if ((GameState > 4'b0000) && (P1_Hit || P2_Hit) && (DrawX >= 10'd283) && (DrawX <= 10'd355) &&(DrawY >= 10'd60) && (DrawY <= 10'd94))
		begin
			SpriteDataFound = 1'b1;
			SpriteData = memWordKO[(DrawX-(10'd283)) + (DrawY-10'd60)*73];
		end
		//draw victory
		else if((GameState == 4'b0111) && (DrawX >= 10'd200 ) && (DrawX <= 10'd438) &&(DrawY >= 10'd60) && (DrawY <= 10'd94))
		begin
			SpriteDataFound = 1'b1;
			SpriteData = memWordVictory[(DrawX-10'd200) + (DrawY-10'd60)*239];
		end
		else if ((GameState == 4'b0111) && (DrawX >= 10'd270) && (DrawX <= 10'd350) && (DrawY >= 10'd96) && (DrawY<=10'd117))
		begin
			SpriteDataFound = 1'b1;
			SpriteData = memWordPlayer[(DrawX-10'd270) + (DrawY-10'd96) * 81];
		end
		else if ((GameState == 4'b0111) && (DrawX >= 10'd352) && (DrawX <= 10'd367) && (DrawY >= 10'd96) && (DrawY<=10'd113))
		begin
			SpriteDataFound = 1'b1;
			if(P1_Score == 10'd5)
				SpriteData = memNumOne[(DrawX-10'd352) + (DrawY-10'd96) * 16];
			else
				SpriteData = memNumTwo[(DrawX-10'd352) + (DrawY-10'd96) * 16];
		end
		/*Drawing the Round number */
		else if ((GameState == 4'b1000) && (DrawX >= 10'd264 ) && (DrawX <= 10'd357) &&(DrawY >= 10'd60) && (DrawY <= 10'd77))
		begin
			SpriteDataFound = 1'b1;
			SpriteData = memWordRound[(DrawX-10'd264) + (DrawY-10'd60)*94];
		end
		else if ((GameState == 4'b1000) && (DrawX >= 10'd359 ) && (DrawX <= 10'd374) &&(DrawY >= 10'd60) && (DrawY <= 10'd77))
		begin
			SpriteDataFound = 1'b1;
			case (TotalScore)
				4'b0000 : 
					SpriteData = memNumOne[(DrawX-10'd359) + (DrawY-10'd60)*16];
				4'b0001 : 
					SpriteData = memNumTwo[(DrawX-10'd359) + (DrawY-10'd60)*16];
				4'b0010 : 
					SpriteData = memNumThree[(DrawX-10'd359) + (DrawY-10'd60)*16];
				4'b0011 : 
					SpriteData = memNumFour[(DrawX-10'd359) + (DrawY-10'd60)*16];
				4'b0100 : 
					SpriteData = memNumFive[(DrawX-10'd359) + (DrawY-10'd60)*16];
				4'b0101 : 
					SpriteData = memNumSix[(DrawX-10'd359) + (DrawY-10'd60)*16];
				4'b0110 : 
					SpriteData = memNumSeven[(DrawX-10'd359) + (DrawY-10'd60)*16];
				4'b0111 : 
					SpriteData = memNumEight[(DrawX-10'd359) + (DrawY-10'd60)*16];
				4'b1000 : 
					SpriteData = memNumNine[(DrawX-10'd359) + (DrawY-10'd60)*16];
				default :
					SpriteData = memNumZero[(DrawX-10'd359) + (DrawY-10'd60)*16];
			endcase
		end
		else if ((GameState == 4'b1001) && (DrawX >= 10'd251 ) && (DrawX <= 10'd388) &&(DrawY >= 10'd60) && (DrawY <= 10'd77)) //draw divekick!
		begin
			SpriteDataFound = 1'b1;
			SpriteData = memWordDiveKickStart[(DrawX-10'd251) + (DrawY-10'd60)*138];
		end
		
		if(SpriteDataFound == 1'b1)
		begin
		unique case (SpriteData)
					4'b0000 :
					begin
						Red = 8'h3f;
						Green = 8'h00;
						Blue = 8'h7f - {1'b0, DrawX[9:3]};
					end
					4'b0001 : //black
					begin
						Red = 8'h00;
						Green = 8'h00;
						Blue = 8'h00;
					end
					4'b0010 : //grey
					begin
						Red = 8'hE0;
						Green = 8'hE0;
						Blue = 8'hE0;
					end
					4'b0011 : //brown
					begin
						Red = 8'h80;
						Green = 8'h40;
						Blue = 8'h20;
					end
					4'b0100 : //redish
					begin
						Red = 8'hF0;
						Green = 8'h40;
						Blue = 8'h10;
					end
					4'b0101 : //blue
					begin
						Red = 8'h00;
						Green = 8'h40;
						Blue = 8'hF0;
					end
					4'b0110 : //tan
					begin
						Red = 8'hF8;
						Green = 8'hB0;
						Blue = 8'h80;
					end
					4'b0111 : //another brown
					begin
						Red = 8'hB8;
						Green = 8'h60;
						Blue = 8'h48;
					end
					4'b1000 : //red
					begin
						Red = 8'hF0;
						Green = 8'h00;
						Blue = 8'h00;
					end
					4'b1001 : //yellow
					begin
						Red = 8'hFF;
						Green = 8'hD8;
						Blue = 8'h00;
					end
					4'b1010 : //blue
					begin
						Red = 8'h00;
						Green = 8'h26;
						Blue = 8'hFF;
					end
					4'b1011 : //grey
					begin
						Red = 8'h80;
						Green = 8'h80;
						Blue = 8'h80;
					end
					default : 
					begin
						Red = 8'h3f; 
						Green = 8'h00;
						Blue = 8'h7f - {1'b0, DrawX[9:3]};
					end
				endcase
		end
		else if ((GameState == 4'b0011) && (DrawX >= 10'd318) && (DrawX <= 10'd321) && (DrawY > 10'd60) && (DrawY < 10'd400) && (Round_Time <= 4'd3))
		begin
			Red = 8'hF0;
			Green = 8'h00;
			Blue = 8'h00;
		end
		else if (DrawY >= 10'd400) //bottom of the screen
		 begin
			Red = 8'h80;
			Green = 8'h40;
			Blue = 8'h20;
		end
      else 
        begin
            // Background with nice color gradient
           // Red = 8'h00 + {1'b0, DrawX[9:3]};//8'h3f; 
          //  Green = 8'hF2;//8'h00;
           // Blue = 8'hff;//8'h7f - {1'b0, DrawX[9:3]};
						Red = 8'h3f; 
						Green = 8'h00;
						Blue = 8'h7f - {1'b0, DrawX[9:3]};
        end
    end 
    
		//***************************************//
		//******************old shit*************//
		//***************************************//
		
		/*if(DrawX >= 10'd0 && DrawX <= 10'd29 && DrawY >= 10'd0 && DrawY <= 10'd31)
		  begin
				Addr = (DrawX+10'd104) + (DrawY+10'd15)*144;*/
				
      //else if (/*(GameState > 3'b000) &&*/ (DrawX >= (PlayerOneX - 10'd24)) && (DrawX <= (PlayerOneX + 10'd24)) && (DrawY >= (PlayerOneY- 10'd24)) && (DrawY <= (PlayerOneY + 10'd24))) 
      // begin
      //     // White player
		//		unique case (P1_DKS)
		//		endcase
      //     Red = 8'hff;
      //     Green = 8'hff;
      //     Blue = 8'hff;
      // end
		// else if (/*(GameState > 3'b000) && */(DrawX >= (PlayerTwoX - 10'd24)) && (DrawX <= (PlayerTwoX + 10'd24)) && (DrawY >= (PlayerTwoY- 10'd24)) && (DrawY <= (PlayerTwoY + 10'd24))) 
      // begin
      //     // Black player
      //     Red = 8'h00;
      //     Green = 8'h00;
      //     Blue = 8'h00;
      // end
		
endmodule

