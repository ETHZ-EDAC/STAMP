%% General Explanation
% MATERIAL
% materal can be given in three modes:
% A) provide material as material ID, as defined in the matinfo struct.
% This will assign homogenous material to a region
% B) provide material as mixtures given as Nx2 matrx. Each row is the
% material ID of a mixture material as given in the matinfo struct and the
% fraction of the raw material. The fractions must add up to 1
% C) provide material as mechanical requirements as Nx3 matrix. Each row
% contains a target temperature in °C, a target frequency and a target
% E-Modulus in MPa. If multiple rows are given, the script estimates the
% best possible material to fulfill all the property triplets.


%% Operations - Definition
% ---- SPLIT ----
% split.direction - 1,2 or 3 / determines axis of split
% split.cord      - determines the coordinate of the split plane
% split.mat.neg   - material ID of all points in negative axis direction
% split.mat.pos   - material ID of all points in positive axis direction
% ---------------

% split information
library{1}.split.direction = 1;
library{1}.split.cord      = 0;
library{1}.split.mat.neg   = [matinfo.mat1.ID,0.8;matinfo.mat2.ID,0.2];
library{1}.split.mat.pos   = [matinfo.mat1.ID,0.2;matinfo.mat2.ID,0.8];


% ---- GRADIENT ----
% gradient.direction   - 1,2 or 3 / determines the direction (x,y,z) of the gradient
% gradient.coord.start - determines the start coordinate of the gradient
% gradient coord.end   - determines the end coordinate of the gradient
% gradient.mat.start   - material ID at start of gradient
% gradient.mat.start   - material ID at end of gradient
% gradient.type.name   - determines type of gradient (linear, linsymm, power, sigmoid)
% gradient.type.args   - passes arguments depending on the gradient type (see below)
%
% Arguments to be passed:
% linear  - NONE
% linsymm - NONE
% power   - exponent of the power law
% sigmoid - exponent in the sigmoid function
% ------------------

% gradient information
library{11}.gradient.direction   = 2; 
library{11}.gradient.coord.start = -57.5;
library{11}.gradient.coord.end   = -39.5;
library{11}.gradient.mat.start   = matinfo.mat2.ID;
library{11}.gradient.mat.end     = matinfo.mat2.ID;
library{11}.gradient.type.name   = 'linear';
library{11}.gradient.type.args   = {};

% gradient information
library{12}.gradient.direction   = 2; 
library{12}.gradient.coord.start = -40.5;
library{12}.gradient.coord.end   = -38.5;
library{12}.gradient.mat.start   = matinfo.mat2.ID;
library{12}.gradient.mat.end     = matinfo.basemat;
library{12}.gradient.type.name   = 'linear';
library{12}.gradient.type.args   = {};

% gradient information
library{13}.gradient.direction   = 2; 
library{13}.gradient.coord.start = 39.5;
library{13}.gradient.coord.end   = 57.5;
library{13}.gradient.mat.start   = matinfo.mat2.ID;
library{13}.gradient.mat.end     = matinfo.mat2.ID;
library{13}.gradient.type.name   = 'linear';
library{13}.gradient.type.args   = {};

% gradient information
library{14}.gradient.direction   = 2; 
library{14}.gradient.coord.start = 38.5;
library{14}.gradient.coord.end   = 40.5;
library{14}.gradient.mat.start   = matinfo.basemat;
library{14}.gradient.mat.end     = matinfo.mat2.ID;
library{14}.gradient.type.name   = 'linear';
library{14}.gradient.type.args   = {};


% ---- COAT ----
% coat.thickness - thickness of the coating in mm
% coat.mat.out   - material ID at the outer surface
% coat mat.in    - material ID at the inner surface
% coat.grad.type - determines type of gradient (linear, linsymm, power, sigmoid)
% coat.grad.args - passes arguments depending on the gradient type (see below)
%
% Arguments to be passed:
% linear  - NONE
% linsymm - NONE
% power   - exponent of the power law
% sigmoid - exponent in the sigmoid function
% ------------------

% coat information
library{21}.coat.thickness = 1;
library{21}.coat.mat.out   = matinfo.mat3.ID;
library{21}.coat.mat.in    = matinfo.mat2.ID;
library{21}.coat.grad.type = 'linear';
library{21}.coat.grad.args = {};


% ---- STENCIL ----
% stencil.shape    - Nx3 matrix providing the control points of the stencil (convex hull) in X,Y,Z coordinates
% stencil.mat      - material ID within stencil
% stencil.fillvoid - set TRUE if void material shall be filled, set FALSE if void material shall be ignored
% stencil.blendval - thickness of linear gradient over stencil boundary in
%                    number of coarse grained points
% ------------------

% stencil information
library{30}.stencil.shape    = ['src',filesep,'01_in',filesep,'Damper_Core.stl'];
library{30}.stencil.mat      = [matinfo.mat1.ID,0.835;matinfo.mat2.ID,0.165];
library{30}.stencil.fillvoid = true;
library{30}.stencil.blendval = 1;

% stencil information
library{31}.stencil.shape    = ['src',filesep,'01_in',filesep,'Orthosis_Thumb.stl'];
library{31}.stencil.mat      = [25,1,0];
library{31}.stencil.fillvoid = false;
library{31}.stencil.blendval = 1;

% stencil information
library{32}.stencil.shape    = ['src',filesep,'01_in',filesep,'Orthosis_TopSplint.stl'];
library{32}.stencil.mat      = [25,1,2000];
library{32}.stencil.fillvoid = false;
library{32}.stencil.blendval = 1;


% ---- GENERATE SUPPORT ----
% gensupp.mat - material ID of support material
% ------------------

% support information
library{40}.gensupp.mat = matinfo.mat3.ID;