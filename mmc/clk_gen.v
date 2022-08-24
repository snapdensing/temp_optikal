module MMC_clk_gen(
	output wire mmc_malicmata_clk_o,
	output wire mmc_sys_clk
);
	wire OSC_CLK;
	
	
	osc OSC_I (.OSC_CLK(OSC_CLK));
	
	clk_div DIV_I(
		.OSC_CLK(OSC_CLK),
		.RST(1'b0),
		.DIV_CLK(mmc_malicmata_clk_o)
	);

	assign mmc_sys_clk = OSC_CLK;

endmodule