module asyncRam8k_8 #(parameter addr_width=8, data_width=8) (addr, wr_en, cs, w_data, ram_PRDATA, ram_PREADY, ram_PSLVERR);

	input [addr_width-1:0] addr;
	input wr_en,cs;
	input [data_width-1:0] w_data;
	output reg [data_width-1:0] ram_PRDATA;
	output reg ram_PSLVERR;
	output ram_PREADY;
	
	reg [data_width-1:0] myRam [(2**addr_width)-1:0];
	
	assign ram_PREADY='h1;

	always@(addr,wr_en,w_data,cs)
		begin
			ram_PSLVERR='h0;
			if(wr_en & cs)
				begin
					if (addr > 'h111 | addr < 'h0 ) begin
						ram_PSLVERR='h1;
					end
					else begin
						myRam [addr] = w_data;
						ram_PRDATA='hz;
					end
				end
			else if(~wr_en & cs)
				begin
					if (addr > 'h111 | addr < 'h0 ) begin
						ram_PSLVERR='h1;
					end
					else begin
						ram_PRDATA = myRam [addr];
					end
					
				end
			else
				begin
					if (addr > 'h111 | addr < 'h0 ) begin
						ram_PSLVERR='h1;
					end
					else begin
						myRam [addr]= myRam [addr];	
					end
				end
		end

endmodule