module ScoreRegister (input logic Clk, Reset, 
							 input logic [3:0] gameState,
							 input logic Increment,
							 output logic [2:0] Score
							 );
			
always_ff @ (posedge Clk)
begin
	if(Reset || gameState == 4'b0000)
		Score <= 3'b00;
	else if (Increment)
		Score <= Score + 3'b01;
end
endmodule