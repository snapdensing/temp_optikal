module clk_div(
	input OSC_CLK,
	input RST,
	output DIV_CLK
);
	wire CDIVX;
	
	
	defparam I1.DIV = "2.0";
	defparam I1.GSR = "DISABLED";
	CLKDIVF I1 (
	 .RST (RST)
	 ,.CLKI (OSC_CLK)
	 ,.ALIGNWD ()
	 ,.CDIVX (CDIVX));
	 
	defparam I2.DIV = "2.0";
	defparam I2.GSR = "DISABLED";
	CLKDIVF I2 (
	 .RST (RST),
	 .CLKI (CDIVX),
	 .ALIGNWD (),
	 .CDIVX (DIV_CLK));

endmodule