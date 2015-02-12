/******************************************************************************
 * Copyright 2013 AMIQ Consulting SRL
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * MODULE:    amiq_dcr_if.sv
 * PROJECT:   DCR
 *
 * Description:  DCR bus interface
 *******************************************************************************/

`ifndef AMIQ_DCR_IF_SV
	//protection against multiple includes
	`define AMIQ_DCR_IF_SV

	//minimum address width - unchanged by protocol
	`define AMIQ_DCR_MIN_ADDR_WIDTH 10

	//maximum address width - unchanged by protocol
	`define AMIQ_DCR_MAX_ADDR_WIDTH 32

	//maximum data width - unchanged by protocol
	`define AMIQ_DCR_MAX_DATA_WIDTH 32

	//maximum master ID width - unchanged by protocol
	`define AMIQ_DCR_MAX_MASTER_ID_WIDTH 4

	// DCR bus interface
	interface amiq_dcr_if (input clk);

		// DCR reset signal
		logic reset_n;

		// DCR read command signal
		logic read;

		// DCR write command signal
		logic write;

		// DCR privileged operation signal
		logic privileged;

		// DCR master ID indicator signal
		logic[`AMIQ_DCR_MAX_MASTER_ID_WIDTH-1:0] master_id;

		// DCR address bus
		logic[`AMIQ_DCR_MAX_ADDR_WIDTH-1:0] a_bus;

		// DCR data bus used for write transfers
		logic[`AMIQ_DCR_MAX_DATA_WIDTH-1:0] d_bus_out;

		// DCR timeout counter inhibitor signal
		logic timeout_wait;

		// DCR transfer acknowledge signal
		logic ack;

		// DCR data bus used for read transfers
		logic[`AMIQ_DCR_MAX_DATA_WIDTH-1:0] d_bus_in;

		// ----------------------------------------------------------------------------------------
		// --- INTERFACE LOGIC ADITIONAL SIGNALS AND SWITCHES
		// ----------------------------------------------------------------------------------------

		// Switch global checking on (1) or off (0)
		bit has_checks = 1;

		// Switch protocol checking on (1) or off (0)
		bit has_protocol_checks = 1;

		// Switch x/z checking on (1) or off (0)
		bit has_x_z_checks = 1;

		// Switch reset checking on (1) or off (0)
		bit has_rst_checks = 1;

		// ----------------------------------------------------------------------------------------
		// --- PROTOCOL CHECKS
		// --- switch it on/off by toggling has_protocol_checks field
		// ----------------------------------------------------------------------------------------

		//threshold for timeout
		integer timeout_threshold = 10_000;

		//timeout counter
		integer timeout_counter = 10_000;

		//previous read
		bit prev_read;

		//previous write
		bit prev_write;

		always @(posedge clk or negedge reset_n) begin
			if(reset_n == 0) begin
				timeout_counter <= timeout_threshold;
				prev_read <= 0;
				prev_write <= 0;
			end
			else begin
				prev_read <= read;
				prev_write <= write;

				if(((prev_read == 0) && (read == 1)) || ((prev_write == 0) && (write == 1))) begin
					if(timeout_threshold == 0) begin
						timeout_counter <= 0;
					end
					else begin
						timeout_counter <= timeout_threshold - 1;
					end
				end
				else if(((read == 1) || (write == 1)) && (ack == 0)) begin
					if(timeout_wait === 0) begin
						if(timeout_counter != 0) begin
							timeout_counter <= timeout_counter - 1;
						end
					end
				end
			end
		end

		// Check that if read or write is asserted privileged is constant
		property amiq_dcr_priv_sig_cnst_on_cmd_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_protocol_checks == 0))
				(((read != 0) || (write != 0)) && $stable(read) && $stable(write)) |-> $stable(privileged);
		endproperty
		AMIQ_DCR_PRIV_CNST_ON_CMD_ERR : assert property (amiq_dcr_priv_sig_cnst_on_cmd_p) else
			$error("[%t]\t%m failed! privileged signal has changed during transfer.", $time);
		AMIQ_DCR_PRIV_CNST_ON_CMD_CVR : cover property (amiq_dcr_priv_sig_cnst_on_cmd_p);


		// Check that if read or write is asserted master_id is constant
		property amiq_dcr_master_id_sig_cnst_on_cmd_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_protocol_checks == 0))
				(((read != 0) || (write != 0)) && $stable(read) && $stable(write)) |-> $stable(master_id);
		endproperty
		AMIQ_DCR_MASTER_ID_CNST_ON_CMD_ERR : assert property (amiq_dcr_master_id_sig_cnst_on_cmd_p) else
			$error("[%t]\t%m failed! Master ID signal has changed during transfer.", $time);
		AMIQ_DCR_MASTER_ID_CNST_ON_CMD_CVR : cover property (amiq_dcr_master_id_sig_cnst_on_cmd_p);


		// Check that if read or write is asserted a_bus is constant
		property amiq_dcr_a_bus_cnst_on_cmd_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_protocol_checks == 0))
				(((read != 0) || (write != 0)) && $stable(read) && $stable(write)) |-> $stable(a_bus);
		endproperty
		AMIQ_DCR_ABUS_CNST_ON_CMD_ERR : assert property (amiq_dcr_a_bus_cnst_on_cmd_p) else
			$error("[%t]\t%m failed! Address signal has changed during transfer.", $time);
		AMIQ_DCR_ABUS_CNST_ON_CMD_CVR : cover property (amiq_dcr_a_bus_cnst_on_cmd_p);


		// Check that if read is asserted d_bus_out is deasserted and constant
		property amiq_dcr_d_bus_out_cnst_on_read_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_protocol_checks == 0))
				(read == 1) |-> d_bus_out == 0;
		endproperty
		AMIQ_DCR_DBUS_WT_CNST_ON_READ_ERR : assert property (amiq_dcr_d_bus_out_cnst_on_read_p) else
			$error("[%t]\t%m failed! Write data bus signal has changed during read transfer (should stay deasserted).", $time);
		AMIQ_DCR_DBUS_WT_CNST_ON_READ_CVR : cover property (amiq_dcr_d_bus_out_cnst_on_read_p);


		// Check that read or write is not being asserted while ack is asserted
		property amiq_dcr_cmd_while_ack_asserted_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_protocol_checks == 0))
				($rose(read) or $rose(write)) |-> ack === 0;
		endproperty
		AMIQ_DCR_CMD_WHILE_ACK_ASSERTED_ERR : assert property (amiq_dcr_cmd_while_ack_asserted_p) else
			$error("[%t]\t%m failed! DCR command signal has been asserted while acknowledge is asserted.", $time);
		AMIQ_DCR_CMD_WHILE_ACK_ASSERTED_CVR : cover property (amiq_dcr_cmd_while_ack_asserted_p);

		// Check that read is deasserted if a timeout condition  has been reached or ack is high
		property amiq_dcr_cmd_fall_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_protocol_checks == 0))
				($fell(read) || $fell(write)) |-> ((timeout_counter == 0) || (ack == 1));
		endproperty
		AMIQ_DCR_CMD_FALL_ERR : assert property (amiq_dcr_cmd_fall_p) else
			$error("[%t]\t%m failed! DCR command has not been deasserted although timeout expired or ack was asserted.", $time);
		AMIQ_DCR_CMD_FALL_CVR : cover property (amiq_dcr_cmd_fall_p);


		// Check that if write is asserted d_bus_out is constant
		property amiq_dcr_d_bus_out_cnst_on_write_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_protocol_checks == 0))
				((write != 0) && $stable(write)) |-> $stable(d_bus_out);
		endproperty
		AMIQ_DCR_DBUS_WT_CNST_ON_WRITE_ERR : assert property (amiq_dcr_d_bus_out_cnst_on_write_p) else
			$error("[%t]\t%m failed! Write data bus signal has changed during write transfer.", $time);
		AMIQ_DCR_DBUS_WT_CNST_ON_WRITE_CVR : cover property (amiq_dcr_d_bus_out_cnst_on_write_p);


		// Check that if read is asserted and ack is asserted d_bus_in is constant
		property amiq_dcr_d_bus_in_cnst_on_read_ack_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_protocol_checks == 0))
				((read == 1) && ($stable(read) == 1) && (ack == 1) && ($stable(ack) == 1)) |-> $stable(d_bus_in);
		endproperty
		AMIQ_DCR_D_BUS_IN_CNST_ON_READ_ACK_ERR : assert property (amiq_dcr_d_bus_in_cnst_on_read_ack_p) else
			$error("[%t]\t%m failed! Read data bus signal has changed during acknowledged read transfer.", $time);
		AMIQ_DCR_D_BUS_IN_CNST_ON_READ_ACK_CVR : cover property (amiq_dcr_d_bus_in_cnst_on_read_ack_p);


		// Check that write and read are not asserted at the same time
		property amiq_dcr_command_valid_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_protocol_checks == 0))
				(!(write && read));
		endproperty
		AMIQ_DCR_COMMAND_VALID_ERR : assert property (amiq_dcr_command_valid_p) else
			$error("[%t]\t%m failed! Found read and write asserted at the same time.", $time);
		AMIQ_DCR_COMMAND_VALID_CVR : cover property (amiq_dcr_command_valid_p);


		// Check that ack is not being asserted when both the read and write are deasserted
		property amiq_dcr_ack_assertion_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_protocol_checks == 0))
				($rose(ack) == 1) |-> ($past(write) || $past(read));
		endproperty
		AMIQ_DCR_ACK_ASSERTION_ERR : assert property (amiq_dcr_ack_assertion_p) else
			$error("[%t]\t%m failed! Acknowledge was asserted outside a valid transfer.", $time);
		AMIQ_DCR_ACK_ASSERTION_CVR : cover property (amiq_dcr_ack_assertion_p);

		// Check that ack is not being deasserted while read or write is asserted
		property amiq_dcr_ack_deassertion_while_cmd_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_protocol_checks == 0))
				$fell(ack) |-> (($past(write) == 0) && ($past(read) == 0));
		endproperty
		AMIQ_DCR_ACK_DEASSERTION_WHILE_CMD_ERR : assert property (amiq_dcr_ack_deassertion_while_cmd_p) else
			$error("[%t]\t%m failed! Acknowledge was deasserted while read was still asserted.", $time);
		AMIQ_DCR_ACK_DEASSERTION_WHILE_CMD_CVR : cover property (amiq_dcr_ack_deassertion_while_cmd_p);

		// Check that read is 0 or 1 (not z, x)
		property amiq_dcr_read_valid_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_x_z_checks == 0))
				$isunknown(read) == 0;
		endproperty
		AMIQ_DCR_READ_VALID_ERR : assert property (amiq_dcr_read_valid_p) else
			$error("[%t]\t%m failed! Found DCR Read signal X or Z.", $time);
		AMIQ_DCR_READ_VALID_CVR : cover property (amiq_dcr_read_valid_p);


		// Check that write is 0 or 1 (not z, x)
		property amiq_dcr_write_valid_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_x_z_checks == 0))
				$isunknown(write) == 0;
		endproperty
		AMIQ_DCR_WRITE_VALID_ERR : assert property (amiq_dcr_write_valid_p) else
			$error("[%t]\t%m failed! Found DCR Write signal X or Z.", $time);
		AMIQ_DCR_WRITE_VALID_CVR : cover property (amiq_dcr_write_valid_p);


		// Check that privileged is 0 or 1 (not z, x)
		property amiq_dcr_privileged_valid_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_x_z_checks == 0))
				$isunknown(privileged) == 0;
		endproperty
		AMIQ_DCR_PRIVILEDGED_VALID_ERR : assert property (amiq_dcr_privileged_valid_p) else
			$error("[%t]\t%m failed! Found DCR privileged signal X or Z.", $time);
		AMIQ_DCR_PRIVILEDGED_VALID_CVR : cover property (amiq_dcr_privileged_valid_p);


		// Check that master_id is 0 or 1 (not z, x)
		property amiq_dcr_master_id_valid_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_x_z_checks == 0))
				$isunknown(master_id) == 0;
		endproperty
		AMIQ_DCR_MASTERID_VALID_ERR : assert property (amiq_dcr_master_id_valid_p) else
			$error("[%t]\t%m failed! Found DCR Master ID X or Z.", $time);
		AMIQ_DCR_MASTERID_VALID_CVR : cover property (amiq_dcr_master_id_valid_p);


		// Check that a_bus is 0 or 1 (not z, x)
		property amiq_dcr_a_bus_valid_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_x_z_checks == 0))
				$isunknown(a_bus) == 0;
		endproperty
		AMIQ_DCR_ABUS_VALID_ERR : assert property (amiq_dcr_a_bus_valid_p) else
			$error("[%t]\t%m failed! Found DCR Address bus signal X or Z.", $time);
		AMIQ_DCR_ABUS_VALID_CVR : cover property (amiq_dcr_a_bus_valid_p);


		// Check that d_bus_out is 0 or 1 (not z, x)
		property amiq_dcr_d_bus_out_valid_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_x_z_checks == 0))
				$isunknown(d_bus_out) == 0;
		endproperty
		AMIQ_DCR_DBUS_WT_VALID_ERR : assert property (amiq_dcr_d_bus_out_valid_p) else
			$error("[%t]\t%m failed! Found DCR data write signal X or Z.", $time);
		AMIQ_DCR_DBUS_WT_VALID_CVR : cover property (amiq_dcr_d_bus_out_valid_p);


		// Check that timeout_wait is 0 or 1 (not z, x)
		property amiq_dcr_timeout_wait_valid_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_x_z_checks == 0))
				$isunknown(timeout_wait) == 0;
		endproperty
		AMIQ_DCR_TIMEOUTWAIT_VALID_ERR : assert property (amiq_dcr_timeout_wait_valid_p) else
			$error("[%t]\t%m failed! Found DCR TimeoutWait signal X or Z.", $time);
		AMIQ_DCR_TIMEOUTWAIT_VALID_CVR : cover property (amiq_dcr_timeout_wait_valid_p);


		// Check that ack is 0 or 1 (not z, x)
		property amiq_dcr_ack_valid_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_x_z_checks == 0))
				$isunknown(ack) == 0;
		endproperty
		AMIQ_DCR_ACK_VALID_ERR : assert property (amiq_dcr_ack_valid_p) else
			$error("[%t]\t%m failed! Found DCR Acknowledge signal X or Z.", $time);
		AMIQ_DCR_ACK_VALID_CVR : cover property (amiq_dcr_ack_valid_p);


		// Check that d_bus_in is 0 or 1 (not z, x)
		property amiq_dcr_d_bus_in_valid_p;
			@(posedge clk) disable iff ((reset_n == 0) || (has_checks == 0) || (has_x_z_checks == 0))
				$isunknown(d_bus_in) == 0;
		endproperty
		AMIQ_DCR_DBUS_RD_VALID_ERR : assert property (amiq_dcr_d_bus_in_valid_p) else
			$error("[%t]\t%m failed! Found DCR data read signal X or Z.", $time);
		AMIQ_DCR_DBUS_RD_VALID_CVR : cover property (amiq_dcr_d_bus_in_valid_p);



		// ----------------------------------------------------------------------------------------
		// --- RESET CHECKS
		// --- switch it on/off by toggling has_rst_checks field
		// ----------------------------------------------------------------------------------------


		// Check that read is deasserted during reset
		property amiq_dcr_read_deasserted_at_reset_p;
			@(posedge clk) disable iff ((has_checks == 0) || (has_rst_checks == 0))
				(reset_n == 0) |-> (read == 0);
		endproperty
		AMIQ_DCR_READ_DEASSERTED_AT_RESET_ERR : assert property (amiq_dcr_read_deasserted_at_reset_p) else
			$error("[%t]\t%m failed! Found DCR Read signal asserted during reset.", $time);
		AMIQ_DCR_READ_DEASSERTED_AT_RESET_CVR : cover property (amiq_dcr_read_deasserted_at_reset_p);


		// Check that write is deasserted during reset
		property amiq_dcr_write_deasserted_at_reset_p;
			@(posedge clk) disable iff ((has_checks == 0) || (has_rst_checks == 0))
				(reset_n == 0) |-> (write == 0);
		endproperty
		AMIQ_DCR_WRITE_DEASSERTED_AT_RESET_ERR : assert property (amiq_dcr_write_deasserted_at_reset_p) else
			$error("[%t]\t%m failed! Found DCR Write signal asserted during reset.", $time);
		AMIQ_DCR_WRITE_DEASSERTED_AT_RESET_CVR : cover property (amiq_dcr_write_deasserted_at_reset_p);


		// Check that ack is deasserted during reset
		property amiq_dcr_ack_deasserted_at_reset_p;
			@(posedge clk) disable iff ((has_checks == 0) || (has_rst_checks == 0))
				(reset_n == 0) |-> (ack == 0);
		endproperty
		AMIQ_DCR_ack_DEASSERTED_AT_RESET_ERR : assert property (amiq_dcr_ack_deasserted_at_reset_p) else
			$error("[%t]\t%m failed! Found DCR write data signal asserted during reset.", $time);
		AMIQ_DCR_ack_DEASSERTED_AT_RESET_CVR : cover property (amiq_dcr_ack_deasserted_at_reset_p);

	endinterface

`endif
