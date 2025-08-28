function [fname_gradL,fname_gradP,fname_gradH,grad_unwarp] = mmil_grad_files(gradient_type)
%function [fname_gradL,fname_gradP,fname_gradH,grad_unwarp] = mmil_grad_files(gradient_type)
%
% Purpose: assign grad warp file name based on gradient_type
%
% Input:
%
%   gradient_type: 0:  Siemens Sonata
%                  1:  Siemens Allegra
%                  2:  GE BRM
%                  3:  GE CRM
%                  4:  Siemens Avanto
%                  5:  Siemens AXXess/Espree
%                  6:  Siemens Quantum/Symphony
%                  7:  GE Twin Speed Whole Body
%                  8:  GE Twin Speed Zoom
%                  9:  GE MR450 or MR750
%                  10: GE MR750W
%                  11: Siemens Skyra
%                  12: Siemens Connectome Skyra
%                  13: Siemens Prisma
%                  14: GE Signa Premier
%                  15: GE Signa UHP
%                  16: Siemens Verio/Biograph
%                  17: Siemens Vida
%                  18: Siemens Cima.X
%                  19: Siemens Aera XJ
%
% Output:
%
%   fname_gradL: fulll path of grad warp file for RL
%   fname_gradP: fulll path of grad warp file for AP
%   fname_gradH: fulll path of grad warp file for IS
%   grad_unwarp: gradient warp type


fname_gradL = []; fname_gradP = []; fname_gradH = []; grad_unwarp = [];

if ~mmil_check_nargs(nargin,1), return; end

switch gradient_type
 case 0, % Sonata
    fname_gradL = 'siemens_sonata_dL.mgh';
    fname_gradP = 'siemens_sonata_dP.mgh';
    fname_gradH = 'siemens_sonata_dH.mgh';
    grad_unwarp = 'Siemens_Sonata';
 case 1, % Allegra
    fname_gradL = 'siemens_allegra_dL.mgh';
    fname_gradP = 'siemens_allegra_dP.mgh';
    fname_gradH = 'siemens_allegra_dH.mgh';
    grad_unwarp = 'Siemens_Allegra';
 case 2, %GE BRM
    fname_gradL='ge_brm_dL.mgh';
    fname_gradP='ge_brm_dP.mgh';
    fname_gradH='ge_brm_dH.mgh';
    grad_unwarp = 'GE_BRM';
 case 3, %GE CRM
    fname_gradL='ge_crm_dL.mgh';
    fname_gradP='ge_crm_dP.mgh';
    fname_gradH='ge_crm_dH.mgh';
    grad_unwarp = 'GE_CRM';
 case 4, % Allegra
    fname_gradL = 'siemens_avanto_dL.mgh';
    fname_gradP = 'siemens_avanto_dP.mgh';
    fname_gradH = 'siemens_avanto_dH.mgh';
    grad_unwarp = 'Siemens_Avanto';  
 case 5, % Axxess
    fname_gradL = 'siemens_axxess_dL.mgh';
    fname_gradP = 'siemens_axxess_dP.mgh';
    fname_gradH = 'siemens_axxess_dH.mgh';
    grad_unwarp = 'Siemens_Axxess';
 case 6, % Quantum
    fname_gradL = 'siemens_quantum_dL.mgh';
    fname_gradP = 'siemens_quantum_dP.mgh';
    fname_gradH = 'siemens_quantum_dH.mgh';
    grad_unwarp = 'Siemens_Quantum';   
 case 7, % GE WHole
    fname_gradL = 'ge_whole_dL.mgh';
    fname_gradP = 'ge_whole_dP.mgh';
    fname_gradH = 'ge_whole_dH.mgh';
    grad_unwarp = 'GE_WHOLE';      
 case 8, % GE Zoom
    fname_gradL = 'ge_zoom_dL.mgh';
    fname_gradP = 'ge_zoom_dP.mgh';
    fname_gradH = 'ge_zoom_dH.mgh';
    grad_unwarp = 'GE_ZOOM';      
 case 9, % GE XRMB
    fname_gradL = 'ge_xrmb_dL.mgh';
    fname_gradP = 'ge_xrmb_dP.mgh';
    fname_gradH = 'ge_xrmb_dH.mgh';
    grad_unwarp = 'GE_XRMB';
 case 10, % GE xrmw
    fname_gradL = 'ge_xrmw_dL.mgh';
    fname_gradP = 'ge_xrmw_dP.mgh';
    fname_gradH = 'ge_xrmw_dH.mgh';
    grad_unwarp = 'GE_XRMV';
 case 11, % Siemens Skyra
    fname_gradL = 'siemens_skyra_dL.mgh';
    fname_gradP = 'siemens_skyra_dP.mgh';
    fname_gradH = 'siemens_skyra_dH.mgh';
    grad_unwarp = 'Siemens_Skyra';
 case 12, % Siemens Connectome Skyra
    fname_gradL = 'siemens_connectome_dL.mgh';
    fname_gradP = 'siemens_connectome_dP.mgh';
    fname_gradH = 'siemens_connectome_dH.mgh';
    grad_unwarp = 'Siemens_Connectome';
 case 13, % Siemens Prisma
    fname_gradL = 'siemens_prisma_dL.mgh';
    fname_gradP = 'siemens_prisma_dP.mgh';
    fname_gradH = 'siemens_prisma_dH.mgh';
    grad_unwarp = 'Siemens_Prisma';
 case 14, % GE HRMW
    fname_gradL = 'ge_HRMw_dL.mgh';
    fname_gradP = 'ge_HRMw_dP.mgh';
    fname_gradH = 'ge_HRMw_dH.mgh';
    grad_unwarp = 'GE_HRMW';  
 case 15, % GE HRMB2
    fname_gradL = 'ge_HRMB2_dL.mgh';
    fname_gradP = 'ge_HRMB2_dP.mgh';
    fname_gradH = 'ge_HRMB2_dH.mgh';
    grad_unwarp = 'GE_HRMB2';
 case 16, % Siemens Verio
    fname_gradL = 'siemens_verio_dL.mgh';
    fname_gradP = 'siemens_verio_dP.mgh';
    fname_gradH = 'siemens_verio_dH.mgh';
    grad_unwarp = 'Siemens_Verio';
case 17, % Siemens Vida
    fname_gradL = 'siemens_vida_dL.mgh';
    fname_gradP = 'siemens_vida_dP.mgh';
    fname_gradH = 'siemens_vida_dH.mgh';
    grad_unwarp = 'Siemens_Vida';
case 18, % Siemens Cima.X
    fname_gradL = 'siemens_CimaX_dL.mgh';
    fname_gradP = 'siemens_CimaX_dP.mgh';
    fname_gradH = 'siemens_CimaX_dH.mgh';
    grad_unwarp = 'Siemens_CimaX';
case 19, % Siemens Aera XJ
    fname_gradL = 'siemens_AeraXJ_dL.mgh';
    fname_gradP = 'siemens_AeraXJ_dP.mgh';
    fname_gradH = 'siemens_AeraXJ_dH.mgh';
    grad_unwarp = 'Siemens_AeraXJ';
case 20, % Siemens Aera XQ
    fname_gradL = 'siemens_AeraXQ_dL.mgh';
    fname_gradP = 'siemens_AeraXQ_dP.mgh';
    fname_gradH = 'siemens_AeraXQ_dH.mgh';
    grad_unwarp = 'Siemens_AeraXQ';
 otherwise,
    error('unsupported error type %d',gradient_type);
end

if ~exist(fname_gradL,'file')
  indir = sprintf('%s/external/matlab/Projects/MorphometryToolbox/6_DistortionCorrection/gradient_nonlinearity/gradient_data',getenv('MMPS_DIR'));
  if exist(indir,'dir')
    fname_gradL = [indir '/' fname_gradL];
    fname_gradP = [indir '/' fname_gradP];
    fname_gradH = [indir '/' fname_gradH];
  else
    fprintf('%s: WARNING: grad file indir %s not found\n',mfilename,indir);
  end
else
  fname_gradL = which(fname_gradL);
  fname_gradP = which(fname_gradP);
  fname_gradH = which(fname_gradH);
end

if ~exist(fname_gradL,'file')
  error('gradL file %s not found',fname_gradL);
end
if ~exist(fname_gradP,'file')
  error('gradP file %s not found',fname_gradP);
end
if ~exist(fname_gradH,'file')
  error('gradH file %s not found',fname_gradH);
end


