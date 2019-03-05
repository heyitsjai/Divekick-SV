// 15 seconds for now
module roundtimer ( input Clk, 
						  input logic Reset,
						  input logic [3:0] GameState, //to see if game is currently being played
						  output logic [3:0] clocktime //decimal value of the timer.
						); 
						
logic [25:0] internalClk;
logic [3:0] roundtime = 4'b0000;
//we need clocktime to increment by 1 every 60 cycles of roundclk
always_ff @ (posedge Clk)
begin 
	if(Reset || GameState== 4'b0101 || GameState == 4'b0000)
		begin
			internalClk <= 6'b000000;
			roundtime <= 4'b0000;
		end
	else if (internalClk == 26'd49999999)
		begin
		internalClk <= 0;
		if(GameState == 3'b011) //currently playing, increase round time
			roundtime   <= roundtime + 4'd1;
		else
			roundtime  <= roundtime;
		end
	else 
		begin
		internalClk <= internalClk + 4'd1;
		roundtime <= roundtime;
		end
		
end
assign clocktime = ~(roundtime);

endmodule

//timer for KO
module PauseTimer_2 ( input Clk, 
						  input logic Reset,
						  input logic [3:0] GameState, //to see if game is currently being played
						  output logic [1:0] clocktime //decimal value of the timer.
						); 
						
logic [25:0] internalClk;
logic [1:0] roundtime = 2'b00;
//we need clocktime to increment by 1 every 60 cycles of roundclk
always_ff @ (posedge Clk)
begin 
	if(Reset || GameState != 4'b0110)
		begin
			internalClk <= 6'b000000;
			roundtime <= 2'b00;
		end
	else if (internalClk == 26'd49999999)
		begin
		internalClk <= 0;
		if(GameState == 4'b0110) //currently paused, increase timeout
			roundtime   <= roundtime + 2'd1;
		else
			roundtime  <= roundtime;
		end
	else 
		begin
		internalClk <= internalClk + 2'd1;
		roundtime <= roundtime;
		end
		
end
assign clocktime = roundtime;
endmodule


module PauseTimer_3 ( input Clk, 
						  input logic Reset,
						  input logic [3:0] GameState, //to see if game is currently being played
						  output logic [1:0] clocktime //decimal value of the timer.
						); 
						
logic [25:0] internalClk;
logic [1:0] roundtime = 2'b00;
//we need clocktime to increment by 1 every 60 cycles of roundclk
always_ff @ (posedge Clk)
begin 
	if(Reset || GameState != 4'b1000)
		begin
			internalClk <= 6'b000000;
			roundtime <= 2'b00;
		end
	else if (internalClk == 26'd49999999)
		begin
		internalClk <= 0;
		if(GameState == 4'b1000) //currently paused, increase timeout
			roundtime   <= roundtime + 2'd1;
		else
			roundtime  <= roundtime;
		end
	else 
		begin
		internalClk <= internalClk + 2'd1;
		roundtime <= roundtime;
		end
		
end
assign clocktime = roundtime;
endmodule

//half a second increments
module PauseTimer_4 ( input Clk, 
						  input logic Reset,
						  input logic [3:0] GameState, //to see if game is currently being played
						  output logic [1:0] clocktime //decimal value of the timer.
						); 
					
logic [25:0] internalClk;
logic [1:0] roundtime = 2'b00;
//we need clocktime to increment by 1 every 60 cycles of roundclk
always_ff @ (posedge Clk)
begin 
	if(Reset || GameState != 4'b1001)
		begin
			internalClk <= 6'b000000;
			roundtime <= 2'b00;
		end
	else if (internalClk == 26'd24999999)
		begin
		internalClk <= 0;
		if(GameState == 4'b1001) //currently paused, increase timeout
			roundtime   <= roundtime + 2'd1;
		else
			roundtime  <= roundtime;
		end
	else 
		begin
		internalClk <= internalClk + 4'd1;
		roundtime <= roundtime;
		end
		
end
assign clocktime = roundtime;
endmodule