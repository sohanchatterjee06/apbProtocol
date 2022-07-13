`include "ApbTransaction.sv"
class ApbReceiver;

	virtual output_interface.OP output_intf;
	virtual input_interface.IP input_intf;

	mailbox rcvr2sb;

	//int count;

	function new(virtual output_interface.OP output_intf_new,virtual input_interface.IP input_intf_new, mailbox rcvr2sb);
		this.output_intf= output_intf_new;
		this.input_intf= input_intf_new;

		if (rcvr2sb==null) begin
			$display("***ERROR***: rcvr2sb is null");
			$finish;
		end
		else
			this.rcvr2sb=rcvr2sb;
	endfunction : new

	task start();
		ApbTransaction tr;
		logic [127:0] rcv_m_rdata;
		logic rcv_m_error;
		logic read;

		forever begin
			while(!output_intf.cb_o.m_ready) @(posedge output_intf.PCLK);
			if (output_intf.cb_o.m_ready) begin
				rcv_m_rdata= output_intf.cb_o.m_rdata;
				rcv_m_error= output_intf.cb_o.m_error;
				//count++;
				read=!input_intf.cb_i.PWRITE;
			end
			if (read) begin
				$display("Receiver: Received a Packet", $time);
				tr=new;
				tr.byte_unpack(rcv_m_rdata);
				tr.rv_display();
				rcvr2sb.put(tr);
			end
			
			
			repeat(5)@(posedge output_intf.PCLK);	
		end

		

	endtask : start
	
endclass : ApbReceiver