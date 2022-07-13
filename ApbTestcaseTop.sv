
module ApbTestcaseTop ();
	bit clk=1;

	always
	 begin
	 	#5 clk=~clk;
	 end

	input_interface input_intf(clk);

	output_interface output_intf(clk);

	ApbTest TC (input_intf, output_intf);

	apb_top uut0 (.PCLK(clk), 
				  .PRESETn(input_intf.PRESETn), 
				  .PWRITE(input_intf.PWRITE), 
				  .PSELx(input_intf.PSELx), 
				  .PENABLE(input_intf.PENABLE), 
				  .PADDR(input_intf.PADDR), 
				  .PWDATA(input_intf.PWDATA), 
				  .m_rdata(output_intf.m_rdata), 
				  .m_ready(output_intf.m_ready), 
				  .m_error(output_intf.m_error)
				  );

endmodule : ApbTestcaseTop