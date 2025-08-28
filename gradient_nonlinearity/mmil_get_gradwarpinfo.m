function [gradwarpinfo,errmsg] = mmil_get_gradwarpinfo(dcminfo)
%function [gradwarpinfo,errmsg] = mmil_get_gradwarpinfo(dcminfo)
%
% Created:  03/19/19 by Feng Xue
% Prev Mod: 10/31/22 by Don Hagler
% Prev Mod: 11/14/24 by Don Hagler
% Prev Mod: 12/09/24 by Don Hagler
% Prev Mod: 01/30/25 by Don Hagler
% Last Mod: 08/27/25 by Don Hagler
%

% based on Josh Kuperman's QD_get_gradwarpinfo

errmsg='';

if length(dcminfo)>1, dcminfo = dcminfo(1); end

Manufacturer = mmil_getfield(dcminfo,'Manufacturer');
if isempty(Manufacturer)
  errmsg=sprintf('%s: missing Manufacturer in dicom file %s\n',...
    mfilename,mmil_getfield(dcminfo,'Filename'));
  return;
end

FieldStrength = mmil_getfield(dcminfo,'MagneticFieldStrength');
if isempty(Manufacturer)
  errmsg=sprintf('%s: missing MagneticFieldStrength in dicom file %s\n',...
    mfilename,mmil_getfield(dcminfo,'Filename'));
  return;
end

if isfield(dcminfo,'ManufacturersModelName')
  ManufacturersModelName = dcminfo.ManufacturersModelName;
else
  ManufacturersModelName = dcminfo.ManufacturerModelName;
end

% check whether enhanced DICOM
enhanced_flag = mmil_check_enhanced(dcminfo);
if enhanced_flag
  fprintf('%s: enhanced DICOM\n',mfilename);
else
  fprintf('%s: standard DICOM\n',mfilename);
end

if ~isempty(regexpi(Manufacturer,'siemens'))
  if enhanced_flag
    if isfield(dcminfo.PerFrameFunctionalGroupsSequence.Item_1,'Private_0021_11fe') &&...
       isstruct(dcminfo.PerFrameFunctionalGroupsSequence.Item_1.Private_0021_11fe) &&...
       isfield(dcminfo.PerFrameFunctionalGroupsSequence.Item_1.Private_0021_11fe.Item_1,'Private_0021_1175')
      ImageType = checkstr(dcminfo.PerFrameFunctionalGroupsSequence.Item_1.Private_0021_11fe.Item_1.Private_0021_1175);
      % NOTE: ND = no distortion correction was applied
      %       NORM = intensity normalization was applied
    elseif isfield(dcminfo.PerFrameFunctionalGroupsSequence.Item_1,'Private_0021_10fe') &&...
       isstruct(dcminfo.PerFrameFunctionalGroupsSequence.Item_1.Private_0021_10fe) &&...
       isfield(dcminfo.PerFrameFunctionalGroupsSequence.Item_1.Private_0021_10fe.Item_1,'Private_0021_1075')
      ImageType = checkstr(dcminfo.PerFrameFunctionalGroupsSequence.Item_1.Private_0021_10fe.Item_1.Private_0021_1075);
    else
      ImageType = mmil_getfield(dcminfo,'ImageType','UNDEFINED');
    end
  else
    ImageType = mmil_getfield(dcminfo,'ImageType','UNDEFINED');
  end
  fprintf('%s: ImageType = %s\n',mfilename,ImageType);

  VolumetricProperties = mmil_getfield(dcminfo,'VolumetricProperties');
  if ~isempty(VolumetricProperties)
    fprintf('%s: VolumetricProperties = %s\n',mfilename,VolumetricProperties);
  end

  % set unwarpflag
  if ~isempty(regexp(ImageType,'DIS3D'))
    gradwarpinfo.unwarpflag = 3; % full 3D online gradwarp applied
  elseif ~isempty(regexp(ImageType,'DIS2D'))
    gradwarpinfo.unwarpflag = 1; % in-plane online gradwarp applied
  elseif ~isempty(regexp(ImageType,'DIS1D'))
    gradwarpinfo.unwarpflag = 2; % through-plane online gradwarp applied
  elseif ~isempty(regexp(ImageType,'ND'))
    gradwarpinfo.unwarpflag = 0; % no online gradwarp applied
  else
    gradwarpinfo.unwarpflag = -1;
  end
  fprintf('%s: setting unwarpflag = %d\n',mfilename,gradwarpinfo.unwarpflag);

  % set isoctrflag
  if enhanced_flag
    if isfield(dcminfo.SharedFunctionalGroupsSequence.Item_1,'Private_0021_10fe') &&...
       isstruct(dcminfo.SharedFunctionalGroupsSequence.Item_1.Private_0021_10fe) &&...
       isfield(dcminfo.SharedFunctionalGroupsSequence.Item_1.Private_0021_10fe.Item_1,'Private_0021_1005')
      TablePosition = dcminfo.SharedFunctionalGroupsSequence.Item_1.Private_0021_10fe.Item_1.Private_0021_1005;
    elseif isfield(dcminfo.SharedFunctionalGroupsSequence.Item_1,'Private_0021_11fe') &&...
       isstruct(dcminfo.SharedFunctionalGroupsSequence.Item_1.Private_0021_11fe) &&...
       isfield(dcminfo.SharedFunctionalGroupsSequence.Item_1.Private_0021_11fe.Item_1,'Private_0021_1005')
      TablePosition = dcminfo.SharedFunctionalGroupsSequence.Item_1.Private_0021_11fe.Item_1.Private_0021_1005;
    else
      TablePosition = NaN; % will assume not using isocenter scanning
    end
    if all(TablePosition==0)    
      gradwarpinfo.isoctrflag = 0;
    else
      gradwarpinfo.isoctrflag = 1;
    end
    if ~isnan(TablePosition)
      fprintf('%s: settting isoctrflag = %d\n',mfilename,gradwarpinfo.isoctrflag);
    else
      fprintf('%s: assuming isoctrflag = %d\n',mfilename,gradwarpinfo.isoctrflag);
    end  
  elseif isfield(dcminfo,'Private_0029_1010') & isfield(dcminfo,'Private_0029_1020')
    SiemensCsaParse_ReadDicomTag(['Private_0029_1010']);
    SiemensCsaParse_ReadDicomTag(['Private_0029_1020']);
    if ~isfield(dcminfo.csa,'Isocentered')
      gradwarpinfo.isoctrflag = 0; % assume not using isocenter scanning
      fprintf('%s: assuming isoctrflag = %d\n',mfilename,gradwarpinfo.isoctrflag);
    else
      gradwarpinfo.isoctrflag = dcminfo.csa.Isocentered;
      fprintf('%s: setting isoctrflag = %d\n',mfilename,gradwarpinfo.isoctrflag);
    end
  else
    gradwarpinfo.isoctrflag = 0; % assume not using isocenter scanning
    fprintf('%s: assuming isoctrflag = %d\n',mfilename,gradwarpinfo.isoctrflag);
  end

  % handle special cases
  ManufacturersModelName = regexprep(ManufacturersModelName,'MAGNETOM Prisma','Prisma');
  ManufacturersModelName = regexprep(ManufacturersModelName,'MAGNETOM Vida','Vida');
  ManufacturersModelName = regexprep(ManufacturersModelName,'[_\s][Ff]it$','');

  switch lower(ManufacturersModelName)
    case {'sonata','trio','sonatavision'}
      gradwarpinfo.gwtype = 0;
    case {'allegra'}
      gradwarpinfo.gwtype = 1;
    case {'avanto','triotim'}
      gradwarpinfo.gwtype = 4;
    case {'espree','axxess'}
      gradwarpinfo.gwtype = 5;
    case {'symphony','symphonyvision','symphonytim'} % Quantum
      gradwarpinfo.gwtype = 6;
    case {'skyra'} % Skyra
      gradwarpinfo.gwtype = 11;
    case {'connectome'} % HCP Connectome Skyra
      gradwarpinfo.gwtype = 12;
    case {'prisma'} % Prisma (and Prisma_fit)
      gradwarpinfo.gwtype = 13;
    case {'verio','biograph_mmr'} % Verio
      gradwarpinfo.gwtype = 16;
    case {'vida'}
      gradwarpinfo.gwtype = 17;
    case {'cimax'}
      gradwarpinfo.gwtype = 18;
    case {'aeraxj'}
      gradwarpinfo.gwtype = 19;
    case {'aeraxq'}
      gradwarpinfo.gwtype = 20;
    otherwise
      errmsg=sprintf('%s: Unknown gradient model %s %s\n',mfilename,Manufacturer,ManufacturersModelName);
      return;
  end
elseif ~isempty(regexpi(Manufacturer,'ge medical'))
  gradwarpinfo.isoctrflag = 1; % Assume that GE always does isoccenter scanning
  gradwarpinfo.unwarpflag = 1; % Assume in-plance correction already performed -- should check images
  tmp = mmil_getfield(dcminfo,'Private_0043_102d',[]);
  if ~isempty(tmp)
    fprintf('%s: DICOM tag Private_0043_102d: ',mfilename);
    try
      fprintf('%s',tmp);
    catch
      disp(tmp);
    end
    fprintf('\n');
    if isnumeric(tmp)
      tmp = char(mmil_rowvec(tmp));
    end
    if ~isempty(regexp(tmp,'w'))
      fprintf('%s: 3D gradwarp applied on scanner\n',mfilename);
      gradwarpinfo.unwarpflag = 3;
    end
  end
  % Should check images using version of ctx_get_gwtype, if gradwarpinfo.unwarpflag == 1, to handle case of CV nograd=1
  if ismember(deblank(lower(ManufacturersModelName)),{'discovery mr450','discovery mr750' })
      gradwarpinfo.gwtype = 9;
      return;
  end
  if ismember(deblank(lower(ManufacturersModelName)),{'discovery mr750w', 'signa pet/mr', 'signa architect'})
      gradwarpinfo.gwtype = 10;
      return;
  end
  if ismember(deblank(lower(ManufacturersModelName)),{'signa premier'})
      gradwarpinfo.gwtype = 14;
      return;
  end
  if ismember(deblank(lower(ManufacturersModelName)),{'signa uhp'})
      gradwarpinfo.gwtype = 15;
      return;
  end
  if ismember(deblank(lower(ManufacturersModelName)),{'signa creator'}) && FieldStrength == 3
      gradwarpinfo.gwtype = 9;
      return;
  end 
  if isfield(dcminfo,'Private_0043_106f')
      tmp = dcminfo.Private_0043_106f;
      if length(tmp)>=2 & tmp(1)>=48 & tmp(1)<=57 & tmp(2)==92 % Does it look like ASCII nums delimited by \?
          tmp = tmp(1:2:end)-48;
      end
      if length(tmp) >=4
          key = tmp(4);
      else
          key = 0;
      end
      if key == 1
          gradwarpinfo.gwtype = 7; % Whole
      elseif key == 2;
          gradwarpinfo.gwtype = 8; % Zoom
      elseif key == 0;
          %        gradwarpinfo.gwtype = 2; % BRM mode??? NB: Needs to be checked!
          gradwarpinfo.ambiguousgwtype = 1; % Ambiguous
          errmsg=sprintf('%s: Ambiguous gradient info for %s %s\n',mfilename,Manufacturer,ManufacturersModelName);
%          disp(errmsg)
          return;
      else
          gradwarpinfo.ambiguousgwtype = 1; % Ambiguous
          errmsg=sprintf('%s: TwinSpeed mode = %d unknown for %s %s\n',mfilename,key,Manufacturer,ManufacturersModelName);
%          disp(errmsg)
          return;
      end
      return
  end
  switch lower(ManufacturersModelName)
    case {'brm'} % Check on actual name
      gradwarpinfo.gwtype = 2;
    case {'crm'} % Check on actual name
      gradwarpinfo.gwtype = 3;
    case {'signa excite','signa hdx'}
      gradwarpinfo.ambiguousgwtype = 1; % Ambiguous
      errmsg=sprintf('%s: Missing DICOM tag Private_0043_106f for %s %s\n',mfilename,Manufacturer,ManufacturersModelName);
      return;
    case 'genesis_signa'
      %        gradwarpinfo.gwtype = 2; % BRM mode??? NB: Needs to be checked!
      %        GET INFO FROM TEXTFILE FOR SYSTEM           XXX
      gradwarpinfo.ambiguousgwtype = 1; % Ambiguous
      errmsg=sprintf('%s: Ambiguous gradient info for %s %s\n',mfilename,Manufacturer,ManufacturersModelName);
%      disp(errmsg)
      return;
    otherwise
      gradwarpinfo.ambiguousgwtype = 1; % Ambiguous
      errmsg=sprintf('%s: Unknown gradient model %s %s\n',mfilename,Manufacturer,ManufacturersModelName);
%      disp(errmsg)
      return;
  end
elseif ~isempty(regexpi(Manufacturer,'philips medical'))
  gradwarpinfo = []; % Default to no gradwarp for Philips scanners
else
  gradwarpinfo = []; % Default to no gradwarp for unknown scanner mfgrs
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SiemensCsaParse_ReadDicomTag(strTag)
    currdx=0;
    
    if ~strcmp(char(private_read(4)),'SV10') || ~all(private_read(4)==[4 3 2 1])
        error('Unsupported CSA block format');
    end
    
    % This parsing code is translated from gdcm (http://gdcm.sf.net/)
    numElements = double(private_readuint32(1));
    
    % Sanity check
    if private_readuint32(1)~=77
        error('Unsupported CSA block format');
    end
    
    try

    for tagdx=1:numElements
        tagName = private_readstring(64);
        
        % Fix up tagName
        tagName(tagName == '-') = [];
        
        vm = private_readuint32(1);
        vr = private_readstring(4);
        syngodt = private_readuint32(1);
        nitems = double(private_readuint32(1));
        
        checkbit = private_readuint32(1);
        
        if checkbit ~= 77 && checkbit ~= 205
            error('Unsupported CSA block format');
        end
        
        data = {};
        for itemdx=1:nitems
            header = double(private_readuint32(4));
            
            if (header(3) ~= 77 && header(3) ~= 205) || ...
                    (header(1) ~= header(2)) || ...
                    (header(1) ~= header(4))
                error('Unsupported CSA block format');
            end
            
            data{itemdx} = private_readstring(header(1));
            
            % Dump junk up to DWORD boundary
            private_read(mod(mod(4-header(1),4),4));
        end
        
        % Store this in the csa structure
        if ~isfield(dcminfo,'csa')
          dcminfo.csa = struct();
        end

        switch vr
            case {'CS', 'LO', 'LT', 'SH', 'SS', 'UI', 'UT', 'UN'} % Strings and unknown byte string
                if numel(data) < vm
                    % Pad if necessary. Siemens CSA format omits null strings.
                    data{vm} = '';
                end
                
                if vm == 1
                    dcminfo.csa.(tagName) = data{1};
                else
                    dcminfo.csa.(tagName) = data(1:vm);
                end
            case {'DS', 'FD', 'FL', 'IS', 'SL', 'ST', 'UL', 'US'} % Numbers
                dataNumeric = arrayfun(@str2double,data);
                
                if numel(dataNumeric) < vm
                    % Zero pad if necessary. Siemens CSA format omits zeros.
                    dataNumeric(vm) = 0;
                end
                
                dcminfo.csa.(tagName) = dataNumeric(1:vm);
            otherwise
                warning('RodgersSpectroTools:UnknownVrType','Unknown VR type: "%s".',vr)
        end
    end

    catch ME
      PrintErrorStruct(ME);
%      keyboard
      rethrow(ME)
    end
        
    %% Helper functions to simulate file I/O
    function [out] = private_read(numBytes)
        tmp = dcminfo.(strTag);
        tmp = mmil_rowvec(tmp);
%        out = dcminfo.(strTag)(currdx+(1:numBytes)).';
        out = tmp(currdx+(1:numBytes));
        currdx=currdx+numBytes;
    end
    
    function [out] = private_readuint32(num)
        out=typecast(private_read(4*num),'uint32');
    end
    
    function [out] = private_readstring(maxchar)
        out = reshape(char(private_read(maxchar)),1,[]);
        terminator = find(out==0,1);
        if numel(terminator)>0
            out=out(1:(terminator-1));
        end
    end
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function strval = checkstr(strval)
  if isnumeric(strval)
    strval = strtrim(reshape(char(strval),[1 numel(strval)]));
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



