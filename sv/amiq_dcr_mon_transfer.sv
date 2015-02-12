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
 * NAME:        amiq_dcr_mon_transfer.sv
 * PROJECT:     amiq_dcr
 * Engineers:   Daniel Ciupitu (daniel.ciupitu@amiq.com)
 *              Cristian Florin Slav (cristian.slav@amiq.com)
 * Description: This file contains the declaration of the monitored transfer.
 *******************************************************************************/

`ifndef AMIQ_DCR_MON_TRANSFER_SV
	//protection against multiple includes
	`define AMIQ_DCR_MON_TRANSFER_SV

	// AMIQ DCR monitored transfer
	class amiq_dcr_mon_transfer extends amiq_dcr_transfer;

		//Time when direction was disabled - read signal became 0 or write signal became 0
		time direction_disabled;

		// Acknowledge time - a value of zero means that acknowledge was not received
		time acknowledge_time;

		//start time
		time start_time;

		//end time
		time end_time;

		//system clock period
		time sys_clock_period;

		//changes of "timeout wait" signal
		amiq_dcr_change#(.T(bit)) timeout_wait_changes[$];

		`uvm_object_utils(amiq_dcr_mon_transfer)

		//constructor
		//@param name - name of the object instance
		function new(string name = "");
			super.new(name);
			acknowledge_time = 0;
			start_time = 0;
			end_time = 0;
			sys_clock_period = 0;
		endfunction

		//function for recording the transfer
		//@param recorder - recorder for tracking all fields
		virtual function void do_record(input uvm_recorder recorder);
			super.do_record(recorder);
			recorder.record_field("ack", (acknowledge_time != 0), 1, UVM_BIN);
			recorder.record_field("timeout counter", get_timeout_counter(), 32, UVM_DEC);
		endfunction

		//converts the information containing in the instance of this class to an easy-to-read string
		//@return easy-to-read string with the information contained in the instance of this class
		virtual function string convert2string();
			if(acknowledge_time != 0) begin
				convert2string = $sformatf("%s, ACK (%0d)", super.convert2string(), acknowledge_time);
			end
			else begin
				convert2string = $sformatf("%s, NOT ACK", super.convert2string());
			end
		endfunction

		//function for returning the timeout counter value - number of clock cycles while waiting for acknowledge
		virtual function int unsigned get_timeout_counter();
			get_timeout_counter = 0;

			if(timeout_wait_changes.size() == 0) begin
				`uvm_fatal("AMIQ_DCT", $sformatf("Algorithm error: called get_timeout_counter() while no changes are available in timeout_wait_changes"));
			end

			if(sys_clock_period == 0) begin
				`uvm_fatal("AMIQ_DCT", $sformatf("Algorithm error: called get_timeout_counter() while system clock period was not set"));
			end

			begin
				time end_reference = ((acknowledge_time != 0) ? acknowledge_time : ((end_time != 0) ? end_time : $time));

				for(int i = 0; i < timeout_wait_changes.size(); i++) begin
					if(timeout_wait_changes[i].change_time > end_reference) begin
						break;
					end

					if(timeout_wait_changes[i].value == 0) begin
						if(i < timeout_wait_changes.size() - 1) begin
							time local_end_reference = timeout_wait_changes[i+1].change_time;

							if(local_end_reference > end_reference) begin
								local_end_reference = end_reference;
							end

							get_timeout_counter = get_timeout_counter + ((local_end_reference - timeout_wait_changes[i].change_time) / sys_clock_period);
						end
						else begin
							//this is the last element in the list
							get_timeout_counter = get_timeout_counter + ((end_reference - timeout_wait_changes[i].change_time) / sys_clock_period);
						end
					end
				end
			end
		endfunction

		//function to determine if the transfer was acknowledged
		//@return the acknowledge response for this DCR transfer
		virtual function bit is_acknowledged();
			return ((acknowledge_time == 0) ? 0 : 1);
		endfunction

		//function for getting the number of cycles of the DCR transfer
		//@return length of the DCR transfer in clock cycles
		virtual function int unsigned get_length();
			time used_end_time;

			if(sys_clock_period == 0) begin
				`uvm_fatal("AMIQ_DCT", $sformatf("Algorithm error: called get_length() while system clock period was not set"));
			end

			used_end_time = end_time;
			if(used_end_time == 0) begin
				used_end_time = $time;
			end

			return ((used_end_time - start_time) / sys_clock_period);
		endfunction

		//function to determine if during this transfer timeout wait was enabled
		//@return - returns value 1 if timeout wait was enabled at least once
		virtual function bit was_timeout_wait_enabled();
			was_timeout_wait_enabled = 0;

			for(int i = 0; i < timeout_wait_changes.size(); i++) begin
				if(timeout_wait_changes[i].value == 1) begin
					was_timeout_wait_enabled = 1;
					break;
				end
			end
		endfunction
	endclass

`endif

