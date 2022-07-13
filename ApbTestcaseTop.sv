
module ApbTestcaseTop ();
	bit clk=1;

	always
	 begin
	 	#5 clk=~clk;
	 end

	input_interface input_intf(clk);

	output_interface output_intf(clk);

	ApbTest TC (input_intf, output_intf);

	apb_top #(
			.addr_width(4),
			.data_width(128),
			.mem_data(8)
		) inst_apb_top (
			.PCLK    (clk),
			.PRESETn (input_intf.PRESETn),
			.PWRITE  (input_intf.PWRITE),
			.PSELx   (input_intf.PSELx),
			.PENABLE (input_intf.PENABLE),
			.PADDR   (input_intf.PADDR),
			.PWDATA  (input_intf.PWDATA),
			.PRDATA  (output_intf.m_rdata),
			.PREADY  (output_intf.m_ready),
			.PSLVERR (output_intf.m_error)
		);


endmodule : ApbTestcaseTop