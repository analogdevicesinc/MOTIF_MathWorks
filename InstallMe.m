function InstallMe
%% InstallMe.m

% Add directories to path
sRoot = pwd;

% Location of library files
bin_folder  = [filesep 'bin'];

if ispc()
    library_folder = [filesep 'bin' filesep 'Windows'];
else if ismac()
        error('Apple Mac OS X not supported.');
    else
        library_folder = [filesep 'bin' filesep 'Linux'];    
    end
end

% Location of utilities related to MOTIF
utilities_folder  = [filesep 'utilities'];

% Location of help
%help_folder  = [filesep 'help'];
%html_folder  = [filesep 'help' filesep 'html'];

% Location of tutorials
%tutorials_folder = [filesep 'tutorials'];

% Add the root
folder_string = sprintf('%s',sRoot);
addpath(folder_string);

% Add the bin folder
folder_string = sprintf('%s%s',sRoot,bin_folder);
addpath(folder_string);

% Add the library folder
folder_string = sprintf('%s%s',sRoot,library_folder);
addpath(folder_string);

% Add the utilities folder
folder_string = sprintf('%s%s',sRoot,utilities_folder);
addpath(folder_string);

% Add the help folders
%folder_string = sprintf('%s%s',sRoot,help_folder);
%addpath(folder_string);
%folder_string = sprintf('%s%s',sRoot,html_folder);
%addpath(folder_string);

% Add the tutorials folder
%tutorials_string = sprintf('%s%s',sRoot,tutorials_folder);
%addpath(tutorials_string);


