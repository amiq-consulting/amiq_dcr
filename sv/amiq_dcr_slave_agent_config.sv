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
 * NAME:        amiq_dcr_slave_agent_config.sv
 * PROJECT:     amiq_dcr
 * Engineer(s): Cristian Florin Slav (cristian.slav@amiq.com)
 *
 * Description: This file contains the declaration of the slave agent
 *              configuration class.
 *******************************************************************************/

`ifndef AMIQ_DCR_SLAVE_AGENT_CONFIG_SV
	//protection against multiple includes
	`define AMIQ_DCR_SLAVE_AGENT_CONFIG_SV

	//DCR slave agent configuration
	class amiq_dcr_slave_agent_config extends amiq_dcr_agent_config;

		// Enable DCR TimeoutWait optional signal
		protected bit has_timeout_wait_sig = 1;

		//function for getting the value of has_timeout_wait_sig field
		//@return has_timeout_wait_sig field value
		virtual function bit get_has_timeout_wait_sig();
			return has_timeout_wait_sig;
		endfunction

		//function for setting a new value for has_timeout_wait_sig field
		//@param has_timeout_wait_sig - new value of the has_timeout_wait_sig field
		virtual function void set_has_timeout_wait_sig(bit has_timeout_wait_sig);
			this.has_timeout_wait_sig = has_timeout_wait_sig;
		endfunction

		`uvm_component_utils(amiq_dcr_slave_agent_config)

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name="", uvm_component parent);
			super.new(name, parent);
		endfunction

	endclass

`endif

