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
 * NAME:        amiq_dcr_agent.sv
 * PROJECT:     amiq_dcr
 * Engineers:   Daniel Ciupitu (daniel.ciupitu@amiq.com)
 *              Cristian Florin Slav (cristian.slav@amiq.com)
 * Description: This file contains the declaration of the DCR agent
 *******************************************************************************/

`ifndef AMIQ_DCR_AGENT_SV
	//protection against multiple includes
	`define AMIQ_DCR_AGENT_SV

	//DCR agent
	class amiq_dcr_agent #(type DRIVER_ITEM_REQ=uvm_sequence_item) extends cagt_agent #(.VIRTUAL_INTF_TYPE(amiq_dcr_vif), .MONITOR_ITEM(amiq_dcr_mon_transfer), .DRIVER_ITEM_REQ(DRIVER_ITEM_REQ));

		`uvm_component_param_utils(amiq_dcr_agent#(DRIVER_ITEM_REQ))

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name, uvm_component parent);
			super.new(name, parent);

			cagt_monitor#(.VIRTUAL_INTF_TYPE(amiq_dcr_vif), .MONITOR_ITEM(amiq_dcr_mon_transfer))::type_id::set_inst_override(amiq_dcr_monitor::get_type(), "monitor", this);
			cagt_coverage#(.VIRTUAL_INTF_TYPE(amiq_dcr_vif), .MONITOR_ITEM(amiq_dcr_mon_transfer))::type_id::set_inst_override(amiq_dcr_coverage::get_type(), "coverage", this);
		endfunction

	endclass

`endif

