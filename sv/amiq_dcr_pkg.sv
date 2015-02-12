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
 * MODULE:      amiq_dcr_pkg.sv
 * PROJECT:     amiq_dcr
 * Engineers:   Daniel Ciupitu (daniel.ciupitu@amiq.com)
 *              Cristian Florin Slav (cristian.slav@amiq.com)
 * Description: This file contains all the imports part of amiq_dcr_pkg package.
 *******************************************************************************/

`ifndef AMIQ_DCR_PKG_SV
	//protection against multiple includes
	`define AMIQ_DCR_PKG_SV

	`include "uagt_pkg.sv"
	`include "amiq_dcr_if.sv"

	package amiq_dcr_pkg;

		import uvm_pkg::*;
		import uagt_pkg::*;

		`include "uvm_macros.svh"

		`include "amiq_dcr_defines.sv"
		`include "amiq_dcr_types.sv"
		`include "amiq_dcr_agent_config.sv"
		`include "amiq_dcr_change.sv"
		`include "amiq_dcr_base_transfer.sv"
		`include "amiq_dcr_transfer.sv"
		`include "amiq_dcr_mon_transfer.sv"
		`include "amiq_dcr_monitor.sv"
		`include "amiq_dcr_coverage.sv"
		`include "amiq_dcr_agent.sv"

		`include "amiq_dcr_master_drv_transfer.sv"
		`include "amiq_dcr_master_agent_config.sv"
		`include "amiq_dcr_master_driver.sv"
		`include "amiq_dcr_master_agent.sv"
		`include "amiq_dcr_master_seq_lib.sv"

		`include "amiq_dcr_slave_drv_transfer.sv"
		`include "amiq_dcr_slave_agent_config.sv"
		`include "amiq_dcr_slave_driver.sv"
		`include "amiq_dcr_slave_agent.sv"
		`include "amiq_dcr_slave_seq_lib.sv"

	endpackage

`endif
