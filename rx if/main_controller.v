module mmc_main_controller(
	input nrst,
	input sys_clk,

	input [2:0] mlc_cmd,
	input [3:0] mlc_res,
	input mlc_en,
	output mlc_idle,
	
	input spi_done,
	output reg spi_en,
	output reg spi_rd_wr,
	output [4:0]spi_addr,
	output [7:0]spi_data,
	
	output reg mlc_5v_en,
	output reg mlc_3p3v_12v_en,
	
	input cap_done,
	
	output [5:0]idx,
	input [4:0] addr_reg,
	input [7:0] data_reg,
	
	input rx_if_rdy,
	
	output reg sh_r,
	output reg [2:0] mlc_state
	);

	parameter MLC_OFF = 3'b000;
	parameter MLC_POWER = 3'b001;
	parameter MLC_CONFIG = 3'b010;
	parameter MLC_IDLE = 3'b011;
	parameter MLC_CAP = 3'b100;
	
	parameter CMD_ON = 3'b000;
	parameter CMD_OFF = 3'b001;
	parameter CMD_CAP_SET = 3'b010;
	parameter CMD_CAP_STOP = 3'b011;
	parameter CMD_RSV = 3'b100;

	
	//reg [2:0] mlc_state;
	wire [2:0] next_mlc_state;
	
	reg power_done;
	wire config_done;
	
	
	// State transitions 
	always @ (posedge sys_clk) begin
		if (!nrst) begin
			mlc_state <= MLC_OFF;
		end
		else begin
			mlc_state <= next_mlc_state;
		end
	end
	
	assign next_mlc_state = ((mlc_state == MLC_OFF) && (mlc_cmd == CMD_ON) && (mlc_en == 1'b1)) ? MLC_POWER :
								((mlc_state == MLC_POWER) && (power_done == 1'b1)) ? MLC_CONFIG :
								((mlc_state == MLC_CONFIG) && (config_done == 1'b1)) ? MLC_IDLE : 
								((mlc_state == MLC_IDLE) && (mlc_cmd == CMD_CAP_SET) && (mlc_en == 1'b1)) ? MLC_CONFIG :
								((next_mlc_state == MLC_CAP) && (cap_done == 1'b1)) ? MLC_CONFIG : mlc_state;
	// counter for POWER ON
	reg [15:0] ctr_power;
	
	always @ (posedge sys_clk) begin
		if (!nrst) begin
			ctr_power <= 16'd0;
		end
		else begin
			if (mlc_state == MLC_POWER) begin
				ctr_power <= ctr_power + 1;
			end
			else begin
				ctr_power <= 16'd0;
			end
		end
	end
	
	// power regulators
	parameter DELAY_5V = 16'd1;
	parameter DELAY_3p3V_12V = 16'd3;
	
	always @ (posedge sys_clk) begin
		if (!nrst) begin
			mlc_5v_en <= 1'b0;
			mlc_3p3v_12v_en <= 1'b0;
			power_done <= 0;
		end
		else begin
			if ( mlc_state == MLC_POWER ) begin
				if (ctr_power == DELAY_5V) begin
					mlc_5v_en <= 1'b1;
					mlc_3p3v_12v_en <= mlc_3p3v_12v_en;
					power_done <= 0;
				end
				else if (ctr_power == DELAY_3p3V_12V) begin
					mlc_5v_en <= mlc_5v_en;
					mlc_3p3v_12v_en <= 1'b1;
					power_done <= 1;
				end
			end
			else if (mlc_state == MLC_OFF) begin
				mlc_5v_en <= 1'b0;
				mlc_3p3v_12v_en <= 1'b0;
				power_done <= 0;
			end
			else begin
				mlc_5v_en <= mlc_5v_en;
				mlc_3p3v_12v_en <= mlc_3p3v_12v_en;
				power_done <= power_done;
			end
		end 
	end
	reg [5:0]next_idx;
	always @ (posedge spi_done) begin
		if (!nrst) begin
			next_idx <= 0;
		end
		else begin
			next_idx <= next_idx + 1;
		end
	end

	
	
	reg [1:0]cap_state;
	// config
	//integer i;
	reg [5:0]i;

	always @ (posedge spi_done) begin
		if (!nrst) begin
			i <= 0;
		end
		else begin
			if ( next_mlc_state == MLC_CONFIG && config_done == 1'b0) begin
				i <= i+1;
			end
			else if (next_mlc_state == MLC_CAP && cap_done == 1'b0 && (cap_state == 2'b00 || cap_state == 2'b01)) begin
				i <= 0;
			end
			else if (next_mlc_state == MLC_CAP && cap_done == 1'b0 && (cap_state == 2'b10)) begin
				i <= i+1;
			end
			else if (next_mlc_state == MLC_IDLE) begin
				i <= 0;
			end
			else begin
				i <= 0;
			end
		end
	end
	wire [5:0]idx_cap;
	wire idx_cap_en;
	assign idx = (idx_cap_en )? idx_cap: i;
	assign spi_addr = addr_reg;
	assign spi_data = data_reg;
	//reg [1:0]cap_state;
	always @ (posedge sys_clk) begin
		if (next_mlc_state == MLC_CONFIG) begin
			spi_rd_wr <= 1'b0;
			if (spi_done == 1'b1) begin
				spi_en <= 1'b1;
			end
			else begin
				spi_en <= 1'b0;

			end
		end
		else if (mlc_state == MLC_CAP && next_mlc_state == MLC_CAP && cap_state == 2'b00) begin
			spi_rd_wr <= 1'b0;
			if (spi_done == 1'b1) begin
				spi_en <= 1'b1;
			end
			else begin
				spi_en <= 1'b0;

			end
		end
		else begin
			spi_rd_wr <= 1'b0;
			spi_en <= 1'b0;
		end
	end
	
	assign config_done = (i < 55) ?  1'b0 : 1'b1;
	
	always @ (posedge sys_clk) begin
		if (!nrst) begin
			cap_state <= 0;
		end
		else if (mlc_state == MLC_CAP && cap_state == 0) begin
			cap_state <= 2'b01;
		end
		else if (mlc_state == MLC_CAP && cap_state == 1 && spi_done == 1) begin
			cap_state <= 2'b10;
		end
		else if (mlc_state == MLC_CAP && cap_state == 2'b10 && cap_done == 1) begin
			cap_state <= 2'b00;
		end
		else
			cap_state <= cap_state;

	end
	
	always @ (posedge sys_clk) begin
		if (!nrst) begin
			sh_r <= 0;
		end
		else begin
			if (mlc_state == MLC_CAP && next_mlc_state == MLC_CAP && cap_state == 2'b10 && spi_done == 1'b1) begin
				if (rx_if_rdy == 1 && sh_r == 0) begin
					sh_r <= 1;
				end
				else begin
					sh_r <= 0;
				end
			end
		end

	end
	//always @ (posedge sys_clk) begin
	//	if (mlc_state == MLC_CONFIG) begin
	//		while (i < 6) begin
	//			spi_addr <= addr_reg;
	//			spi_data <= data_reg;
	//		end
	//	end
	//end
	
	
	// CAPTURE
	//wire idx_cap;
	//wire idx_cap_en;
	
	assign idx_cap_en = (mlc_state == MLC_CAP && (cap_state == 0 ||cap_state == 1) && cap_done == 0)? 1 : 0;
	assign idx_cap = 5'd61;
	
endmodule
