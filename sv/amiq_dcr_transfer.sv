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
 * MODULE:      amiq_dcr_transfer.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the DCR transfer
 *******************************************************************************/

`ifndef AMIQ_DCR_TRANSFER_SV
	//protection against multiple includes
	`define AMIQ_DCR_TRANSFER_SV

	// AMIQ DCR transfer
	class amiq_dcr_transfer extends amiq_dcr_base_transfer;

		// Direction of transfer
		rand amiq_dcr_direction direction;

		// Access type for transfer
		rand bit privileged;

		// DCR master ID indicator
		rand amiq_dcr_master_id master_id;

		// DCR address
		rand amiq_dcr_address address;

		`uvm_object_utils(amiq_dcr_transfer)

		//constructor
		//@param name - name of the object instance
		function new(string name = "");
			super.new(name);
		endfunction

		//function for recording the transfer
		//@param recorder - recorder for tracking all fields
		virtual function void do_record(input uvm_recorder recorder);
			super.do_record(recorder);
			recorder.record_string("direction", direction.name());
			recorder.record_field("address", address, `AMIQ_DCR_MAX_ADDR_WIDTH, UVM_HEX);
			recorder.record_field("data", data, `AMIQ_DCR_MAX_DATA_WIDTH, UVM_HEX);
			recorder.record_field("privileged", privileged, 1, UVM_BIN);
			recorder.record_field("master_id", master_id, (`AMIQ_DCR_MAX_MASTER_ID_WIDTH + 1), UVM_DEC);
		endfunction

		//converts the information containing in the instance of this class to an easy-to-read string
		//@return easy-to-read string with the information contained in the instance of this class
		virtual function string convert2string();
			convert2string = $sformatf("dir: %s, addr: %X, data: %X, priv: %b, master_id: %0d",
				direction.name(), address, data, privileged, master_id);
		endfunction

	endclass

`endif
