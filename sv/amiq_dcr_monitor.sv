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
 * NAME:        amiq_dcr_monitor.sv
 * PROJECT:     amiq_dcr
 * Engineers:   Daniel Ciupitu (daniel.ciupitu@amiq.com)
 *              Cristian Florin Slav (cristian.slav@amiq.com)
 * Description: This file contains the declaration of the monitor
 *******************************************************************************/

`ifndef AMIQ_DCR_MONITOR_SV
	//protection against multiple includes
	`define AMIQ_DCR_MONITOR_SV

	// DCR monitor
	class amiq_dcr_monitor extends uagt_monitor#(.VIRTUAL_INTF_TYPE(amiq_dcr_vif), .MONITOR_ITEM(amiq_dcr_mon_transfer));

		//casted agent configuration
		amiq_dcr_agent_config casted_agent_config;

		`uvm_component_utils(amiq_dcr_monitor)

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
			assert ($cast(casted_agent_config, agent_config) == 1) else
				`uvm_fatal(get_id(), "Could not cast agent configuration to amiq_dcr_agent_config");
		endfunction

		//function for recording the change of "timeout wait"
		//@param collected_transfer - pointer to the collected item
		protected function void update_timeout_wait_changes(ref amiq_dcr_mon_transfer collected_transfer);
			amiq_dcr_vif dut_vif = agent_config.get_dut_vif();
			bit add_change = 0;

			if(collected_transfer.timeout_wait_changes.size() == 0) begin
				add_change = 1;
			end
			else begin
				bit last_change = collected_transfer.timeout_wait_changes[collected_transfer.timeout_wait_changes.size() - 1].value;

				if(last_change != dut_vif.timeout_wait) begin
					add_change = 1;
				end
			end

			if(add_change) begin
				amiq_dcr_change#(bit) change = amiq_dcr_change#(bit)::type_id::create("change");
				change.value = dut_vif.timeout_wait;
				change.change_time = $time;
				collected_transfer.timeout_wait_changes.push_back(change);
			end
		endfunction

		//function for initializing the collected item at the beginning of the transfer
		//@param collected_transfer - pointer to the collected item
		protected function void initialize_collected_item(ref amiq_dcr_mon_transfer collected_transfer);
			amiq_dcr_vif dut_vif = agent_config.get_dut_vif();
			collected_transfer.start_time = $time;

			if (dut_vif.write === 1) begin
				collected_transfer.direction = WRITE;
				collected_transfer.data = dut_vif.d_bus_out;
			end
			else if (dut_vif.read === 1) begin
				collected_transfer.direction = READ;
			end
			else begin
				`uvm_fatal(get_id(), $sformatf("Unknown operation - write signal: %0d, read signal: %0d",
						dut_vif.write, dut_vif.read))
			end

			collected_transfer.address = dut_vif.a_bus & casted_agent_config.get_address_mask();

			if(casted_agent_config.get_has_privileged()) begin
				collected_transfer.privileged = dut_vif.privileged;
			end

			if(casted_agent_config.get_has_master_id()) begin
				collected_transfer.master_id = dut_vif.master_id;
			end

			update_timeout_wait_changes(collected_transfer);
		endfunction

		//function to determine if the transfer length respect maximum timeout setting
		//@param collected_transfer - pointer to the collected item
		virtual protected function void check_transfer_length(ref amiq_dcr_mon_transfer collected_transfer);
			if(agent_config.get_has_checks()) begin
				int unsigned timeout_counter = collected_transfer.get_timeout_counter();

				if(timeout_counter > casted_agent_config.get_max_timeout_delay()) begin
					`uvm_error(get_id(), $sformatf("Transfer %s should have been terminated earlier because the timeout counter is %0d while max_timeout_delay is %0d",
							collected_transfer.convert2string(), timeout_counter, casted_agent_config.get_max_timeout_delay()));
				end
			end
		endfunction

		//task for collecting one transaction
		virtual task collect_transaction();
			amiq_dcr_vif dut_vif = agent_config.get_dut_vif();

			//collected transfer
			amiq_dcr_mon_transfer collected_transfer;

			while(1 == 1) begin
				if((dut_vif.write === 1) || (dut_vif.read === 1)) begin
					break;
				end
				@(posedge dut_vif.clk);
			end

			collected_transfer = amiq_dcr_mon_transfer::type_id::create("collected_transfer");
			collected_transfer.enable_recording($sformatf("%s.DCR_TRANSFER", get_full_name()));
			void'(collected_transfer.begin_tr($time));
			initialize_collected_item(collected_transfer);

			//send the item when it starts - identified that it started by having a 0 end time
			output_port.write(collected_transfer);

			@(posedge dut_vif.clk);
			collected_transfer.sys_clock_period = $time - collected_transfer.start_time;

			//determine the end of the transfer
			while(1 == 1) begin
				update_timeout_wait_changes(collected_transfer);

				if(dut_vif.ack === 1) begin
					if(collected_transfer.acknowledge_time == 0) begin
						collected_transfer.acknowledge_time = $time;
						if(collected_transfer.direction == READ) begin
							collected_transfer.data = dut_vif.d_bus_in;
						end
					end
				end

				if(((collected_transfer.direction == READ) && (dut_vif.read === 0)) ||
						((collected_transfer.direction == WRITE) && (dut_vif.write === 0))) begin
					if(collected_transfer.direction_disabled == 0) begin
						collected_transfer.direction_disabled = $time;
					end
				end

				if((dut_vif.ack === 0) &&
						(((collected_transfer.direction == READ) && (dut_vif.read === 0)) ||
							((collected_transfer.direction == WRITE) && (dut_vif.write === 0)))) begin
					collected_transfer.end_time = $time;

					output_port.write(collected_transfer);

					`uvm_info(get_id(), $sformatf("Collected item: %s", collected_transfer.convert2string()), UVM_LOW);
					collected_transfer.end_tr($time);

					check_transfer_length(collected_transfer);

					break;
				end

				@(posedge dut_vif.clk);
			end
		endtask

	endclass

`endif
