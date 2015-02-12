/******************************************************************************
 * (C) Copyright 2015 AMIQ Consulting
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * NAME:        amiq_dcr_master_driver.sv
 * PROJECT:     amiq_dcr
 * Engineers:   Daniel Ciupitu (daniel.ciupitu@amiq.com)
 *              Cristian Florin Slav (cristian.slav@amiq.com)
 * Description: This file contains the declaration of the master driver.
 *******************************************************************************/

`ifndef AMIQ_DCR_MASTER_DRIVER_SV
	//protection against multiple includes
	`define AMIQ_DCR_MASTER_DRIVER_SV

	// DCR master Driver
	class amiq_dcr_master_driver extends uagt_driver #(.VIRTUAL_INTF_TYPE(amiq_dcr_vif), .REQ(amiq_dcr_master_drv_transfer));

		//casted agent configuration
		amiq_dcr_master_agent_config master_agent_config;

		//pointer to DUT virtual interface
		local amiq_dcr_vif dut_vif;

		`uvm_component_param_utils(amiq_dcr_master_driver)

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name="", uvm_component parent);
			super.new(name, parent);
		endfunction

		//UVM start of simulation phase
		//@param phase - current phase
		virtual function void start_of_simulation_phase(input uvm_phase phase);
			super.start_of_simulation_phase(phase);
			assert ($cast(master_agent_config, agent_config) == 1) else
				`uvm_fatal(get_id(), "Could not cast agent configuration to amiq_dcr_master_agent_config");

			dut_vif = agent_config.get_dut_vif();
		endfunction

		//function for handling reset
		virtual function void handle_reset();
			super.handle_reset();

			dut_vif.read <= 0;
			dut_vif.write <= 0;
			dut_vif.a_bus <= 0;
			dut_vif.d_bus_out <= 0;

			if(master_agent_config.get_has_privileged()) begin
				dut_vif.privileged <= 0;
			end

			if(master_agent_config.get_has_master_id()) begin
				dut_vif.master_id <= 0;
			end
		endfunction

		//task for driving one transaction
		virtual task drive_transaction(amiq_dcr_master_drv_transfer transaction);
			int unsigned timeout_counter = 0;

			`uvm_info(get_id(), $sformatf("Driving transfer: %s", transaction.convert2string()), UVM_LOW);

			for(int i = 0; i < transaction.transfer_delay; i++) begin
				@(posedge dut_vif.clk);
			end

			// Drive direction
			if (transaction.direction == READ) begin
				dut_vif.read <= 1;
				dut_vif.write <= 0;

				// Deassert data out bus on read transfers
				dut_vif.d_bus_out <= 0;
			end
			else if (transaction.direction == WRITE) begin
				dut_vif.write <= 1;
				dut_vif.read <= 0;

				// Drive data for write transfers
				dut_vif.d_bus_out <= transaction.data;
			end

			// Drive address
			dut_vif.a_bus <= transaction.address;

			// Set access type
			if (master_agent_config.get_has_privileged()) begin
				dut_vif.privileged <= transaction.privileged;
			end

			// Drive master ID
			if (master_agent_config.get_has_master_id()) begin
				dut_vif.master_id <= transaction.master_id;
			end

			@(posedge dut_vif.clk);

			while (dut_vif.ack !== 1) begin
				//Increment timeout counter when TimeoutWait signal is not asserted
				if(dut_vif.timeout_wait === 0) begin
					timeout_counter += 1;
					`uvm_info(get_id(), $sformatf("timeout_counter: %0d, timeout: %0d", timeout_counter, master_agent_config.get_max_timeout_delay()), UVM_FULL)

					if(timeout_counter >= master_agent_config.get_max_timeout_delay()) begin
						break;
					end
				end

				@(posedge dut_vif.clk);
			end

			if((timeout_counter >= master_agent_config.get_max_timeout_delay()) && (dut_vif.ack !== 1)) begin
				`uvm_info(get_id(), $sformatf("Terminating transfer due to timeout! timeout counter: %0d", timeout_counter), UVM_LOW)
			end

			// Terminate transfer
			dut_vif.read <= 0;
			dut_vif.write <= 0;
			dut_vif.a_bus <= 0;
			dut_vif.d_bus_out <= 0;

			// Separate non-acknowledged transfers
			if (dut_vif.ack == 0) begin
				int unsigned drain_time = master_agent_config.get_drain_time_at_timeout();

				repeat(drain_time) begin
					@(posedge dut_vif.clk);
				end
			end

			// Wait for acknowledge to be deasserted
			while (dut_vif.ack === 1) begin
				@(posedge dut_vif.clk);
			end
		endtask

	endclass

`endif
