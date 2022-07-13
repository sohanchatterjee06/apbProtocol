`include "ApbTransaction.sv"
class ApbCoverage;
	ApbTransaction tr;

	covergroup ApbCov();
		Addr: coverpoint tr.tr_PADDR{ option.auto_bin_max = 5;}
		Op:   coverpoint tr.tr_PWRITE;
		AdOpCross: cross Addr, Op;  	
	endgroup : ApbCov

	function new();
		ApbCov=new();
	endfunction : new

    task sample(ApbTransaction tr);
    	this.tr= tr;
    	ApbCov.sample();
    endtask : sample


endclass : ApbCoverage