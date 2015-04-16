/******************************************************************************
 * (C) Copyright 2014 AMIQ Consulting
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
 * MODULE:      amiq_dcr_coverage.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the coverage.
 *******************************************************************************/

`ifndef AMIQ_DCR_COVERAGE_SV
	//protection against multiple includes
	`define AMIQ_DCR_COVERAGE_SV

	`uvm_analysis_imp_decl(_item_from_mon)

	// DCR coverage collector
	class amiq_dcr_coverage extends uvm_component;

		//pointer to the agent configuration class
		amiq_dcr_agent_config agent_config;

		//port for receiving items collected by the monitor
		uvm_analysis_imp_item_from_mon#(amiq_dcr_mon_transfer,amiq_dcr_coverage) item_from_mon_port;

		//consecutive collected transfers
		protected amiq_dcr_mon_transfer collected_transfers[$];

		//casted agent configuration
		amiq_dcr_agent_config casted_agent_config;

		`uvm_component_utils(amiq_dcr_coverage)

		// Cover transfer components
		covergroup cover_transfer with function sample(amiq_dcr_mon_transfer collected_item);
			option.per_instance = 1;

			direction : coverpoint collected_item.direction {
				type_option.comment = "Direction of the DCR transfer";
			}

			trans_direction : coverpoint collected_item.direction {
				bins direction_trans[] = (READ, WRITE => READ, WRITE);
				type_option.comment = "Direction transitions of the DCR transfer";
			}

			privilege_access : coverpoint collected_item.privileged iff (casted_agent_config.get_has_privileged()) {
				type_option.comment = "Privileged attribute of the DCR transfer";
				bins non_privileged_access = {0};
				bins privileged_access = {1};
				bins privileged_transitions[] = (0, 1 => 0, 1);
			}

			master_id : coverpoint collected_item.master_id iff (casted_agent_config.get_has_master_id()) {
				type_option.comment = "Master ID of the DCR transfer";
			}

			acknowledged : coverpoint collected_item.is_acknowledged() {
				type_option.comment = "Acknowledge response of the DCR transfer";
				bins not_acknowledged = {0};
				bins acknowledged = {1};
				bins acknowledged_transitions[] = (0, 1 => 0, 1);
			}

			transfer_length : coverpoint collected_item.get_length() {
				type_option.comment = "Length of the DCR transfer in clock cycles";
				bins minimum_ccc = {3};
				bins small_ccc[1] = {[4:10]};
				bins medium_ccc[1] = {[11:100]};
				bins large_ccc[1] = {[101:$]};
				bins transitions = (3, [4:10], [11:100], [101:$] => 3, [4:10], [11:100], [101:$]);
			}

			`cvr_multiple_32_bits(address, collected_item.address, )

			`cvr_multiple_32_bits(data, collected_item.data, )

			was_timeout_active : coverpoint collected_item.was_timeout_wait_enabled() {
				type_option.comment = "\"Timeout Wait\" was active at least once during this transfer";
				bins no = {0};
				bins yes = {1};
			}

			transfer_definition : cross direction, privilege_access, master_id, acknowledged {
				type_option.comment = "Cross coverage with all the main fields of the DCR transfer";
			}
		endgroup

		//Cover the delay between two transfers
		covergroup cover_delay_between_transfers;
			option.per_instance = 1;

			//Cover the delays between transfer
			transfer_delay_units : coverpoint get_delay_between_transfers() {
				type_option.comment = "Delay, in clock cycles, between two consecutive transfers";
				bins back2back[] = {0};
				bins small_delays[1] = {[1:10]};
				bins medium_delays[1] = {[11:50]};
				bins big_delays[1] = {[51:100]};
			}
		endgroup

		//cover reset information
		covergroup cover_reset;
			option.per_instance = 1;

			bus_not_idle_at_reset : coverpoint get_bus_phase() {
				type_option.comment = "Bus phase at reset";
			}
		endgroup

		//function for getting the delay between two consecutive transfers
		//@return the delay between two consecutive transfers
		protected function int unsigned get_delay_between_transfers();
			AMIQ_DCR_ALGORITHM_ERROR : assert (collected_transfers.size() == 2) else
				`uvm_fatal("COVERAGE", $sformatf("Expecting collected_transfers.size() = 2 but found %0d", collected_transfers.size()))

			return (((collected_transfers[1].start_time - collected_transfers[0].end_time) /  collected_transfers[0].sys_clock_period) - 1);
		endfunction

		//get the current bus phase
		//@return bus phase
		virtual protected function amiq_dcr_bus_phase get_bus_phase();
			get_bus_phase = IDLE;

			if(collected_transfers.size() > 0) begin
				amiq_dcr_mon_transfer transfer = collected_transfers[collected_transfers.size() - 1];

				if(transfer.end_time == 0) begin
					if((transfer.acknowledge_time == 0) && (transfer.direction_disabled == 0)) begin
						get_bus_phase = REQUEST;
					end
					else if((transfer.acknowledge_time != 0) && (transfer.direction_disabled == 0)) begin
						get_bus_phase = ACKNOWLEGED;
					end
					else if((transfer.acknowledge_time != 0) && (transfer.direction_disabled != 0)) begin
						get_bus_phase = END;
					end
				end
			end
		endfunction

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name="", uvm_component parent);
			super.new(name, parent);
			
			item_from_mon_port = new("item_from_mon_port", this);

			cover_transfer = new();
			cover_transfer.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_transfer"));

			cover_delay_between_transfers = new();
			cover_delay_between_transfers.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_delay_between_transfers"));

			cover_reset = new();
			cover_reset.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_reset"));
		endfunction

		//function for getting the ID used in messaging
		//@return message ID
		virtual function string get_id();
			return "COV";
		endfunction

		//UVM start of simulation phase
		//@param phase - current phase
		virtual function void start_of_simulation_phase(input uvm_phase phase);
			super.start_of_simulation_phase(phase);
			assert ($cast(casted_agent_config, agent_config) == 1) else
				`uvm_fatal(get_id(), "Could not cast agent configuration to amiq_dcr_agent_config");
		endfunction

		//implementation of the port receiving item from the monitor
		//@param item - received item from the monitor
		virtual function void write_item_from_mon(input amiq_dcr_mon_transfer transfer);
			if(transfer.end_time != 0) begin
				cover_transfer.sample(transfer);

				begin
					bit found_item = 0;
					for(int i = 0; i < collected_transfers.size(); i++) begin
						if(collected_transfers[i].start_time == transfer.start_time) begin
							collected_transfers[i] = transfer;
							found_item = 1;
							break;
						end
					end

					AMIQ_DCR_ALGORITHM_ERROR : assert (found_item == 1) else
						`uvm_fatal("COVERAGE", $sformatf("Did not found item in collected_transfers: %s", transfer.convert2string()));
				end
			end
			else begin
				collected_transfers.push_back(transfer);

				while(collected_transfers.size() > 2) begin
					void'(collected_transfers.pop_front());
				end

				if(collected_transfers.size() == 2) begin
					cover_delay_between_transfers.sample();
				end
			end
		endfunction

		//function for handling reset
		virtual function void handle_reset();
			cover_reset.sample();
			while(collected_transfers.size() > 0) begin
				void'(collected_transfers.pop_front());
			end
		endfunction

	endclass

`endif
