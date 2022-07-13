`include "ApbTransaction.sv"
`include "ApbCoverage.sv"
class ApbScoreboard;
	
	mailbox drvr2sb;
	mailbox rcvr2sb;
	int pkt_count;
	logic [127:0] shadow [16];
	ApbCoverage cov=new();

	function new(mailbox drvr2sb, mailbox rcvr2sb);
		pkt_count=0;
		this.drvr2sb=drvr2sb;
		this.rcvr2sb=rcvr2sb;
	endfunction : new
	
	task start();
		ApbTransaction trfdr, trfrv;
		forever
			begin
				drvr2sb.get(trfdr);
				if (trfdr.tr_PWRITE) begin
					shadow[trfdr.tr_PADDR]= trfdr.tr_PWDATA;
					pkt_count++;
					cov.sample(trfdr);
				end
				else begin
					rcvr2sb.get(trfrv);
					$display("| Scoreboard |: Received packet from Receiver ", $time);
					if (shadow[trfdr.tr_PADDR]==trfrv.tr_m_rdata) begin
						$display("| Scoreboard |: Packet Matched ", $time);
						pkt_count++;
						cov.sample(trfdr);
					end
					else begin
						$display("| Scoreboard |: Packet **Not** Matched ", $time);
						pkt_count++;
					end
				end

			end
	endtask : start
endclass : ApbScoreboard