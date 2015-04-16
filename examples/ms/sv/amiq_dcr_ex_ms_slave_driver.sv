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
 * NAME:        amiq_dcr_ex_ms_slave_driver.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the slave driver which should
 *              drive on read transfers data from the register model.
 *******************************************************************************/

`ifndef AMIQ_DCR_EX_MS_SLAVE_DRIVER_SV
	//protection against multiple includes
	`define AMIQ_DCR_EX_MS_SLAVE_DRIVER_SV

	class amiq_dcr_ex_ms_slave_driver extends amiq_dcr_slave_driver;

		//pointer to the register block
		amiq_dcr_ex_ms_reg_block reg_block;

		`uvm_component_utils(amiq_dcr_ex_ms_slave_driver)

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name="", uvm_component parent);
			super.new(name, parent);
		endfunction

		//function to get the custom read data
		//@param transfer - transaction to be driven on the bus
		//@param address - current address on the bus
		//@return read data
		virtual function amiq_dcr_data get_read_data(amiq_dcr_slave_drv_transfer transfer, amiq_dcr_address address, amiq_dcr_master_id master_id);
			uvm_reg accessed_reg = reg_block.default_map.get_reg_by_offset(address, 1);

			if(accessed_reg != null) begin
				return accessed_reg.get_mirrored_value();
			end
			else begin
				return transfer.data;
			end
		endfunction

	endclass

`endif

