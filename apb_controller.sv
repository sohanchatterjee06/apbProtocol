module apb_controller #(parameter addr_width=4, data_width=128, mem_data=8) (PCLK, PRESETn, PWRITE, PSELx, PENABLE, PADDR, PWDATA, PREADY, PSLVERR, PRDATA, m_rdata, m_ready, m_error, s_addr, s_wdata, s_write, s_cs);
	
	input PCLK, PRESETn; 											//input clock and reset

	//Inputs from master 
	input PWRITE, PSELx, PENABLE;  									//input control signals from master 
	input [addr_width-1:0] PADDR;  									//input address from master for controller to be used by slave
	input [data_width-1:0] PWDATA; 									//input data from master to write for controller to be used by slave

	//output to master
	output reg [mem_data-1:0] PRDATA; 							//output data from controller to be read by master
	output reg PREADY, PSLVERR; 						//tranfer of PREADY, PSLVERR and extra ack to show data is received 

	//input from slave
	input m_ready, m_error;;          								//input response from slave to transfer to master 
	input [data_width-1:0] m_rdata;  									//input of data from slave to controller to be read by master
	
	//output to slave
	output reg [(addr_width+4)-1:0] s_addr; 						//output addr from controller to write to in slave
	output reg [mem_data-1:0] s_wdata; 								//output data from controller to write to slave
	output reg s_write;                 							//output control signal to read and write from controller to slave
	output reg s_cs;												//output chip select control signal from controller to slave

	typedef enum {IDLE, SETUP, ACCESS} state;                      	//enum for states of fsm

	state pst,nst;							                        //fsm pst and nst

	reg [data_width-1:0] temp_rdata;                                //temp reg to read data from memory, acts as buffer
	reg [data_width-1:0] temp_wdata;								//temp reg to write data to memory, acts as buffer

	reg [addr_width-1:0] temp_addr;									//temp reg to store the address recieved from master
	reg [addr_width:0] count;										//counts to 16, req to write 128 bit to memory or read 128 from memory
	reg count_en,count_rst;											//control signals to control the counter

	//sequential block
	always_ff @(posedge PCLK , negedge PRESETn) begin
		if(~PRESETn) begin
			 pst<=IDLE;												//pst goes to IDLE state at reset
			 count<='h0;											//counter is initilised to zero at reset
		end else begin
				pst<=nst;
				if (count_en) begin									// next state is assigned to present state
					count<=count+1;									//counter is increamented is its enabled 
				end
				else if (count_rst) begin
					count<='h0;										//else if count_rst, its reset to zero
				end

		end
	end

	//combinational block, nst determination
	always_comb begin

		case (pst)
			IDLE: begin
						case(PSELx)									//in IDLE state, if PSELx is set, it goes to setup
							1'b1: nst= SETUP;						// else it stays in IDLE
							default: nst=IDLE;
						endcase
				  end

			SETUP: begin
						case({PENABLE, PSELx})						//in SETUP, different cases of {PENABLE,PSELx} are considered
							2'b11: nst= ACCESS;
							2'b01: nst=SETUP;
							default: nst= IDLE;
						endcase
				   end
			ACCESS: begin
						case({PENABLE, PSELx, PREADY})				//in ACCESS, different cases of {PENABLE, PSELx, mready} are considered
							3'b111: nst= SETUP;
							3'b110: nst= ACCESS;
							3'b010: nst=SETUP;
							3'b011: nst=SETUP;
							default: nst= IDLE;
						endcase
				    end
			default: nst= IDLE;									  	//in all other cases nst will be IDLE
		endcase
	
	end

	//output block to determine 
	always_comb
		begin

			case(pst)
				
				ACCESS:	begin
							case ({PWRITE,m_ready})
								
								2'b11: begin             			//write and ready
									s_cs='h1;
									s_write='h1;
									count_rst='h1;
									temp_wdata=PWDATA;
									count_en='h1;
									s_addr={temp_addr,count[3:0]};									
									s_wdata=temp_wdata[((count[3:0])*8)+:8];			
									PRDATA='hz;
									if(count>'d15) begin	
										PREADY=m_ready;
										count_en='h0;
									end
									else begin
										PREADY='h0;
									end
									PSLVERR=m_error;
								end 
								
								2'b10: begin            			//PREADY always high from memory so this hasn't been handled
									s_cs='h1;
									s_addr='hz;
									s_write='hz;
									s_wdata<='hz; 
									PRDATA='hz;
									PREADY='h1;
									PSLVERR=m_error;
								end 
								
								2'b01: begin            			//read and ready
									s_cs='h1;
									s_write='h0;
									count_rst='h1;
									count_en='h1;								
									s_addr={temp_addr,count[3:0]};
									temp_rdata[((count[3:0])*8)+:8]= m_rdata;
									if(count>'d15)	begin
										PRDATA= temp_rdata;
										PREADY=m_ready;
										count_en='h0;
									end
									else begin
										PREADY='h0;
										PRDATA='hz;
									end
									PSLVERR=m_error;
								end

								default: begin            			//PREADY always high from memory so this hasn't been handled
									s_cs='h1;
									s_addr=PADDR;
									s_write='hz;
									s_wdata='hz;
									PRDATA=m_rdata;
									PREADY='h1;
									PSLVERR=m_error;
								end
							
							endcase

						end

				SETUP: 	begin										//outputs in SETUP state are handled here 
							s_cs='h0;
							count_en=0;
							temp_addr=PADDR;
							PRDATA='hz;
							PREADY='h1;
							PSLVERR='h0;
						end

				default:begin										//IDLE state outputs are handled here
							s_cs='h0;
							PRDATA='hz;
							PREADY='h0;
							PSLVERR='h0;
						end

			endcase
		end
		

		

endmodule





/*for (int i = 0; i<16; i++) begin
	s_wdata=PWDATA[(i*8)+:8]; 
end*/


/*for (int i = 16; i>0; i--) begin
	m_ready<='h0;
	s_addr<={PADDR,(count+i)};
	temp_rdata[(i*8)-:8]<= PRDATA;
end*/

/*for (int i = 0; i<16; i++) begin
	@(posedge PCLK) begin
			m_ready<='h0;
			s_addr<={PADDR,(count+i)};
			s_wdata<=PWDATA[(i*8)+:8];
	end 
end*/

/*for (int i = 16; i>0; i--) begin
	m_ready<='h0;
	s_addr<={PADDR,(count+(16-i))};
	temp_rdata[(i*8)-:8]<= PRDATA;
end*/



