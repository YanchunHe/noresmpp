;*************************************************
; rotate and plot vectors
; NorESM User Workshop 2019
; yanchun.he@nersc.no
;************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl" 
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"   
;************************************************
begin
;************************************************
; read in grid data
;************************************************
  gid   = addfile("../grid/grid_tnx1v4.nc","r")
  ulat  = gid->ulat
  ulon  = gid->ulon
  vlat  = gid->vlat
  vlon  = gid->vlon
  plat  = gid->plat
  plon  = gid->plon
  angle = gid->angle
;************************************************
; read in flow/current data
;************************************************
  fid   = addfile("uv.nc","r")
  ubaro = fid->ubaro(0,:,:)
  vbaro = fid->vbaro(0,:,:)

  u0    = ubaro
  v0    = vbaro
  title0= "original"
  
  u1    = ubaro*cos(angle)-vbaro*sin(angle);
  v1    = ubaro*sin(angle)+vbaro*cos(angle);
  title1= "rotated"

  fname = "micom_rotate"

  s0 = sqrt(u0^2+v0^2)
  s1 = sqrt(u1^2+v1^2)

  u0@lat2d    = ulat
  u0@lon2d    = ulon
  v0@lat2d    = vlat
  v0@lon2d    = vlon
  s0@lat2d    = plat
  s0@lon2d    = plon

  u1@lat2d    = ulat
  u1@lon2d    = ulon
  v1@lat2d    = vlat
  v1@lon2d    = vlon
  s1@lat2d    = plat
  s1@lon2d    = plon
;************************************************
;************************************************
; this data only has an missing_value, so we are
; copying this to _FillValue for plotting purposes
;************************************************
;  assignFillValue(v,u)                           ; in contributed.ncl   
;  assignFillValue(u,v)
;************************************************
; create plot
;************************************************
  wks   = gsn_open_wks("pdf",fname)             ; send graphics to PDF file
  gsn_define_colormap(wks, "MPL_Blues")

;  wks1 = gsn_open_wks("pdf",fname1)             ; send graphics to PDF file
;  gsn_define_colormap(wks1, "MPL_Blues")

  res            = True                         ; plot mods desired
  res@gsnDraw    = False
  res@gsnFrame   = False
  res@gsnPolar   = "NH"                         ; specify the hemisphere
  res@mpMinLatF  = 40                           ; minimum lat to plot
  res@mpFillOn   = False
  res@gsnAddCyclic    = True

  res@cnFillOn          = True                  ; color fill
  res@cnLinesOn         = False                 ; no contour lines
  res@cnLevelSelectionMode    = "ManualLevels"
  res@cnMinLevelValF        = 0.0
  res@cnMaxLevelValF        = 0.5
  res@cnLevelSpacingF        = 0.05                    ; interval spacing

  res@gsnSpreadColors        = True
  res@gsnScalarContour      = True              ; vectors over scalars
  res@vcRefMagnitudeF       = .1                ; vec magnitude
  res@vcRefLengthF          = 0.02              ; size of ref vector
;  res@vcLineArrowColor      = "white"          ; white vectors
  res@vcMinDistanceF        = 0.01              ; thins arrows near pole  
  res@vcGlyphStyle          = "CurlyVector"     ; turns on curly vectors

  res@vcRefAnnoArrowLineColor   = "black"       ; black ref vector
  res@vcRefAnnoArrowUseVecColor = False

;  res@gsnLeftString       = "Wind Velocity over Surface Temperature"

  plot  = new(2,graphic)
  res@tiMainString    = title0
  plot(0) = gsn_csm_vector_scalar_map_polar(wks,u0(:,:),v0(:,:),s0(:,:),res)
  res@tiMainString    = title1
  plot(1) = gsn_csm_vector_scalar_map_polar(wks,u1(:,:),v1(:,:),s1(:,:),res)

  ; panel plot only resources
  resP                = True        ; modify the panel plot
;  resP@gsnMaximize    = True        ; large format
  
  gsn_panel(wks,plot,(/1,2/),resP)
;  draw((/plot0,plot1/))
;  frame(wks)

end
