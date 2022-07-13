`include "ApbTransaction.sv"
`include "ApbCallbacks.sv"
class ApbDriver;
	virtual input_interface.IP input_intf;                                   //getting interface to be used in driver class
	ApbCallbacks cb [$];

	mailbox drvr2sb;                                                         //Mailbox object to send packet from driver to scoreboard

	function new(virtual input_interface.IP input_intf_new, mailbox drvr2sb);   
		this.input_intf=input_intf_new;                                      //passing interface data when new object is created
		if(drvr2sb==null) begin
			$display("***ERROR***: drvr2sb is null");						 								
			$finish;
		end
		else
			this.drvr2sb= drvr2sb;
	endfunction : new

	task start();
		ApbTransaction tr;													// object of transaction class

		for (int i = 0; i < no_of_pkts; i++)                                        
			begin
				tr=new();
				if(tr.randomize()) begin
					$display("| Driver |: Randomization successful ",$time);
					
					if (tr.bad_fcs) begin
						foreach (cb[i]) begin
							cb[i].pre_drive(tr);
						end
					end

					tr.byte_pack();
					//tr.dr_display();

					if (tr.tr_PWRITE) begin
						tr.dr_display();
						@(posedge input_intf.PCLK);
						input_intf.cb_i.PWRITE<=1;
						input_intf.cb_i.PSELx<=1;
						input_intf.cb_i.PADDR<= tr.tr_PADDR;
						input_intf.cb_i.PWDATA<= tr.tr_PWDATA;
						@(posedge input_intf.PCLK);
						input_intf.cb_i.PENABLE<=1;
						drvr2sb.put(tr);
					end
					else begin
						tr.dr_display();
						@(posedge input_intf.PCLK);
						input_intf.cb_i.PWRITE<=0;
						input_intf.cb_i.PSELx<=1;
						input_intf.cb_i.PADDR<= tr.tr_PADDR;
						input_intf.cb_i.PWDATA<= 'hz;
						@(posedge input_intf.PCLK);
						input_intf.cb_i.PENABLE<=1;
						
						drvr2sb.put(tr);
					end
				end
				else begin
					$display("| Driver |: Randomization failed ",$time);
					error++;
				end
				if (i==0) begin
					@(posedge input_intf.PCLK);
				end
				repeat(17)@(posedge input_intf.PCLK);
				input_intf.cb_i.PSELx<=0;
				input_intf.cb_i.PENABLE<=0;
			end

	endtask : start

	
endclass : ApbDriver