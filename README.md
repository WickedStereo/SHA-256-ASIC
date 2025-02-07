# SHA-256-ASIC-for-Bitcoin-Mining

## Overview
This repository contains all the necessary design files and configuration files to run OpenROAD and generate the GDS (Graphic Data System) files of the ASIC designed for Bitcoin mining. The ASIC is primarily built to execute the SHA-256 hash function efficiently. Please refer to the Presentation and Report for detailed information about the project.

## Implementations
### Naive Implementation
- Location: `src/naive/`
- Features: Basic sequential processing

### Pipelined Implementation (New!)
- Location: `src/pipeline/`
A pipelined implementation of the SHA‑256 hashing algorithm using SystemVerilog.  
This project is intended for FPGA/ASIC application and demonstrates a modular design comprising the following stages:
- **Message Padder:** Adjusts raw input messages to a 512‑bit block in compliance with SHA‑256 padding rules.
- **Message Scheduler:** Expands the padded block into 64 individual 32‑bit words.
- **Pipeline (Compression) Module:** Implements the iterative compression rounds using a state machine.
- **Top-Level Module:** Integrates the above components to produce the final hash output.

#### Features
- **Pipelined Architecture:** Improves throughput by processing data in stages.
- **Modular Structure:** Each component is split into separate, well-documented modules.
- **SHA‑256 Standard Compliance:** Follows the official SHA‑256 specification.
- **Easy to Simulate and Integrate:** Suitable for FPGA and ASIC verification flows.

## Running the Project
To run this project and generate the GDS-II files using OpenROAD, follow the steps below:
1. Install OpenROAD-flow-scripts, refer this [page](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts).
2. The "designs" directory structure is similar to that of ORFS. Add the files in this directory to ORFS after building it.
3. In the `OpenROAD-flow-scripts/flow/` directory, run the RTL to GDS-II flow using the command `make DESIGN_CONFIG=./designs/nangate45/config.mk`.

## Contributing
Contributions to improve the design are welcome. Please submit a pull request or open an issue to discuss proposed changes.

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for more details.

## Code of Conduct

For details, please read our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Acknowledgments

- Inspired by industry-standard SHA‑256 implementations.

- Contributors: Devashish Gawde, Anish Miryala, Navin Nadar \
Institution: New York University \

