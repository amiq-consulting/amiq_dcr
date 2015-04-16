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
 * MODULE:      amiq_dcr_base_transfer.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the DCR basic transfer
 *******************************************************************************/

`ifndef AMIQ_DCR_BASE_TRANSFER_SV
	//protection against multiple includes
	`define AMIQ_DCR_BASE_TRANSFER_SV

	// AMIQ DCR basic transfer
	class amiq_dcr_base_transfer extends uvm_sequence_item;

		// DCR data
		rand amiq_dcr_data data;

		`uvm_object_utils(amiq_dcr_base_transfer)

		//constructor
		//@param name - name of the component instance
		function new(string name = "");
			super.new(name);
		endfunction

	endclass

`endif
