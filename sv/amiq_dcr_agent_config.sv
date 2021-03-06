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
 * MODULE:      amiq_dcr_agent_config.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the agent configuration class.
 *******************************************************************************/

`ifndef AMIQ_DCR_AGENT_CONFIG_SV
	//protection against multiple includes
	`define AMIQ_DCR_AGENT_CONFIG_SV

	// DCR agent config (enable/disable checkers and coverage switches)
	class amiq_dcr_agent_config extends uvm_component;

		//switch to determine the active or the passive aspect of the agent
		protected uvm_active_passive_enum is_active = UVM_ACTIVE;

		//switch to determine if to enable or not the coverage
		protected bit has_coverage = 1;

		//switch to determine if to enable or not the checks
		protected bit has_checks = 1;

		//active level of reset signal
		protected bit reset_active_level = 0;

		//pointer to the DUT interface
		protected amiq_dcr_vif dut_vif;

		// Enable DCR privileged optional signal
		protected bit has_privileged = 1;

		// Enable DCR Master ID optional signal
		protected bit has_master_id = 1;

		// Address width
		protected int unsigned address_width = `AMIQ_DCR_MAX_ADDR_WIDTH;

		// Maximum delay (clock cycles) until a timeout occurs
		protected int unsigned max_timeout_delay = 1_000;

		//function for getting the value of is_active field
		//@return is_active field value
		virtual function uvm_active_passive_enum get_is_active();
			return is_active;
		endfunction

		//function for setting a new value for is_active field
		//@param is_active - new value of the is_active field
		virtual function void set_is_active(uvm_active_passive_enum is_active);
			this.is_active = is_active;
		endfunction

		//function for getting the value of has_coverage field
		//@return has_coverage field value
		virtual function bit get_has_coverage();
			return has_coverage;
		endfunction

		//function for setting a new value for has_coverage field
		//@param has_coverage - new value of the has_coverage field
		virtual function void set_has_coverage(bit has_coverage);
			this.has_coverage = has_coverage;
		endfunction

		//function for getting the value of has_checks field
		//@return has_checks field value
		virtual function bit get_has_checks();
			return has_checks;
		endfunction

		//function for setting a new value for has_checks field
		//@param has_checks - new value of the has_checks field
		virtual function void set_has_checks(bit has_checks);
			this.has_checks = has_checks;

			if(dut_vif != null) begin
				dut_vif.has_checks = has_checks;
			end
		endfunction

		//function for getting the value of dut_vif field
		//@return dut_vif field value
		virtual function amiq_dcr_vif get_dut_vif();
			return dut_vif;
		endfunction

		//function for setting a new value for dut_vif field
		//@param dut_vif - new value of the dut_vif field
		virtual function void set_dut_vif(amiq_dcr_vif dut_vif);
			this.dut_vif = dut_vif;
		endfunction

		//function for getting the value of reset_active_level field
		//@return reset_active_level field value
		virtual function bit get_reset_active_level();
			return reset_active_level;
		endfunction

		//function for setting a new value for reset_active_level field
		//@param reset_active_level - new value of the reset_active_level field
		virtual function void set_reset_active_level(bit reset_active_level);
			this.reset_active_level = reset_active_level;
		endfunction

		//function for getting the value of has_privileged field
		//@return has_privileged field value
		virtual function bit get_has_privileged();
			return has_privileged;
		endfunction

		//function for setting a new value for has_privileged field
		//@param has_privileged - new value of the has_privileged field
		virtual function void set_has_privileged(bit has_privileged);
			this.has_privileged = has_privileged;
		endfunction

		//function for getting the value of has_master_id field
		//@return has_master_id field value
		virtual function bit get_has_master_id();
			return has_master_id;
		endfunction

		//function for setting a new value for has_master_id field
		//@param has_master_id - new value of the has_master_id field
		virtual function void set_has_master_id(bit has_master_id);
			this.has_master_id = has_master_id;
		endfunction

		//function for getting the value of addr_width field
		//@return addr_width field value
		virtual function int unsigned get_address_width();
			return address_width;
		endfunction

		//function for setting a new value for addr_width field
		//@param addr_width - new value of the addr_width field
		virtual function void set_address_width(int unsigned addr_width);
			this.address_width = addr_width;
		endfunction

		//function for getting the value of max_timeout_delay field
		//@return max_timeout_delay field value
		virtual function int unsigned get_max_timeout_delay();
			return max_timeout_delay;
		endfunction

		//function for setting a new value for max_timeout_delay field
		//@param max_timeout_delay - new value of the max_timeout_delay field
		virtual function void set_max_timeout_delay(int unsigned max_timeout_delay);
			this.max_timeout_delay = max_timeout_delay;

			if(dut_vif != null) begin
				dut_vif.timeout_counter = max_timeout_delay;
			end
		endfunction

		//function to get the address mask based on its width
		//@return address mask
		function amiq_dcr_address get_address_mask();
			bit[`AMIQ_DCR_MAX_ADDR_WIDTH:0] mask = 1;
			mask = mask << address_width;
			return (mask - 1);
		endfunction

		`uvm_component_utils(amiq_dcr_agent_config)

		//function for getting the ID used in messaging
		//@return message ID
		virtual function string get_id();
			return "AGT_CFG";
		endfunction

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name="", uvm_component parent);
			super.new(name, parent);
			set_reset_active_level(0);
		endfunction

		//UVM start of simulation phase
		//@param phase - current phase
		virtual function void start_of_simulation_phase(input uvm_phase phase);
			super.start_of_simulation_phase(phase);
			
			AMIQ_DCR_DUT_IF_NULL : assert (dut_vif != null) else
				`uvm_fatal(get_id(), "The pointer to the DUT interface is null - please make sure you set it via set_dut_vif() function before \"Start of Simulation\" phase!");

			AMIQ_DCR_ILLEGAL_ADDR_WIDTH_DEFINES : assert ((`AMIQ_DCR_MIN_ADDR_WIDTH <= `AMIQ_DCR_MAX_ADDR_WIDTH)) else
				`uvm_fatal(get_id(), $sformatf("Illegal defines: AMIQ_DCR_MIN_ADDR_WIDTH: %d should be less or equal to AMIQ_DCR_MAX_ADDR_WIDTH: %0d",
					`AMIQ_DCR_MIN_ADDR_WIDTH,`AMIQ_DCR_MAX_ADDR_WIDTH));

			AMIQ_DCR_ILLEGAL_ADDR_WIDTH : assert ((address_width >= `AMIQ_DCR_MIN_ADDR_WIDTH) && (address_width <= `AMIQ_DCR_MAX_ADDR_WIDTH)) else
				`uvm_fatal(get_id(), $sformatf("addr_width should be in interval [%0d..%0d] but it was set to %0d",
					`AMIQ_DCR_MIN_ADDR_WIDTH,`AMIQ_DCR_MAX_ADDR_WIDTH,  address_width));

			dut_vif.has_checks = has_checks;
			dut_vif.timeout_threshold = max_timeout_delay;
		endfunction

		//task for waiting the reset to start
		virtual task wait_reset_start();
			if(reset_active_level == 0) begin
				@(negedge dut_vif.reset_n);
			end
			else begin
				@(posedge dut_vif.reset_n);
			end
		endtask

		//task for waiting the reset to be finished
		virtual task wait_reset_end();
			if(reset_active_level == 0) begin
				@(posedge dut_vif.reset_n);
			end
			else begin
				@(negedge dut_vif.reset_n);
			end
		endtask

	endclass

`endif
