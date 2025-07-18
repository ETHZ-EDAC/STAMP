<style type="text/css">
    ol { list-style-type: upper-alpha; }
</style>
# Stochastic Two-Phase Analysis & Meshing for Voxelated Polymers (STAMP)

## Short Description

Unified modeling and inverse material design framework for stochastically mixed voxelated polymer structures developed by the Engineering Design and Computing Laboratory (EDAC) at ETH Zurich.

## Introduction

Polymer material jetting enables the fabrication of voxelated, multi-material parts with material control at the microscale. However, current work often neglects viscoelastic effects and designing voxelated structures remains challenging due to the complexity of the vast design freedom and intractability of efficiently modeling macroscale voxel structures. We present an efficient representation of stochastically mixed voxelated material and develop a generalized viscoelastic temperature-dependent material model to design and simulate voxelated structures mixed from two constituent polymers. The material model is based on an extended percolation theory considering frequency and temperature. An artificial neural network is trained on the material model to directly estimate target material behavior given arbitrary non-linear user requirements. The approach is validated using two case studies requiring tailored non-linear material behavior: a personalized wrist orthosis and a machine damper. These show the newly unlocked possibilities for the design and fabrication of tuned, stochastic voxelated material.

## Project Layout

- `lib/dataprocess`: pre- and post-processing scripts for key operations
- `lib/helperfunc`: contains helper functions required for the key operations
- `lib/ops`: contains operations used to assign material to geometry
- `src/01_in`: contains the .stl files required to run the example files
- `src/02_Meshes`: contains pre-generated meshes required to run the example files
- `src/03_FEworkdir`: finite element outputs of the example files
- `MAIN_Damper.m`: file to run the damper example
- `MAIN_Dogbone.m`: file to run a basic dogbone example
- `MAIN_Orthosis.m`: file to run the orthosis example

## Requirements

**MATLAB:** R2024a or higher.

The additional package requirements are:
- `MATLAB Parallel Computing Toolbox`
- `MATLAB Image Manipulation Toolbox`
- `MATLAB Image Processing Toolbox`
- `MATLAB Mapping Toolbox`
- `MATLAB Optimization Toolbox`
- `MATLAB Partial Differential Equation Toolbox`
- `MATLAB Statistics and Machine Learning Toolbox`

**Python:** Version 3.11.5 or higher.
**PyTorch:** Version 2.2.0 or higher.

## Installation

To run the toolbox, it needs to be added to the MATLAB path. A configuration script `config.m` is provided to automate this step. This config script has three options as shown in all three MAIN files. 
- `permanent`: permanently adds the current toolbox location to the MATLAB path.
- `temp`: adds the current toolbox location to the MATLAB path until restart.
- `pass`: do nothing, user must manually add the toolbox to the MATLAB path.

Additionally, the local Python environement needs to be linked by setting the *pyenvdef* variable in the MAIN file.

## Examples

To run the provided examples, just run the provided MATLAB scripts:
- `MAIN_Damper.m`
- `MAIN_Dogbone.m`
- `MAIN_Orthosis.m`

## Problem User Inputs

| Group | Name | Size | Unit | Description|
|----------|:----------:|:----------:|:----------:|----------|
| Slicing |	*layerheight* |	[1 x 1] | mm |	Layer height. |
| Slicing |	*dpi* |	[1 x 1] |	dpi |	XY resolution. |
| Slicing |	*cg_res* | [1 x 3] | mm |	Coarse grid spacing in xyz direction. |
| Geometry |	*name* | - | - |	Name and path of .stl input file. |
| Geometry |	*type* | - | - |	Provide type ‘solid’ or type ‘shell’. |
| FE |	*ShellThickness* |	[1 x 1] | mm |	Thickness of elements if type='shell'. |
| FE |	*ElemSize* |	[1 x 1] | mm |	Target edge length of FE elements. |
| Output |	*nameout* | - | - |	Name and path of the PNG output folder, no images are saved if left empty. |
| Geometry | *rotang_x* |	[1 x 1] | deg |	Rotation fo .stl file around global x-axis [°]. |
| Geometry | *rotang_y* |	[1 x 1] | deg |	Rotation fo .stl file around global y-axis [°]. |
| Geometry | *rotang_z* |	[1 x 1] | deg |	Rotation fo .stl file around global z-axis [°]. |
| Material | *matinfo.void.ID* |	[1 x 1] | - |	Void material ID. |
| Material | *matinfo.mat1.ID* |	[1 x 1] | - |	Material ID of *mat1*, any number of additional base materials can be defined. |
| Material | *matinfo.void.Name* | - | - |	Void material name. |
| Material | *matinfo.mat1.Name* | - | - |	Material name of *mat1*, used for FE material assignment. |
| Material | *matinfo.void.col* | [1 x 3] | RGB |	Void material color, used for sliced image export and plotting. |
| Material | *matinfo.mat1.col* | [1 x 3] | RGB |	Material color of *mat1*, used for sliced image export and plotting. |
| Material | *matinfo.basemat* | [1 x 2n] | - |	Base material or material mixture assigned to the geometry before operations consisting of material ID and volume fraction pairs for *n* materials. |

## Operations

Operations are used to assign material to the geometry that currently only consists of a base material. The framework consists of four four steps:
<ol>
  <li>Determine general settings</li>
  <li>Define operations and operation parameters</li>
  <li>Line up operations in the correct order</li>
  <li>Process operations, save outputs</li>
</ol>

## Authors

- Marc Wirth
- Joël N. Chapuis
- Prof. Dr. Kristina Shea