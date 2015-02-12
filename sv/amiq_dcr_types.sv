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
 * MODULE:      amiq_dcr_types.sv
 * PROJECT:     amiq_dcr
 * Engineers:   Daniel Ciupitu (daniel.ciupitu@amiq.com)
 *              Cristian Florin Slav (cristian.slav@amiq.com)
 * Description: This file contains all the types required by amiq_dcr_pkg package.
 *******************************************************************************/

`ifndef AMIQ_DCR_TYPES_SV
	//protection against multiple includes
	`define AMIQ_DCR_TYPES_SV

	// Forward of virtual interface definition
	typedef virtual amiq_dcr_if amiq_dcr_vif;

	// Define DCR transfer direction
	typedef enum bit {WRITE = 0, READ = 1} amiq_dcr_direction;

	// master ID type
	typedef bit[`AMIQ_DCR_MAX_MASTER_ID_WIDTH-1:0] amiq_dcr_master_id;

	// address type
	typedef bit[`AMIQ_DCR_MAX_ADDR_WIDTH-1:0] amiq_dcr_address;

	// data type
	typedef bit[`AMIQ_DCR_MAX_DATA_WIDTH-1:0] amiq_dcr_data;

	//bus phases
	typedef enum {IDLE, REQUEST, ACKNOWLEGED, END} amiq_dcr_bus_phase;

`endif
