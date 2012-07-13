%% EXPORTFIG
% A function for generating images from MATLAB figures. The function will
% save a copy of the figure (*.fig) and an image that is sized exactly as
% the figure itself.

%% Function Definition
function exportfig(handle,varargin)
% EXPORTFIG 
% exports a figure as a *.fig and an additional image file
%__________________________________________________________________________
% SYNTAX:
%  exportfig(handle)
%  exportfig(handle,FigureFilename)
%  exportfig(handle,FigureFilename,ImageFilename)
%  exportfig(...,resolution)
%  exportfig(...,'clear')
%
% DESCRIPTION:
%  exportfig(handle) - exports the specificed figure first as *.fig file 
%       as well as an image file.  The image filename utilized is then
%       stored in the userdata property of the figure and utlized in
%       subsequent calls of exportfig
%  exportfig(handle,FigureFilename) exports the figure specified by the
%       handle using the *.fig file provided in FigureFilename.
%  exportfig(handle,ImageFilename) exports the figure specified by the
%       handle using the image file provided in ImageFilename, the
%       supported types are included in Section 1 of this program and may
%       be modified to included more file types if desired.
%  exportfig(handle,FigureFilename,ImageFilename) allows for the user to
%       specify both a .fig and image file. The order is irrelevent, the
%       extensions are used for distigusihing between the two.
%  exportfig(...,'clear') - removes any existing filename assumptions
%  exportfig(...,resolution) - allows user to specify resolution, the
%       default is 600, resultion should be entered as a numeric value
%
% EXAMPLES:
%   plot(rand(10,1),randn(10,1));
%   exportfig(gcf)
%__________________________________________________________________________

%% 1 - DEFINE THE IMAGE FILE FORMATS DESIRED
% (if additional formats are desired add the extenstion and associated
% description to the filterspec variable and add the associated print
% command option, see "help print" for a list)

    filterspec = {'*.pdf','PDF vector (*.pdf)';...
        '*.jpg','JPEG bitmap (*.jpg)';...
        '*.png','Portable Network Graphics (*.png)';...
        '*.emf','Enhanced metafile (*.emf)';...
        '*.eps','Encapsulated PostScript (*.eps)';...
        '*.tiff','Tagged Image File Format (*.tiff)'};
    cmd = {'-dpdf','-djpeg','-dpng','-dmeta','-depsc','-tiff'};  
    for j = 1:length(filterspec); ext{j} = filterspec{j,1}(2:end); end
    
%% 2 - ERROR CHECKING

    % Check that cmd and filterspec variables are the same size
        if length(filterspec) ~= length(cmd);
            error('exportfig:printfile',['The file filter ',...
                'specification and print commands are mismatched']);
        end
        
    %  Check that input handle is a figure    
        if ~ishandle(handle) && strcmpi(get(handle,'Type'),'figure'); 
            error('exportfig:badhandle','Input figure handle was invalid');
        end  
   
%% 3 - GATHER USER INPUT

    [mfile,pfile,res,clr] = getuseroptions(ext,varargin{:});
    if strcmpi(clr,'clear');
        set(handle,'UserData','','Filename','');
    end
    
%% 4 - LOAD THE LAST PATH USED BY EXPORTFIG
    if ~ispref('exportfig','lastdir'); 
        addpref('exportfig','lastdir',''); 
    end
    pn = getpref('exportfig','lastdir');

%% 5 - DETERMINE THE FILENAME FOR THE *.FIG

    % Determine the matlab .fig file to save
        if isempty(mfile); mfile = get(handle,'Filename'); end
        if isempty(mfile); 
            [fn,pn] = uiputfile('*.fig','Save as...',pn);
            if isnumeric(fn); return; end
            mfile = [pn,filesep,fn];
        end

    % Create the directory for .fig file if needed
        mpth = fileparts(mfile);
        if ~isempty(mpth) && ~exist(mpth,'dir'); 
            mkdir(fileparts(mfile)); 
        end       

    % Update last used directory and save *.fig file
        pn = fileparts(mfile);
        setpref('exportfig','lastdir',pn);    
        saveas(handle,mfile); set(handle,'Filename',mfile); % Stores .fig file

%% 6 - DETERMINE THE IMAGE FILENAME TO CREATE

    if isempty(pfile); pfile = get(handle,'UserData'); end
    if ~ischar(pfile) || isempty(pfile);
        [pn,fn] = fileparts(mfile);
        [fn,pn] = uiputfile(filterspec,'Save file as...',...
            [pn,filesep,fn,'.pdf']);
        if fn == 0; return; end
        pfile = [pn,fn]; 
    end
    set(handle,'UserData',pfile); % Stores image name in figures userdata

%% 7 - SET THE PAPERSIZE FOR PRINTING
    set(handle,'Units','inches');
    set(handle,'PaperUnits','Inches','PaperPositionMode','auto');
    P = get(handle,'Position');
    set(handle,'PaperSize', [P(3),P(4)]);

%% 8 - PRINT THE FILE

    % Create a directory if it does not exist
        [p,~,e] = fileparts(pfile);
        if ~isempty(p) && ~exist(p,'dir'); 
            q = questdlg(['Directory does not exist, ',...
                'would you like to create this directory?']);
            if strcmpi(q,'yes'); mkdir(p); 
            else set(handle,'userdata',''); return; end
        end

    % Delete existing file
        if exist(pfile,'file'); delete(pfile); end 
    
    % Print the file    
        try
            idx = find(strcmp(e,ext),1,'first');
            fhandle = ['-f', num2str(handle)];
            print(cmd{idx},res,'-noui','-painters',fhandle,pfile);
        catch err
            disp('Failed to write file, make sure the file is not open.');
            rethrow(err);
        end
    
%% SUBFUNTION: getuseroptions
function [mfile,pfile,res,clr] = getuseroptions(ext,varargin)
% GETUSEROPTIONS 
% gathers the user inputs

% Set the default values
    mfile = ''; pfile = ''; res = '-r600'; clr = '';

% Loop through each user supplied option and parse out information   
    v = varargin;
    for i = 1:length(v);
        if isnumeric(v{i}); res = ['-r',num2str(v{i})]; % Resolution
        elseif strcmpi(v{i},'clear'); clr = lower(v{i}); % Clear option
        elseif ischar(v{i}); % Fig and Image filenames       
            [~,~,e] = fileparts(v{i});
            if sum(strcmpi(e,ext)) == 1; pfile = v{i}; % Image file
            elseif strcmpi(e,'.fig'); mfile = v{i}; % Fig file
            end
        else
            warning('exprotfig:inputwarn','An input was not recognized!');
        end 
    end
