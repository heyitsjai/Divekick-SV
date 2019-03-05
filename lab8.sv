//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
    logic Reset_h, Clk;
    logic is_ball;
	 logic pone_dive, pone_kick, ptwo_dive, ptwo_kick, P1_hit_Detected, P2_hit_Detected, game_start;
    logic [31:0] keycode;
    logic [9:0] DrawX, DrawY, PoneX, PoneY, PtwoX, PtwoY;
	 logic [2:0] playerone_dks, playertwo_dks;
	 logic [3:0] r_time;
	 logic [1:0] p_time, ready_time, divekicktime;
	 logic [3:0] gameState;
	 logic [2:0] POne_Score, PTwo_Score, spriteData;
	 logic POne_Increment, PTwo_Increment;
    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     lab8_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance( .Clk(Clk),
														  .Reset(Reset_h),
                                            .VGA_HS(VGA_HS),
                                            .VGA_VS(VGA_VS),
                                            .VGA_CLK(VGA_CLK),
                                            .VGA_BLANK_N(VGA_BLANK_N),
                                            .VGA_SYNC_N(VGA_SYNC_N),
                                            .DrawX(DrawX),
                                            .DrawY(DrawY) 
                                        );
    
								
	 keycode_reader keyreader(.keycode(keycode), 
									  .pone_dive(pone_dive), 
									  .pone_kick(pone_kick), 
									  .ptwo_dive(ptwo_dive), 
									  .ptwo_kick(ptwo_kick),
									  .game_start(game_start)
									  );

    color_mapper color_instance(.Clk(Clk),
										  .PlayerOneX(PoneX), 
										  .PlayerOneY(PoneY), 
										  .PlayerTwoX(PtwoX), 
										  .PlayerTwoY(PtwoY),
										  .GameState(gameState),
										  //.GameState(3'b000),
										  .P1_Score(POne_Score),
										  .P2_Score(PTwo_Score),
										  .P1_DKS(playerone_dks),
										  .P2_DKS(playertwo_dks),
										  .Round_Time(r_time),
                                .DrawX(DrawX),
                                .DrawY(DrawY),
										  .P1_Hit(P1_hit_Detected),
										  .P2_Hit(P2_hit_Detected),
                                .VGA_R(VGA_R),
                                .VGA_G(VGA_G),
                                .VGA_B(VGA_B)
                                );
										  
    player_one playerone(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS),
								 .dive(pone_dive), .kick(pone_kick), .PlayerNum(1'b0),
								 .GameState(gameState), 
								 //.GameState(3'b011),
								 .OtherPlayerX(PtwoX),
								 .PlayerX(PoneX), .PlayerY(PoneY), .divekickstatus(playerone_dks));
	 
								 
    player_one playertwo(.Clk(Clk), .Reset(Reset_h), .frame_clk(VGA_VS),
								 .dive(ptwo_dive), .kick(ptwo_kick), .PlayerNum(1'b1),
								 .GameState(gameState), 
								 //.GameState(3'b011),
								 .OtherPlayerX(PoneX),
								 .PlayerX(PtwoX), .PlayerY(PtwoY), .divekickstatus(playertwo_dks));
								 
	 ScoreRegister ponescore(.Clk(Clk), .Reset(Reset_h), .gameState(gameState), .Increment(POne_Increment), .Score(POne_Score));
	 ScoreRegister ptwoscore(.Clk(Clk), .Reset(Reset_h), .gameState(gameState), .Increment(PTwo_Increment), .Score(PTwo_Score));
								 
	 GameState gs(	.Clk(Clk), 
						.Reset(Reset_h), 
						.W_Pressed(pone_dive), 
						.A_Pressed(pone_kick), 
						.S_Pressed(ptwo_dive),
						.D_Pressed(ptwo_kick),
						.Space_Pressed(game_start),
						.gameTime(r_time),
						.pauseTime(p_time),
						.readyTime(ready_time), 
						.DiveKickTime(divekicktime),
						.P1_Hit_Detected(P1_hit_Detected),
						.P2_Hit_Detected(P2_hit_Detected),
						.POne_Score(POne_Score),
						.PTwo_Score(PTwo_Score),
						.gameState(gameState),
						.POne_Increment(POne_Increment),
						.PTwo_Increment(PTwo_Increment)
						);	
						
		GameEngine engine(.CLK(Clk), .Reset(Reset_h),
								.P1_X(PoneX), .P1_Y(PoneY), .P2_X(PtwoX), .P2_Y(PtwoY),
								.Player_One_Char_Height(10'd44), //hard coded parameters for now
								.Player_One_Char_Width(10'd30),
								.Player_One_HB_Height(10'd32),
								.Player_One_HB_Width(10'd30),
								.Player_Two_Char_Height(10'd44), 
								.Player_Two_Char_Width(10'd30),
								.Player_Two_HB_Height(10'd32),
								.Player_Two_HB_Width(10'd30),
								.P1_Status(playerone_dks),
								.P2_Status(playertwo_dks),
								.gameTime(r_time),
								.P1_Hit_Detected(P1_hit_Detected),
								.P2_Hit_Detected(P2_hit_Detected)
								);
		
	 
	 roundtimer timer(.Clk(Clk), 
							.Reset(Reset_h), 
							.GameState(gameState),
							.clocktime(r_time));
							
	 PauseTimer_2 timer2(.Clk(Clk), 
							.Reset(Reset_h), 
							.GameState(gameState),
							.clocktime(p_time)); //timer for the KO display
							
	 PauseTimer_3 timer3(.Clk(Clk), 
							.Reset(Reset_h), 
							.GameState(gameState),
							.clocktime(ready_time)); //timer for displaying the round number
							
	 PauseTimer_4 timer4(.Clk(Clk), 
							.Reset(Reset_h), 
							.GameState(gameState),
							.clocktime(divekicktime)); //timer for displaying the words DIVEKICK!
							
    // Display keycode on hex display
	 HexDriver hex_inst_0 (pone_dive, HEX0);	 //player one dive
    HexDriver hex_inst_1 (pone_kick, HEX1); //player one kick
	 
    HexDriver hex_inst_2 (playerone_dks[2:0], HEX2);
    HexDriver hex_inst_3 (playertwo_dks[2:0], HEX3);
    HexDriver hex_inst_4 (r_time, HEX4);
    HexDriver hex_inst_5 (gameState, HEX5);
    HexDriver hex_inst_6 (POne_Score, HEX6);
    HexDriver hex_inst_7 (PTwo_Score, HEX7);
endmodule
