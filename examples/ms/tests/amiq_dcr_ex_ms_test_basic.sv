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
 * NAME:        amiq_dcr_ex_ms_test_basic.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the basic test.
 *******************************************************************************/

`ifndef AMIQ_DCR_EX_MS_TEST_BASIC_SV
	//protection against multiple includes
	`define AMIQ_DCR_EX_MS_TEST_BASIC_SV

	//basic test
	class amiq_dcr_ex_ms_test_basic extends uvm_test;

		amiq_dcr_ex_ms_env env;

		`uvm_component_utils(amiq_dcr_ex_ms_test_basic)

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(input string name, input uvm_component parent);
			super.new(name, parent);
		endfunction

		//UVM connect phase
		//@param phase - current phase
		virtual function void build_phase(input uvm_phase phase);
			super.build_phase(phase);

			env = amiq_dcr_ex_ms_env::type_id::create("env", this);

			begin
				amiq_dcr_ex_ms_env_config env_config = amiq_dcr_ex_ms_env_config::type_id::create("env_config", env);

				if(!uvm_config_db#(virtual amiq_dcr_if)::get(this, "", "master_dut_if", env_config.master_dut_if)) begin
					`uvm_fatal(get_name(), "Could not get from database the master virtual interface")
				end

				if(!uvm_config_db#(virtual amiq_dcr_if)::get(this, "", "slave_dut_if", env_config.slave_dut_if)) begin
					`uvm_fatal(get_name(), "Could not get from database the slave virtual interface")
				end

				uvm_config_db#(amiq_dcr_ex_ms_env_config)::set(this, "env", "env_config", env_config);
			end
		endfunction

	endclass

`endif

