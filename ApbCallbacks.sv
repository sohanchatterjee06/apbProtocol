`include "ApbTransaction.sv"
class ApbCallbacks;

	virtual task pre_drive(ref ApbTransaction tr);
		$display("Pre Drive");
	endtask : pre_drive

	virtual task post_drive(ref ApbTransaction tr);
		$display("Post Drive");
	endtask : post_drive
	
endclass : ApbCallbacks