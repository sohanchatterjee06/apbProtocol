
////////////////////////////////////////
//interface for output side of the apb//
///////////////////////////////////////

interface output_interface (input bit PCLK);
	logic [127:0] m_rdata;
	logic m_ready;
	logic m_error;

	clocking cb_o@(posedge PCLK);
		default input #1 output #1;
		input m_rdata;
		input m_ready;
		input m_error;
	endclocking
	
	modport OP (clocking cb_o, input PCLK);

endinterface : output_interface

////////////////////////////////////////
//interface for input side of the apb//
///////////////////////////////////////

interface input_interface (input bit PCLK);
	logic PRESETn; 											
	logic PWRITE; 
	logic PSELx; 
	logic PENABLE;  
	logic [3:0] PADDR;  
	logic [127:0] PWDATA;

	clocking cb_i@(posedge PCLK); 
		default input #1 output #1;											
		output PWRITE; 
		output PSELx; 
		output PENABLE;  
		output PADDR;  
		output PWDATA;
	endclocking

	modport IP (clocking cb_i, output PRESETn, input PCLK);

endinterface : input_interface	


