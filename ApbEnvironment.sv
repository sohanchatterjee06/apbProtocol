`include "ApbDriver.sv"
`include "ApbReceiver.sv"
`include "ApbScoreboard.sv"
class ApbEnvironment;
	ApbDriver drvr;
	ApbReceiver rcvr;
	ApbScoreboard sb;

	virtual input_interface.IP input_intf;
	virtual output_interface.OP output_intf;

	mailbox drvr2sb;
	mailbox rcvr2sb;

	function new(virtual input_interface.IP input_intf_new, virtual output_interface.OP output_intf_new);
		this.input_intf=input_intf_new;
		this.output_intf= output_intf_new;
		$display("Environment object created ",$time);
	endfunction : new

	function void build();
		$display("Environment: Start of Build method ",$time);
		drvr2sb=new();
		rcvr2sb=new();
		drvr=new(input_intf,drvr2sb);
		rcvr=new(output_intf,input_intf,rcvr2sb);
		sb=new(drvr2sb, rcvr2sb);
		$display("Environment: End of Build method ",$time);	
	endfunction : build

	task reset();
		$display("Environment: Start of Reset method ",$time);
		input_intf.PWRITE=0;
		input_intf.PSELx=0;
		input_intf.PENABLE=0;
		input_intf.PADDR=0;
		input_intf.PWDATA=0;

		input_intf.PRESETn=0;
		@(posedge input_intf.PCLK);
		input_intf.PRESETn=1;
		$display("Environment: End of Reset method ",$time);
	endtask : reset

	task start();
		$display("Environment: Start of Start() method ",$time);
		fork
			drvr.start();
			rcvr.start();
			sb.start();
		join_any
		$display("Environment: End of Start() method ",$time);	
	endtask : start

	task wait_for_end();
		$display("Environment: Start of Wait For End method ",$time);
		while(sb.pkt_count<no_of_pkts) @(posedge input_intf.PCLK);
		$display("Environment: End of Wait For End method ",$time);
	endtask : wait_for_end

	task report();
		$display("============================================================");
		if (error==0) begin
			$display("=====================TEST PASSED========================");
		end
		else begin
			$display("=============TEST FAILED with %d errors=================",error);
		end
		$display("============================================================");
	endtask : report
	
	task run();
		$display("Environment: Start of Run method ",$time);
		build();
		reset();
		start();
		wait_for_end();
		report();
		$display("Environment: End of Run method ",$time);		
	endtask : run	

endclass : ApbEnvironment