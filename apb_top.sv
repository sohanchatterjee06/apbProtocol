/*`include "apb_controller.sv"
`include "asyncRam8k_8.sv"*/

module apb_top  #(parameter addr_width=4, data_width=128, mem_data=8) (PCLK, PRESETn, PWRITE, PSELx, PENABLE, PADDR, PWDATA, PRDATA, PREADY, PSLVERR);
	input PCLK, PRESETn; 											
	input PWRITE, PSELx, PENABLE;  
	input [addr_width-1:0] PADDR;  
	input [data_width-1:0] PWDATA;
	

	output [data_width-1:0] PRDATA; 
	output PREADY, PSLVERR; 

	logic [mem_data-1:0] ram_PRDATA;
	logic ram_PREADY, ram_PSLVERR;
	logic [addr_width+3:0]s_addr;
	logic [mem_data-1:0] s_wdata;  
	logic s_write, s_cs;

	apb_controller #(.addr_width(4), .data_width(128), .mem_data(8))  apb_c ( .PCLK(PCLK), 
				                                                             .PRESETn(PRESETn), 
				                                                             .PWRITE(PWRITE), 
				                                                             .PSELx(PSELx), 
				                                                             .PENABLE(PENABLE), 
				                                                             .PADDR(PADDR), 
				                                                             .PWDATA(PWDATA), 
				                                                             .PREADY(PREADY), 
				                                                             .PSLVERR(PSLVERR), 
				                                                             .PRDATA(PRDATA), 
				                                                             .m_rdata(ram_PRDATA), 
				                                                             .m_ready(ram_PREADY), 
				                                                             .m_error(ram_PSLVERR), 
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