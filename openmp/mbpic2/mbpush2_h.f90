!-----------------------------------------------------------------------
! Interface file for mbpush2.f
      module mbpush2_h
      implicit none
!
      interface
         subroutine DISTR2H(part,vtx,vty,vtz,vdx,vdy,vdz,npx,npy,idimp, &
     &nop,nx,ny,ipbc)
         implicit none
         integer, intent(in) :: npx, npy, idimp, nop, nx, ny, ipbc
         real, intent(in) :: vtx, vty, vtz, vdx, vdy, vdz
         real, dimension(idimp,nop), intent(inout) :: part
         end subroutine
      end interface
!
      interface
         subroutine DBLKP2L(part,kpic,nppmx,idimp,nop,mx,my,mx1,mxy1,irc&
     &)
         implicit none
         integer, intent(in) :: idimp, nop, mx, my, mx1, mxy1
         integer, intent(inout) :: nppmx, irc
         real, dimension(idimp,nop), intent(in) :: part
         integer, dimension(mxy1), intent(inout) :: kpic
         end subroutine
      end interface
!
      interface
         subroutine PPMOVIN2L(part,ppart,kpic,nppmx,idimp,nop,mx,my,mx1,&
     &mxy1,irc)
         implicit none
         integer, intent(in) :: nppmx, idimp, nop, mx, my, mx1, mxy1
         integer, intent(inout) :: irc
         real, dimension(idimp,nop), intent(in) :: part
         real, dimension(idimp,nppmx,mxy1), intent(inout) :: ppart
         integer, dimension(mxy1), intent(inout) :: kpic
         end subroutine
      end interface
!
      interface
         subroutine PPCHECK2L(ppart,kpic,idimp,nppmx,nx,ny,mx,my,mx1,my1&
     &,irc)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, ny, mx, my, mx1, my1
         integer, intent(inout) :: irc
         real, dimension(idimp,nppmx,mx1*my1), intent(in) :: ppart
         integer, dimension(mx1*my1), intent(in) :: kpic
         end subroutine
      end interface
!
      interface
         subroutine GBPPUSH23L(ppart,fxy,bxy,kpic,qbm,dt,dtc,ek,idimp,  &
     &nppmx,nx,ny,mx,my,nxv,nyv,mx1,mxy1,ipbc)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, ny, mx, my, nxv, nyv
         integer, intent(in) :: mx1, mxy1, ipbc
         real, intent(in) :: qbm, dt, dtc
         real, intent(inout) :: ek
         real, dimension(idimp,nppmx,mxy1), intent(inout) :: ppart
         real, dimension(3,nxv,nyv), intent(in) :: fxy, bxy
         integer, dimension(mxy1), intent(in) :: kpic
         end subroutine
      end interface
!
      interface
         subroutine GBPPUSHF23L(ppart,fxy,bxy,kpic,ncl,ihole,qbm,dt,dtc,&
     &ek,idimp,nppmx,nx,ny,mx,my,nxv,nyv,mx1,mxy1,ntmax,irc)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, ny, mx, my, nxv, nyv
         integer, intent(in) :: mx1, mxy1, ntmax
         integer, intent(inout) :: irc
         real, intent(in) :: qbm, dt, dtc
         real, intent(inout) :: ek
         real, dimension(idimp,nppmx,mxy1), intent(inout) :: ppart
         real, dimension(3,nxv,nyv), intent(in) :: fxy, bxy
         integer, dimension(mxy1), intent(in) :: kpic
         integer, dimension(8,mxy1), intent(inout) :: ncl
         integer, dimension(2,ntmax+1,mxy1), intent(inout) :: ihole
         end subroutine
      end interface
!
      interface
         subroutine GRBPPUSH23L(ppart,fxy,bxy,kpic,qbm,dt,dtc,ci,ek,    &
     &idimp, nppmx,nx,ny,mx,my,nxv,nyv,mx1,mxy1,ipbc)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, ny, mx, my, nxv, nyv
         integer, intent(in) :: mx1, mxy1, ipbc
         real, intent(in) :: qbm, dt, dtc, ci
         real, intent(inout) :: ek
         real, dimension(idimp,nppmx,mxy1), intent(inout)  :: ppart
         real, dimension(3,nxv,nyv), intent(in) :: fxy, bxy
         integer, dimension(mxy1), intent(in) :: kpic
         end subroutine
      end interface
!
      interface
         subroutine GRBPPUSHF23L(ppart,fxy,bxy,kpic,ncl,ihole,qbm,dt,dtc&
     &,ci,ek,idimp,nppmx,nx,ny,mx,my,nxv,nyv,mx1,mxy1,ntmax,irc)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, ny, mx, my, nxv, nyv
         integer, intent(in) :: mx1, mxy1, ntmax
         integer, intent(inout) :: irc
         real, intent(in) :: qbm, dt, dtc, ci
         real, intent(inout) :: ek
         real, dimension(idimp,nppmx,mxy1), intent(inout) :: ppart
         real, dimension(3,nxv,nyv), intent(in) :: fxy, bxy
         integer, dimension(mxy1), intent(in) :: kpic
         integer, dimension(8,mxy1), intent(inout) :: ncl
         integer, dimension(2,ntmax+1,mxy1), intent(inout) :: ihole
         end subroutine
      end interface
!
      interface
         subroutine GPPOST2L(ppart,q,kpic,qm,nppmx,idimp,mx,my,nxv,nyv, &
     &mx1,mxy1)
         implicit none
         integer, intent(in) :: nppmx, idimp, mx, my, nxv, nyv
         integer, intent(in) :: mx1, mxy1
         real, intent(in) :: qm
         real, dimension(idimp,nppmx,mxy1), intent(in) :: ppart
         real, dimension(nxv,nyv), intent(inout) :: q
         integer, dimension(mxy1), intent(in) :: kpic
         end subroutine
      end interface
!
      interface
         subroutine GJPPOST2L(ppart,cu,kpic,qm,dt,nppmx,idimp,nx,ny,mx, &
     &my, nxv,nyv,mx1,mxy1,ipbc)
         implicit none
         integer, intent(in) :: nppmx, idimp, nx, ny, mx, my, nxv, nyv
         integer, intent(in) :: mx1, mxy1, ipbc
         real, intent(in) :: qm, dt
         real, dimension(idimp,nppmx,mxy1), intent(inout) :: ppart
         real, dimension(3,nxv,nyv), intent(inout) :: cu
         integer, dimension(mxy1), intent(in) :: kpic
         end subroutine
      end interface
!
      interface
         subroutine GJPPOSTF2L(ppart,cu,kpic,ncl,ihole,qm,dt,nppmx,idimp&
     &,nx,ny,mx,my,nxv,nyv,mx1,mxy1,ntmax,irc)
         implicit none
         integer, intent(in) :: nppmx, idimp, nx, ny, mx, my, nxv, nyv
         integer, intent(in) :: mx1, mxy1, ntmax
         integer, intent(inout) :: irc
         real, intent(in) :: qm, dt
         real, dimension(idimp,nppmx,mxy1), intent(inout) :: ppart
         real, dimension(3,nxv,nyv), intent(inout) :: cu
         integer, dimension(mxy1), intent(in) :: kpic
         integer, dimension(8,mxy1), intent(inout) :: ncl
         integer, dimension(2,ntmax+1,mxy1), intent(inout) :: ihole
         end subroutine
      end interface
!
      interface
         subroutine GRJPPOST2L(ppart,cu,kpic,qm,dt,ci,nppmx,idimp,nx,ny,&
     &mx,my,nxv,nyv,mx1,mxy1,ipbc)
         implicit none
         integer, intent(in) :: nppmx, idimp, nx, ny, mx, my, nxv, nyv
         integer, intent(in) :: mx1, mxy1, ipbc
         real, intent(in) :: qm, dt, ci
         real, dimension(idimp,nppmx,mxy1), intent(inout) :: ppart
         real, dimension(3,nxv,nyv), intent(inout) :: cu
         integer, dimension(mxy1), intent(in) :: kpic
         end subroutine
      end interface
!
      interface
         subroutine GRJPPOSTF2L(ppart,cu,kpic,ncl,ihole,qm,dt,ci,nppmx, &
     &idimp,nx,ny,mx,my,nxv,nyv,mx1,mxy1,ntmax,irc)
         implicit none
         integer, intent(in) :: nppmx, idimp, nx, ny, mx, my, nxv, nyv
         integer, intent(in) :: mx1, mxy1, ntmax
         integer, intent(inout) :: irc
         real, intent(in) :: qm, dt, ci
         real, dimension(idimp,nppmx,mxy1), intent(inout) :: ppart
         real, dimension(3,nxv,nyv), intent(inout) :: cu
         integer, dimension(mxy1), intent(in) :: kpic
         integer, dimension(8,mxy1), intent(inout) :: ncl
         integer, dimension(2,ntmax+1,mxy1), intent(inout) :: ihole
         end subroutine
      end interface
!
      interface
         subroutine PPORDER2L(ppart,ppbuff,kpic,ncl,ihole,idimp,nppmx,nx&
     &,ny,mx,my,mx1,my1,npbmx,ntmax,irc)
         implicit none
         integer, intent(in) :: idimp, nppmx, nx, ny, mx, my, mx1, my1
         integer, intent(in) :: npbmx, ntmax
         integer, intent(inout) :: irc
         real, dimension(idimp,nppmx,mx1*my1), intent(inout) :: ppart
         real, dimension(idimp,npbmx,mx1*my1), intent(inout) :: ppbuff
         integer, dimension(mx1*my1), intent(inout) :: kpic
         integer, dimension(8,mx1*my1), intent(inout) :: ncl
         integer, dimension(2,ntmax+1,mx1*my1), intent(inout) :: ihole
         end subroutine
      end interface
!
      interface
         subroutine PPORDERF2L(ppart,ppbuff,kpic,ncl,ihole,idimp,nppmx, &
     &mx1,my1,npbmx,ntmax,irc)
         implicit none
         integer, intent(in) :: idimp, nppmx, mx1, my1, npbmx, ntmax
         integer, intent(inout) :: irc
         real, dimension(idimp,nppmx,mx1*my1), intent(inout) :: ppart
         real, dimension(idimp,npbmx,mx1*my1), intent(inout) :: ppbuff
         integer, dimension(mx1*my1), intent(inout) :: kpic
         integer, dimension(8,mx1*my1), intent(inout) :: ncl
         integer, dimension(2,ntmax+1,mx1*my1), intent(in) :: ihole
         end subroutine
      end interface
!
      interface
         subroutine BGUARD2L(bxy,nx,ny,nxe,nye)
         implicit none
         integer, intent(in) :: nx, ny, nxe, nye
         real, dimension(3,nxe,nye), intent(inout) :: bxy
         end subroutine
      end interface
!
      interface
         subroutine ACGUARD2L(cu,nx,ny,nxe,nye)
         implicit none
         integer, intent(in) :: nx, ny, nxe, nye
         real, dimension(3,nxe,nye), intent(inout) :: cu
         end subroutine
      end interface
!
      interface
         subroutine AGUARD2L(q,nx,ny,nxe,nye)
         implicit none
         integer, intent(in) :: nx, ny, nxe, nye
         real, dimension(nxe,nye), intent(inout) :: q
         end subroutine
      end interface
!
      interface
         subroutine MPOIS23(q,fxy,isign,ffc,ax,ay,affp,we,nx,ny,nxvh,nyv&
     &,nxhd,nyhd)
         implicit none
         integer, intent(in) :: isign, nx, ny, nxvh, nyv, nxhd, nyhd
         real, intent(in) :: ax, ay, affp
         real, intent(inout) :: we
         real, dimension(2*nxvh,nyv), intent(in) :: q
         real, dimension(3,2*nxvh,nyv), intent(inout) :: fxy
         complex, dimension(nxhd,nyhd), intent(inout) :: ffc
         end subroutine
      end interface
!
      interface
         subroutine MCUPERP2(cu,nx,ny,nxvh,nyv)
         implicit none
         integer, intent(in) :: nx, ny, nxvh, nyv
         real, dimension(3,2*nxvh,nyv), intent(inout) :: cu
         end subroutine
      end interface
!
      interface
         subroutine MIBPOIS23(cu,bxy,ffc,ci,wm,nx,ny,nxvh,nyv,nxhd,nyhd)
         implicit none
         integer, intent(in) :: nx, ny, nxvh, nyv, nxhd, nyhd
         real, intent(in) :: ci
         real, intent(inout) :: wm
         real, dimension(3,2*nxvh,nyv), intent(in) :: cu
         complex, dimension(3,nxvh,nyv), intent(inout) :: bxy
         complex, dimension(nxhd,nyhd), intent(in) :: ffc
         end subroutine
      end interface
!
      interface
         subroutine MMAXWEL2(exy,bxy,cu,ffc,ci,dt,wf,wm,nx,ny,nxvh,nyv, &
     &nxhd,nyhd)
         implicit none
         integer, intent(in) :: nx, ny, nxvh, nyv, nxhd, nyhd
         real, intent(in) :: ci, dt
         real, intent(inout) :: wf, wm
         complex, dimension(3,nxvh,nyv), intent(inout) :: exy, bxy
         real, dimension(3,2*nxvh,nyv), intent(in) :: cu
         complex, dimension(nxhd,nyhd), intent(in) :: ffc
         end subroutine
      end interface
!
      interface
         subroutine MEMFIELD2(fxy,exy,ffc,isign,nx,ny,nxvh,nyv,nxhd,nyhd&
     &)
         implicit none
         integer, intent(in) :: isign, nx, ny, nxvh, nyv, nxhd, nyhd
         real, dimension(3,2*nxvh,nyv), intent(inout) :: fxy
         complex, dimension(3,nxvh,nyv), intent(in) :: exy
         complex, dimension(nxhd,nyhd), intent(in) :: ffc
         end subroutine
      end interface
!
      interface
         subroutine WFFT2RINIT(mixup,sct,indx,indy,nxhyd,nxyhd)
         implicit none
         integer, intent(in) :: indx, indy, nxhyd, nxyhd
         integer, dimension(nxhyd), intent(inout) :: mixup
         complex, dimension(nxyhd), intent(inout) :: sct
         end subroutine
      end interface
!
      interface
         subroutine WFFT2RMX(f,isign,mixup,sct,indx,indy,nxhd,nyd,nxhyd,&
     &nxyhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, nxhd, nyd
         integer, intent(in) :: nxhyd, nxyhd
         real, dimension(2*nxhd,nyd), intent(inout) :: f
         integer, dimension(nxhyd), intent(in) :: mixup
         complex, dimension(nxyhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine WFFT2RM3(f,isign,mixup,sct,indx,indy,nxhd,nyd,nxhyd,&
     &nxyhd)
         implicit none
         integer , intent(in):: isign, indx, indy, nxhd, nyd
         integer, intent(in) :: nxhyd, nxyhd
         real, dimension(3,2*nxhd,nyd), intent(inout) :: f
         integer, dimension(nxhyd), intent(in) :: mixup
         complex, dimension(nxyhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine FFT2RMXX(f,isign,mixup,sct,indx,indy,nyi,nyp,nxhd,  &
     &nyd,nxhyd,nxyhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, nyi, nyp, nxhd, nyd
         integer, intent(in) :: nxhyd, nxyhd
         real, dimension(2*nxhd,nyd), intent(inout) :: f
         integer, dimension(nxhyd), intent(in) :: mixup
         complex, dimension(nxyhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine FFT2RMXY(f,isign,mixup,sct,indx,indy,nxi,nxp,nxhd,  &
     &nyd,nxhyd,nxyhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, nxi, nxp, nxhd, nyd
         integer, intent(in) :: nxhyd, nxyhd
         real, dimension(2*nxhd,nyd), intent(inout) :: f
         integer, dimension(nxhyd), intent(in) :: mixup
         complex, dimension(nxyhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine FFT2RM3X(f,isign,mixup,sct,indx,indy,nyi,nyp,nxhd,  &
     &nyd,nxhyd,nxyhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, nyi, nyp, nxhd, nyd
         integer, intent(in) :: nxhyd, nxyhd
         real, dimension(3,2*nxhd,nyd), intent(inout) :: f
         integer, dimension(nxhyd), intent(in) :: mixup
         complex, dimension(nxyhd), intent(in) :: sct
         end subroutine
      end interface
!
      interface
         subroutine FFT2RM3Y(f,isign,mixup,sct,indx,indy,nxi,nxp,nxhd,  &
     &nyd,nxhyd,nxyhd)
         implicit none
         integer, intent(in) :: isign, indx, indy, nxi, nxp, nxhd, nyd
         integer, intent(in) :: nxhyd, nxyhd
         real, dimension(3,2*nxhd,nyd), intent(inout) :: f
         integer, dimension(nxhyd), intent(in) :: mixup
         complex, dimension(nxyhd), intent(in) :: sct
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
