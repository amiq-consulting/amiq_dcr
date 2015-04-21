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
 * NAME:        amiq_dcr_ex_reg_env_config.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the environment configuration
 *******************************************************************************/

`ifndef AMIQ_DCR_EX_REG_ENV_CONFIG_SV
	//protection against multiple includes
	`define AMIQ_DCR_EX_REG_ENV_CONFIG_SV

	class amiq_dcr_ex_reg_env_config extends uvm_component;

		//pointer to the master DCR interface
		virtual amiq_dcr_if master_dut_if;

		//pointer to the slave DCR interface
		virtual amiq_dcr_if slave_dut_if;

		`uvm_component_utils(amiq_dcr_ex_reg_env_config)

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(input string name, input uvm_component parent);
			super.new(name, parent);
		endfunction

	endclass

`endif

