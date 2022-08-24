module register_file(
	input nrst,
	input [5:0]idx,
	output [4:0]addr,
	output [7:0]data
	);

	reg [4:0] addr_reg [63:0];
	reg [7:0] data_reg [63:0];
	
	assign addr = addr_reg[idx][4:0];
	assign data = data_reg[idx][7:0];
	
	integer i;
	always @ (*) begin
		if (!nrst) begin
			for (i = 0; i < 64; i = i+1) begin
				addr_reg[i] <= 0;
				data_reg[i] <= 0;
			end
		end
		else begin
			
			// Page 0
			addr_reg[0] <= 5'h1F;
			data_reg[0] <= 8'h00;
			
			addr_reg[1] <= 5'h00;
			data_reg[1] <= 8'hF1;
			
			addr_reg[2] <= 5'h01;
			data_reg[2] <= 8'h54;
			
			addr_reg[3] <= 5'h02;
			data_reg[3] <= 8'h00;
			
			addr_reg[4] <= 5'h04;
			data_reg[4] <= 8'h00;
			
			addr_reg[5] <= 5'h05;
			data_reg[5] <= 8'h0C;
			
			// Page 1
			addr_reg[6] <= 5'h1F;
			data_reg[6] <= 8'h01;
			
			addr_reg[7] <= 5'h00;
			data_reg[7] <= 8'h54;
			
			addr_reg[8] <= 5'h01;
			data_reg[8] <= 8'h54;
			
			addr_reg[9] <= 5'h02;
			data_reg[9] <= 8'h54;
			
			// Page 2
			addr_reg[10] <= 5'h1F;
			data_reg[10] <= 8'h02;
			
			addr_reg[11] <= 5'h00;
			data_reg[11] <= 8'hC0;
			
			addr_reg[12] <= 5'h01;
			data_reg[12] <= 8'h08;
			
			addr_reg[13] <= 5'h02;
			data_reg[13] <= 8'hFB;
			
			addr_reg[14] <= 5'h03;
			data_reg[14] <= 8'hDD;
			
			addr_reg[15] <= 5'h04;
			data_reg[15] <= 8'h40;
			
			// Page 3
			addr_reg[16] <= 5'h1F;
			data_reg[16] <= 8'h03;
			
			addr_reg[17] <= 5'h00;
			data_reg[17] <= 8'hFF;
			
			addr_reg[18] <= 5'h01;
			data_reg[18] <= 8'hF1;
			
			addr_reg[19] <= 5'h02;
			data_reg[19] <= 8'h12;
			
			addr_reg[20] <= 5'h03;
			data_reg[20] <= 8'h23;
			
			addr_reg[21] <= 5'h04;
			data_reg[21] <= 8'hF5;
			
			addr_reg[22] <= 5'h0C;
			data_reg[22] <= 8'h00;
			
			addr_reg[23] <= 5'h0D;
			data_reg[23] <= 8'h0;
			
			addr_reg[24] <= 5'h0E;
			data_reg[24] <= 8'h00;
			
			addr_reg[25] <= 5'h0F;
			data_reg[25] <= 8'h00;
			
			addr_reg[26] <= 5'h10;
			data_reg[26] <= 8'h00;
			
			addr_reg[27] <= 5'h11;
			data_reg[27] <= 8'h00;
			
			addr_reg[28] <= 5'h12;
			data_reg[28] <= 8'h00;
			
			addr_reg[29] <= 5'h13;
			data_reg[29] <= 8'h00;
			
			addr_reg[30] <= 5'h14;
			data_reg[30] <= 8'h00;
			
			addr_reg[31] <= 5'h15;
			data_reg[31] <= 8'h00;
			
			addr_reg[32] <= 5'h16;
			data_reg[32] <= 8'h00;
			
			addr_reg[33] <= 5'h17;
			data_reg[33] <= 8'h00;
			
			addr_reg[34] <= 5'h18;
			data_reg[34] <= 8'h00;
			
			addr_reg[35] <= 5'h19;
			data_reg[35] <= 8'h00;
			
			addr_reg[36] <= 5'h1A;
			data_reg[36] <= 8'h00;
			
			addr_reg[37] <= 5'h1B;
			data_reg[37] <= 8'h00;
			
			addr_reg[38] <= 5'h1C;
			data_reg[38] <= 8'h00;
			
			addr_reg[39] <= 5'h1D;
			data_reg[39] <= 8'h00;
			
			addr_reg[40] <= 5'h1E;
			data_reg[40] <= 8'h00;
			
			// Page 4
			addr_reg[41] <= 5'h1F;
			data_reg[41] <= 8'h04;
			
			addr_reg[42] <= 5'h04;
			data_reg[42] <= 8'hBC;
			
			addr_reg[43] <= 5'h05;
			data_reg[43] <= 8'hEB;
			
			addr_reg[44] <= 5'h07;
			data_reg[44] <= 8'hEF;
			
			addr_reg[45] <= 5'h08;
			data_reg[45] <= 8'h2B;
			
			addr_reg[46] <= 5'h09;
			data_reg[46] <= 8'h1F;
			
			addr_reg[47] <= 5'h0A;
			data_reg[47] <= 8'h2B;
			
			addr_reg[48] <= 5'h0B;
			data_reg[48] <= 8'hDD;
			
			//Page 5
			addr_reg[49] <= 5'h1F;
			data_reg[49] <= 8'h05;
			
			addr_reg[50] <= 5'h00;
			data_reg[50] <= 8'hAF;
			
			addr_reg[51] <= 5'h01;
			data_reg[51] <= 8'hB0;
			
			addr_reg[52] <= 5'h02;
			data_reg[52] <= 8'hAF;
			
			addr_reg[53] <= 5'h03;
			data_reg[53] <= 8'hB0;
			
			addr_reg[54] <= 5'h04;
			data_reg[54] <= 8'hAF;
			
			addr_reg[55] <= 5'h05;
			data_reg[55] <= 8'hB0;
			
			addr_reg[56] <= 5'h06;
			data_reg[56] <= 8'hAF;
			
			addr_reg[57] <= 5'h07;
			data_reg[57] <= 8'hB0;
			
			addr_reg[58] <= 5'h08;
			data_reg[58] <= 8'hAF;
			
			addr_reg[59] <= 5'h09;
			data_reg[59] <= 8'hB0;
			

			
			
			addr_reg[63] <= 5'h02;
			data_reg[63] <= 8'h01;
			
			

		end
	end
	
	
endmodule