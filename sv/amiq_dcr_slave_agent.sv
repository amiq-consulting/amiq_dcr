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
 * NAME:        amiq_dcr_slave_agent.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the slave agent.
 *******************************************************************************/

`ifndef AMIQ_DCR_SLAVE_AGENT_SV
	//protection against multiple includes
	`define AMIQ_DCR_SLAVE_AGENT_SV

	// DCR slave agent
	class amiq_dcr_slave_agent extends amiq_dcr_agent #(.DRIVER_ITEM_REQ(amiq_dcr_slave_drv_transfer));

		`uvm_component_utils(amiq_dcr_slave_agent)

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(input string name, input uvm_component parent);
			super.new(name, parent);

			amiq_dcr_agent_config::type_id::set_inst_override(amiq_dcr_slave_agent_config::get_type(), "agent_config", this);
			amiq_dcr_driver#(.DRIVER_ITEM_REQ(amiq_dcr_slave_drv_transfer))::type_id::set_inst_override(amiq_dcr_slave_driver::get_type(), "driver", this);
		endfunction

	endclass

`endif
