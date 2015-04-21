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
 * NAME:        amiq_dcr_ex_reg_pkg.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the includes of all files part of amiq_dcr_ex_reg_pkg package.
 *******************************************************************************/

`ifndef AMIQ_DCR_EX_REG_PKG_SV
	//protection against multiple includes
	`define AMIQ_DCR_EX_REG_PKG_SV

	`include "amiq_dcr_pkg.sv"

	package amiq_dcr_ex_reg_pkg;
		import uvm_pkg::*;
		import amiq_dcr_pkg::*;

		`include "amiq_dcr_ex_reg_defines.sv"
		`include "amiq_dcr_ex_reg_env_config.sv"
		`include "amiq_dcr_ex_reg_virtual_sequencer.sv"
		`include "amiq_dcr_ex_reg_reg_file.sv"
		`include "amiq_dcr_ex_reg_reg_block.sv"
		`include "amiq_dcr_ex_reg_reg2dcr_adapter.sv"
		`include "amiq_dcr_ex_reg_dcr2reg_predictor.sv"
		`include "amiq_dcr_ex_reg_slave_driver.sv"
		`include "amiq_dcr_ex_reg_env.sv"
		`include "amiq_dcr_ex_reg_virtual_seq_lib.sv"

	endpackage
`endif

