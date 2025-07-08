function DataProny = HELPER_ImportProny(filename, dataLines)
% HELPER_ImportProny: Import Prony series data from a csv file
%  DataHyper = HELPER_ImportProny(FILENAME, DATALINES) reads data from text file
%  FILENAME for the default selection.  Returns the numeric data.
%
%  DataHyper = HELPER_ImportProny(FILENAME, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  DataProny = HELPER_ImportProny("\helperfunc\helpers_FEM\data_materials\VeroWhiteUltraProny.csv", [3, Inf]);

%% Input handling
% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 3, "Encoding", "UTF-8");

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ";";

% Specify column names and types
opts.VariableNames = ["g_iProny", "k_iProny", "tau_iProny"];
opts.VariableTypes = ["double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
DataProny = readtable(filename, opts);

%% Convert to output type
DataProny = table2array(DataProny);
end
