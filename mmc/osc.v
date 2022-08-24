`timescale 1ns/1ps

module osc(
    output OSC_CLK
);
	defparam OSCG_inst.DIV = 128; //60MHz output

	OSCG OSCG_inst(.OSC(OSC_CLK));
endmodule
