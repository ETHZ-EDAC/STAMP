% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
%% Environment Setup
clc; clear all; close all;
configmode = 'temp'; % config mode - 'permament', 'temp', 'pass'
run config.m % run config
global pyenvdef
pyenvdef = '/opt/homebrew/Caskroom/miniforge/base/bin/python'; % define python environment

%% Settings
% print resulution 
layerheight = 0.027; % layer height in mm
dpi         = 300; % xy resolution in dpi

% coarse grid
cg_res = [1,1,1]*0.5001; % spacing between grid points in xyz direction [mm]

% input file
name = ['src',filesep,'01_in',filesep,'Damper_FullGeometry.stl']; % name and path to .stl input file
type = 'solid';  % type of file ('shell' or 'solid')

% geometry output
FEinfo.ElementSettings.ShellThickness = 1; % thickness of elements if type='shell'
FEinfo.ElementSettings.ElemSize = 1.5; % target edge length of FE elements

% png output
nameout = ''; % name of output foler ('' > png not saved)

% geometry pre-processing
rotang_x = 0; % rotation around global x-axis [°]
rotang_y = 0; % rotation around global y-axis [°]
rotang_z = 0; % rotation around global z-axis [°]

% material IDs
matinfo.void.ID = 0; % void ID
matinfo.mat1.ID = 1; % ID of material 1
matinfo.mat2.ID = 2; % ID of material 2
matinfo.mat3.ID = 3; % ID of material 3
matinfo.mat4.ID = 4; % ID of material 4
matinfo.mat5.ID = 5; % ID of material 5
matinfo.mat6.ID = 6; % ID of material 6
matinfo.mat7.ID = 7; % ID of material 7

% material names
matinfo.void.Name = 'Void'; % name of void material
matinfo.mat1.Name = 'Agilus'; % name of material 1
matinfo.mat2.Name = 'VeroWhiteUltra';  % name of material 2
matinfo.mat3.Name = 'Support'; % name of material 3
matinfo.mat4.Name = 'Cyan'; % name of material 4
matinfo.mat5.Name = 'Magenta'; % name of material 5
matinfo.mat6.Name = 'Yellow'; % name of material 6
matinfo.mat7.Name = 'Clear'; % name of material 7

% material display colors
matinfo.void.col = [255 166 38]; % color to display void [R G B]
matinfo.mat1.col = [22 23 23]; % color to display material 1 [R G B]
matinfo.mat2.col = [189 222 222]; % color to display material 2 [R G B]
matinfo.mat3.col = [0 0 1] * 255; % color to display material 3 [R G B]
matinfo.mat4.col = [0 255 255]; % color to display material 4 [R G B]
matinfo.mat5.col = [255 0 255]; % color to display material 5 [R G B]
matinfo.mat6.col = [255 255 0]; % color to display material 6 [R G B]
matinfo.mat7.col = [255 255 255]; % color to display material 7 [R G B]

% base material (aribitrary material definition possible)
matinfo.basemat = 2;


%% Operations - Definition
% load operation library
run('LIBRARY.m'); 

% assemble operations in cell array
operations{1} = library{30};


%% PreProcess
% toggle saving of pre-processed data
savemode = 'none'; % save, load or none

% load and process geometry
[gridinfo,mat,matinfo,stlfile] = PREPROCESS_voxelstructure(name,cg_res,matinfo,[rotang_x, rotang_y, rotang_z],type,savemode,FEinfo.ElementSettings.ElemSize);


%% Operations - Execution
% run all operations
[mat,matinfo,addargs] = HELPER_operationpipeline(mat,matinfo,gridinfo,operations);


%% PostProcess Voxel Structure
% toggle to make boundary exact according to STL file
smoothbdry = 1; % 0: png according to coarse grid  1: png according to STL
% make and save .png files
POSTPROCESS_savePNG(layerheight,dpi,gridinfo,mat,matinfo,FEinfo,stlfile,nameout,smoothbdry,type,addargs);

% Visualize Structure as 3D coarse grid
POSTPROCESS_visualize(gridinfo,mat,matinfo,stlfile,type); 
% Visualize individual layers
sliceIDstart = 1; % first slice to visualize
sliceIDstop  = 3; % last slice to visualize
showVoid     = 1; % toggle on to  show void material
POSTPROCESS_visualize_slices(gridinfo,mat,matinfo,stlfile,type,[sliceIDstart,sliceIDstop],showVoid);


%% Setup FE Simlation
% Initialize work directory
FEinfo.WorkDir = ['src',filesep,'03_FEworkdir']; % work directory path
FEinfo.InpFile = 'Damper'; % name of Abaqus input file
FEinfo.ElementType = type; % assign element type

% Simulation parameters
HyperelasticBool = 1; % set 1 to use hyperelastic material

% retrieve master curves
[MasterCurve,uniqueMixID,Tg_mix,rho] = HELPER_GetMasterCurve(mat,matinfo);

% Generate FE Materials
[FEinfo] = HELPER_MaterialsFE(FEinfo,MasterCurve,uniqueMixID,Tg_mix,rho,mat,matinfo);

% Generate FE Mesh
geomName = ['src',filesep,'01_in',filesep,'Damper_FullGeometry.stl']; % stl file containing full geometry
FEinfo.MeshImport = ['src',filesep,'02_Meshes',filesep,'Damper_Mesh.mat']; % optional - name of external mesh to be imported
[FEinfo] = HELPER_GenerateMesh(cg_res,gridinfo,mat,matinfo,FEinfo,uniqueMixID,rho,geomName,stlfile,[rotang_x, rotang_y, rotang_z]);

% Visualize FE Mesh
POSTPROCESS_VisualizeFE(FEinfo,matinfo,cg_res)

% Generate Fortran Subroutine for Abaqus
HELPER_GenerateSubroutine(FEinfo);

% Run FE Sim
[FEinfo] = POSTPROCESS_exportFEM(FEinfo,HyperelasticBool);