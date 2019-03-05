module keycode_reader(	input logic [31:0] keycode,
								output logic pone_dive, pone_kick, ptwo_dive, ptwo_kick, game_start
								);

								//8'h1A should be swapped to whichever key we use for each button
assign pone_dive = (keycode[31:24] == 8'h1A | keycode[23:16] == 8'h1A | keycode[15:8] == 8'h1A | keycode[7:0] == 8'h1A); //w
assign pone_kick = (keycode[31:24] == 8'h04 | keycode[23:16] == 8'h04 | keycode[15:8] == 8'h04 | keycode[7:0] == 8'h04); //a
assign ptwo_dive = (keycode[31:24] == 8'h16 | keycode[23:16] == 8'h16 | keycode[15:8] == 8'h16 | keycode[7:0] == 8'h16); //s
assign ptwo_kick = (keycode[31:24] == 8'h07 | keycode[23:16] == 8'h07 | keycode[15:8] == 8'h07 | keycode[7:0] == 8'h07); //d
assign game_start = (keycode[31:24] == 8'h2C | keycode[23:16] == 8'h2C | keycode[15:8] == 8'h2C | keycode[7:0] == 8'h2C); //d
endmodule
