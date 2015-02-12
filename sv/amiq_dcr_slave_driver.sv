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
 * NAME:        amiq_dcr_slave_driver.sv
 * PROJECT:     amiq_dcr
 * Engineers:   Daniel Ciupitu (daniel.ciupitu@amiq.com)
 *              Cristian Florin Slav (cristian.slav@amiq.com)
 * Description: This file contains the declaration of the slave driver.
 *******************************************************************************/

`ifndef AMIQ_DCR_SLAVE_DRIVER_SV
	//protection against multiple includes
	`define AMIQ_DCR_SLAVE_DRIVER_SV

	// DCR slave Driver
	class amiq_dcr_slave_driver extends uagt_driver #(.VIRTUAL_INTF_TYPE(amiq_dcr_vif), .REQ(amiq_dcr_slave_drv_transfer));

		//casted agent configuration
		amiq_dcr_slave_agent_config slave_agent_config;

		//pointer to DUT virtual interface
		local amiq_dcr_vif dut_vif;

		`uvm_component_param_utils(amiq_dcr_slave_driver)

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
			assert ($cast(slave_agent_config, agent_config) == 1) else
				`uvm_fatal(get_id(), "Could not cast agent configuration to amiq_dcr_slave_agent_config");
			dut_vif = agent_config.get_dut_vif();
		endfunction

		//function for handling reset
		virtual function void handle_reset();
			super.handle_reset();

			dut_vif.timeout_wait <= 0;
			dut_vif.ack <= 0;
			dut_vif.d_bus_in <= 0;
		endfunction

		//function to get the custom read data
		//@param transfer - transaction to be driven on the bus
		//@param address - current address on the bus
		//@return read data
		virtual function amiq_dcr_data get_read_data(amiq_dcr_slave_drv_transfer transfer, amiq_dcr_address address, amiq_dcr_master_id master_id);
			return transfer.data;
		endfunction

		process p;
		//task for driving one transaction
		virtual task drive_transaction(amiq_dcr_slave_drv_transfer transaction);

			while((dut_vif.read === 0) && (dut_vif.write === 0)) begin
				@(posedge dut_vif.clk);
			end

			`uvm_info(get_id(), $sformatf("Driving transfer: %s", transaction.convert2string()), UVM_LOW);

			fork
				begin
					fork
						begin
							for(int i = 0; i < transaction.cycles_until_acknowledge; i++) begin
								@(posedge dut_vif.clk);
							end

							dut_vif.ack <= transaction.acknowledge;
							if(dut_vif.read === 1) begin
								dut_vif.d_bus_in <= get_read_data(transaction, dut_vif.a_bus, dut_vif.master_id);
							end
							@(posedge dut_vif.clk);
						end
						begin
							if(slave_agent_config.get_has_timeout_wait_sig()) begin
								int unsigned delay;
								bit current_timeout = transaction.timeout_wait_init_value;

								dut_vif.timeout_wait <= current_timeout;

								while (1) begin
									if(current_timeout == 0) begin
										assert (std::randomize(delay) with {
													(delay >= transaction.timeout_off_min) &&
													(delay <= transaction.timeout_off_max);
												}) else
											`uvm_fatal(get_id(), "Could not randomize delay");
									end
									else begin
										assert (std::randomize(delay) with {
													(delay >= transaction.timeout_on_min) &&
													(delay <= transaction.timeout_on_max);
												}) else
											`uvm_fatal(get_id(), "Could not randomize delay");
									end

									for(int i = 0; i < delay; i++) begin
										@(posedge dut_vif.clk);
									end

									current_timeout = ~current_timeout;
									dut_vif.timeout_wait <= current_timeout;
								end

							end
							else begin
								while(1) begin
									@(posedge dut_vif.clk);
								end
							end
						end
						begin
							while((dut_vif.read !== 0) || (dut_vif.write !== 0)) begin
								@(posedge dut_vif.clk);
							end
						end
					join_any
					disable fork;
				end
			join

			if((transaction.acknowledge == 0) && (dut_vif.timeout_wait == 1)) begin
				//simulation can get stuck as nobody will make timeout 0 back
				dut_vif.timeout_wait <= 0;
			end

			while((dut_vif.read !== 0) || (dut_vif.write !== 0)) begin
				@(posedge dut_vif.clk);
			end
			dut_vif.ack <= 0;

		endtask

	endclass

`endif
