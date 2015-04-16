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
 * NAME:        amiq_dcr_ex_ms_reg2dcr_adapter.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the register adaptor
 *******************************************************************************/

`ifndef AMIQ_DCR_EX_MS_REG2DCR_ADAPTER_SV
	//protection against multiple includes
	`define AMIQ_DCR_EX_MS_REG2DCR_ADAPTER_SV

	class amiq_dcr_ex_ms_reg2dcr_adapter extends uvm_reg_adapter;

		`uvm_object_utils(amiq_dcr_ex_ms_reg2dcr_adapter)

		//function for getting the ID used in messaging
		//@return message ID
		virtual function string get_id();
			return "ADAPTER";
		endfunction

		//constructor
		//@param name - name of the component instance
		function new(string name = "");
			super.new(name);
		endfunction

		virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
			amiq_dcr_master_drv_transfer transaction = amiq_dcr_master_drv_transfer::type_id::create("transaction");

			assert (transaction.randomize() with {
						address == rw.addr;
						data == rw.data;
					}) else
				`uvm_fatal(get_id(), "Could not randomize amiq_uart_drv_item_master");

			if(rw.kind == UVM_WRITE) begin
				transaction.direction = WRITE;
			end
			else begin
				transaction.direction = READ;
			end

			return transaction;
		endfunction

		virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
			amiq_dcr_mon_transfer transaction;

			rw.status = UVM_NOT_OK;

			if($cast(transaction, bus_item)) begin
				if(transaction.direction == WRITE) begin
					rw.kind = UVM_WRITE;
				end
				else begin
					rw.kind = UVM_READ;
				end

				rw.addr = transaction.address;
				rw.data = transaction.data;
				rw.status = UVM_IS_OK;
			end
			else begin
				`uvm_fatal(get_id(), $sformatf("casting did not worked - bus_item: %s", bus_item.convert2string()))
			end

		endfunction
	endclass

`endif

