`include "ApbEnvironment.sv"
class ApbFcsEr extends ApbCallbacks;
	virtual task pre_drive(ref ApbTransaction tr);
		if (tr.bad_fcs) begin
			tr.fcs='h11;
		end
	endtask : pre_drive		
endclass : ApbFcsEr

program ApbTest(input_interface.IP input_intf, output_interface.OP output_intf);
	ApbEnvironment env;
	ApbFcsEr Fcb;
	initial 
		begin
			$display("==============Start of TEST============== ",$time);
			env=new(input_intf, output_intf);
			env.build();
			Fcb=new;
			env.drvr.cb.push_back(Fcb);
			env.reset();
			env.start();
			env.wait_for_end();
			env.report();
			//env.run();
			#1000;
			$display("================End of TEST================ ",$time);
		end
endprogram