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
 * NAME:        amiq_dcr_master_agent_config.sv
 * PROJECT:     amiq_dcr
 * Engineer(s): Cristian Florin Slav (cristian.slav@amiq.com)
 *
 * Description: This file contains the declaration of the master agent
 *              configuration class.
 *******************************************************************************/

`ifndef AMIQ_DCR_MASTER_AGENT_CONFIG_SV
	//protection against multiple includes
	`define AMIQ_DCR_MASTER_AGENT_CONFIG_SV

	//DCR master agent configuration
	class amiq_dcr_master_agent_config extends amiq_dcr_agent_config;

		//time to wait before starting a new transfer, if the previous one ended due to timeout
		protected int unsigned drain_time_at_timeout = 1;

		//function for getting the value of addr_width field
		//@return addr_width field value
		virtual function int unsigned get_drain_time_at_timeout();
			return drain_time_at_timeout;
		endfunction

		//function for setting a new value for addr_width field
		//@param addr_width - new value of the addr_width field
		virtual function void set_drain_time_at_timeout(int unsigned drain_time_at_timeout);
			this.drain_time_at_timeout = drain_time_at_timeout;
		endfunction

		`uvm_component_utils(amiq_dcr_master_agent_config)

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name="", uvm_component parent);
			super.new(name, parent);
		endfunction

	endclass

`endif

