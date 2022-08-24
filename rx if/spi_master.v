`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2017 02:39:48 PM
// Design Name: 
// Module Name: flash_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module spi_master(
    input clk,
    input nrst,
	input [4:0] addr,
	input [7:0] data_in,
	input Rd_Wr,
    input En,
    inout SDIO,
    output reg SEN,
	output sclk,
    
    output reg [7:0] data_out,
	output busy,
	output done
    );
    
    reg [3:0] ctr;
	reg [7:0] ctr_clk;
    reg [1:0] sel_op;
    reg [2:0] state;
    reg [23:0] bit_size;
	reg [7:0] dataout_buf;
	reg SDIO_out;
	wire SDIO_En;
	
    assign sclk = (!SEN && clk);
    
    //States
    parameter SPI_IDLE = 3'h0;
	parameter SPI_MISO = 3'h1;
    parameter SPI_INST = 3'h2;
    parameter SPI_ADDR = 3'h3;
    parameter SPI_MOSI = 3'h4;
    parameter SPI_END = 3'h5;
    
	assign busy = (state == SPI_MISO) || (state == SPI_INST) || (state == SPI_ADDR) || (state == SPI_MOSI);
	assign done = ~busy;
	
    //assign SDIO = (state == SPI_INST || state == SPI_ADDR || state == SPI_MOSI) ? SDIO_out : 1'bz;
	assign SDIO = (SDIO_En) ? SDIO_out : 1'bz;
	assign SDIO_En = ((state != SPI_IDLE) && (state != SPI_END) && (ctr_clk >= 8'd17)) ? 1'b1 : 1'b0;
	always@(posedge clk or negedge clk) begin
		if (!nrst) begin
			ctr_clk <= 0;
			//SDIO_En <= 0;

		end
		else begin
			if (state != SPI_IDLE && state != SPI_END) begin
				ctr_clk <= ctr_clk + 1;
				//if (ctr_clk >= 8'd16) begin
				//	SDIO_En <= 1;
				//end
				//else begin
				//	SDIO_En <= 0;
				//end
			end
			else begin
				ctr_clk <= 0;
				//SDIO_En <= 0;
			end
		end
	end
	
    always@(posedge clk) begin
        if (!nrst) begin
            state <= SPI_IDLE;
            SDIO_out <= 1'b1;
            SEN <= 1;
            ctr <= 0;
            dataout_buf <= 0;
        end
        else begin
            case (state)
                SPI_IDLE: begin
					if(En) begin
						state <= SPI_MISO;
						SEN <= 0;
						SDIO_out <= 1'b1;
					end
					else begin
						state <= SPI_IDLE;
						SEN <= 1;
						SDIO_out <= 1'b1;
					end
				end
				SPI_MISO: begin
					if (ctr == 4'h7) begin
						ctr <= 0;
						state <= SPI_INST;
						dataout_buf[7] <= SDIO;
						SDIO_out <= Rd_Wr;
					end
					else begin
						ctr <= ctr + 1;
						state <= SPI_MISO;
						dataout_buf[7-ctr] <= SDIO;
						SDIO_out <= 1'b1;
					end
				
				end
				SPI_INST: begin
					case (ctr)
						0: begin
							ctr <= ctr + 1;
							state <= SPI_INST;
							SDIO_out <= 1'b0;
							
						end
						1: begin
							ctr <= ctr + 1;
							state <= SPI_INST;
							SDIO_out <= 1'b0;
						end
						2: begin
							ctr <= 0;
							state <= SPI_ADDR;
							SDIO_out <= addr[4];
						end
					endcase
				
				end
				
				SPI_ADDR: begin
					if (ctr == 4) begin
						ctr <= 0;
						SDIO_out <= data_in[7];
						state <= SPI_MOSI;
					end
					else begin
						ctr <= ctr + 1;
						SDIO_out <= addr[4-ctr];
						state <= SPI_ADDR;
					end
				end
				SPI_MOSI: begin
					if (ctr == 7) begin
						ctr <= 0;
						SDIO_out <= 1'b1;
						state <= SPI_END;
						SEN <= 1;
					end
					else begin
						ctr <= ctr + 1;
						SDIO_out <= data_in[7-ctr];
						state <= SPI_MOSI;
					end
				end
				SPI_END: begin
					ctr <= 0;
					SEN <= 1;
					state <= SPI_IDLE;
					SDIO_out <= data_in[7-ctr];
				end
            endcase
        end
    end
endmodule
