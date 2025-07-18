% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function [FEinfo] = POSTPROCESS_exportFEM(FEinfo,HyperelasticBool)

%% Generate Load Case and FE Step Parameters
FEinfo.MaterialSettings.HyperelasticBool = HyperelasticBool;

[FEinfo] = HELPER_GenerateAbaqusInputFile(FEinfo);

end