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
 * NAME:        amiq_dcr_slave_drv_transfer.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the slave driven transfer.
 *******************************************************************************/

`ifndef AMIQ_DCR_SLAVE_DRV_TRANSFER_SV
	//protection against multiple includes
	`define AMIQ_DCR_SLAVE_DRV_TRANSFER_SV

	// AMIQ DCR master driven transfer
	class amiq_dcr_slave_drv_transfer extends amiq_dcr_base_transfer;

		//clock cycles to wait until driving acknowledge
		rand int unsigned cycles_until_acknowledge;

		//value of acknowledge
		rand bit acknowledge;

		//determine if to force timeout wait
		rand bit timeout_wait;

		//value of the "timeout wait" at the beginning of the transfer.
		//after the beginning of the transfer "timeout wait" signal will be oscillated
		//based on random delays generated considering min timeout_<on|off>_<min|max>
		rand bit timeout_wait_init_value;

		//minimum length while timeout is asserted
		rand int unsigned timeout_on_min;

		//maximum length while timeout is asserted
		rand int unsigned timeout_on_max;

		//minimum length while timeout is de-asserted
		rand int unsigned timeout_off_min;

		//maximum length while timeout is de-asserted
		rand int unsigned timeout_off_max;

		constraint acknowledge_default {
			soft acknowledge dist {
				0 := 10,
				1 := 90
			};
		}

		constraint cycles_until_acknowledge_default {
			soft cycles_until_acknowledge <= 500;
		}

		constraint timeout_on_default {
			timeout_on_min <= timeout_on_max;
			soft timeout_on_min inside {[10:20]};
			soft timeout_on_max inside {[50:60]};
		}

		constraint timeout_off_default {
			timeout_off_min <= timeout_off_max;
			soft timeout_off_min inside {[1:10]};
			soft timeout_off_max inside {[200:300]};
		}

		`uvm_object_utils(amiq_dcr_slave_drv_transfer)

		//constructor
		//@param name - name of the object instance
		function new(string name = "");
			super.new(name);
		endfunction

		//converts the information containing in the instance of this class to an easy-to-read string
		//@return easy-to-read string with the information contained in the instance of this class
		virtual function string convert2string();
			convert2string = $sformatf("ack: %b, data: %X", acknowledge, data);
		endfunction

	endclass

`endif

