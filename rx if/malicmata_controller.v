module MALICMATA_Controller(
	input nrst,
	//input sys_clk,

	input [2:0] mlc_cmd,
	input [3:0] mlc_res,
	input mlc_en,
	output mlc_idle,
	
	input ddr3_ack,
	output [63:0]mlc_data,
	output mlc_data_valid,
	
	
	output mmc_clk,
	output mlc_5v_en,
	output mlc_3p3v_12v_en,
	input cap_done,	
	
	input rx_if_rdy,
	
	output spi_sen,
	output spi_sdio,
	output spi_sclk,
	
	output wire led1,
	output wire led2,
	
	output [2:0] mlc_state
);

wire mmc_clk;
wire SPI_en;
wire sys_clk;

assign led1 = nrst;
assign led2 = mlc_en;

MMC_clk_gen MMC_CLK_GEN(
	.mmc_malicmata_clk_o(mmc_clk),
	.mmc_sys_clk(sys_clk)
);

wire spi_clk;
assign spi_clk = sys_clk;
wire [4:0]spi_addr;
wire [7:0]spi_data_in;
wire spi_rd_wr;
wire spi_en;
wire spi_sdio;
wire spi_sen;
wire [7:0]spi_data_out;
wire spi_busy;
wire spi_done;
wire spi_sclk;

spi_master mmc_spi_master(
    .clk(mmc_clk),
    .nrst(nrst),
	.addr(spi_addr),
	.data_in(spi_data_in),
	.Rd_Wr(spi_rd_wr),
    .En(spi_en),
    .SDIO(spi_sdio),
    .SEN(spi_sen),
	.sclk(spi_sclk),
    
    .data_out(spi_data_out),
	.busy(spi_busy),
	.done(spi_done)
    );

wire [5:0]reg_idx;
wire [4:0]reg_addr;
wire [7:0]reg_data;

register_file mmc_memory_mapped_registers(
	.nrst(nrst),
	.idx(reg_idx),
	.addr(reg_addr),
	.data(reg_data)
	);
	
mmc_main_controller mmc_main_controller(
	.nrst(nrst),
	.sys_clk(sys_clk),

	.mlc_cmd(mlc_cmd),
	.mlc_res(mlc_res),
	.mlc_en(mlc_en),
	.mlc_idle(mlc_idle),
	.mlc_state(mlc_state),
	
	.spi_done(spi_done),
	.spi_en(spi_en),
	.spi_rd_wr(spi_rd_wr),
	.spi_addr(spi_addr),
	.spi_data(spi_data_in),
	
	.mlc_5v_en(mlc_5v_en),
	.mlc_3p3v_12v_en(mlc_3p3v_12v_en),
	
	.cap_done(cap_done),
	
	.idx(reg_idx),
	.addr_reg(reg_addr),
	.data_reg(reg_data),
	
	.rx_if_rdy(rx_if_rdy)
	);

endmodule