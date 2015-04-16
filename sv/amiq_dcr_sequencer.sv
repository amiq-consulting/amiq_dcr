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
 * NAME:        amiq_dcr_sequencer.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the DCR sequencer
 *******************************************************************************/

`ifndef AMIQ_DCR_SEQUENCER_SV
	//protection against multiple includes
	`define AMIQ_DCR_SEQUENCER_SV

	//DCR agent
	class amiq_dcr_sequencer #(type REQ=uvm_sequence_item, type RSP=REQ) extends uvm_sequencer#(.REQ(REQ), .RSP(RSP));

		`uvm_component_param_utils(amiq_dcr_sequencer#(REQ, RSP))

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name, uvm_component parent);
			super.new(name, parent);
		endfunction

		//function for handling reset
		//@param phase - current phase
		virtual function void handle_reset(uvm_phase phase);
			int objections_count;
			stop_sequences();

			objections_count = uvm_test_done.get_objection_count(this);

			if(objections_count > 0) begin
				uvm_test_done.drop_objection(this, $sformatf("Dropping %0d objections at reset", objections_count), objections_count);
			end

			start_phase_sequence(phase);
		endfunction

	endclass

`endif

