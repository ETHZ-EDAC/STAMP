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
- `LIBRARY.m`: contains all operations defined by the user to assign materials

## Requirements
The code has been tested on both Windows 11 24H2 and macOS Sequoia 15.5.

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

**Voxelization:**
The voxelization of the input geometry uses the `Mesh Voxelisation` with version 1.20.0.0. These functions are already integrated into the provided code at `lib/dataprocess/VOXELISE.m`, `lib/dataprocess/READ_stl.m`, `lib/dataprocess/COMPUTE_mesh_normals.m` and `lib/dataprocess/CONVERT_meshformat.m`.

- Adam A (2025). Mesh voxelisation (https://www.mathworks.com/matlabcentral/fileexchange/27390-mesh-voxelisation), MATLAB Central File Exchange. Retrieved July 18, 2025.

## Installation

To run the toolbox, it needs to be added to the MATLAB path. A configuration script `config.m` is provided to automate this step. This config script has three options as shown in all three MAIN files. 
- `permanent`: permanently adds the current toolbox location to the MATLAB path.
- `temp`: adds the current toolbox location to the MATLAB path until restart.
- `pass`: do nothing, user must manually add the toolbox to the MATLAB path.

Additionally, the local Python environement needs to be linked by setting the `pyenvdef` variable in the MAIN file. If all other required packages are installed, this should be the only machine-specific change that needs to be made to run the code. Thus, the install time should not exceed a couple of minutes.

## Examples

To run the provided examples, just run the provided MATLAB scripts:
- `MAIN_Damper.m`
- `MAIN_Dogbone.m`
- `MAIN_Orthosis.m`

A breakdown of the individual runtimes for each example is provided in the assosciated published article. The expected finite element outputs of the three provided examples can be found in `src/03_FEworkdir`.

## Problem User Inputs
The three example files cover the core functionalities of this toolbox, additional information on the user inputs and operations is provided below to enable the transfer to user geometries and designs.

| Group | Name | Size | Unit | Description|
|----------|:----------:|:----------:|:----------:|----------|
| Slicing |	*layerheight* |	[1x1] | mm | Layer height. |
| Slicing |	*dpi* |	[1x1] |	dpi |	XY resolution. |
| Slicing |	*cg_res* | [1x3] | mm |	Coarse grid spacing in xyz direction. |
| Geometry |	*name* | - | - |	Name and path of .stl input file. |
| Geometry |	*type* | - | - |	Provide type ‘solid’ or type ‘shell’. |
| FE |	*ShellThickness* |	[1x1] | mm |	Thickness of elements if type='shell'. |
| FE |	*ElemSize* |	[1x1] | mm |	Target edge length of FE elements. |
| FE |	*HyperelasticBool* | - | Boolean |	Set to use hyperelastic material formulation for viscoelasticity. |
| Output |	*nameout* | - | - |	Name and path of the PNG output folder, no images are saved if left empty. |
| Geometry | *rotang_x* |	[1x1] | deg |	Rotation fo .stl file around global x-axis. |
| Geometry | *rotang_y* |	[1x1] | deg |	Rotation fo .stl file around global y-axis. |
| Geometry | *rotang_z* |	[1x1] | deg |	Rotation fo .stl file around global z-axis. |
| Material | *matinfo.void.ID* |	[1x1] | - |	Void material ID. |
| Material | *matinfo.mat1.ID* |	[1x1] | - |	Material ID of *mat1*, any number of additional base materials can be defined. |
| Material | *matinfo.void.Name* | - | - |	Void material name. |
| Material | *matinfo.mat1.Name* | - | - |	Material name of *mat1*, used for FE material assignment. |
| Material | *matinfo.void.col* | [1x3] | RGB |	Void material color, used for sliced image export and plotting. |
| Material | *matinfo.mat1.col* | [1x3] | RGB |	Material color of *mat1*, used for sliced image export and plotting. |
| Material | *matinfo.basemat* | [nx2] | - |	Base material or material mixture assigned to the geometry before operations consisting of material ID and volume fraction pairs for *n* materials. |

## Operations

Operations are used to assign material to the geometry that currently only consists of a base material. This process consists of three steps:
<ol type="A">
  <li>Define operations and operation parameters</li>
  <li>Line up operations in the correct order</li>
  <li>Process operations, save outputs</li>
</ol>

### A - Define Operations and Operation Parameters

**Overview:** 
The script is based on applying operations on a matrix containing information about the material at each point. The operations are first defined in a file called `LIBRARY.m` that creates a cell array named *library*. In a second step (B), they are lined up in an *operations* cell array. Define a new operation as a new cell entry in the *library* cell array using the `LIBRARY.m` file. Each cell contains a struct named after the operation and containing the operation-specific entries.

**Example of operation:** 
```
library{1}.split.direction = 1;
library{1}.split.cord      = 12;
library{1}.split.mat.neg   = matinfo.mat1.ID;
library{1}.split.mat.pos   = matinfo.mat2.ID;
```

### B - Line Up Operations in the Correct Order

**Overview:**
The operations defined in the library are loaded in the cell array called 'operations'. The operations array contains all operations in chronological order. Load the operations by passing the cell content of the library array directly to the operations (e.g., `operations{1} = library{9}`).

### C - Process Operations

**Overview:**
The user has no influence in this step. The STL file is loaded, the operations are executed.

## Default Operations 
The default operations are *split*, *gradient*, *coat*, *stencil* and *gensupp*.

### Split

**Function:** Assigns material to the file such that there is a sharp material transition at a defined position.

**Arguments:**
- `split.direction`: determines the normal direction of the split. Provided as 1,2, and 3,
                    correspond to the x-, y- and z-axis
- `split.cord`:      absolute coordinate in the chosen direction where the split should occur
- `split.mat.neg`:   determines the material ID of all points before the split (negative coordinate direction)
- `split.mat.pos`:   determines the material ID of all points afterthe split (positive coordinate direction)

**Materials:** The material can be given as a material mixture by providing a mixing table. The mixing table is a n x 2 array, where n are the rows containing all materials to be mixed. The first column contains the material ID's and the second the volume fraction of the material. The volume fractions have to add up to 1.
   
### Gradient

**Function:** Adds a material gradient across the geometry in a chosen direction.

**Arguments:**
 - `gradient.direction`:  determines the direction of the gradient Provided as 1,2, and 3,
                        correspond to the x-, y- and z-axis
 - `gradient.cord.start`: absolute coordinate in the chosen direction where the gradient should start
 - `gradient.cord.end`:   absolute coordinate in the chosen direction where the gradient should end
 - `gradient.mat.start`:  material ID at the start of the gradient
 - `gradient.mat.end`:    material ID at the end of the gradient
 - `gradient.type.name`:  determines the type of the gradient (see below)
 - `gradient.tyoe.args`:  passes arguments depending on the gradient type (see below)

**Materials:** The material can be given as a material mixture by providing a mixing table. The mixing table is a n x 2 array, where n are the rows containing all materials to be mixed. The first column contains the material ID's and the second the volume fraction of the material. The volume fractions have to add up to 1.

**Gradient Types:**
 - `linear`: Linear gradient
   - Arguments passed: NONE
 - `linsymm`: Gradient peaking in the middle and going to the start material for the end coordinate
   - Arguments passed: NONE
 - `power`: Gradient based on the power law 
   - Arguments passed: exponent of power law
 - `sigmoid`: sigmoid function determines material fraction
   - Arguments passed: exponent of the sigmoid function

### Coat

**Function:** Replaces the surface material of a part.

**Arguments:**
 - `coat.thickness`: thickness of the coating in mm
 - `coat.mat.out`: material at the surface of the part
 - `coat.mat.in`: material at the transition of the coating to the internal material
 - `coat.grad.type`: determines the type of the gradient (see below)
 - `coat.grad.args`: arguments passed to gradient (see below)

**Materials:** The material can be given as a material mixture by providing a mixing table. The mixing table is a n x 2 array, where n are the rows containing all materials to be mixed. The first column contains the material ID's and the second the volume fraction of the material. The volume fractions have to add up to 1.

**Gradient Types:**
 - `linear`: Linear gradient
   - Arguments passed: NONE
 - `linsymm`: Gradient peaking in the middle and going to the start material for the end coordinate
   - Arguments passed: NONE
 - `power`: Gradient based on the power law 
   - Arguments passed: exponent of power law
 - `sigmoid`: sigmoid function determines material fraction
   - Arguments passed: exponent of the sigmoid function

### Stencil

**Function:** Stencils material in the shape of a new .stl file on the existing geometry.

**Arguments:**
 - `stencil.shape`: path and file name of the stencil geomtry .stl file
 - `stencil.mat`: material to be stenciled
 - `stencil.fillvoid`: set TRUE if void material shall be filled, set FALSE if void material shall be ignored
 - `stencil.blendval`: thickness of linear gradient over stencil boundary in number of coarse grained points into existing geometry

**Materials:** The material can be given as a material mixture by providing a mixing table. The mixing table is a n x 2 array, where n are the rows containing all materials to be mixed. The first column contains the material ID's and the second the volume fraction of the material. The volume fractions have to add up to 1.

### Support

**Function:** Generates support material to ensure all parts are supported.

**Arguments:**
 - `gensupp.mat`: support material to be used

**Materials:** Should be set to the standard soluble support material for the chosen printing method.

## Authors

- Marc Wirth
- Joël N. Chapuis
- Prof. Dr. Kristina Shea
