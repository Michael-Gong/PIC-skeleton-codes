!-----------------------------------------------------------------------
! Interface file for mpdpush3.f
      module mpdpush3_h
      implicit none
!
      interface
         subroutine PDICOMP32L(edges,nyzp,noff,nypmx,nzpmx,nypmn,nzpmn, &
     &ny,nz,kstrt,nvpy,nvpz,idps,idds)
         implicit none
         integer, intent(in) :: ny, nz, kstrt, nvpy, nvpz, idps, idds
         integer, intent(inout) :: nypmx, nzpmx, nypmn, nzpmn
         integer, dimension(idds), intent(inout) :: nyzp, noff
         real, dimension(idps), intent(inout) :: edges
         end subroutine
      end interface
!
      interface
         subroutine FCOMP32(nvp,nx,ny,nz,nvpy,nvpz,ierr)
         implicit none
         integer, intent(in) :: nvp, nx, ny, nz
         integer, intent(inout) :: nvpy, nvpz, ierr
         end subroutine
      end interface
!
      interface
         subroutine PDISTR32(part,edges,npp,nps,vtx,vty,vtz,vdx,vdy,vdz,&
     &npx,npy,npz,nx,ny,nz,idimp,npmax,idps,ipbc,ierr)
         implicit none
         integer, intent(in) :: nps, npx, npy, npz, nx, ny, nz, idimp
         integer, intent(in) :: npmax, idps, ipbc
         integer, intent(inout) :: npp, ierr
         real, intent(in) :: vtx, vty, vtz, vdx, vdy, vdz
         real, dimension(idimp,npmax), intent(inout) :: part
         real, dimension(idps), intent(in) :: edges
         end subroutine
      end interface
!
      interface
         subroutine PPDBLKP3L(part,kpic,npp,noff,nppmx,idimp,npmax,mx,my&
     &,mz,mx1,myp1,mxyzp1,idds,irc)
         implicit none
         integer, intent(in) :: npp, idimp, npmax, mx, my, mz
         integer, intent(in) :: mx1, myp1, mxyzp1, idds
         integer, intent(inout) :: nppmx, irc
         real, dimension(idimp,npmax), intent(in) :: part
         integer, dimension(mxyzp1), intent(inout) :: kpic
         integer, dimension(idds), intent(in) :: noff
         end subroutine
      end interface
!
      interface
         subroutine PPPMOVIN3L(part,ppart,kpic,npp,noff,nppmx,idimp,    &
     &npmax,mx,my,mz,mx1,myp1,mxyzp1,idds,irc)
         implicit none
         integer, intent(in) :: npp, nppmx, idimp, npmax, mx, my, mz
         integer, intent(in) :: mx1, myp1, mxyzp1, idds
         integer, intent(inout) :: irc
         real, dimension(idimp,npmax), intent(in) :: part
         real, dimension(idimp,nppmx,mxyzp1), intent(inout) :: ppart
         integer, dimension(mxyzp1), intent(inout) :: kpic
         integer, dimension(idds), intent(in) :: noff
         end subroutine
      end interface
!
      interface
         subroutine PPPCHECK3L(ppart,kpic,noff,nyzp,idimp,nppmx,nx,mx,my&
     &,mz,mx1,myp1,mzp1,idds,irc)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, mx, my, mz
         integer, intent(in) :: mx1, myp1, mzp1, idds
         integer, intent(inout) :: irc
         real, dimension(idimp,nppmx,mx1*myp1*mzp1), intent(in) :: ppart
         integer, dimension(mx1*myp1*mzp1), intent(in) :: kpic
         integer, dimension(idds), intent(in) :: noff, nyzp
         end subroutine
      end interface
!
      interface
         subroutine PPGBPPUSH32L(ppart,fxyz,bxyz,kpic,noff,nyzp,qbm,dt, &
     &dtc,ek,idimp,nppmx,nx,ny,nz,mx,my,mz,nxv,nypmx,nzpmx,mx1,myp1,    &
     &mxyzp1,idds,ipbc)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, ny, nz, mx, my, mz
         integer, intent(in) :: nxv, nypmx, nzpmx, mx1, myp1, mxyzp1
         integer, intent(in) :: idds, ipbc
         real, intent(in) :: qbm, dt, dtc
         real, intent(inout) :: ek
         real, dimension(idimp,nppmx,mxyzp1), intent(inout) :: ppart
         real, dimension(3,nxv,nypmx,nzpmx), intent(in) :: fxyz, bxyz
         integer, dimension(mxyzp1), intent(in) :: kpic
         integer, dimension(idds), intent(in) :: noff, nyzp
         end subroutine
      end interface
!
      interface
         subroutine PPGBPPUSHF32L(ppart,fxyz,bxyz,kpic,ncl,ihole,noff,  &
     &nyzp,qbm,dt,dtc,ek,idimp,nppmx,nx,ny,nz,mx,my,mz,nxv,nypmx,nzpmx, &
     &mx1,myp1,mxyzp1,ntmax,idds,irc)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, ny, nz, mx, my, mz
         integer, intent(in) :: nxv, nypmx, nzpmx, mx1, myp1, mxyzp1
         integer, intent(in) :: ntmax, idds
         integer, intent(inout) :: irc
         real, intent(in) :: qbm, dt, dtc
         real, intent(inout) :: ek
         real, dimension(idimp,nppmx,mxyzp1), intent(inout)  :: ppart
         real, dimension(3,nxv,nypmx,nzpmx), intent(in) :: fxyz, bxyz
         integer, dimension(mxyzp1), intent(in) :: kpic
         integer, dimension(26,mxyzp1), intent(inout)  :: ncl
         integer, dimension(2,ntmax+1,mxyzp1), intent(inout)  :: ihole
         integer, dimension(idds), intent(in) :: noff, nyzp
         end subroutine
      end interface
!
      interface
         subroutine PPGPPOST32L(ppart,q,kpic,noff,qm,nppmx,idimp,mx,my, &
     &mz,nxv,nypmx,nzpmx,mx1,myp1,mxyzp1,idds)
         implicit none
         integer, intent(in) :: nppmx, idimp, mx, my, mz, nxv
         integer, intent(in) :: nypmx, nzpmx, mx1, myp1, mxyzp1, idds
         real, intent(in) :: qm
         real, dimension(idimp,nppmx,mxyzp1), intent(in) :: ppart
         real, dimension(nxv,nypmx,nzpmx), intent(inout) :: q
         integer, dimension(mxyzp1), intent(in) :: kpic
         integer, dimension(idds), intent(in) :: noff
         end subroutine
      end interface
!
      interface
         subroutine PPGJPPOST32L(ppart,cu,kpic,noff,qm,dt,nppmx,idimp,nx&
     &,ny,nz,mx,my,mz,nxv,nypmx,nzpmx,mx1,myp1,mxyzp1,idds,ipbc)
         implicit none
         integer, intent(in) :: nppmx, idimp, nx, ny, nz, mx, my, mz
         integer, intent(in) :: nxv, nypmx, nzpmx, mx1, myp1, mxyzp1
         integer, intent(in) :: idds, ipbc
         real, intent(in) :: qm, dt
         real, dimension(idimp,nppmx,mxyzp1), intent(inout) :: ppart
         real, dimension(3,nxv,nypmx,nzpmx), intent(inout) :: cu
         integer, dimension(mxyzp1), intent(in) :: kpic
         integer, dimension(idds), intent(in) :: noff
         end subroutine
      end interface
!
      interface
         subroutine PPGMJPPOST32L(ppart,amu,kpic,noff,qm,nppmx,idimp,mx,&
     &my,mz,nxv,nypmx,nzpmx,mx1,myp1,mxyzp1,idds)
         implicit none
         integer, intent(in) :: nppmx, idimp, mx, my, mz, nxv
         integer, intent(in) :: nypmx, nzpmx, mx1, myp1, mxyzp1, idds
         real, intent(in) :: qm
         real, dimension(idimp,nppmx,mxyzp1), intent(in) :: ppart
         real, dimension(6,nxv,nypmx,nzpmx), intent(inout) :: amu
         integer, dimension(mxyzp1), intent(in) :: kpic
         integer, dimension(idds), intent(in) :: noff
         end subroutine
      end interface
!
      interface
         subroutine PPGDJPPOST32L(ppart,fxyz,bxyz,kpic,noff,nyzp,dcu,amu&
     &,qm,qbm,dt,idimp,nppmx,nx,mx,my,mz,nxv,nypmx,nzpmx,mx1,myp1,mxyzp1&
     &,idds)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, mx, my, mz, nxv
         integer, intent(in) :: nypmx, nzpmx, mx1, myp1, mxyzp1, idds
         real, intent(in) :: qm, qbm, dt
         real, dimension(idimp,nppmx,mxyzp1), intent(in) :: ppart
         real, dimension(3,nxv,nypmx,nzpmx), intent(in) :: fxyz, bxyz
         real, dimension(3,nxv,nypmx,nzpmx), intent(inout) :: dcu
         real, dimension(6,nxv,nypmx,nzpmx), intent(inout) :: amu
         integer, dimension(mxyzp1), intent(in) :: kpic
         integer, dimension(idds), intent(in) :: noff, nyzp
         end subroutine
      end interface
!
      interface
         subroutine PPGDCJPPOST32L(ppart,fxyz,bxyz,kpic,noff,nyzp,cu,dcu&
     &,amu,qm,qbm,dt,idimp,nppmx,nx,mx,my,mz,nxv,nypmx,nzpmx,mx1,myp1,  &
     &mxyzp1,idds)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, mx, my, mz, nxv
         integer, intent(in) :: nypmx, nzpmx, mx1, myp1, mxyzp1, idds
         real, intent(in) :: qm, qbm, dt
         real, dimension(idimp,nppmx,mxyzp1), intent(in) :: ppart
         real, dimension(3,nxv,nypmx,nzpmx), intent(in) :: fxyz, bxyz
         real, dimension(3,nxv,nypmx,nzpmx), intent(inout) :: cu, dcu
         real, dimension(6,nxv,nypmx,nzpmx), intent(inout) :: amu
         integer, dimension(mxyzp1), intent(in) :: kpic
         integer, dimension(idds), intent(in) :: noff, nyzp
         end subroutine
      end interface
!
      interface
         subroutine PPPORDER32LA(ppart,ppbuff,sbufl,sbufr,kpic,ncl,ihole&
     &,ncll,nclr,noff,nyzp,idimp,nppmx,nx,ny,nz,mx,my,mz,mx1,myp1,mzp1, &
     &mxzyp1,npbmx,ntmax,nbmax,idds,irc)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, ny, nz, mx, my, mz
         integer, intent(in) :: mx1, myp1, mzp1, mxzyp1, npbmx, ntmax
         integer, intent(in) :: nbmax, idds
         integer, intent(inout) :: irc
         real, dimension(idimp,nppmx,mx1*myp1*mzp1), intent(inout) ::   &
     &ppart
         real, dimension(idimp,npbmx,mx1*myp1*mzp1), intent(inout) ::   &
     &ppbuff
         real, dimension(idimp,nbmax,2), intent(inout) :: sbufl, sbufr
         integer, dimension(mx1*myp1*mzp1), intent(in) :: kpic
         integer, dimension(26,mx1*myp1*mzp1), intent(inout) :: ncl
         integer, dimension(2,ntmax+1,mx1*myp1*mzp1), intent(inout) ::  &
     &ihole
         integer, dimension(3,mxzyp1,3,2), intent(inout) :: ncll, nclr
         integer, dimension(idds), intent(in) :: noff, nyzp
         end subroutine
      end interface
!
      interface
         subroutine PPPORDERF32LA(ppart,ppbuff,sbufl,sbufr,ncl,ihole,   &
     &ncll,nclr,idimp,nppmx,mx1,myp1,mzp1,mxzyp1,npbmx,ntmax,nbmax,irc)
         implicit none
         integer, intent(in) :: idimp, nppmx, mx1, myp1, mzp1, mxzyp1
         integer, intent(in) :: npbmx, ntmax, nbmax
         integer, intent(inout) :: irc
         real, dimension(idimp,nppmx,mx1*myp1*mzp1), intent(inout) ::   &
     &ppart
         real, dimension(idimp,npbmx,mx1*myp1*mzp1), intent(inout) ::   &
     &ppbuff
         real, dimension(idimp,nbmax,2), intent(inout) :: sbufl, sbufr
         integer, dimension(26,mx1*myp1*mzp1), intent(inout) :: ncl
         integer, dimension(2,ntmax+1,mx1*myp1*mzp1), intent(in) ::     &
     &ihole
         integer, dimension(3,mxzyp1,3,2), intent(inout) :: ncll, nclr
         end subroutine
      end interface
!
      interface
         subroutine PPPORDER32LB(ppart,ppbuff,rbufl,rbufr,kpic,ncl,ihole&
     &,mcll,mclr,mcls,idimp,nppmx,mx1,myp1,mzp1,mxzyp1,npbmx,ntmax,nbmax&
     &,irc)
         implicit none
         integer, intent(in) :: idimp, nppmx, mx1, myp1, mzp1, mxzyp1
         integer, intent(in) :: npbmx, ntmax, nbmax
         integer, intent(inout) :: irc
         real, dimension(idimp,nppmx,mx1*myp1*mzp1), intent(inout) ::   &
     &ppart
         real, dimension(idimp,npbmx,mx1*myp1*mzp1), intent(in) :: ppbuff
         real, dimension(idimp,nbmax,2), intent(in) :: rbufl, rbufr
         integer, dimension(mx1*myp1*mzp1), intent(inout) :: kpic
         integer, dimension(26,mx1*myp1*mzp1), intent(in) :: ncl
         integer, dimension(2,ntmax+1,mx1*myp1*mzp1), intent(in) ::     &
     &ihole
         integer, dimension(3,mxzyp1,3,2), intent(in) :: mcll, mclr
         integer, dimension(3,mx1+1,4), intent(in) :: mcls
         end subroutine
      end interface
!
      interface
         subroutine PPCGUARD32XL(fxyz,nyzp,nx,ndim,nxe,nypmx,nzpmx,idds)
         implicit none
         integer, intent(in) :: nx, ndim, nxe, nypmx, nzpmx, idds
         real, dimension(ndim,nxe,nypmx,nzpmx), intent(inout) :: fxyz
         integer, dimension(idds), intent(in) :: nyzp
         end subroutine
      end interface
!
      interface
         subroutine PPAGUARD32XL(q,nyzp,nx,nxe,nypmx,nzpmx,idds)
         implicit none
         integer, intent(in) :: nx, nxe, nypmx, nzpmx, idds
         real, dimension(nxe,nypmx,nzpmx), intent(inout) :: q
         integer, dimension(idds), intent(in) :: nyzp
         end subroutine
      end interface
!
      interface
         subroutine PPACGUARD32XL(cu,nyzp,nx,ndim,nxe,nypmx,nzpmx,idds)
         implicit none
         integer, intent(in) :: nx, ndim, nxe, nypmx, nzpmx, idds
         real, dimension(ndim,nxe,nypmx,nzpmx), intent(inout) :: cu
         integer, dimension(idds), intent(in) :: nyzp
         end subroutine
      end interface
!
      interface
         subroutine MPPASCFGUARD32L(dcu,cus,nyzp,q2m0,nx,nxe,nypmx,nzpmx&
     &,idds)
         implicit none
         integer, intent(in) :: nx, nxe, nypmx, nzpmx, idds
         real, intent(in) :: q2m0
         real, dimension(3,nxe,nypmx,nzpmx), intent(inout) :: dcu
         real, dimension(3,nxe,nypmx,nzpmx), intent(in) :: cus
         integer, dimension(idds), intent(in) :: nyzp
         end subroutine
      end interface
!
      interface
         subroutine PPFWPMINMX32(qe,nyzp,qbme,wpmax,wpmin,nx,nxe,nypmx, &  
     &nzpmx,idds)
         implicit none
         integer, intent(in) :: nx, nxe, nypmx, nzpmx, idds
         real, intent(in) :: qbme
         real, intent(inout) :: wpmax, wpmin
         real, dimension(nxe,nypmx,nzpmx), intent(in) :: qe
         integer, dimension(idds), intent(in) :: nyzp
         end subroutine
      end interface
!
      interface
         subroutine MPPOIS332(q,fxyz,isign,ffc,ax,ay,az,affp,we,nx,ny,nz&
     &,kstrt,nvpy,nvpz,nzv,kxyp,kyzp,nzhd)
         implicit none
         integer, intent(in) :: isign, nx, ny, nz, kstrt, nvpy, nvpz
         integer, intent(in) :: nzv, kxyp, kyzp, nzhd
         real, intent(in) :: ax, ay, az, affp
         real, intent(inout) :: we
         complex, dimension(nzv,kxyp,kyzp), intent(in)  :: q
         complex, dimension(3,nzv,kxyp,kyzp), intent(inout) :: fxyz
         complex, dimension(nzhd,kxyp,kyzp), intent(inout) :: ffc
         end subroutine
      end interface
!
      interface
         subroutine MPPCUPERP32(cu,nx,ny,nz,kstrt,nvpy,nvpz,nzv,kxyp,   &
     &kyzp)
         implicit none
         integer, intent(in) :: nx, ny, nz, kstrt, nvpy, nvpz
         integer, intent(in) :: nzv, kxyp, kyzp
         complex, dimension(3,nzv,kxyp,kyzp), intent(inout) :: cu
         end subroutine
      end interface
!
      interface
         subroutine MPPBBPOISP332(cu,bxyz,ffc,ci,wm,nx,ny,nz,kstrt,nvpy,&
     &nvpz,nzv,kxyp,kyzp,nzhd)
         implicit none
         integer, intent(in) :: nx, ny, nz, kstrt, nvpy, nvpz
         integer, intent(in) :: nzv, kxyp, kyzp, nzhd
         real, intent(in) :: ci
         real, intent(inout) :: wm
         complex, dimension(3,nzv,kxyp,kyzp), intent(in) :: cu
         complex, dimension(3,nzv,kxyp,kyzp), intent(inout) :: bxyz
         complex, dimension(nzhd,kxyp,kyzp), intent(in) :: ffc
         end subroutine
      end interface
!
      interface
         subroutine MPPBADDEXT32(bxyz,nyzp,omx,omy,omz,nx,nxe,nypmx,    &
     &nzpmx,idds)
         implicit none
         integer, intent(in) :: nx, nxe, nypmx, nzpmx, idds
         real, intent(in) :: omx, omy, omz
         real, dimension(3,nxe,nypmx,nzpmx), intent(inout) :: bxyz
         integer, dimension(idds), intent(in) :: nyzp
         end subroutine
      end interface
!
      interface
         subroutine MPPDCUPERP32(dcu,amu,nx,ny,nz,kstrt,nvpy,nvpz,nzv,  &
     &kxyp,kyzp)
         implicit none
         integer, intent(in) :: nx, ny, nz, kstrt, nvpy, nvpz
         integer, intent(in) :: nzv, kxyp, kyzp
         complex, dimension(3,nzv,kxyp,kyzp), intent(inout) :: dcu
         complex, dimension(6,nzv,kxyp,kyzp), intent(in) :: amu
         end subroutine
      end interface
!
      interface
         subroutine MPPADCUPERP32(dcu,amu,nx,ny,nz,kstrt,nvpy,nvpz,nzv, &
     &kxyp,kyzp)
         implicit none
         integer, intent(in) :: nx, ny, nz, kstrt, nvpy, nvpz
         integer, intent(in) :: nzv, kxyp, kyzp
         complex, dimension(3,nzv,kxyp,kyzp), intent(inout) :: dcu
         complex, dimension(6,nzv,kxyp,kyzp), intent(in) :: amu
         end subroutine
      end interface
!
      interface
         subroutine MPPEPOISP332(dcu,exyz,isign,ffe,ax,ay,az,affp,wp0,ci&
     &,wf,nx,ny,nz,kstrt,nvpy,nvpz,nzv,kxyp,kyzp,nzhd)
         implicit none
         integer, intent(in) :: isign, nx, ny, nz, kstrt, nvpy, nvpz
         integer, intent(in) :: nzv, kxyp, kyzp, nzhd
         real, intent(in) :: ax, ay, az, affp, wp0, ci
         real, intent(inout) :: wf
         complex, dimension(3,nzv,kxyp,kyzp), intent(in) :: dcu
         complex, dimension(3,nzv,kxyp,kyzp), intent(inout) :: exyz
         complex, dimension(nzhd,kxyp,kyzp), intent(inout) :: ffe
         end subroutine
      end interface
!
      interface
         subroutine MPPADDVRFIELD32(a,b,c,ndim,nxe,nypmx,nzpmx)
         implicit none
         integer, intent(in) :: ndim, nxe, nypmx, nzpmx
         real, dimension(ndim,nxe,nypmx,nzpmx), intent(inout) :: a
         real, dimension(ndim,nxe,nypmx,nzpmx), intent(in) :: b, c
         end subroutine
      end interface
!
      interface
         subroutine WPFFT32RINIT(mixup,sct,indx,indy,indz,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: indx, indy, indz, nxhyzd, nxyzhd
         integer, dimension(nxhyzd), intent(inout) :: mixup
         complex, dimension(nxyzhd), intent(inout) :: sct
         end subroutine
      end interface
!
      interface
         subroutine WPPFFT32RM(f,g,h,bs,br,isign,ntpose,mixup,sct,ttp,  &
     &indx,indy,indz,kstrt,nvpy,nvpz,nxvh,nyv,nzv,kxyp,kyp,kyzp,kzp,    &
     &kxypd,kypd,kyzpd,kzpd,kzyp,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, ntpose, indx, indy, indz, kstrt
         integer, intent(in) :: nvpy, nvpz, nxvh, nyv, nzv, kxyp, kyp
         integer, intent(in) :: kyzp, kzp, kxypd, kypd, kyzpd, kzpd
         integer, intent(in) :: kzyp, nxhyzd, nxyzhd
         real, intent(inout) :: ttp
         real, dimension(2*nxvh,kypd,kzpd), intent(inout) :: f
         complex, dimension(nyv,kxypd,kzpd), intent(inout) :: g
         complex, dimension(nzv,kxypd,kyzpd), intent(inout) :: h
         complex, dimension(kxyp*kzyp,kzp), intent(inout) :: bs, br
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine WPPFFT32RM3(f,g,h,bs,br,isign,ntpose,mixup,sct,ttp, &
     &indx,indy,indz,kstrt,nvpy,nvpz,nxvh,nyv,nzv,kxyp,kyp,kyzp,kzp,    &
     &kxypd,kypd,kyzpd,kzpd,kzyp,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, ntpose, indx, indy, indz, kstrt
         integer, intent(in) :: nvpy, nvpz, nxvh, nyv, nzv, kxyp, kyp
         integer, intent(in) :: kyzp, kzp, kxypd, kypd, kyzpd, kzpd
         integer, intent(in) :: kzyp, nxhyzd, nxyzhd
         real, intent(inout) :: ttp
         real, dimension(3,2*nxvh,kypd,kzpd), intent(inout) :: f
         complex, dimension(3,nyv,kxypd,kzpd), intent(inout) :: g
         complex, dimension(3,nzv,kxypd,kyzpd), intent(inout) :: h
         complex, dimension(3,kxyp*kzyp,kzp), intent(inout) :: bs, br
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine WPPFFT32RMN(f,g,h,bs,br,ss,isign,ntpose,mixup,sct,  &
     &ttp,indx,indy,indz,kstrt,nvpy,nvpz,nxvh,nyv,nzv,kxyp,kyp,kyzp,kzp,&
     &kxypd,kypd,kyzpd,kzpd,kzyp,ndim,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, ntpose, indx, indy, indz, kstrt
         integer, intent(in) :: nvpy, nvpz, nxvh, nyv, nzv, kxyp, kyp
         integer, intent(in) :: kyzp, kzp, kxypd, kypd, kyzpd, kzpd
         integer, intent(in) :: kzyp, ndim, nxhyzd, nxyzhd
         real, intent(inout) :: ttp
         real, dimension(ndim,2*nxvh,kypd,kzpd), intent(inout) :: f
         complex, dimension(ndim,nyv,kxypd,kzpd), intent(inout) :: g
         complex, dimension(ndim,nzv,kxypd,kyzpd), intent(inout) :: h
         complex, dimension(ndim,kxyp*kzyp,kzp), intent(inout) :: bs, br
         complex, dimension(ndim,nxvh,kzpd) ::  ss
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine PPFFT32RMXX(f,isign,mixup,sct,indx,indy,indz,kstrt, &
     &nvp,kypi,kypp,nxvh,kzpp,kypd,kzpd,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, indz, kstrt, nvp
         integer, intent(in) :: kypi, kypp, nxvh, kzpp, kypd, kzpd
         integer, intent(in) :: nxhyzd, nxyzhd
         real, dimension(2*nxvh,kypd,kzpd), intent(inout) :: f
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine PPFFT32RMXY(g,isign,mixup,sct,indx,indy,indz,kstrt, &
     &nvpy,nvpz,kxypi,kxypp,nyv,kzpp,kxypd,kzpd,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, indz, kstrt, nvpy
         integer, intent(in) :: nvpz, kxypi, kxypp, nyv, kzpp, kxypd
         integer, intent(in) :: kzpd, nxhyzd, nxyzhd
         complex, dimension(nyv,kxypd,kzpd), intent(inout) :: g
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine PPFFT32RMXZ(h,isign,mixup,sct,indx,indy,indz,kstrt, &
     &nvpy,nvpz,kxypi,kxypp,nzv,kyzp,kxypd,kyzpd,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, indz, kstrt, nvpy
         integer, intent(in) :: nvpz, kxypi, kxypp, nzv, kyzp, kxypd
         integer, intent(in) :: kyzpd, nxhyzd, nxyzhd
         complex, dimension(nzv,kxypd,kyzpd), intent(inout) :: h
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine PPFFT32RM3XX(f,isign,mixup,sct,indx,indy,indz,kstrt,&
     &nvp,kypi,kypp,nxvh,kzpp,kypd,kzpd,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, indz, kstrt, nvp
         integer, intent(in) :: kypi, kypp, nxvh, kzpp, kypd, kzpd
         integer, intent(in) :: nxhyzd, nxyzhd
         real, dimension(3,2*nxvh,kypd,kzpd), intent(inout) :: f
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine PPFFT32RM3XY(g,isign,mixup,sct,indx,indy,indz,kstrt,&
     &nvpy,nvpz,kxypi,kxypp,nyv,kzpp,kxypd,kzpd,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, indz, kstrt, nvpy
         integer, intent(in) :: nvpz, kxypi, kxypp, nyv, kzpp, kxypd
         integer, intent(in) :: kzpd, nxhyzd, nxyzhd
         complex, dimension(3,nyv,kxypd,kzpd), intent(inout) :: g
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine PPFFT32RM3XZ(h,isign,mixup,sct,indx,indy,indz,kstrt,&
     &nvpy,nvpz,kxypi,kxypp,nzv,kyzp,kxypd,kyzpd,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, indz, kstrt, nvpy
         integer, intent(in) :: nvpz, kxypi, kxypp, nzv, kyzp, kxypd
         integer, intent(in) :: kyzpd, nxhyzd, nxyzhd
         complex, dimension(3,nzv,kxypd,kyzpd), intent(inout) :: h
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine PPFFT32RMNXX(f,ss,isign,mixup,sct,indx,indy,indz,   &
     &kstrt,nvp,kypi,kypp,nxvh,kzpp,kypd,kzpd,ndim,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, indz, kstrt, nvp
         integer, intent(in) :: kypi, kypp, nxvh, kzpp, kypd, kzpd
         integer, intent(in) :: ndim, nxhyzd, nxyzhd
         real, dimension(ndim,2*nxvh,kypd,kzpd), intent(inout) :: f
         complex, dimension(ndim,nxvh,kzpd) :: ss
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine PPFFT32RMNXY(g,isign,mixup,sct,indx,indy,indz,kstrt,&
     &nvpy,nvpz,kxypi,kxypp,nyv,kzpp,kxypd,kzpd,ndim,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, indz, kstrt, nvpy
         integer, intent(in) :: nvpz, kxypi, kxypp, nyv, kzpp, kxypd
         integer, intent(in) :: kzpd, ndim, nxhyzd, nxyzhd
         complex, dimension(ndim,nyv,kxypd,kzpd), intent(inout) :: g
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine PPFFT32RMNXZ(h,isign,mixup,sct,indx,indy,indz,kstrt,&
     &nvpy,nvpz,kxypi,kxypp,nzv,kyzp,kxypd,kyzpd,ndim,nxhyzd,nxyzhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, indz, kstrt, nvpy
         integer, intent(in) :: nvpz, kxypi, kxypp, nzv, kyzp, kxypd
         integer, intent(in) :: kyzpd, ndim, nxhyzd, nxyzhd
         complex, dimension(ndim,nzv,kxypd,kyzpd), intent(inout) :: h
         integer, dimension(nxhyzd), intent(in) :: mixup
         complex, dimension(nxyzhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine MPPSWAPC32N(f,s,isign,nxh,kypi,kypt,nxvh,kzpp,kypd, &
     &kzpd,ndim)
         implicit none 
         integer, intent(in) :: isign, nxh, kypi, kypt, nxvh, kzpp
         integer, intent(in) :: kypd, kzpd, ndim
         real, dimension(ndim,2*nxvh,kypd,kzpd), intent(inout) :: f
         complex, dimension(ndim*nxvh,kzpd), intent(inout) :: s
         end subroutine
      end interface
!
      interface
         function ranorm()
         implicit none
         double precision :: ranorm
         end function
      end interface
!
      end module