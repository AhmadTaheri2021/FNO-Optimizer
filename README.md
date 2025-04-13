# FNO-Optimizer
Official implementation of the Farthest Better or Nearest Worse Optimizer (FNO) algorithm, a novel metaheuristic optimization method designed for solving complex, constrained, and unconstrained problems.

# FNO - Farthest Better or Nearest Worse Optimizer (MATLAB)

This is the official MATLAB implementation of the FNO algorithm presented in the paper:

**"Farthest Better or Nearest Worse Optimizer: A Novel Metaheuristic Algorithm"**  
_Ahmad Taheri, Keyvan RahimiZadeh, Jan Baumbach, Amin Beheshti, Olga Zolotareva, Mohammed Azmi Al-Betar, Seyedali Mirjalili, Amir H. Gandomi_

---

## 🧠 Overview

The **FNO algorithm** is a novel metaheuristic approach based on two key behaviors:

- **Farthest Better**: Exploration toward far, high-potential regions.
- **Nearest Worse**: Avoidance of nearby low-quality regions.

A unique **Dynamic Focus Strategy (DFS)** is introduced to balance exploration and exploitation dynamically over iterations.

---

## 🚀 Getting Started

### Requirements

- MATLAB R2020a or later
- Optimization Toolbox (optional, for visualization)

### Running the Algorithm

1. Clone the repository:
   
   git clone https://github.com/YOUR_USERNAME/FNO-Optimizer.git

   cd FNO-Optimizer

3. Open MATLAB and navigate to the folder:

    cd('path_to/FNO-Optimizer')

4. Run the main script:

    FNO_Main

### 📦 Directory Structure
FNO_Main.m: Entry point for running FNO.

FNO_Functions/: Core logic for FNO and its components.

Benchmarks/: CEC2005, CEC2014, CEC2019 test functions.

Engineering/: Real-world problem cases.

Results/: Output folder (optional).

Examples/: Sample configurations and visualizations.

### 📑 Citation
If you use this algorithm in your work, please cite:

### 📄 License
Distributed under the MIT License. See LICENSE for more information.

### 📬 Contact
For questions or collaboration, feel free to reach out to the authors or open an issue.

