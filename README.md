# SHA-256-ASIC-for-Bitcoin-Mining

## Overview
This repository contains all the necessary design files and configuration files to run OpenROAD and generate the GDS (Graphic Data System) files of the ASIC designed for Bitcoin mining. The ASIC is primarily built to execute the SHA-256 hash function efficiently. Please refer to the Presentation and Report for detailed information about the project.

## Running the Project
To run this project and generate the GDS-II files using OpenROAD, follow the steps below:
1. Install OpenROAD-flow-scripts, refer this [page](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts).
2. The "designs" directory structure is similar to that of ORFS. Add the files in this directory to ORFS after building it.
3. In the `OpenROAD-flow-scripts/flow/` directory, run the RTL to GDS-II flow using the command `make DESIGN_CONFIG=./designs/nangate45/config.mk`.

## Contributing
Contributions to improve the design are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## Project Details
Authors: Devashish Gawde, Anish Miryala, Navin Nadar
Institution: New York University
Date: May 16, 2024

