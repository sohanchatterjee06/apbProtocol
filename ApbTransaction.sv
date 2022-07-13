
`ifndef PKTGAURD
 `define PKTGAURD

`include "ApbDefines.vh"
class ApbTransaction;
	rand bit tr_PWRITE;
	rand bit [3:0] tr_PADDR;
	rand byte data[15];
	rand bit bad_fcs;
	byte fcs;
	bit [127:0] tr_PWDATA;
	bit [127:0] tr_m_rdata;
	/*bit tr_m_ready;
	bit tr_m_error;*/
	static bit [3:0] tr_written_addr [];

	//contraining the destination address between the available ports in the memory
	constraint PADDR_c { if (tr_PWRITE) 
								tr_PADDR inside {[0:16]};
						 else 
						 		tr_PADDR inside {tr_written_addr}; 

						 	solve tr_PWRITE before tr_PADDR;
						}
				
	
	//function to calculate crc of the data
	function byte cal_fcs();
		begin
			cal_fcs=0;
			foreach (data[i]) begin
				cal_fcs=cal_fcs^data[i];
			end
			return cal_fcs;
		end
	endfunction : cal_fcs
	
	//assigning the calculated crc to fcs after randomization
	function void post_randomize();
		fcs= cal_fcs();
		tr_written_addr=new[tr_written_addr.size+1](tr_written_addr);
		tr_written_addr[tr_written_addr.size-1]= tr_PADDR;
	endfunction : post_randomize


	virtual function void dr_display();
		
		if (tr_PWRITE) begin
			$display("-------- Write PACKET ---------- ");
			$display("  FCS : %h ",fcs);
			$display("  Write Data: %d", tr_PWDATA);
			$display("  Write Add: %h", tr_PADDR);
			$display("  Bad_Fcs: %h", bad_fcs);
			$display("----------------------------------------------------------- \n");
		end
		else begin
			$display("-------- Read PACKET ---------- ");
			$display("  Read Add: %h", tr_PADDR);
			$display("----------------------------------------------------------- \n");
		end
	  
	endfunction : dr_display

	virtual function void rv_display();
			$display("-------- Read PACKET ---------- ");
			$display("  FCS : %h ", fcs);
			$display("  Read Data: %d", tr_m_rdata);
			$display("----------------------------------------------------------- \n");	  
	endfunction : rv_display


	virtual function void byte_pack();

		foreach (data[i]) begin
			tr_PWDATA[(i)*8+:8]=data[i];
		end
		tr_PWDATA[127-:8]=fcs;
		
	endfunction : byte_pack

	virtual function void byte_unpack(ref logic [127:0] rcv_m_rdata);
			this.fcs= rcv_m_rdata[127-:8];
			this.tr_m_rdata= rcv_m_rdata;
	endfunction : byte_unpack
		
endclass : ApbTransaction

`endif