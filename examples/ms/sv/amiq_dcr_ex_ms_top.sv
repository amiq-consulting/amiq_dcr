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
 * NAME:        amiq_dcr_ex_ms_top.sv
 * PROJECT:     amiq_dcr
 * Description: This file contains the declaration of the top module used by
 *              master-slave example.
 *******************************************************************************/

`ifndef AMIQ_DCR_EX_MS_TOP_SV
	//protection against multiple includes
	`define AMIQ_DCR_EX_MS_TOP_SV

	//period of the master clock
	`define AMIQ_DCR_EX_MS_MASTER_PERIOD 10

	//period of the slave clock
	`define AMIQ_DCR_EX_MS_SLAVE_PERIOD 40

	`include "amiq_dcr_ex_ms_test_pkg.sv"

	module amiq_dcr_ex_ms_top;
		import uvm_pkg::*;
		import amiq_dcr_ex_ms_test_pkg::*;

		//master clock
		reg master_clock;

		initial begin
			master_clock = 0;
			forever #(`AMIQ_DCR_EX_MS_MASTER_PERIOD/2) master_clock = ~master_clock;
		end

		//slave clock
		reg slave_clock;

		initial begin
			slave_clock = 0;
			forever #(`AMIQ_DCR_EX_MS_SLAVE_PERIOD/2) slave_clock = ~slave_clock;
		end

		//master DCR interface
		amiq_dcr_if master_dut_if (.clk(master_clock));

		//slave DCR interface
		amiq_dcr_if slave_dut_if (.clk(slave_clock));

		initial begin
			master_dut_if.reset_n <= 1;
			#1 master_dut_if.reset_n <= 0;
			#2000 master_dut_if.reset_n <= 1;
		end

		assign slave_dut_if.reset_n = master_dut_if.reset_n;
		assign slave_dut_if.read = master_dut_if.read;
		assign slave_dut_if.write = master_dut_if.write;
		assign slave_dut_if.privileged = master_dut_if.privileged;
		assign slave_dut_if.master_id = master_dut_if.master_id;
		assign slave_dut_if.a_bus = master_dut_if.a_bus;
		assign slave_dut_if.d_bus_out = master_dut_if.d_bus_out;

		assign master_dut_if.timeout_wait = slave_dut_if.timeout_wait;
		assign master_dut_if.ack = slave_dut_if.ack;
		assign master_dut_if.d_bus_in = slave_dut_if.d_bus_in;

		initial begin
			uvm_config_db #(virtual amiq_dcr_if)::set(null, "uvm_test_top", "master_dut_if", master_dut_if);
			uvm_config_db #(virtual amiq_dcr_if)::set(null, "uvm_test_top", "slave_dut_if", slave_dut_if);

			run_test();
		end

	endmodule

`endif

