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
 * NAME:        amiq_dcr_ex_reg_reg_file.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the register file
 *******************************************************************************/

`ifndef AMIQ_DCR_EX_REG_REG_FILE_SV
	//protection against multiple includes
	`define AMIQ_DCR_EX_REG_REG_FILE_SV

	//data register
	class amiq_dcr_ex_reg_reg_data extends uvm_reg;

		rand uvm_reg_field data;

		`uvm_object_utils(amiq_dcr_ex_reg_reg_data)

		//constructor
		//@param name - name of the component instance
		function new(string name = "");
			super.new(name, `AMIQ_DCR_MAX_DATA_WIDTH, 1);
		endfunction

		//build function
		virtual function void build();
			data = uvm_reg_field::type_id::create("data");
			data.configure(this, `AMIQ_DCR_MAX_DATA_WIDTH, 0, "RW", 0, 0, 1, 1, 1);
		endfunction

	endclass

`endif

