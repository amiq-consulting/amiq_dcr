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
 * NAME:        amiq_dcr_master_agent.sv
 * PROJECT:     amiq_dcr
 * Engineers:   Daniel Ciupitu (daniel.ciupitu@amiq.com)
 *              Cristian Florin Slav (cristian.slav@amiq.com)
 * Description: This file contains the declaration of the master agent.
 *******************************************************************************/

`ifndef AMIQ_DCR_MASTER_AGENT_SV
	//protection against multiple includes
	`define AMIQ_DCR_MASTER_AGENT_SV

	// DCR master agent
	class amiq_dcr_master_agent extends amiq_dcr_agent #(.DRIVER_ITEM_REQ(amiq_dcr_master_drv_transfer));

		`uvm_component_utils(amiq_dcr_master_agent)

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(input string name, input uvm_component parent);
			super.new(name, parent);

			cagt_agent_config #(.VIRTUAL_INTF_TYPE(amiq_dcr_vif))::type_id::set_inst_override(amiq_dcr_master_agent_config::get_type(), "agent_config", this);
			cagt_driver #(.VIRTUAL_INTF_TYPE(amiq_dcr_vif), .REQ(amiq_dcr_master_drv_transfer))::type_id::set_inst_override(amiq_dcr_master_driver::get_type(), "driver", this);
		endfunction

	endclass

`endif
