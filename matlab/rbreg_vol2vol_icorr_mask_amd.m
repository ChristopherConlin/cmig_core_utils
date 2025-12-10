function [M_v1_to_v2, min_cost, sf, vol2_res] = rbreg_vol2vol_icorr_mask_amd(vol1, vol2, volmask, bdispiter, mstep, M_reg_init, bsmooth, scales, tmin, amin, allowchanged)
% Multiscale Rigid body registration By Intensity Correlation
%       
% [M_reg, min_cost, sf] = rbreg_vol2vol_icorr_mask(vol1, vol2, volmask, [bdispiter], [mstep], [M_v1_to_v2_init], [bsmooth], ...
%                                          [scales], [tmin], [amin], ...
%                                         [allowchanged])
%
% Input:
%   vol1: template vol structure
%   vol2: regsitering vol structure
%   volmask; Mask volume structure for ROI. make sure it is the same dim as vol1
%   bdispiter: show debug
%   mstep: sampling in the mask; default = 1;
%   bsmooth: smooth input volume (default=false);
%   scales: number of scales (default:[0 83 49 27 16 9 5 3 2 1]). Be sure
%   put 0 in the first scale to initialize algorithm
%   tmin: minimun in translation (in mm) default=0.05;
%   amin: minimum in angle (in rad) default= 0.05 degree
%   allowchanged: allowable parameter changes default=2;

%
% Output:
%   M_v1_to_v2: Registration matrix from Vol1 to Vol2
%   min_const:  Minimization error
%   sf:         Scaling factor for Vol1/Vol2;

%clear
%vol1=read_mgh('flash30r.mgh');
%vol2=read_mgh('flash05r.mgh');

if ~exist('bdispiter','var') | isempty(bdispiter), bdispiter=false; end
if ~exist('mstep','var') | isempty(mstep), mstep=1; end
if ~exist('M_reg_init','var') | isempty(M_reg_init), M_reg_init=eye(4); end
if ~exist('bsmooth','var') | isempty(bsmooth), bsmooth=false; end
if ~exist('scales','var') | isempty(scales), scales=[0 200 83 49 27 16 9 5 3 2 1]; end
if ~exist('tmin','var') | isempty(tmin), tmin=0.05; end
if ~exist('amin','var') | isempty(amin), amin=(0.05)*(pi/180); end
if ~exist('allowchanged','var') | isempty(allowchanged), allowchanged=2; end

if (bsmooth)
  if bdispiter
    disp    'Smoothing volume...'
  end
  volf1=vol_filter(vol1, 1);
  clear vol1;
  vols1=vol_filter(volf1, 1);
  clear volf1;
  volf1=vol_filter(vol2, 1);
  clear vol2;
  vols2=vol_filter(volf1, 1);
  clear volf1;
else
  vols1=vol1;
  vols2=vol2;
end

if any(size(volmask.imgs)~=size(vols1.imgs)) | any(volmask.Mvxl2lph(:)~=vols1.Mvxl2lph(:))
  fprintf(1,'%s: volmask does not match vols1\n',mfilename);
end

if 1 % Skip by mstep in each dimension
  volmask_sparse = volmask; volmask_sparse.imgs(:) = 0;
  volmask_sparse.imgs(1:mstep:end,1:mstep:end,1:mstep:end) = volmask.imgs(1:mstep:end,1:mstep:end,1:mstep:end);
  inds = find(volmask_sparse.imgs>0);
else
  ind = find(volmask.imgs>0);
  tsize=length(ind);
  inds = ind(1:mstep:tsize); % Should skip by mstep in each dimension?
end

[I J K]=ind2sub(size(volmask.imgs), inds);
bvxl=ones(length(I),4);
bvxl(:,1)=I;
bvxl(:,2)=J;
bvxl(:,3)=K;
lphpos=(volmask.Mvxl2lph*bvxl')';
vxlval1 = vol_getvxlsval(lphpos, vols1, eye(4,4));
vxlvalw = vol_getvxlsval(lphpos, volmask, eye(4,4));

if bdispiter
  disp    'Registration...'
end
%M_reg = eye(4,4);
M_reg = M_reg_init;
M_reg_opt = M_reg;
min_cost = 1e10;
sf=1;
for scale = scales
  if scale==0
    win = 0;
  else
    win = 1;
  end
  changed = 1;
  pass = 0;
  while changed
    pass = pass+1;
    changed = 0;
    M_reg_bak = M_reg_opt;
    for txi = -win:win
    for tyi = -win:win
    for tzi = -win:win
    for axi = -win:win
    for ayi = -win:win
    for azi = -win:win
        if (sum([txi tyi tzi axi ayi azi]~=0)<=allowchanged)
            tx = txi*scale*tmin; ty = tyi*scale*tmin; tz = tzi*scale*tmin;
            ax = axi*scale*amin; ay = ayi*scale*amin; az = azi*scale*amin;
            M_reg = Mrotz(az)*Mroty(ay)*Mrotx(ax)*Mtrans(tx,ty,tz)*M_reg_bak;
            [vxlval2 inbound]= vol_getvxlsval(lphpos, vols2, M_reg); % Need to check if inbound is correct (compare with code in vol_resample_amd.m)
            ind = find(inbound>0&isfinite(vxlval1+vxlval2));
            if 0 % Do weighted linear regression -- cost not working
              y = vxlvalw(ind).*vxlval2(ind); wy = vxlvalw(ind).*y;
              X = vxlval1(ind); Xtw = (X.*vxlvalw(ind))';
              sf = inv(Xtw*X)*Xtw*y;
              y_hat = sf*X;
              cost = sum(vxlvalw(ind).*((y_hat-y).^2))/sum(vxlvalw(ind)); % Not sure why this is slipping off the FOV!
%keyboard
            else
%              cost =-vxlval1(ind)'*vxlval2(ind)/(norm(vxlval1(ind))*norm(vxlval2(ind)));
%              cost = -corr(vxlval1(ind),vxlval2(ind));
              Sxx = sum(vxlvalw(ind).*vxlval1(ind).^2); Syy = sum(vxlvalw(ind).*vxlval2(ind).^2); Sxy = sum(vxlvalw(ind).*(vxlval1(ind).*vxlval2(ind)));
              cost = -Sxy/sqrt(Sxx*Syy); % Weighted (or Cosine) correlation
            end
            if 0
              vol2r = vol_resample(vols2, vols1, M_reg_opt); % Should scale by sf, display weighted residual (sum should equal cost)
              vol1m = vols1;
              vol1m.imgs = vols1.imgs .*volmask.imgs;
              vol2rm = vol2r;
              vol2rm.imgs = vol2r.imgs.* volmask.imgs;
              showVol(vol2r,vols1,volmask); 
            end
           
            str = 'scale=%d (%d) [%d %d %d %d %d %d] cost=%f min_cost=%f\n';
            if (bdispiter)
                fprintf(str,scale,pass,txi,tyi,tzi,axi,ayi,azi,cost,min_cost);
            end
            if (cost<min_cost)
                [mval maxldir] = max(abs(M_reg(:,1)));
                [mval maxpdir] = max(abs(M_reg(:,2)));
                [mval maxhdir] = max(abs(M_reg(:,3)));
                if (maxldir == 1) & (maxpdir == 2) & (maxhdir == 3)
                    min_cost = cost;
                    M_reg_opt = M_reg;
                    str = '*** scale=%d (%d) [%d %d %d %d %d %d]';
                    str = [str 'cost=%f min_cost=%f\n'];
                    if (bdispiter)
                        fprintf(str,scale,pass,txi,tyi,tzi,axi,ayi,azi, cost,min_cost);
                    end
                    changed = 1;
%keyboard

                    if 0
%                      M_reg = Mrotx(20*pi/180)*Mtrans(0,15,25);
                      vol2r = vol_resample(vols2, vols1, M_reg); vol2r.imgs = vol2r.imgs*sf;
%                      ivec = find(volmask.imgs>0.5&isfinite(vols1.imgs+vol2r.imgs));
%                      corr(vols1.imgs(ivec),vol2r.imgs(ivec))
                      showVol(vols1.imgs,vol2r.imgs,(vols1.imgs-vol2r.imgs).*volmask.imgs,volmask.imgs)
                    end
                end
            end
        end
    end
    end
    end
    end
    end
    end
  end
end

M_v1_to_v2 = M_reg_opt;

if nargout>=3
  [vxlval2 inbound]= vol_getvxlsval(lphpos, vols2, M_reg_opt);
  ind = find(inbound>0&isfinite(vxlval1+vxlval2));
  y = vxlvalw(ind).*vxlval2(ind); wy = vxlvalw(ind).*y;
  X = vxlval1(ind); Xtw = (X.*vxlvalw(ind))';
  sf = inv(Xtw*X)*Xtw*y;
end

if nargout>=4
  vol2.imgs = vol2.imgs/sf;
  vol2_res = vol_resample_amd(vol2, vol1, M_reg_opt); % Should replace this with version that returns vol_inbound
end

