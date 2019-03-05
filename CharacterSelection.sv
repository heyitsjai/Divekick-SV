module CharacterSelection (input Clk, Reset,
									input  logic [3:0] Player_One_Char_Num, Player_Two_Char_Num,
									output logic [9:0] Player_One_Char_Height, 
															 Player_One_Char_Width,
															 Player_One_Jump_X,
															 Player_One_Kick_X,
															 Player_One_Jump_Y,
															 Player_One_Kick_Y,
															 Player_One_HB_Height,
															 Player_One_HB_Width,
															 Player_Two_Char_Height, 
															 Player_Two_Char_Width,
															 Player_Two_Jump_X,
															 Player_Two_Kick_X,
															 Player_Two_Jump_Y,
															 Player_Two_Kick_Y,
															 Player_Two_HB_Height,
															 Player_Two_HB_Width
);
always_comb
begin
	unique case (Player_One_Char_Num)
		4'b0000 : //character 1
			begin
				Player_One_Char_Height 	= 10'd16;
				Player_One_Char_Width	= 10'd16;
				Player_One_Jump_X			= 10'd1;
				Player_One_Kick_X			= 10'd1;
				Player_One_Jump_Y			= 10'd1;
				Player_One_Kick_Y			= 10'd1;
				Player_One_HB_Height		= 10'd10;
				Player_One_HB_Width		= 10'd10;
			end
	endcase
		unique case (Player_Two_Char_Num)
		4'b0000 : //character 1
			begin
				Player_Two_Char_Height 	= 10'd16;
				Player_Two_Char_Width	= 10'd16;
				Player_Two_Jump_X			= 10'd1;
				Player_Two_Kick_X			= 10'd1;
				Player_Two_Jump_Y			= 10'd1;
				Player_Two_Kick_Y			= 10'd1;
				Player_Two_HB_Height		= 10'd10;
				Player_Two_HB_Width		= 10'd10;
			end
	endcase
end
endmodule