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
 * NAME:        amiq_dcr_ex_reg_dcr2reg_predictor.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the register predictor
 *******************************************************************************/

`ifndef AMIQ_DCR_EX_REG_DCR2REG_PREDICTOR_SV
	//protection against multiple includes
	`define AMIQ_DCR_EX_REG_DCR2REG_PREDICTOR_SV

	//predictor
	class amiq_dcr_ex_reg_dcr2reg_predictor extends uvm_reg_predictor#(amiq_dcr_mon_transfer);

		`uvm_component_utils(amiq_dcr_ex_reg_dcr2reg_predictor)

		//function for getting the ID used in messaging
		//@return message ID
		virtual function string get_id();
			return "PREDICTOR";
		endfunction

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(input string name, input uvm_component parent);
			super.new(name, parent);
		endfunction

		virtual function void write(amiq_dcr_mon_transfer tr);
			if(tr.acknowledge_time != 0) begin
				super.write(tr);
			end
		endfunction

	endclass

`endif

