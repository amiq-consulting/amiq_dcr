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
 * NAME:        amiq_dcr_ex_ms_env.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the environment used by
 *              "master-slave" example.
 *******************************************************************************/

`ifndef AMIQ_DCR_EX_MS_ENV_SV
	//protection against multiple includes
	`define AMIQ_DCR_EX_MS_ENV_SV

	//environment class
	class amiq_dcr_ex_ms_env extends uvm_env;

		//environment configuration unit
		amiq_dcr_ex_ms_env_config env_config;

		//DCR master agent
		amiq_dcr_master_agent master_agent;

		//DCR slave agent
		amiq_dcr_slave_agent slave_agent;

		amiq_dcr_ex_ms_virtual_sequencer sequencer;

		//scoreboard
		amiq_dcr_ex_ms_scoreboard scoreboard;

		`uvm_component_utils(amiq_dcr_ex_ms_env)

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(input string name, input uvm_component parent);
			super.new(name, parent);
		endfunction

		//UVM build phase
		//@param phase - current phase
		virtual function void build_phase(input uvm_phase phase);
			super.build_phase(phase);

			master_agent = amiq_dcr_master_agent::type_id::create("master_agent", this);
			slave_agent = amiq_dcr_slave_agent::type_id::create("slave_agent", this);
			begin
				int unsigned period_ratio = (`AMIQ_DCR_EX_MS_SLAVE_PERIOD / `AMIQ_DCR_EX_MS_MASTER_PERIOD);
				int unsigned master_max_timeout_delay = 1000;
				int unsigned slave_max_timeout_delay = master_max_timeout_delay / period_ratio;

				if(!uvm_config_db#(amiq_dcr_ex_ms_env_config)::get(this, "", "env_config", env_config)) begin
					`uvm_fatal(get_name(), "Could not get from database the environment configuration class")
				end

				begin
					amiq_dcr_master_agent_config agent_config = amiq_dcr_master_agent_config::type_id::create("agent_config", master_agent);
					agent_config.set_dut_vif(env_config.master_dut_if);
					agent_config.set_max_timeout_delay(master_max_timeout_delay);
					agent_config.set_drain_time_at_timeout(period_ratio);

					uvm_config_db#(amiq_dcr_agent_config)::set(this, "master_agent", "agent_config", agent_config);
				end

				begin
					amiq_dcr_slave_agent_config agent_config = amiq_dcr_slave_agent_config::type_id::create("agent_config", slave_agent);
					agent_config.set_dut_vif(env_config.slave_dut_if);
					agent_config.set_max_timeout_delay(slave_max_timeout_delay);

					uvm_config_db#(amiq_dcr_agent_config)::set(this, "slave_agent", "agent_config", agent_config);
				end

				sequencer = amiq_dcr_ex_ms_virtual_sequencer::type_id::create("sequencer", this);

			end

			scoreboard = amiq_dcr_ex_ms_scoreboard::type_id::create("scoreboard", this);
		endfunction

		//UVM connect phase
		//@param phase - current phase
		virtual function void connect_phase(input uvm_phase phase);
			super.connect_phase(phase);

			sequencer.master_sequencer = master_agent.sequencer;
			sequencer.slave_sequencer = slave_agent.sequencer;
			sequencer.env_config = env_config;

			master_agent.monitor.output_port.connect(scoreboard.input_port_master_mon);
			master_agent.driver.output_port.connect(scoreboard.input_port_master_drv);
			slave_agent.driver.output_port.connect(scoreboard.input_port_slave_drv);
		endfunction

		//function for handling reset
		//@param phase - current phase
		virtual function void handle_reset(uvm_phase phase);
			scoreboard.handle_reset();
		endfunction

		//wait for reset to start
		virtual task wait_reset_start();
			@(negedge(env_config.master_dut_if.reset_n));
		endtask

		//wait for reset to be finished
		virtual task wait_reset_end();
			@(posedge(env_config.master_dut_if.reset_n));
		endtask

		//function for getting the ID used in messaging
		//@return message ID
		virtual function string get_id();
			return "ENV";
		endfunction

		//UVM run phase
		//@param phase - current phase
		virtual task run_phase(uvm_phase phase);
			forever begin
				wait_reset_start();

				`uvm_info(get_id(), "Reset start detected", UVM_LOW)

				handle_reset(phase);

				wait_reset_end();

				`uvm_info(get_id(), "Reset end detected", UVM_LOW)
			end
		endtask

	endclass

`endif

