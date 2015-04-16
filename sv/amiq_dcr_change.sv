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
 * NAME:        amiq_dcr_change.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the change information
 *******************************************************************************/

`ifndef AMIQ_DCR_CHANGE_SV
	//protection against multiple includes
	`define AMIQ_DCR_CHANGE_SV

	//change information
	class amiq_dcr_change #(type T=bit) extends uvm_object;

		//new value of the signal
		T value;

		//time when the change happen
		time change_time;

		`uvm_object_param_utils(amiq_dcr_change#(T))

		//constructor
		//@param name - name of the object instance
		function new(string name = "");
			super.new(name);
		endfunction

	endclass
`endif

