% ©2025 ETH Zurich; D-​MAVT; Engineering Design and Computing
function DataHyper = HELPER_ImportHyper(filename, dataLines)
% HELPER_ImportHyper: Import hyperelastic test data from a csv file
%  DataHyper = HELPER_ImportHyper(FILENAME, DATALINES) reads data from text file
%  FILENAME for the default selection.  Returns the numeric data.
%
%  DataHyper = HELPER_ImportHyper(FILENAME, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  DataHyper = HELPER_ImportHyper("\helperfunc\helpers_FEM\data_materials\VeroWhiteUltraHyper.csv", [3, Inf]);

%% Input handling
% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [3, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 2, "Encoding", "UTF-8");

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ";";

% Specify column names and types
opts.VariableNames = ["TensileStress", "TensileStrainExtension"];
opts.VariableTypes = ["double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
DataHyper = readtable(filename, opts);

%% Convert to output type
DataHyper = table2array(DataHyper);

end

