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
 * NAME:        amiq_dcr_ex_ms_scoreboard.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the scoreboard.
 *******************************************************************************/

`ifndef AMIQ_DCR_EX_MS_SCOREBOARD_SV
	//protection against multiple includes
	`define AMIQ_DCR_EX_MS_SCOREBOARD_SV

	`uvm_analysis_imp_decl(_master_mon)
	`uvm_analysis_imp_decl(_master_drv)
	`uvm_analysis_imp_decl(_slave_drv)

	//scoreboard
	class amiq_dcr_ex_ms_scoreboard extends uvm_component;

		uvm_analysis_imp_master_mon#(amiq_dcr_mon_transfer, amiq_dcr_ex_ms_scoreboard) input_port_master_mon;

		uvm_analysis_imp_master_drv#(amiq_dcr_master_drv_transfer, amiq_dcr_ex_ms_scoreboard) input_port_master_drv;
		uvm_analysis_imp_slave_drv#(amiq_dcr_slave_drv_transfer, amiq_dcr_ex_ms_scoreboard) input_port_slave_drv;

		//elements received from the master driver
		amiq_dcr_master_drv_transfer master_drv_items[$];

		//elements received from the slave driver
		amiq_dcr_slave_drv_transfer slave_drv_items[$];

		`uvm_component_utils(amiq_dcr_ex_ms_scoreboard)

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(input string name, input uvm_component parent);
			super.new(name, parent);

			input_port_master_mon = new("input_port_master_mon", this);
			input_port_master_drv = new("input_port_master_drv", this);
			input_port_slave_drv = new("input_port_slave_drv", this);
		endfunction

		//function for getting the ID used in messaging
		//@return message ID
		virtual function string get_id();
			return "SCOREBOARD";
		endfunction

		//port implementation for data coming from master monitor
		virtual function void write_master_mon(amiq_dcr_mon_transfer transaction);
			if(transaction.end_time != 0) begin
				if(master_drv_items.size() == 0) begin
					`uvm_fatal(get_id(), $sformatf("Received monitor item %s but there is no element in master_drv_items", transaction.convert2string()))
				end

				if(slave_drv_items.size() == 0) begin
					`uvm_fatal(get_id(), $sformatf("Received monitor item %s but there is no element in slave_drv_items", transaction.convert2string()))
				end

				if(transaction.direction != master_drv_items[0].direction) begin
					`uvm_fatal(get_id(), $sformatf("direction mismatch - exp: %s, rcv: %s", master_drv_items[0].direction.name(), transaction.direction.name()))
				end

				if(transaction.privileged != master_drv_items[0].privileged) begin
					`uvm_fatal(get_id(), $sformatf("privileged mismatch - exp: %b, rcv: %b", master_drv_items[0].privileged, transaction.privileged))
				end

				if(transaction.master_id != master_drv_items[0].master_id) begin
					`uvm_fatal(get_id(), $sformatf("master_id mismatch - exp: %d, rcv: %d", master_drv_items[0].master_id, transaction.master_id))
				end

				if(transaction.address != master_drv_items[0].address) begin
					`uvm_fatal(get_id(), $sformatf("address mismatch - exp: %X, rcv: %X", master_drv_items[0].address, transaction.address))
				end

				if(transaction.acknowledge_time != 0) begin
					if(slave_drv_items[0].acknowledge != 1) begin
						`uvm_fatal(get_id(), $sformatf("ack mismatch - exp: 1, rcv: %b", slave_drv_items[0].acknowledge))
					end
				end

				if(transaction.direction == WRITE) begin
					if(transaction.data != master_drv_items[0].data) begin
						`uvm_fatal(get_id(), $sformatf("data mismatch - exp: %X, rcv: %X", master_drv_items[0].data, transaction.data))
					end
				end

				void'(slave_drv_items.pop_front());
				void'(master_drv_items.pop_front());
			end
		endfunction

		//port implementation for data coming from master driver
		virtual function void write_master_drv(amiq_dcr_master_drv_transfer transaction);
			master_drv_items.push_back(transaction);
		endfunction

		//port implementation for data coming from slave driver
		virtual function void write_slave_drv(amiq_dcr_slave_drv_transfer transaction);
			slave_drv_items.push_back(transaction);
		endfunction

		virtual function void check_phase(input uvm_phase phase);
			super.check_phase(phase);

			if(master_drv_items.size() > 0) begin
				`uvm_fatal(get_id(), $sformatf("There are still %0d elements in master_drv_items", master_drv_items.size()))
			end

			if(slave_drv_items.size() > 1) begin
				`uvm_fatal(get_id(), $sformatf("There are still %0d elements in slave_drv_items", slave_drv_items.size()))
			end
		endfunction

		//function for handling reset
		virtual function void handle_reset();
			while(master_drv_items.size() > 0) begin
				void'(master_drv_items.pop_front());
			end
			while(slave_drv_items.size() > 0) begin
				void'(slave_drv_items.pop_front());
			end
		endfunction

	endclass

`endif

