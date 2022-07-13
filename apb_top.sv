/*`include "apb_controller.sv"
`include "asyncRam8k_8.sv"*/

module apb_top (PCLK, PRESETn, PWRITE, PSELx, PENABLE, PADDR, PWDATA, m_rdata, m_ready, m_error);
	input PCLK, PRESETn; 											//
	input PWRITE, PSELx, PENABLE;  
	input [apb_c.addr_width-1:0] PADDR;  
	input [apb_c.data_width-1:0] PWDATA;
	

	output [apb_c.data_width-1:0] m_rdata; 
	output m_ready, m_error; 

	logic [apb_c.data_width-1:0] ram_PRDATA;
	logic ram_PREADY, ram_PSLVERR;
	logic [apb_c.addr_width+3:0]s_addr;
	logic [apb_c.data_width-1:0] s_wdata;  
	logic s_write, s_cs;

	apb_controller #(.addr_width(4), .data_width(128), .mem_data(8))  apb_c ( .PCLK(PCLK), 
				                                                             .PRESETn(PRESETn), 
				                                                             .PWRITE(PWRITE), 
				                                                             .PSELx(PSELx), 
				                                                             .PENABLE(PENABLE), 
				                                                             .PADDR(PADDR), 
				                                                             .PWDATA(PWDATA), 
				                                                             .PREADY(ram_PREADY), 
				                                                             .PSLVERR(ram_PSLVERR), 
				                                                             .PRDATA(ram_PRDATA), 
				                                                             .m_rdata(m_rdata), 
				                                                             .m_ready(m_ready), 
				                                                             .m_error(m_error), 
				                                                             .s_addr(s_addr), 
				                                                             .s_wdata(s_wdata), 
				                                                             .s_write(s_write), 
				                                                             .s_cs(s_cs)
																			);

	asyncRam8k_8 #(.addr_width(8), .data_width(8)) mem  ( .addr(s_addr),
														  .wr_en(s_write),
														  .cs(s_cs),
														  .w_data(s_wdata),
														  .ram_PRDATA(ram_PRDATA),
														  .ram_PREADY(ram_PREADY), 
														  .ram_PSLVERR(ram_PSLVERR)
													  	);

endmodule