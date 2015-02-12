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
 * NAME:        amiq_dcr_master_drv_transfer.sv
 * PROJECT:     amiq_dcr
 * Engineers:   Daniel Ciupitu (daniel.ciupitu@amiq.com)
 *              Cristian Florin Slav (cristian.slav@amiq.com)
 * Description: This file contains the declaration of the master driven transfer.
 *******************************************************************************/

`ifndef AMIQ_DCR_MASTER_DRV_TRANSFER_SV
	//protection against multiple includes
	`define AMIQ_DCR_MASTER_DRV_TRANSFER_SV

	// AMIQ DCR master driven transfer
	class amiq_dcr_master_drv_transfer extends amiq_dcr_transfer;

		// Delay before transfer
		rand int unsigned transfer_delay;

		// Constrain transfer delay generation
		constraint transfer_delay_default {
			soft transfer_delay <= 1000;
		}

		`uvm_object_utils(amiq_dcr_master_drv_transfer)

		//constructor
		//@param name - name of the object instance
		function new(string name = "");
			super.new(name);
		endfunction

		//converts the information containing in the instance of this class to an easy-to-read string
		//@return easy-to-read string with the information contained in the instance of this class
		virtual function string convert2string();
			if(direction == WRITE) begin
				convert2string = $sformatf("dir: %s, addr: %X, data: %X, priv: %b, master_id: %0d",
					direction.name(), address, data, privileged, master_id);
			end
			else begin
				convert2string = $sformatf("dir: %s, addr: %X,priv: %b, master_id: %0d",
					direction.name(), address, privileged, master_id);
			end
		endfunction

	endclass

`endif

