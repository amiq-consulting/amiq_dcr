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
 * MODULE:      amiq_dcr_slave_seq_lib.sv
 * PROJECT:     amiq_dcr
 * Engineers:   Daniel Ciupitu (daniel.ciupitu@amiq.com)
 *              Cristian Florin Slav (cristian.slav@amiq.com)
 * Description: This file contains the definition of the slave sequence library.
 *******************************************************************************/

`ifndef AMIQ_DCR_SLAVE_SEQ_LIB_SV
	//protection against multiple includes
	`define AMIQ_DCR_SLAVE_SEQ_LIB_SV

	// DCR slave base sequence
	class amiq_dcr_slave_base_seq extends uvm_sequence#(amiq_dcr_slave_drv_transfer);

		`uvm_object_param_utils(amiq_dcr_slave_base_seq)

		`uvm_declare_p_sequencer(uagt_sequencer #(.REQ(amiq_dcr_slave_drv_transfer)))

		//constructor
		//@param name - name of the component instance
		function new(string name="");
			super.new(name);
		endfunction

	endclass

	// DCR slave simple sequence
	class amiq_dcr_slave_simple_seq extends amiq_dcr_slave_base_seq;

		`uvm_object_utils(amiq_dcr_slave_simple_seq)

		//constructor
		//@param name - name of the component instance
		function new(string name="");
			super.new(name);
		endfunction

		//body task
		virtual task body();
			amiq_dcr_slave_drv_transfer seq_item = amiq_dcr_slave_drv_transfer::type_id::create("seq_item");

			start_item(seq_item);

			if(!(seq_item.randomize())) begin
				`uvm_fatal("AMIQ_DCR", "The sequence item could not be generated");
			end

			finish_item(seq_item);
		endtask
	endclass

`endif
