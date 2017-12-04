c Fortran Library for Skeleton 3D Electromagnetic OpenMP PIC Code
c written by Viktor K. Decyk, UCLA
c-----------------------------------------------------------------------
      subroutine DISTR3(part,vtx,vty,vtz,vdx,vdy,vdz,npx,npy,npz,idimp, 
     1nop,nx,ny,nz,ipbc)
c for 3d code, this subroutine calculates initial particle co-ordinates
c and velocities with uniform density and maxwellian velocity with drift
c part(1,n) = position x of particle n
c part(2,n) = position y of particle n
c part(3,n) = position z of particle n
c part(4,n) = velocity vx of particle n
c part(5,n) = velocity vy of particle n
c part(6,n) = velocity vz of particle n
c vtx/vty/vtz = thermal velocity of electrons in x/y/z direction
c vdx/vdy/vdz = drift velocity of beam electrons in x/y/z direction
c npx/npy/npz = initial number of particles distributed in x/y/z
c direction
c idimp = size of phase space = 6
c nop = number of particles
c nx/ny/nz = system length in x/y/z direction
c ipbc = particle boundary condition = (0,1,2,3) =
c (none,3d periodic,3d reflecting,mixed 2d reflecting/1d periodic)
c ranorm = gaussian random number with zero mean and unit variance
      implicit none
      integer npx, npy, npz, idimp, nop, nx, ny, nz, ipbc
      real vtx, vty, vtz, vdx, vdy, vdz
      real part
      dimension part(idimp,nop)
c local data
      integer j, k, l, k1, l1, npxy, npxyz
      real edgelx, edgely, edgelz, at1, at2, at3, at4, at5
      real sum1, sum2, sum3
      double precision dsum1, dsum2, dsum3
      double precision ranorm
      npxy = npx*npy
      npxyz = npxy*npz
c set boundary values
      edgelx = 0.0
      edgely = 0.0
      edgelz = 0.0
      at1 = real(nx)/real(npx)
      at2 = real(ny)/real(npy)
      at3 = real(nz)/real(npz)
      if (ipbc.eq.2) then
         edgelx = 1.0
         edgely = 1.0
         edgelz = 1.0
         at1 = real(nx-2)/real(npx)
         at2 = real(ny-2)/real(npy)
         at3 = real(nz-2)/real(npz)
      else if (ipbc.eq.3) then
         edgelx = 1.0
         edgely = 1.0
         edgelz = 0.0
         at1 = real(nx-2)/real(npx)
         at2 = real(ny-2)/real(npy)
      endif
c uniform density profile
      do 30 l = 1, npz
      l1 = npxy*(l - 1)
      at5 = edgelz + at3*(real(l) - .5)
      do 20 k = 1, npy
      k1 = npx*(k - 1) + l1
      at4 = edgely + at2*(real(k) - .5)
      do 10 j = 1, npx
      part(1,j+k1) = edgelx + at1*(real(j) - .5)
      part(2,j+k1) = at4
      part(3,j+k1) = at5
   10 continue
   20 continue
   30 continue
c maxwellian velocity distribution
      do 40 j = 1, npxyz
      part(4,j) = vtx*ranorm()
      part(5,j) = vty*ranorm()
      part(6,j) = vtz*ranorm()
   40 continue
c add correct drift
      dsum1 = 0.0d0
      dsum2 = 0.0d0
      dsum3 = 0.0d0
      do 50 j = 1, npxyz
      dsum1 = dsum1 + part(4,j)
      dsum2 = dsum2 + part(5,j)
      dsum3 = dsum3 + part(6,j)
   50 continue
      sum1 = dsum1
      sum2 = dsum2
      sum3 = dsum3
      at1 = 1.0/real(npxyz)
      sum1 = at1*sum1 - vdx
      sum2 = at1*sum2 - vdy
      sum3 = at1*sum3 - vdz
      do 60 j = 1, npxyz
      part(4,j) = part(4,j) - sum1
      part(5,j) = part(5,j) - sum2
      part(6,j) = part(6,j) - sum3
   60 continue
      return
      end
c-----------------------------------------------------------------------
      subroutine DBLKP3L(part,kpic,nppmx,idimp,nop,mx,my,mz,mx1,my1,    
     1mxyz1,irc)
c this subroutine finds the maximum number of particles in each tile of
c mx, my, mz to calculate size of segmented particle array ppart
c linear interpolation
c input: all except kpic, nppmx, output: kpic, nppmx
c part = input particle array
c part(1,n) = position x of particle n
c part(2,n) = position y of particle n
c part(3,n) = position z of particle n
c kpic = output number of particles per tile
c nppmx = return maximum number of particles in tile
c idimp = size of phase space = 6
c nop = number of particles
c mx/my/mz = number of grids in sorting cell in x, y and z
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mxyz1 = mx1*my1*mz1,
c where mz1 = (system length in z direction - 1)/mz + 1
c irc = maximum overflow, returned only if error occurs, when irc > 0
      implicit none
      integer kpic, nppmx, idimp, nop, mx, my, mz, mx1, my1, mxyz1, irc
      real part
      dimension part(idimp,nop), kpic(mxyz1)
c local datal, 
      integer j, k, n, m, l, mxy1, isum, ist, npx, ierr
      ierr = 0
      mxy1 = mx1*my1
c clear counter array
      do 10 k = 1, mxyz1
      kpic(k) = 0
   10 continue
c find how many particles in each tile
      do 20 j = 1, nop
      n = part(1,j)
      n = n/mx + 1
      m = part(2,j)
      m = m/my
      l = part(3,j)
      l = l/mz
      m = n + mx1*m + mxy1*l
      if (m.le.mxyz1) then
         kpic(m) = kpic(m) + 1
      else
         ierr = max(ierr,m-mxyz1)
      endif
   20 continue
c find maximum
      isum = 0
      npx = 0
      do 30 k = 1, mxyz1
      ist = kpic(k)
      npx = max(npx,ist)
      isum = isum + ist
   30 continue
      nppmx = npx
c check for errors
      if (ierr.gt.0) then
         irc = ierr
      else if (isum.ne.nop) then
         irc = -1
      endif
      return
      end
c-----------------------------------------------------------------------
      subroutine PPMOVIN3L(part,ppart,kpic,nppmx,idimp,nop,mx,my,mz,mx1,
     1my1,mxyz1,irc)
c this subroutine sorts particles by x,y,z grid in tiles of mx, my, mz
c and copies to segmented array ppart
c linear interpolation
c input: all except ppart, kpic, output: ppart, kpic
c part/ppart = input/output particle arrays
c part(1,n) = position x of particle n
c part(2,n) = position y of particle n
c part(3,n) = position z of particle n
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c ppart(4,n,m) = velocity vx of particle n in tile m
c ppart(5,n,m) = velocity vy of particle n in tile m
c ppart(6,n,m) = velocity vz of particle n in tile m
c kpic = output number of particles per tile
c nppmx = rmaximum number of particles in tile
c idimp = size of phase space = 6
c nop = number of particles
c mx/my/mz = number of grids in sorting cell in x, y and z
c mx1 = (system length in x direction - 1)/mx + 1
c mxy1 = mx1*my1, where my1 = (system length in y direction - 1)/my + 1c my1 = (system length in y direction - 1)/my + 1
c mxyz1 = mx1*my1*mz1,
c where mz1 = (system length in z direction - 1)/mz + 1
c irc = maximum overflow, returned only if error occurs, when irc > 0
      implicit none
      integer kpic, nppmx, idimp, nop, mx, my, mz, mx1, my1, mxyz1, irc
      real part, ppart
      dimension part(idimp,nop), ppart(idimp,nppmx,mxyz1)
      dimension kpic(mxyz1)
c local data
      integer i, j, k, n, m, l, mxy1, ip, ierr
      ierr = 0
      mxy1 = mx1*my1
c clear counter array
      do 10 k = 1, mxyz1
      kpic(k) = 0
   10 continue
c find addresses of particles at each tile and reorder particles
      do 30 j = 1, nop
      n = part(1,j)
      n = n/mx + 1
      m = part(2,j)
      m = m/my
      l = part(3,j)
      l = l/mz
      m = n + mx1*m + mxy1*l
      ip = kpic(m) + 1
      if (ip.le.nppmx) then
         do 20 i = 1, idimp
         ppart(i,ip,m) = part(i,j)
   20    continue
      else
         ierr = max(ierr,ip-nppmx)
      endif
      kpic(m) = ip
   30 continue
      if (ierr.gt.0) irc = ierr
      return
      end
c-----------------------------------------------------------------------
      subroutine PPCHECK3L(ppart,kpic,idimp,nppmx,nx,ny,nz,mx,my,mz,mx1,
     1my1,mz1,irc)
c this subroutine performs a sanity check to make sure particles sorted
c by x,y,z grid in tiles of mx, my, mz, are all within bounds.
c tiles are assumed to be arranged in 3D linear memory
c input: all except irc
c output: irc
c ppart(1,n,l) = position x of particle n in tile l
c ppart(2,n,l) = position y of particle n in tile l
c ppart(3,n,l) = position a of particle n in tile l
c kpic(l) = number of reordered output particles in tile l
c idimp = size of phase space = 6
c nppmx = maximum number of particles in tile
c nx/ny/nz = number of grids in sorting cell in x/y/z
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mz1 = (system length in z direction - 1)/mz + 1
c irc = particle error, returned only if error occurs, when irc > 0
      implicit none
      integer idimp, nppmx, nx, ny, nz, mx, my, mz, mx1, my1, mz1, irc
      real ppart
      integer kpic
      dimension ppart(idimp,nppmx,mx1*my1*mz1)
      dimension kpic(mx1*my1*mz1)
c local data
      integer mxy1, mxyz1, noff, moff, loff, npp, j, k, l, nn, mm, ll
      integer ist
      real edgelx, edgely, edgelz, edgerx, edgery, edgerz, dx, dy, dz
      mxy1 = mx1*my1
      mxyz1 = mxy1*mz1
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(j,k,l,noff,moff,loff,npp,nn,mm,ll,ist,edgelx,edgely,     
!$OMP& edgelz,edgerx,edgery,edgerz,dx,dy,dz)
      do 20 l = 1, mxyz1
      loff = (l - 1)/mxy1
      k = l - mxy1*loff
      loff = mz*loff
      noff = (k - 1)/mx1
      moff = my*noff
      noff = mx*(k - mx1*noff - 1)
      npp = kpic(l)
      nn = min(mx,nx-noff)
      mm = min(my,ny-moff)
      ll = min(mz,nz-loff)
      edgelx = noff
      edgerx = noff + nn
      edgely = moff
      edgery = moff + mm
      edgelz = loff
      edgerz = loff + ll
c loop over particles in tile
      do 10 j = 1, npp
      dx = ppart(1,j,l)
      dy = ppart(2,j,l)
      dz = ppart(3,j,l)
c find particles going out of bounds
      ist = 0
      if (dx.lt.edgelx) ist = 1
      if (dx.ge.edgerx) ist = 2
      if (dy.lt.edgely) ist = ist + 3
      if (dy.ge.edgery) ist = ist + 6
      if (dz.lt.edgelz) ist = ist + 9
      if (dz.ge.edgerz) ist = ist + 18
      if (ist.gt.0) irc = l
   10 continue
   20 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      subroutine GBPPUSH3L(ppart,fxyz,bxyz,kpic,qbm,dt,dtc,ek,idimp,    
     1nppmx,nx,ny,nz,mx,my,mz,nxv,nyv,nzv,mx1,my1,mxyz1,ipbc)
c for 3d code, this subroutine updates particle co-ordinates and
c velocities using leap-frog scheme in time and first-order linear
c interpolation in space, with magnetic field.  Using the Boris Mover.
c OpenMP version using guard cells
c data read in tiles
c particles stored segmented array
c 190 flops/particle, 1 divide, 54 loads, 6 stores
c input: all, output: ppart, ek
c velocity equations used are:
c vx(t+dt/2) = rot(1)*(vx(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(2)*(vy(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(3)*(vz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fx(x(t),y(t),z(t))*dt)
c vy(t+dt/2) = rot(4)*(vx(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(5)*(vy(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(6)*(vz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fy(x(t),y(t),z(t))*dt)
c vz(t+dt/2) = rot(7)*(vx(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(8)*(vy(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(9)*(vz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fz(x(t),y(t),z(t))*dt)
c where q/m is charge/mass, and the rotation matrix is given by:
c    rot(1) = (1 - (om*dt/2)**2 + 2*(omx*dt/2)**2)/(1 + (om*dt/2)**2)
c    rot(2) = 2*(omz*dt/2 + (omx*dt/2)*(omy*dt/2))/(1 + (om*dt/2)**2)
c    rot(3) = 2*(-omy*dt/2 + (omx*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(4) = 2*(-omz*dt/2 + (omx*dt/2)*(omy*dt/2))/(1 + (om*dt/2)**2)
c    rot(5) = (1 - (om*dt/2)**2 + 2*(omy*dt/2)**2)/(1 + (om*dt/2)**2)
c    rot(6) = 2*(omx*dt/2 + (omy*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(7) = 2*(omy*dt/2 + (omx*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(8) = 2*(-omx*dt/2 + (omy*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(9) = (1 - (om*dt/2)**2 + 2*(omz*dt/2)**2)/(1 + (om*dt/2)**2)
c and om**2 = omx**2 + omy**2 + omz**2
c the rotation matrix is determined by:
c omx = (q/m)*bx(x(t),y(t),z(t)), omy = (q/m)*by(x(t),y(t),z(t)), and
c omz = (q/m)*bz(x(t),y(t),z(t)).
c position equations used are:
c x(t+dt)=x(t) + vx(t+dt/2)*dt
c y(t+dt)=y(t) + vy(t+dt/2)*dt
c z(t+dt)=z(t) + vz(t+dt/2)*dt
c fx(x(t),y(t),z(t)), fy(x(t),y(t),z(t)), and fz(x(t),y(t),z(t)),
c bx(x(t),y(t),z(t)), by(x(t),y(t),z(t)), and bz(x(t),y(t),z(t))
c are approximated by interpolation from the nearest grid points:
c fx(x,y,z) = (1-dz)*((1-dy)*((1-dx)*fx(n,m,l)+dx*fx(n+1,m,l))
c                + dy*((1-dx)*fx(n,m+1,l) + dx*fx(n+1,m+1,l)))
c           + dz*((1-dy)*((1-dx)*fx(n,m,l+1)+dx*fx(n+1,m,l+1))
c                + dy*((1-dx)*fx(n,m+1,l+1) + dx*fx(n+1,m+1,l+1)))
c where n,m,l = leftmost grid points and dx = x-n, dy = y-m, dz = z-l
c similarly for fy(x,y,z), fz(x,y,z), bx(x,y,z), by(x,y,z), bz(x,y,z)
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c ppart(4,n,m) = velocity vx of particle n in tile m
c ppart(5,n,m) = velocity vy of particle n in tile m
c ppart(6,n,m) = velocity vz of particle n in tile m
c fxyz(1,j,k,l) = x component of force/charge at grid (j,k,l)
c fxyz(2,j,k,l) = y component of force/charge at grid (j,k,l)
c fxyz(3,j,k,l) = z component of force/charge at grid (j,k,l)
c that is, convolution of electric field over particle shape
c bxyz(1,j,k,l) = x component of magnetic field at grid (j,k,l)
c bxyz(2,j,k,l) = y component of magnetic field at grid (j,k,l)
c bxyz(3,j,k,l) = z component of magnetic field at grid (j,k,l)
c that is, the convolution of magnetic field over particle shape
c kpic = number of particles per tile
c qbm = particle charge/mass ratio
c dt = time interval between successive force calculations
c dtc = time interval between successive co-ordinate calculations
c kinetic energy/mass at time t is also calculated, using
c ek = .5*sum((vx(t-dt/2) + .5*(q/m)*fx(x(t),y(t))*dt)**2 +
c      (vy(t-dt/2) + .5*(q/m)*fy(x(t),y(t))*dt)**2 + 
c      .25*(vz(t+dt/2) + vz(t-dt/2))**2)
c idimp = size of phase space = 6
c nppmx = maximum number of particles in tile
c nx/ny/nz = system length in x/y/z direction
c mx/my/mz = number of grids in sorting cell in x/y/z
c nxv = second dimension of field arrays, must be >= nx+1
c nyv = third dimension of field arrays, must be >= ny+1
c nzv = fourth dimension of field array, must be >= nz+1
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mxyz1 = mx1*my1*mz1,
c where mz1 = (system length in z direction - 1)/mz + 1
c ipbc = particle boundary condition = (0,1,2,3) =
c (none,3d periodic,3d reflecting,mixed 2d reflecting/1d periodic)
      implicit none
      integer idimp, nppmx, nx, ny, nz, mx, my, mz, nxv, nyv, nzv
      integer mx1, my1, mxyz1, ipbc
      real qbm, dt, dtc, ek
      real ppart, fxyz, bxyz
      integer kpic
      dimension ppart(idimp,nppmx,mxyz1)
      dimension fxyz(3,nxv,nyv,nzv), bxyz(3,nxv,nyv,nzv)
      dimension kpic(mxyz1)
c local data
      integer MXV, MYV, MZV
      parameter(MXV=17,MYV=17,MZV=17)
      integer mxy1, noff, moff, loff, npp
      integer i, j, k, l, nn, mm, ll
      real qtmh, edgelx, edgely, edgelz, edgerx, edgery, edgerz
      real dxp, dyp, dzp, amx, amy, amz, dx, dy, dz, ox, oy, oz, dx1
      real acx, acy, acz, omxt, omyt, omzt, omt, anorm
      real rot1, rot2, rot3, rot4, rot5, rot6, rot7, rot8, rot9
      real x, y, z
      real sfxyz, sbxyz
      dimension sfxyz(3,MXV,MYV,MZV), sbxyz(3,MXV,MYV,MZV)
c     dimension sfxyz(3,mx+1,my+1,mz+1), sbxyz(3,mx+1,my+1,mz+1)
      double precision sum1, sum2
      mxy1 = mx1*my1
      qtmh = 0.5*qbm*dt
      sum2 = 0.0d0
c set boundary values
      edgelx = 0.0
      edgely = 0.0
      edgelz = 0.0
      edgerx = real(nx)
      edgery = real(ny)
      edgerz = real(nz)
      if (ipbc.eq.2) then
         edgelx = 1.0
         edgely = 1.0
         edgelz = 1.0
         edgerx = real(nx-1)
         edgery = real(ny-1)
         edgerz = real(nz-1)
      else if (ipbc.eq.3) then
         edgelx = 1.0
         edgely = 1.0
         edgerx = real(nx-1)
         edgery = real(ny-1)
      endif
c error if local array is too small
c     if ((mx.ge.MXV).or.(my.ge.MYV).or.(mz.ge.MZV)) return
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,noff,moff,loff,npp,nn,mm,ll,x,y,z,dxp,dyp,dzp,amx
!$OMP& ,amy,amz,dx1,dx,dy,dz,ox,oy,oz,acx,acy,acz,omxt,omyt,omzt,omt,   
!$OMP& anorm,rot1,rot2,rot3,rot4,rot5,rot6,rot7,rot8,rot9,sum1,sfxyz,   
!$OMP& sbxyz)
!$OMP& REDUCTION(+:sum2)
      do 80 l = 1, mxyz1
      loff = (l - 1)/mxy1
      k = l - mxy1*loff
      loff = mz*loff
      noff = (k - 1)/mx1
      moff = my*noff
      noff = mx*(k - mx1*noff - 1)
      npp = kpic(l)
c load local fields from global array
      do 30 k = 1, min(mz,nz-loff)+1
      do 20 j = 1, min(my,ny-moff)+1
      do 10 i = 1, min(mx,nx-noff)+1
      sfxyz(1,i,j,k) = fxyz(1,i+noff,j+moff,k+loff)
      sfxyz(2,i,j,k) = fxyz(2,i+noff,j+moff,k+loff)
      sfxyz(3,i,j,k) = fxyz(3,i+noff,j+moff,k+loff)
   10 continue
   20 continue
   30 continue
      do 60 k = 1, min(mz,nz-loff)+1
      do 50 j = 1, min(my,ny-moff)+1
      do 40 i = 1, min(mx,nx-noff)+1
      sbxyz(1,i,j,k) = bxyz(1,i+noff,j+moff,k+loff)
      sbxyz(2,i,j,k) = bxyz(2,i+noff,j+moff,k+loff)
      sbxyz(3,i,j,k) = bxyz(3,i+noff,j+moff,k+loff)
   40 continue
   50 continue
   60 continue
      sum1 = 0.0d0
c loop over particles in tile
      do 70 j = 1, npp
c find interpolation weights
      x = ppart(1,j,l)
      y = ppart(2,j,l)
      z = ppart(3,j,l)
      nn = x
      mm = y
      ll = z
      dxp = x - real(nn)
      dyp = y - real(mm)
      dzp = z - real(ll)
      nn = nn - noff + 1
      mm = mm - moff + 1
      ll = ll - loff + 1
      amx = 1.0 - dxp
      amy = 1.0 - dyp
      dx1 = dxp*dyp
      dyp = amx*dyp
      amx = amx*amy
      amz = 1.0 - dzp
      amy = dxp*amy
c find electric field
      dx = amx*sfxyz(1,nn,mm,ll) + amy*sfxyz(1,nn+1,mm,ll)  
      dy = amx*sfxyz(2,nn,mm,ll) + amy*sfxyz(2,nn+1,mm,ll)  
      dz = amx*sfxyz(3,nn,mm,ll) + amy*sfxyz(3,nn+1,mm,ll)  
      dx = amz*(dx + dyp*sfxyz(1,nn,mm+1,ll)                            
     1             + dx1*sfxyz(1,nn+1,mm+1,ll))
      dy = amz*(dy + dyp*sfxyz(2,nn,mm+1,ll)                            
     1             + dx1*sfxyz(2,nn+1,mm+1,ll))
      dz = amz*(dz + dyp*sfxyz(3,nn,mm+1,ll)                            
     1             + dx1*sfxyz(3,nn+1,mm+1,ll))
      acx = amx*sfxyz(1,nn,mm,ll+1) + amy*sfxyz(1,nn+1,mm,ll+1)
      acy = amx*sfxyz(2,nn,mm,ll+1) + amy*sfxyz(2,nn+1,mm,ll+1)
      acz = amx*sfxyz(3,nn,mm,ll+1) + amy*sfxyz(3,nn+1,mm,ll+1)
      dx = dx + dzp*(acx + dyp*sfxyz(1,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(1,nn+1,mm+1,ll+1))
      dy = dy + dzp*(acy + dyp*sfxyz(2,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(2,nn+1,mm+1,ll+1))
      dz = dz + dzp*(acz + dyp*sfxyz(3,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(3,nn+1,mm+1,ll+1))
c find magnetic field
      ox = amx*sbxyz(1,nn,mm,ll) + amy*sbxyz(1,nn+1,mm,ll)  
      oy = amx*sbxyz(2,nn,mm,ll) + amy*sbxyz(2,nn+1,mm,ll)  
      oz = amx*sbxyz(3,nn,mm,ll) + amy*sbxyz(3,nn+1,mm,ll)  
      ox = amz*(ox + dyp*sbxyz(1,nn,mm+1,ll)                            
     1             + dx1*sbxyz(1,nn+1,mm+1,ll))
      oy = amz*(oy + dyp*sbxyz(2,nn,mm+1,ll)                            
     1             + dx1*sbxyz(2,nn+1,mm+1,ll))
      oz = amz*(oz + dyp*sbxyz(3,nn,mm+1,ll)                            
     1             + dx1*sbxyz(3,nn+1,mm+1,ll))
      acx = amx*sbxyz(1,nn,mm,ll+1) + amy*sbxyz(1,nn+1,mm,ll+1)
      acy = amx*sbxyz(2,nn,mm,ll+1) + amy*sbxyz(2,nn+1,mm,ll+1)
      acz = amx*sbxyz(3,nn,mm,ll+1) + amy*sbxyz(3,nn+1,mm,ll+1)
      ox = ox + dzp*(acx + dyp*sbxyz(1,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(1,nn+1,mm+1,ll+1))
      oy = oy + dzp*(acy + dyp*sbxyz(2,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(2,nn+1,mm+1,ll+1))
      oz = oz + dzp*(acz + dyp*sbxyz(3,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(3,nn+1,mm+1,ll+1))
c calculate half impulse
      dx = qtmh*dx
      dy = qtmh*dy
      dz = qtmh*dz
c half acceleration
      acx = ppart(4,j,l) + dx
      acy = ppart(5,j,l) + dy
      acz = ppart(6,j,l) + dz
c time-centered kinetic energy
      sum1 = sum1 + (acx*acx + acy*acy + acz*acz)
c calculate cyclotron frequency
      omxt = qtmh*ox
      omyt = qtmh*oy
      omzt = qtmh*oz
c calculate rotation matrix
      omt = omxt*omxt + omyt*omyt + omzt*omzt
      anorm = 2.0/(1.0 + omt)
      omt = 0.5*(1.0 - omt)
      rot4 = omxt*omyt
      rot7 = omxt*omzt
      rot8 = omyt*omzt
      rot1 = omt + omxt*omxt
      rot5 = omt + omyt*omyt
      rot9 = omt + omzt*omzt
      rot2 = omzt + rot4
      rot4 = -omzt + rot4
      rot3 = -omyt + rot7
      rot7 = omyt + rot7
      rot6 = omxt + rot8
      rot8 = -omxt + rot8
c new velocity
      dx = (rot1*acx + rot2*acy + rot3*acz)*anorm + dx
      dy = (rot4*acx + rot5*acy + rot6*acz)*anorm + dy
      dz = (rot7*acx + rot8*acy + rot9*acz)*anorm + dz
      ppart(4,j,l) = dx
      ppart(5,j,l) = dy
      ppart(6,j,l) = dz
c new position
      dx = x + dx*dtc
      dy = y + dy*dtc
      dz = z + dz*dtc
c reflecting boundary conditions
      if (ipbc.eq.2) then
         if ((dx.lt.edgelx).or.(dx.ge.edgerx)) then
            dx = x
            ppart(4,j,l) = -ppart(4,j,l)
         endif
         if ((dy.lt.edgely).or.(dy.ge.edgery)) then
            dy = y
            ppart(5,j,l) = -ppart(5,j,l)
         endif
         if ((dz.lt.edgelz).or.(dz.ge.edgerz)) then
            dz = z
            ppart(6,j,l) = -ppart(6,j,l)
         endif
c mixed reflecting/periodic boundary conditions
      else if (ipbc.eq.3) then
         if ((dx.lt.edgelx).or.(dx.ge.edgerx)) then
            dx = x
            ppart(4,j,l) = -ppart(4,j,l)
         endif
         if ((dy.lt.edgely).or.(dy.ge.edgery)) then
            dy = y
            ppart(5,j,l) = -ppart(5,j,l)
         endif
      endif
c set new position
      ppart(1,j,l) = dx
      ppart(2,j,l) = dy
      ppart(3,j,l) = dz
   70 continue
      sum2 = sum2 + sum1
   80 continue
!$OMP END PARALLEL DO
c normalize kinetic energy
      ek = ek + 0.5*sum2
      return
      end
c-----------------------------------------------------------------------
      subroutine GBPPUSHF3L(ppart,fxyz,bxyz,kpic,ncl,ihole,qbm,dt,dtc,ek
     1,idimp,nppmx,nx,ny,nz,mx,my,mz,nxv,nyv,nzv,mx1,my1,mxyz1,ntmax,irc
     2)
c for 3d code, this subroutine updates particle co-ordinates and
c velocities using leap-frog scheme in time and first-order linear
c interpolation in space, with magnetic field.  Using the Boris Mover.
c also determines list of particles which are leaving this tile
c OpenMP version using guard cells
c data read in tiles
c particles stored segmented array
c 190 flops/particle, 1 divide, 54 loads, 6 stores
c input: all except ncl, ihole, irc, output: ppart, ncl, ihole, ek, irc
c velocity equations used are:
c vx(t+dt/2) = rot(1)*(vx(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(2)*(vy(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(3)*(vz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fx(x(t),y(t),z(t))*dt)
c vy(t+dt/2) = rot(4)*(vx(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(5)*(vy(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(6)*(vz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fy(x(t),y(t),z(t))*dt)
c vz(t+dt/2) = rot(7)*(vx(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(8)*(vy(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(9)*(vz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fz(x(t),y(t),z(t))*dt)
c where q/m is charge/mass, and the rotation matrix is given by:
c    rot(1) = (1 - (om*dt/2)**2 + 2*(omx*dt/2)**2)/(1 + (om*dt/2)**2)
c    rot(2) = 2*(omz*dt/2 + (omx*dt/2)*(omy*dt/2))/(1 + (om*dt/2)**2)
c    rot(3) = 2*(-omy*dt/2 + (omx*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(4) = 2*(-omz*dt/2 + (omx*dt/2)*(omy*dt/2))/(1 + (om*dt/2)**2)
c    rot(5) = (1 - (om*dt/2)**2 + 2*(omy*dt/2)**2)/(1 + (om*dt/2)**2)
c    rot(6) = 2*(omx*dt/2 + (omy*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(7) = 2*(omy*dt/2 + (omx*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(8) = 2*(-omx*dt/2 + (omy*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(9) = (1 - (om*dt/2)**2 + 2*(omz*dt/2)**2)/(1 + (om*dt/2)**2)
c and om**2 = omx**2 + omy**2 + omz**2
c the rotation matrix is determined by:
c omx = (q/m)*bx(x(t),y(t),z(t)), omy = (q/m)*by(x(t),y(t),z(t)), and
c omz = (q/m)*bz(x(t),y(t),z(t)).
c position equations used are:
c x(t+dt)=x(t) + vx(t+dt/2)*dt
c y(t+dt)=y(t) + vy(t+dt/2)*dt
c z(t+dt)=z(t) + vz(t+dt/2)*dt
c fx(x(t),y(t),z(t)), fy(x(t),y(t),z(t)), and fz(x(t),y(t),z(t)),
c bx(x(t),y(t),z(t)), by(x(t),y(t),z(t)), and bz(x(t),y(t),z(t))
c are approximated by interpolation from the nearest grid points:
c fx(x,y,z) = (1-dz)*((1-dy)*((1-dx)*fx(n,m,l)+dx*fx(n+1,m,l))
c                + dy*((1-dx)*fx(n,m+1,l) + dx*fx(n+1,m+1,l)))
c           + dz*((1-dy)*((1-dx)*fx(n,m,l+1)+dx*fx(n+1,m,l+1))
c                + dy*((1-dx)*fx(n,m+1,l+1) + dx*fx(n+1,m+1,l+1)))
c where n,m,l = leftmost grid points and dx = x-n, dy = y-m, dz = z-l
c similarly for fy(x,y,z), fz(x,y,z), bx(x,y,z), by(x,y,z), bz(x,y,z)
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c ppart(4,n,m) = velocity vx of particle n in tile m
c ppart(5,n,m) = velocity vy of particle n in tile m
c ppart(6,n,m) = velocity vz of particle n in tile m
c fxyz(1,j,k,l) = x component of force/charge at grid (j,k,l)
c fxyz(2,j,k,l) = y component of force/charge at grid (j,k,l)
c fxyz(3,j,k,l) = z component of force/charge at grid (j,k,l)
c that is, convolution of electric field over particle shape
c bxyz(1,j,k,l) = x component of magnetic field at grid (j,k,l)
c bxyz(2,j,k,l) = y component of magnetic field at grid (j,k,l)
c bxyz(3,j,k,l) = z component of magnetic field at grid (j,k,l)
c that is, the convolution of magnetic field over particle shape
c kpic(l) = number of particles in tile l
c ncl(i,l) = number of particles going to destination i, tile l
c ihole(1,:,l) = location of hole in array left by departing particle
c ihole(2,:,l) = direction destination of particle leaving hole
c all for tile l
c ihole(1,1,l) = ih, number of holes left (error, if negative)
c qbm = particle charge/mass ratio
c dt = time interval between successive force calculations
c dtc = time interval between successive co-ordinate calculations
c kinetic energy/mass at time t is also calculated, using
c ek = .5*sum((vx(t-dt/2) + .5*(q/m)*fx(x(t),y(t))*dt)**2 +
c      (vy(t-dt/2) + .5*(q/m)*fy(x(t),y(t))*dt)**2 + 
c      .25*(vz(t+dt/2) + vz(t-dt/2))**2)
c idimp = size of phase space = 6
c nppmx = maximum number of particles in tile
c nx/ny/nz = system length in x/y/z direction
c mx/my/mz = number of grids in sorting cell in x/y/z
c nxv = second dimension of field arrays, must be >= nx+1
c nyv = third dimension of field arrays, must be >= ny+1
c nzv = fourth dimension of field array, must be >= nz+1
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mxyz1 = mx1*my1*mz1,
c where mz1 = (system length in z direction - 1)/mz + 1
c ntmax = size of hole array for particles leaving tiles
c irc = maximum overflow, returned only if error occurs, when irc > 0
c optimized version
      implicit none
      integer idimp, nppmx, nx, ny, nz, mx, my, mz, nxv, nyv, nzv
      integer mx1, my1, mxyz1, ntmax, irc
      real qbm, dt, dtc, ek
      real ppart, fxyz, bxyz
      integer kpic, ncl, ihole
      dimension ppart(idimp,nppmx,mxyz1)
      dimension fxyz(3,nxv,nyv,nzv), bxyz(3,nxv,nyv,nzv)
      dimension kpic(mxyz1), ncl(26,mxyz1)
      dimension ihole(2,ntmax+1,mxyz1)
c local data
      integer MXV, MYV, MZV
      parameter(MXV=17,MYV=17,MZV=17)
      integer mxy1, noff, moff, loff, npp
      integer i, j, k, l, ih, nh, nn, mm, ll
      real anx, any, anz, edgelx, edgely, edgelz, edgerx, edgery, edgerz
      real dxp, dyp, dzp, amx, amy, amz, dx, dy, dz, ox, oy, oz, dx1
      real qtmh, acx, acy, acz, omxt, omyt, omzt, omt, anorm
      real rot1, rot2, rot3, rot4, rot5, rot6, rot7, rot8, rot9
      real x, y, z
      real sfxyz, sbxyz
      dimension sfxyz(3,MXV,MYV,MZV), sbxyz(3,MXV,MYV,MZV)
c     dimension sfxyz(3,mx+1,my+1,mz+1), sbxyz(3,mx+1,my+1,mz+1)
      double precision sum1, sum2
      mxy1 = mx1*my1
      qtmh = 0.5*qbm*dt
      anx = real(nx)
      any = real(ny)
      anz = real(nz)
      sum2 = 0.0d0
c error if local array is too small
c     if ((mx.ge.MXV).or.(my.ge.MYV).or.(mz.ge.MZV)) return
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,noff,moff,loff,npp,nn,mm,ll,ih,nh,x,y,z,dxp,dyp, 
!$OMP& dzp,amx,amy,amz,dx1,dx,dy,dz,ox,oy,oz,acx,acy,acz,omxt,omyt,omzt,
!$OMP& omt,anorm,rot1,rot2,rot3,rot4,rot5,rot6,rot7,rot8,rot9,edgelx,   
!$OMP& edgely,edgelz,edgerx,edgery,edgerz,sum1,sfxyz,sbxyz)
!$OMP& REDUCTION(+:sum2)
      do 90 l = 1, mxyz1
      loff = (l - 1)/mxy1
      k = l - mxy1*loff
      loff = mz*loff
      noff = (k - 1)/mx1
      moff = my*noff
      noff = mx*(k - mx1*noff - 1)
      npp = kpic(l)
      nn = min(mx,nx-noff)
      mm = min(my,ny-moff)
      ll = min(mz,nz-loff)
      edgelx = noff
      edgerx = noff + nn
      edgely = moff
      edgery = moff + mm
      edgelz = loff
      edgerz = loff + ll
      ih = 0
      nh = 0
c load local fields from global array
      do 30 k = 1, ll+1
      do 20 j = 1, mm+1
      do 10 i = 1, nn+1
      sfxyz(1,i,j,k) = fxyz(1,i+noff,j+moff,k+loff)
      sfxyz(2,i,j,k) = fxyz(2,i+noff,j+moff,k+loff)
      sfxyz(3,i,j,k) = fxyz(3,i+noff,j+moff,k+loff)
   10 continue
   20 continue
   30 continue
      do 60 k = 1, ll+1
      do 50 j = 1, mm+1
      do 40 i = 1, nn+1
      sbxyz(1,i,j,k) = bxyz(1,i+noff,j+moff,k+loff)
      sbxyz(2,i,j,k) = bxyz(2,i+noff,j+moff,k+loff)
      sbxyz(3,i,j,k) = bxyz(3,i+noff,j+moff,k+loff)
   40 continue
   50 continue
   60 continue
c clear counters
      do 70 j = 1, 26
      ncl(j,l) = 0
   70 continue
      sum1 = 0.0d0
c loop over particles in tile
      do 80 j = 1, npp
c find interpolation weights
      x = ppart(1,j,l)
      y = ppart(2,j,l)
      z = ppart(3,j,l)
      nn = x
      mm = y
      ll = z
      dxp = x - real(nn)
      dyp = y - real(mm)
      dzp = z - real(ll)
      nn = nn - noff + 1
      mm = mm - moff + 1
      ll = ll - loff + 1
      amx = 1.0 - dxp
      amy = 1.0 - dyp
      dx1 = dxp*dyp
      dyp = amx*dyp
      amx = amx*amy
      amz = 1.0 - dzp
      amy = dxp*amy
c find electric field
      dx = amx*sfxyz(1,nn,mm,ll) + amy*sfxyz(1,nn+1,mm,ll)  
      dy = amx*sfxyz(2,nn,mm,ll) + amy*sfxyz(2,nn+1,mm,ll)  
      dz = amx*sfxyz(3,nn,mm,ll) + amy*sfxyz(3,nn+1,mm,ll)  
      dx = amz*(dx + dyp*sfxyz(1,nn,mm+1,ll)                            
     1             + dx1*sfxyz(1,nn+1,mm+1,ll))
      dy = amz*(dy + dyp*sfxyz(2,nn,mm+1,ll)                            
     1             + dx1*sfxyz(2,nn+1,mm+1,ll))
      dz = amz*(dz + dyp*sfxyz(3,nn,mm+1,ll)                            
     1             + dx1*sfxyz(3,nn+1,mm+1,ll))
      acx = amx*sfxyz(1,nn,mm,ll+1) + amy*sfxyz(1,nn+1,mm,ll+1)
      acy = amx*sfxyz(2,nn,mm,ll+1) + amy*sfxyz(2,nn+1,mm,ll+1)
      acz = amx*sfxyz(3,nn,mm,ll+1) + amy*sfxyz(3,nn+1,mm,ll+1)
      dx = dx + dzp*(acx + dyp*sfxyz(1,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(1,nn+1,mm+1,ll+1))
      dy = dy + dzp*(acy + dyp*sfxyz(2,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(2,nn+1,mm+1,ll+1))
      dz = dz + dzp*(acz + dyp*sfxyz(3,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(3,nn+1,mm+1,ll+1))
c find magnetic field
      ox = amx*sbxyz(1,nn,mm,ll) + amy*sbxyz(1,nn+1,mm,ll)  
      oy = amx*sbxyz(2,nn,mm,ll) + amy*sbxyz(2,nn+1,mm,ll)  
      oz = amx*sbxyz(3,nn,mm,ll) + amy*sbxyz(3,nn+1,mm,ll)  
      ox = amz*(ox + dyp*sbxyz(1,nn,mm+1,ll)                            
     1             + dx1*sbxyz(1,nn+1,mm+1,ll))
      oy = amz*(oy + dyp*sbxyz(2,nn,mm+1,ll)                            
     1             + dx1*sbxyz(2,nn+1,mm+1,ll))
      oz = amz*(oz + dyp*sbxyz(3,nn,mm+1,ll)                            
     1             + dx1*sbxyz(3,nn+1,mm+1,ll))
      acx = amx*sbxyz(1,nn,mm,ll+1) + amy*sbxyz(1,nn+1,mm,ll+1)
      acy = amx*sbxyz(2,nn,mm,ll+1) + amy*sbxyz(2,nn+1,mm,ll+1)
      acz = amx*sbxyz(3,nn,mm,ll+1) + amy*sbxyz(3,nn+1,mm,ll+1)
      ox = ox + dzp*(acx + dyp*sbxyz(1,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(1,nn+1,mm+1,ll+1))
      oy = oy + dzp*(acy + dyp*sbxyz(2,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(2,nn+1,mm+1,ll+1))
      oz = oz + dzp*(acz + dyp*sbxyz(3,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(3,nn+1,mm+1,ll+1))
c calculate half impulse
      dx = qtmh*dx
      dy = qtmh*dy
      dz = qtmh*dz
c half acceleration
      acx = ppart(4,j,l) + dx
      acy = ppart(5,j,l) + dy
      acz = ppart(6,j,l) + dz
c time-centered kinetic energy
      sum1 = sum1 + (acx*acx + acy*acy + acz*acz)
c calculate cyclotron frequency
      omxt = qtmh*ox
      omyt = qtmh*oy
      omzt = qtmh*oz
c calculate rotation matrix
      omt = omxt*omxt + omyt*omyt + omzt*omzt
      anorm = 2.0/(1.0 + omt)
      omt = 0.5*(1.0 - omt)
      rot4 = omxt*omyt
      rot7 = omxt*omzt
      rot8 = omyt*omzt
      rot1 = omt + omxt*omxt
      rot5 = omt + omyt*omyt
      rot9 = omt + omzt*omzt
      rot2 = omzt + rot4
      rot4 = -omzt + rot4
      rot3 = -omyt + rot7
      rot7 = omyt + rot7
      rot6 = omxt + rot8
      rot8 = -omxt + rot8
c new velocity
      dx = (rot1*acx + rot2*acy + rot3*acz)*anorm + dx
      dy = (rot4*acx + rot5*acy + rot6*acz)*anorm + dy
      dz = (rot7*acx + rot8*acy + rot9*acz)*anorm + dz
      ppart(4,j,l) = dx
      ppart(5,j,l) = dy
      ppart(6,j,l) = dz
c new position
      dx = x + dx*dtc
      dy = y + dy*dtc
      dz = z + dz*dtc
c find particles going out of bounds
      mm = 0
c count how many particles are going in each direction in ncl
c save their address and destination in ihole
c use periodic boundary conditions and check for roundoff error
c ist = direction particle is going
      if (dx.ge.edgerx) then
         if (dx.ge.anx) dx = dx - anx
         mm = 2
      else if (dx.lt.edgelx) then
         if (dx.lt.0.0) then
            dx = dx + anx
            if (dx.lt.anx) then
               mm = 1
            else
               dx = 0.0
            endif
         else
            mm = 1
         endif
      endif
      if (dy.ge.edgery) then
         if (dy.ge.any) dy = dy - any
         mm = mm + 6
      else if (dy.lt.edgely) then
         if (dy.lt.0.0) then
            dy = dy + any
            if (dy.lt.any) then
               mm = mm + 3
            else
               dy = 0.0
            endif
         else
            mm = mm + 3
         endif
      endif
      if (dz.ge.edgerz) then
         if (dz.ge.anz) dz = dz - anz
         mm = mm + 18
      else if (dz.lt.edgelz) then
         if (dz.lt.0.0) then
            dz = dz + anz
            if (dz.lt.anz) then
               mm = mm + 9
            else
               dz = 0.0
            endif
         else
            mm = mm + 9
         endif
      endif
c set new position
      ppart(1,j,l) = dx
      ppart(2,j,l) = dy
      ppart(3,j,l) = dz
c increment counters
      if (mm.gt.0) then
         ncl(mm,l) = ncl(mm,l) + 1
         ih = ih + 1
         if (ih.le.ntmax) then
            ihole(1,ih+1,l) = j
            ihole(2,ih+1,l) = mm
         else
            nh = 1
         endif
      endif
   80 continue
      sum2 = sum2 + sum1
c set error and end of file flag
      if (nh.gt.0) then
         irc = ih
         ih = -ih
      endif
      ihole(1,1,l) = ih
   90 continue
!$OMP END PARALLEL DO
c normalize kinetic energy
      ek = ek + 0.5*sum2
      return
      end
c-----------------------------------------------------------------------
      subroutine GRBPPUSH3L(ppart,fxyz,bxyz,kpic,qbm,dt,dtc,ci,ek,idimp,
     1nppmx,nx,ny,nz,mx,my,mz,nxv,nyv,nzv,mx1,my1,mxyz1,ipbc)
c for 3d code, this subroutine updates particle co-ordinates and
c velocities using leap-frog scheme in time and first-order linear
c interpolation in space, for relativistic particles with magnetic field
c Using the Boris Mover.
c OpenMP version using guard cells
c data read in tiles
c particles stored segmented array
c 202 flops/particle, 4 divides, 2 sqrts, 54 loads, 6 stores
c input: all, output: ppart, ek
c momentum equations used are:
c px(t+dt/2) = rot(1)*(px(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(2)*(py(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(3)*(pz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fx(x(t),y(t),z(t))*dt)
c py(t+dt/2) = rot(4)*(px(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(5)*(py(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(6)*(pz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fy(x(t),y(t),z(t))*dt)
c pz(t+dt/2) = rot(7)*(px(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(8)*(py(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(9)*(pz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fz(x(t),y(t),z(t))*dt)
c where q/m is charge/mass, and the rotation matrix is given by:
c    rot(1) = (1 - (om*dt/2)**2 + 2*(omx*dt/2)**2)/(1 + (om*dt/2)**2)
c    rot(2) = 2*(omz*dt/2 + (omx*dt/2)*(omy*dt/2))/(1 + (om*dt/2)**2)
c    rot(3) = 2*(-omy*dt/2 + (omx*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(4) = 2*(-omz*dt/2 + (omx*dt/2)*(omy*dt/2))/(1 + (om*dt/2)**2)
c    rot(5) = (1 - (om*dt/2)**2 + 2*(omy*dt/2)**2)/(1 + (om*dt/2)**2)
c    rot(6) = 2*(omx*dt/2 + (omy*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(7) = 2*(omy*dt/2 + (omx*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(8) = 2*(-omx*dt/2 + (omy*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(9) = (1 - (om*dt/2)**2 + 2*(omz*dt/2)**2)/(1 + (om*dt/2)**2)
c and om**2 = omx**2 + omy**2 + omz**2
c the rotation matrix is determined by:
c omx = (q/m)*bx(x(t),y(t),z(t))*gami, 
c omy = (q/m)*by(x(t),y(t),z(t))*gami,
c omz = (q/m)*bz(x(t),y(t),z(t))*gami,
c where gami = 1./sqrt(1.+(px(t)*px(t)+py(t)*py(t)+pz(t)*pz(t))*ci*ci)
c position equations used are:
c x(t+dt) = x(t) + px(t+dt/2)*dtg
c y(t+dt) = y(t) + py(t+dt/2)*dtg
c z(t+dt) = z(t) + pz(t+dt/2)*dtg
c where dtg = dtc/sqrt(1.+(px(t+dt/2)*px(t+dt/2)+py(t+dt/2)*py(t+dt/2)+
c pz(t+dt/2)*pz(t+dt/2))*ci*ci)
c fx(x(t),y(t),z(t)), fy(x(t),y(t),z(t)), and fz(x(t),y(t),z(t)),
c bx(x(t),y(t),z(t)), by(x(t),y(t),z(t)), and bz(x(t),y(t),z(t))
c are approximated by interpolation from the nearest grid points:
c fx(x,y,z) = (1-dz)*((1-dy)*((1-dx)*fx(n,m,l)+dx*fx(n+1,m,l))
c                + dy*((1-dx)*fx(n,m+1,l) + dx*fx(n+1,m+1,l)))
c           + dz*((1-dy)*((1-dx)*fx(n,m,l+1)+dx*fx(n+1,m,l+1))
c                + dy*((1-dx)*fx(n,m+1,l+1) + dx*fx(n+1,m+1,l+1)))
c where n,m,l = leftmost grid points and dx = x-n, dy = y-m, dz = z-l
c similarly for fy(x,y,z), fz(x,y,z), bx(x,y,z), by(x,y,z), bz(x,y,z)
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c ppart(4,n,m) = momentum px of particle n in tile m
c ppart(5,n,m) = momentum py of particle n in tile m
c ppart(6,n,m) = momentum pz of particle n in tile m
c fxyz(1,j,k,l) = x component of force/charge at grid (j,k,l)
c fxyz(2,j,k,l) = y component of force/charge at grid (j,k,l)
c fxyz(3,j,k,l) = z component of force/charge at grid (j,k,l)
c that is, convolution of electric field over particle shape
c bxyz(1,j,k,l) = x component of magnetic field at grid (j,k,l)
c bxyz(2,j,k,l) = y component of magnetic field at grid (j,k,l)
c bxyz(3,j,k,l) = z component of magnetic field at grid (j,k,l)
c that is, the convolution of magnetic field over particle shape
c kpic = number of particles per tile
c qbm = particle charge/mass ratio
c dt = time interval between successive force calculations
c dtc = time interval between successive co-ordinate calculations
c ci = reciprocal of velocity of light
c kinetic energy/mass at time t is also calculated, using
c ek = gami*sum((px(t-dt/2) + .5*(q/m)*fx(x(t),y(t))*dt)**2 +
c      (py(t-dt/2) + .5*(q/m)*fy(x(t),y(t))*dt)**2 +
c      (pz(t-dt/2) + .5*(q/m)*fz(x(t),y(t))*dt)**2)/(1. + gami)
c idimp = size of phase space = 6
c nppmx = maximum number of particles in tile
c nx/ny/nz = system length in x/y/z direction
c mx/my/mz = number of grids in sorting cell in x/y/z
c nxv = second dimension of field arrays, must be >= nx+1
c nyv = third dimension of field arrays, must be >= ny+1
c nzv = fourth dimension of field array, must be >= nz+1
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mxyz1 = mx1*my1*mz1,
c where mz1 = (system length in z direction - 1)/mz + 1
c ipbc = particle boundary condition = (0,1,2,3) =
c (none,3d periodic,3d reflecting,mixed 2d reflecting/1d periodic)
      implicit none
      integer idimp, nppmx, nx, ny, nz, mx, my, mz, nxv, nyv, nzv
      integer mx1, my1, mxyz1, ipbc
      real qbm, dt, dtc, ci, ek
      real ppart, fxyz, bxyz
      integer kpic
      dimension ppart(idimp,nppmx,mxyz1)
      dimension fxyz(3,nxv,nyv,nzv), bxyz(3,nxv,nyv,nzv)
      dimension kpic(mxyz1)
c local data
      integer MXV, MYV, MZV
      parameter(MXV=17,MYV=17,MZV=17)
      integer mxy1, noff, moff, loff, npp
      integer i, j, k, l, nn, mm, ll
      real qtmh, ci2, edgelx, edgely, edgelz, edgerx, edgery, edgerz
      real dxp, dyp, dzp, amx, amy, amz, dx, dy, dz, ox, oy, oz, dx1
      real acx, acy, acz, p2, gami, qtmg, omxt, omyt, omzt, omt, anorm
      real rot1, rot2, rot3, rot4, rot5, rot6, rot7, rot8, rot9, dtg
      real x, y, z
      real sfxyz, sbxyz
      dimension sfxyz(3,MXV,MYV,MZV), sbxyz(3,MXV,MYV,MZV)
c     dimension sfxyz(3,mx+1,my+1,mz+1), sbxyz(3,mx+1,my+1,mz+1)
      double precision sum1, sum2
      mxy1 = mx1*my1
      qtmh = 0.5*qbm*dt
      ci2 = ci*ci
      sum2 = 0.0d0
c set boundary values
      edgelx = 0.0
      edgely = 0.0
      edgelz = 0.0
      edgerx = real(nx)
      edgery = real(ny)
      edgerz = real(nz)
      if (ipbc.eq.2) then
         edgelx = 1.0
         edgely = 1.0
         edgelz = 1.0
         edgerx = real(nx-1)
         edgery = real(ny-1)
         edgerz = real(nz-1)
      else if (ipbc.eq.3) then
         edgelx = 1.0
         edgely = 1.0
         edgerx = real(nx-1)
         edgery = real(ny-1)
      endif
c error if local array is too small
c     if ((mx.ge.MXV).or.(my.ge.MYV).or.(mz.ge.MZV)) return
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,noff,moff,loff,npp,nn,mm,ll,x,y,z,dxp,dyp,dzp,amx
!$OMP& ,amy,amz,dx1,dx,dy,dz,ox,oy,oz,acx,acy,acz,omxt,omyt,omzt,omt,   
!$OMP& anorm,rot1,rot2,rot3,rot4,rot5,rot6,rot7,rot8,rot9,p2,gami,qtmg, 
!$OMP& dtg,sum1,sfxyz,sbxyz)
!$OMP& REDUCTION(+:sum2)
      do 80 l = 1, mxyz1
      loff = (l - 1)/mxy1
      k = l - mxy1*loff
      loff = mz*loff
      noff = (k - 1)/mx1
      moff = my*noff
      noff = mx*(k - mx1*noff - 1)
      npp = kpic(l)
c load local fields from global array
      do 30 k = 1, min(mz,nz-loff)+1
      do 20 j = 1, min(my,ny-moff)+1
      do 10 i = 1, min(mx,nx-noff)+1
      sfxyz(1,i,j,k) = fxyz(1,i+noff,j+moff,k+loff)
      sfxyz(2,i,j,k) = fxyz(2,i+noff,j+moff,k+loff)
      sfxyz(3,i,j,k) = fxyz(3,i+noff,j+moff,k+loff)
   10 continue
   20 continue
   30 continue
      do 60 k = 1, min(mz,nz-loff)+1
      do 50 j = 1, min(my,ny-moff)+1
      do 40 i = 1, min(mx,nx-noff)+1
      sbxyz(1,i,j,k) = bxyz(1,i+noff,j+moff,k+loff)
      sbxyz(2,i,j,k) = bxyz(2,i+noff,j+moff,k+loff)
      sbxyz(3,i,j,k) = bxyz(3,i+noff,j+moff,k+loff)
   40 continue
   50 continue
   60 continue
      sum1 = 0.0d0
c loop over particles in tile
      do 70 j = 1, npp
c find interpolation weights
      x = ppart(1,j,l)
      y = ppart(2,j,l)
      z = ppart(3,j,l)
      nn = x
      mm = y
      ll = z
      dxp = x - real(nn)
      dyp = y - real(mm)
      dzp = z - real(ll)
      nn = nn - noff + 1
      mm = mm - moff + 1
      ll = ll - loff + 1
      amx = 1.0 - dxp
      amy = 1.0 - dyp
      dx1 = dxp*dyp
      dyp = amx*dyp
      amx = amx*amy
      amz = 1.0 - dzp
      amy = dxp*amy
c find electric field
      dx = amx*sfxyz(1,nn,mm,ll) + amy*sfxyz(1,nn+1,mm,ll)  
      dy = amx*sfxyz(2,nn,mm,ll) + amy*sfxyz(2,nn+1,mm,ll)  
      dz = amx*sfxyz(3,nn,mm,ll) + amy*sfxyz(3,nn+1,mm,ll)  
      dx = amz*(dx + dyp*sfxyz(1,nn,mm+1,ll)                            
     1             + dx1*sfxyz(1,nn+1,mm+1,ll))
      dy = amz*(dy + dyp*sfxyz(2,nn,mm+1,ll)                            
     1             + dx1*sfxyz(2,nn+1,mm+1,ll))
      dz = amz*(dz + dyp*sfxyz(3,nn,mm+1,ll)                            
     1             + dx1*sfxyz(3,nn+1,mm+1,ll))
      acx = amx*sfxyz(1,nn,mm,ll+1) + amy*sfxyz(1,nn+1,mm,ll+1)
      acy = amx*sfxyz(2,nn,mm,ll+1) + amy*sfxyz(2,nn+1,mm,ll+1)
      acz = amx*sfxyz(3,nn,mm,ll+1) + amy*sfxyz(3,nn+1,mm,ll+1)
      dx = dx + dzp*(acx + dyp*sfxyz(1,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(1,nn+1,mm+1,ll+1))
      dy = dy + dzp*(acy + dyp*sfxyz(2,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(2,nn+1,mm+1,ll+1))
      dz = dz + dzp*(acz + dyp*sfxyz(3,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(3,nn+1,mm+1,ll+1))
c find magnetic field
      ox = amx*sbxyz(1,nn,mm,ll) + amy*sbxyz(1,nn+1,mm,ll)  
      oy = amx*sbxyz(2,nn,mm,ll) + amy*sbxyz(2,nn+1,mm,ll)  
      oz = amx*sbxyz(3,nn,mm,ll) + amy*sbxyz(3,nn+1,mm,ll)  
      ox = amz*(ox + dyp*sbxyz(1,nn,mm+1,ll)                            
     1             + dx1*sbxyz(1,nn+1,mm+1,ll))
      oy = amz*(oy + dyp*sbxyz(2,nn,mm+1,ll)                            
     1             + dx1*sbxyz(2,nn+1,mm+1,ll))
      oz = amz*(oz + dyp*sbxyz(3,nn,mm+1,ll)                            
     1             + dx1*sbxyz(3,nn+1,mm+1,ll))
      acx = amx*sbxyz(1,nn,mm,ll+1) + amy*sbxyz(1,nn+1,mm,ll+1)
      acy = amx*sbxyz(2,nn,mm,ll+1) + amy*sbxyz(2,nn+1,mm,ll+1)
      acz = amx*sbxyz(3,nn,mm,ll+1) + amy*sbxyz(3,nn+1,mm,ll+1)
      ox = ox + dzp*(acx + dyp*sbxyz(1,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(1,nn+1,mm+1,ll+1))
      oy = oy + dzp*(acy + dyp*sbxyz(2,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(2,nn+1,mm+1,ll+1))
      oz = oz + dzp*(acz + dyp*sbxyz(3,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(3,nn+1,mm+1,ll+1))
c calculate half impulse
      dx = qtmh*dx
      dy = qtmh*dy
      dz = qtmh*dz
c half acceleration
      acx = ppart(4,j,l) + dx
      acy = ppart(5,j,l) + dy
      acz = ppart(6,j,l) + dz
c find inverse gamma
      p2 = acx*acx + acy*acy + acz*acz
      gami = 1.0/sqrt(1.0 + p2*ci2)
c renormalize magnetic field
      qtmg = qtmh*gami
c time-centered kinetic energy
      sum1 = sum1 + gami*p2/(1.0 + gami)
c calculate cyclotron frequency
      omxt = qtmg*ox
      omyt = qtmg*oy
      omzt = qtmg*oz
c calculate rotation matrix
      omt = omxt*omxt + omyt*omyt + omzt*omzt
      anorm = 2.0/(1.0 + omt)
      omt = 0.5*(1.0 - omt)
      rot4 = omxt*omyt
      rot7 = omxt*omzt
      rot8 = omyt*omzt
      rot1 = omt + omxt*omxt
      rot5 = omt + omyt*omyt
      rot9 = omt + omzt*omzt
      rot2 = omzt + rot4
      rot4 = -omzt + rot4
      rot3 = -omyt + rot7
      rot7 = omyt + rot7
      rot6 = omxt + rot8
      rot8 = -omxt + rot8
c new momentum
      dx = (rot1*acx + rot2*acy + rot3*acz)*anorm + dx
      dy = (rot4*acx + rot5*acy + rot6*acz)*anorm + dy
      dz = (rot7*acx + rot8*acy + rot9*acz)*anorm + dz
      ppart(4,j,l) = dx
      ppart(5,j,l) = dy
      ppart(6,j,l) = dz
c update inverse gamma
      p2 = dx*dx + dy*dy + dz*dz
      dtg = dtc/sqrt(1.0 + p2*ci2)
c new position
      dx = x + dx*dtg
      dy = y + dy*dtg
      dz = z + dz*dtg
c reflecting boundary conditions
      if (ipbc.eq.2) then
         if ((dx.lt.edgelx).or.(dx.ge.edgerx)) then
            dx = x
            ppart(4,j,l) = -ppart(4,j,l)
         endif
         if ((dy.lt.edgely).or.(dy.ge.edgery)) then
            dy = y
            ppart(5,j,l) = -ppart(5,j,l)
         endif
         if ((dz.lt.edgelz).or.(dz.ge.edgerz)) then
            dz = z
            ppart(6,j,l) = -ppart(6,j,l)
         endif
c mixed reflecting/periodic boundary conditions
      else if (ipbc.eq.3) then
         if ((dx.lt.edgelx).or.(dx.ge.edgerx)) then
            dx = x
            ppart(4,j,l) = -ppart(4,j,l)
         endif
         if ((dy.lt.edgely).or.(dy.ge.edgery)) then
            dy = y
            ppart(5,j,l) = -ppart(5,j,l)
         endif
      endif
c set new position
      ppart(1,j,l) = dx
      ppart(2,j,l) = dy
      ppart(3,j,l) = dz
   70 continue
      sum2 = sum2 + sum1
   80 continue
!$OMP END PARALLEL DO
c normalize kinetic energy
      ek = ek + sum2
      return
      end
c-----------------------------------------------------------------------
      subroutine GRBPPUSHF3L(ppart,fxyz,bxyz,kpic,ncl,ihole,qbm,dt,dtc, 
     1ci,ek,idimp,nppmx,nx,ny,nz,mx,my,mz,nxv,nyv,nzv,mx1,my1,mxyz1,
     2ntmax,irc)
c for 3d code, this subroutine updates particle co-ordinates and
c velocities using leap-frog scheme in time and first-order linear
c interpolation in space, for relativistic particles with magnetic field
c Using the Boris Mover.
c also determines list of particles which are leaving this tile
c OpenMP version using guard cells
c data read in tiles
c particles stored segmented array
c 202 flops/particle, 4 divides, 2 sqrts, 54 loads, 6 stores
c input: all except ncl, ihole, irc, output: ppart, ncl, ihole, ek, irc
c momentum equations used are:
c px(t+dt/2) = rot(1)*(px(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(2)*(py(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(3)*(pz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fx(x(t),y(t),z(t))*dt)
c py(t+dt/2) = rot(4)*(px(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(5)*(py(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(6)*(pz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fy(x(t),y(t),z(t))*dt)
c pz(t+dt/2) = rot(7)*(px(t-dt/2) + .5*(q/m)*fx(x(t),y(t),z(t))*dt) +
c    rot(8)*(py(t-dt/2) + .5*(q/m)*fy(x(t),y(t),z(t))*dt) +
c    rot(9)*(pz(t-dt/2) + .5*(q/m)*fz(x(t),y(t),z(t))*dt) +
c    .5*(q/m)*fz(x(t),y(t),z(t))*dt)
c where q/m is charge/mass, and the rotation matrix is given by:
c    rot(1) = (1 - (om*dt/2)**2 + 2*(omx*dt/2)**2)/(1 + (om*dt/2)**2)
c    rot(2) = 2*(omz*dt/2 + (omx*dt/2)*(omy*dt/2))/(1 + (om*dt/2)**2)
c    rot(3) = 2*(-omy*dt/2 + (omx*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(4) = 2*(-omz*dt/2 + (omx*dt/2)*(omy*dt/2))/(1 + (om*dt/2)**2)
c    rot(5) = (1 - (om*dt/2)**2 + 2*(omy*dt/2)**2)/(1 + (om*dt/2)**2)
c    rot(6) = 2*(omx*dt/2 + (omy*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(7) = 2*(omy*dt/2 + (omx*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(8) = 2*(-omx*dt/2 + (omy*dt/2)*(omz*dt/2))/(1 + (om*dt/2)**2)
c    rot(9) = (1 - (om*dt/2)**2 + 2*(omz*dt/2)**2)/(1 + (om*dt/2)**2)
c and om**2 = omx**2 + omy**2 + omz**2
c the rotation matrix is determined by:
c omx = (q/m)*bx(x(t),y(t),z(t))*gami, 
c omy = (q/m)*by(x(t),y(t),z(t))*gami,
c omz = (q/m)*bz(x(t),y(t),z(t))*gami,
c where gami = 1./sqrt(1.+(px(t)*px(t)+py(t)*py(t)+pz(t)*pz(t))*ci*ci)
c position equations used are:
c x(t+dt) = x(t) + px(t+dt/2)*dtg
c y(t+dt) = y(t) + py(t+dt/2)*dtg
c z(t+dt) = z(t) + pz(t+dt/2)*dtg
c where dtg = dtc/sqrt(1.+(px(t+dt/2)*px(t+dt/2)+py(t+dt/2)*py(t+dt/2)+
c pz(t+dt/2)*pz(t+dt/2))*ci*ci)
c fx(x(t),y(t),z(t)), fy(x(t),y(t),z(t)), and fz(x(t),y(t),z(t)),
c bx(x(t),y(t),z(t)), by(x(t),y(t),z(t)), and bz(x(t),y(t),z(t))
c are approximated by interpolation from the nearest grid points:
c fx(x,y,z) = (1-dz)*((1-dy)*((1-dx)*fx(n,m,l)+dx*fx(n+1,m,l))
c                + dy*((1-dx)*fx(n,m+1,l) + dx*fx(n+1,m+1,l)))
c           + dz*((1-dy)*((1-dx)*fx(n,m,l+1)+dx*fx(n+1,m,l+1))
c                + dy*((1-dx)*fx(n,m+1,l+1) + dx*fx(n+1,m+1,l+1)))
c where n,m,l = leftmost grid points and dx = x-n, dy = y-m, dz = z-l
c similarly for fy(x,y,z), fz(x,y,z), bx(x,y,z), by(x,y,z), bz(x,y,z)
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c ppart(4,n,m) = momentum px of particle n in tile m
c ppart(5,n,m) = momentum py of particle n in tile m
c ppart(6,n,m) = momentum pz of particle n in tile m
c fxyz(1,j,k,l) = x component of force/charge at grid (j,k,l)
c fxyz(2,j,k,l) = y component of force/charge at grid (j,k,l)
c fxyz(3,j,k,l) = z component of force/charge at grid (j,k,l)
c that is, convolution of electric field over particle shape
c bxyz(1,j,k,l) = x component of magnetic field at grid (j,k,l)
c bxyz(2,j,k,l) = y component of magnetic field at grid (j,k,l)
c bxyz(3,j,k,l) = z component of magnetic field at grid (j,k,l)
c that is, the convolution of magnetic field over particle shape
c kpic(l) = number of particles in tile l
c ncl(i,l) = number of particles going to destination i, tile l
c ihole(1,:,l) = location of hole in array left by departing particle
c ihole(2,:,l) = direction destination of particle leaving hole
c all for tile l
c ihole(1,1,l) = ih, number of holes left (error, if negative)
c qbm = particle charge/mass ratio
c dt = time interval between successive force calculations
c dtc = time interval between successive co-ordinate calculations
c ci = reciprocal of velocity of light
c kinetic energy/mass at time t is also calculated, using
c ek = gami*sum((px(t-dt/2) + .5*(q/m)*fx(x(t),y(t))*dt)**2 +
c      (py(t-dt/2) + .5*(q/m)*fy(x(t),y(t))*dt)**2 +
c      (pz(t-dt/2) + .5*(q/m)*fz(x(t),y(t))*dt)**2)/(1. + gami)
c idimp = size of phase space = 6
c nppmx = maximum number of particles in tile
c nx/ny/nz = system length in x/y/z direction
c mx/my/mz = number of grids in sorting cell in x/y/z
c nxv = second dimension of field arrays, must be >= nx+1
c nyv = third dimension of field arrays, must be >= ny+1
c nzv = fourth dimension of field array, must be >= nz+1
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mxyz1 = mx1*my1*mz1,
c where mz1 = (system length in z direction - 1)/mz + 1
c ntmax = size of hole array for particles leaving tiles
c irc = maximum overflow, returned only if error occurs, when irc > 0
c optimized version
      implicit none
      integer idimp, nppmx, nx, ny, nz, mx, my, mz, nxv, nyv, nzv
      integer mx1, my1, mxyz1, ntmax, irc
      real qbm, dt, dtc, ci, ek
      real ppart, fxyz, bxyz
      integer kpic, ncl, ihole
      dimension ppart(idimp,nppmx,mxyz1)
      dimension fxyz(3,nxv,nyv,nzv), bxyz(3,nxv,nyv,nzv)
      dimension kpic(mxyz1), ncl(26,mxyz1)
      dimension ihole(2,ntmax+1,mxyz1)
c local data
      integer MXV, MYV, MZV
      parameter(MXV=17,MYV=17,MZV=17)
      integer mxy1, noff, moff, loff, npp
      integer i, j, k, l, ih, nh, nn, mm, ll
      real anx, any, anz, edgelx, edgely, edgelz, edgerx, edgery, edgerz
      real dxp, dyp, dzp, amx, amy, amz, dx, dy, dz, ox, oy, oz, dx1
      real acx, acy, acz, p2, gami, qtmg, omxt, omyt, omzt, omt, anorm
      real rot1, rot2, rot3, rot4, rot5, rot6, rot7, rot8, rot9, dtg
      real qtmh, ci2, x, y, z
      real sfxyz, sbxyz
      dimension sfxyz(3,MXV,MYV,MZV), sbxyz(3,MXV,MYV,MZV)
c     dimension sfxyz(3,mx+1,my+1,mz+1), sbxyz(3,mx+1,my+1,mz+1)
      double precision sum1, sum2
      mxy1 = mx1*my1
      qtmh = 0.5*qbm*dt
      ci2 = ci*ci
      anx = real(nx)
      any = real(ny)
      anz = real(nz)
      sum2 = 0.0d0
c error if local array is too small
c     if ((mx.ge.MXV).or.(my.ge.MYV).or.(mz.ge.MZV)) return
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,noff,moff,loff,npp,nn,mm,ll,ih,nh,x,y,z,dxp,dyp, 
!$OMP& dzp,amx,amy,amz,dx1,dx,dy,dz,ox,oy,oz,acx,acy,acz,omxt,omyt,omzt,
!$OMP& omt,anorm,rot1,rot2,rot3,rot4,rot5,rot6,rot7,rot8,rot9,p2,gami,
!$OMP& qtmg,dtg,edgelx,edgely,edgelz,edgerx,edgery,edgerz,sum1,sfxyz,   
!$OMP& sbxyz)
!$OMP& REDUCTION(+:sum2)
      do 90 l = 1, mxyz1
      loff = (l - 1)/mxy1
      k = l - mxy1*loff
      loff = mz*loff
      noff = (k - 1)/mx1
      moff = my*noff
      noff = mx*(k - mx1*noff - 1)
      npp = kpic(l)
      nn = min(mx,nx-noff)
      mm = min(my,ny-moff)
      ll = min(mz,nz-loff)
      edgelx = noff
      edgerx = noff + nn
      edgely = moff
      edgery = moff + mm
      edgelz = loff
      edgerz = loff + ll
      ih = 0
      nh = 0
c load local fields from global array
      do 30 k = 1, ll+1
      do 20 j = 1, mm+1
      do 10 i = 1, nn+1
      sfxyz(1,i,j,k) = fxyz(1,i+noff,j+moff,k+loff)
      sfxyz(2,i,j,k) = fxyz(2,i+noff,j+moff,k+loff)
      sfxyz(3,i,j,k) = fxyz(3,i+noff,j+moff,k+loff)
   10 continue
   20 continue
   30 continue
      do 60 k = 1, ll+1
      do 50 j = 1, mm+1
      do 40 i = 1, nn+1
      sbxyz(1,i,j,k) = bxyz(1,i+noff,j+moff,k+loff)
      sbxyz(2,i,j,k) = bxyz(2,i+noff,j+moff,k+loff)
      sbxyz(3,i,j,k) = bxyz(3,i+noff,j+moff,k+loff)
   40 continue
   50 continue
   60 continue
c clear counters
      do 70 j = 1, 26
      ncl(j,l) = 0
   70 continue
      sum1 = 0.0d0
c loop over particles in tile
      do 80 j = 1, npp
c find interpolation weights
      x = ppart(1,j,l)
      y = ppart(2,j,l)
      z = ppart(3,j,l)
      nn = x
      mm = y
      ll = z
      dxp = x - real(nn)
      dyp = y - real(mm)
      dzp = z - real(ll)
      nn = nn - noff + 1
      mm = mm - moff + 1
      ll = ll - loff + 1
      amx = 1.0 - dxp
      amy = 1.0 - dyp
      dx1 = dxp*dyp
      dyp = amx*dyp
      amx = amx*amy
      amz = 1.0 - dzp
      amy = dxp*amy
c find electric field
      dx = amx*sfxyz(1,nn,mm,ll) + amy*sfxyz(1,nn+1,mm,ll)  
      dy = amx*sfxyz(2,nn,mm,ll) + amy*sfxyz(2,nn+1,mm,ll)  
      dz = amx*sfxyz(3,nn,mm,ll) + amy*sfxyz(3,nn+1,mm,ll)  
      dx = amz*(dx + dyp*sfxyz(1,nn,mm+1,ll)                            
     1             + dx1*sfxyz(1,nn+1,mm+1,ll))
      dy = amz*(dy + dyp*sfxyz(2,nn,mm+1,ll)                            
     1             + dx1*sfxyz(2,nn+1,mm+1,ll))
      dz = amz*(dz + dyp*sfxyz(3,nn,mm+1,ll)                            
     1             + dx1*sfxyz(3,nn+1,mm+1,ll))
      acx = amx*sfxyz(1,nn,mm,ll+1) + amy*sfxyz(1,nn+1,mm,ll+1)
      acy = amx*sfxyz(2,nn,mm,ll+1) + amy*sfxyz(2,nn+1,mm,ll+1)
      acz = amx*sfxyz(3,nn,mm,ll+1) + amy*sfxyz(3,nn+1,mm,ll+1)
      dx = dx + dzp*(acx + dyp*sfxyz(1,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(1,nn+1,mm+1,ll+1))
      dy = dy + dzp*(acy + dyp*sfxyz(2,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(2,nn+1,mm+1,ll+1))
      dz = dz + dzp*(acz + dyp*sfxyz(3,nn,mm+1,ll+1)                    
     1                   + dx1*sfxyz(3,nn+1,mm+1,ll+1))
c find magnetic field
      ox = amx*sbxyz(1,nn,mm,ll) + amy*sbxyz(1,nn+1,mm,ll)  
      oy = amx*sbxyz(2,nn,mm,ll) + amy*sbxyz(2,nn+1,mm,ll)  
      oz = amx*sbxyz(3,nn,mm,ll) + amy*sbxyz(3,nn+1,mm,ll)  
      ox = amz*(ox + dyp*sbxyz(1,nn,mm+1,ll)                            
     1             + dx1*sbxyz(1,nn+1,mm+1,ll))
      oy = amz*(oy + dyp*sbxyz(2,nn,mm+1,ll)                            
     1             + dx1*sbxyz(2,nn+1,mm+1,ll))
      oz = amz*(oz + dyp*sbxyz(3,nn,mm+1,ll)                            
     1             + dx1*sbxyz(3,nn+1,mm+1,ll))
      acx = amx*sbxyz(1,nn,mm,ll+1) + amy*sbxyz(1,nn+1,mm,ll+1)
      acy = amx*sbxyz(2,nn,mm,ll+1) + amy*sbxyz(2,nn+1,mm,ll+1)
      acz = amx*sbxyz(3,nn,mm,ll+1) + amy*sbxyz(3,nn+1,mm,ll+1)
      ox = ox + dzp*(acx + dyp*sbxyz(1,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(1,nn+1,mm+1,ll+1))
      oy = oy + dzp*(acy + dyp*sbxyz(2,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(2,nn+1,mm+1,ll+1))
      oz = oz + dzp*(acz + dyp*sbxyz(3,nn,mm+1,ll+1)                    
     1                   + dx1*sbxyz(3,nn+1,mm+1,ll+1))
c calculate half impulse
      dx = qtmh*dx
      dy = qtmh*dy
      dz = qtmh*dz
c half acceleration
      acx = ppart(4,j,l) + dx
      acy = ppart(5,j,l) + dy
      acz = ppart(6,j,l) + dz
c find inverse gamma
      p2 = acx*acx + acy*acy + acz*acz
      gami = 1.0/sqrt(1.0 + p2*ci2)
c renormalize magnetic field
      qtmg = qtmh*gami
c time-centered kinetic energy
      sum1 = sum1 + gami*p2/(1.0 + gami)
c calculate cyclotron frequency
      omxt = qtmg*ox
      omyt = qtmg*oy
      omzt = qtmg*oz
c calculate rotation matrix
      omt = omxt*omxt + omyt*omyt + omzt*omzt
      anorm = 2.0/(1.0 + omt)
      omt = 0.5*(1.0 - omt)
      rot4 = omxt*omyt
      rot7 = omxt*omzt
      rot8 = omyt*omzt
      rot1 = omt + omxt*omxt
      rot5 = omt + omyt*omyt
      rot9 = omt + omzt*omzt
      rot2 = omzt + rot4
      rot4 = -omzt + rot4
      rot3 = -omyt + rot7
      rot7 = omyt + rot7
      rot6 = omxt + rot8
      rot8 = -omxt + rot8
c new momentum
      dx = (rot1*acx + rot2*acy + rot3*acz)*anorm + dx
      dy = (rot4*acx + rot5*acy + rot6*acz)*anorm + dy
      dz = (rot7*acx + rot8*acy + rot9*acz)*anorm + dz
      ppart(4,j,l) = dx
      ppart(5,j,l) = dy
      ppart(6,j,l) = dz
c update inverse gamma
      p2 = dx*dx + dy*dy + dz*dz
      dtg = dtc/sqrt(1.0 + p2*ci2)
c new position
      dx = x + dx*dtg
      dy = y + dy*dtg
      dz = z + dz*dtg
c find particles going out of bounds
      mm = 0
c count how many particles are going in each direction in ncl
c save their address and destination in ihole
c use periodic boundary conditions and check for roundoff error
c ist = direction particle is going
      if (dx.ge.edgerx) then
         if (dx.ge.anx) dx = dx - anx
         mm = 2
      else if (dx.lt.edgelx) then
         if (dx.lt.0.0) then
            dx = dx + anx
            if (dx.lt.anx) then
               mm = 1
            else
               dx = 0.0
            endif
         else
            mm = 1
         endif
      endif
      if (dy.ge.edgery) then
         if (dy.ge.any) dy = dy - any
         mm = mm + 6
      else if (dy.lt.edgely) then
         if (dy.lt.0.0) then
            dy = dy + any
            if (dy.lt.any) then
               mm = mm + 3
            else
               dy = 0.0
            endif
         else
            mm = mm + 3
         endif
      endif
      if (dz.ge.edgerz) then
         if (dz.ge.anz) dz = dz - anz
         mm = mm + 18
      else if (dz.lt.edgelz) then
         if (dz.lt.0.0) then
            dz = dz + anz
            if (dz.lt.anz) then
               mm = mm + 9
            else
               dz = 0.0
            endif
         else
            mm = mm + 9
         endif
      endif
c set new position
      ppart(1,j,l) = dx
      ppart(2,j,l) = dy
      ppart(3,j,l) = dz
c increment counters
      if (mm.gt.0) then
         ncl(mm,l) = ncl(mm,l) + 1
         ih = ih + 1
         if (ih.le.ntmax) then
            ihole(1,ih+1,l) = j
            ihole(2,ih+1,l) = mm
         else
            nh = 1
         endif
      endif
   80 continue
      sum2 = sum2 + sum1
c set error and end of file flag
      if (nh.gt.0) then
         irc = ih
         ih = -ih
      endif
      ihole(1,1,l) = ih
   90 continue
!$OMP END PARALLEL DO
c normalize kinetic energy
      ek = ek + sum2
      return
      end
c-----------------------------------------------------------------------
      subroutine GPPOST3L(ppart,q,kpic,qm,nppmx,idimp,mx,my,mz,nxv,nyv, 
     1nzv,mx1,my1,mxyz1)
c for 3d code, this subroutine calculates particle charge density
c using first-order linear interpolation, periodic boundaries
c OpenMP version using guard cells
c data deposited in tiles
c particles stored segmented array
c 33 flops/particle, 11 loads, 8 stores
c input: all, output: q
c charge density is approximated by values at the nearest grid points
c q(n,m,l)=qm*(1.-dx)*(1.-dy)*(1.-dz)
c q(n+1,m,l)=qm*dx*(1.-dy)*(1.-dz)
c q(n,m+1,l)=qm*(1.-dx)*dy*(1.-dz)
c q(n+1,m+1,l)=qm*dx*dy*(1.-dz)
c q(n,m,l+1)=qm*(1.-dx)*(1.-dy)*dz
c q(n+1,m,l+1)=qm*dx*(1.-dy)*dz
c q(n,m+1,l+1)=qm*(1.-dx)*dy*dz
c q(n+1,m+1,l+1)=qm*dx*dy*dz
c where n,m,l = leftmost grid points and dx = x-n, dy = y-m, dz = z-l
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c q(j,k,l) = charge density at grid point j,k,l
c kpic = number of particles per tile
c qm = charge on particle, in units of e
c nppmx = maximum number of particles in tile
c idimp = size of phase space = 6
c mx/my/mz = number of grids in sorting cell in x/y/z
c nxv = first dimension of charge array, must be >= nx+1
c nyv = second dimension of charge array, must be >= ny+1
c nzv = third dimension of charge array, must be >= nz+1
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mxyz1 = mx1*my1*mz1,
c where mz1 = (system length in z direction - 1)/mz + 1
      implicit none
      integer nppmx, idimp, mx, my, mz, nxv, nyv, nzv, mx1, my1, mxyz1
      real qm
      real ppart, q
      integer kpic
      dimension ppart(idimp,nppmx,mxyz1), q(nxv,nyv,nzv)
      dimension kpic(mxyz1)
c local data
      integer MXV, MYV, MZV
      parameter(MXV=17,MYV=17,MZV=17)
      integer mxy1, noff, moff, loff, npp
      integer i, j, k, l, nn, mm, ll, nm, lm
      real x, y, z, dxp, dyp, dzp, amx, amy, amz, dx1
      real sq
c     dimension sq(MXV,MYV,MZV)
      dimension sq(mx+1,my+1,mz+1)
      mxy1 = mx1*my1
c error if local array is too small
c     if ((mx.ge.MXV).or.(my.ge.MYV).or.(mz.ge.MZV)) return
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,noff,moff,loff,npp,nn,mm,ll,nm,lm,x,y,z,dxp,dyp, 
!$OMP& dzp,amx,amy,amz,dx1,sq)
      do 150 l = 1, mxyz1
      loff = (l - 1)/mxy1
      k = l - mxy1*loff
      loff = mz*loff
      noff = (k - 1)/mx1
      moff = my*noff
      noff = mx*(k - mx1*noff - 1)
      npp = kpic(l)
c zero out local accumulator
      do 30 k = 1, mz+1
      do 20 j = 1, my+1
      do 10 i = 1, mx+1
      sq(i,j,k) = 0.0
   10 continue
   20 continue
   30 continue
c loop over particles in tile
      do 40 j = 1, npp
c find interpolation weights
      x = ppart(1,j,l)
      y = ppart(2,j,l)
      z = ppart(3,j,l)
      nn = x
      mm = y
      ll = z
      dxp = qm*(x - real(nn))
      dyp = y - real(mm)
      dzp = z - real(ll)
      nn = nn - noff + 1
      mm = mm - moff + 1
      ll = ll - loff + 1
      amx = qm - dxp
      amy = 1.0 - dyp
      dx1 = dxp*dyp
      dyp = amx*dyp
      amx = amx*amy
      amz = 1.0 - dzp
      amy = dxp*amy
c deposit charge within tile to local accumulator
      x = sq(nn,mm,ll) + amx*amz
      y = sq(nn+1,mm,ll) + amy*amz
      sq(nn,mm,ll) = x
      sq(nn+1,mm,ll) = y
      x = sq(nn,mm+1,ll) + dyp*amz
      y = sq(nn+1,mm+1,ll) + dx1*amz
      sq(nn,mm+1,ll) = x
      sq(nn+1,mm+1,ll) = y
      x = sq(nn,mm,ll+1) + amx*dzp
      y = sq(nn+1,mm,ll+1) + amy*dzp
      sq(nn,mm,ll+1) = x
      sq(nn+1,mm,ll+1) = y
      x = sq(nn,mm+1,ll+1) + dyp*dzp
      y = sq(nn+1,mm+1,ll+1) + dx1*dzp
      sq(nn,mm+1,ll+1) = x
      sq(nn+1,mm+1,ll+1) = y
   40 continue
c deposit charge to interior points in global array
      nn = min(mx,nxv-noff)
      mm = min(my,nyv-moff)
      ll = min(mz,nzv-loff)
      do 70 k = 2, ll
      do 60 j = 2, mm
      do 50 i = 2, nn
      q(i+noff,j+moff,k+loff) = q(i+noff,j+moff,k+loff) + sq(i,j,k)
   50 continue
   60 continue
   70 continue
c deposit charge to edge points in global array
      lm = min(mz+1,nzv-loff)
      do 90 j = 2, mm
      do 80 i = 2, nn
!$OMP ATOMIC
      q(i+noff,j+moff,1+loff) = q(i+noff,j+moff,1+loff) + sq(i,j,1)
      if (lm > mz) then
!$OMP ATOMIC
         q(i+noff,j+moff,lm+loff) = q(i+noff,j+moff,lm+loff)
     1   + sq(i,j,lm)
      endif
   80 continue
   90 continue
      nm = min(mx+1,nxv-noff)
      mm = min(my+1,nyv-moff)
      do 120 k = 1, ll
      do 100 i = 2, nn
!$OMP ATOMIC
      q(i+noff,1+moff,k+loff) = q(i+noff,1+moff,k+loff) + sq(i,1,k)
      if (mm > my) then
!$OMP ATOMIC
         q(i+noff,mm+moff,k+loff) = q(i+noff,mm+moff,k+loff)            
     1   + sq(i,mm,k)
      endif
  100 continue
      do 110 j = 1, mm
!$OMP ATOMIC
      q(1+noff,j+moff,k+loff) = q(1+noff,j+moff,k+loff) + sq(1,j,k)
      if (nm > mx) then
!$OMP ATOMIC
         q(nm+noff,j+moff,k+loff) = q(nm+noff,j+moff,k+loff)            
     1   + sq(nm,j,k)
      endif
  110 continue
  120 continue
      if (lm > mz) then
         do 130 i = 2, nn
!$OMP ATOMIC
         q(i+noff,1+moff,lm+loff) = q(i+noff,1+moff,lm+loff)
     1   + sq(i,1,lm)
         if (mm > my) then
!$OMP ATOMIC
            q(i+noff,mm+moff,lm+loff) = q(i+noff,mm+moff,lm+loff)       
     1      + sq(i,mm,lm)
         endif
  130    continue
         do 140 j = 1, mm
!$OMP ATOMIC
         q(1+noff,j+moff,lm+loff) = q(1+noff,j+moff,lm+loff)            
     1   + sq(1,j,lm)
         if (nm > mx) then
!$OMP ATOMIC
            q(nm+noff,j+moff,lm+loff) = q(nm+noff,j+moff,lm+loff)       
     1      + sq(nm,j,lm)
         endif
  140    continue
      endif
  150 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      subroutine GJPPOST3L(ppart,cu,kpic,qm,dt,nppmx,idimp,nx,ny,nz,mx, 
     1my,mz,nxv,nyv,nzv,mx1,my1,mxyz1,ipbc)
c for 3d code, this subroutine calculates particle current density
c using first-order linear interpolation
c in addition, particle positions are advanced a half time-step
c OpenMP version using guard cells
c data deposited in tiles
c particles stored segmented array
c 69 flops/particle, 30 loads, 27 stores
c input: all, output: ppart, cu
c current density is approximated by values at the nearest grid points
c cu(i,n,m,l)=qci*(1.-dx)*(1.-dy)*(1.-dz)
c cu(i,n+1,m,l)=qci*dx*(1.-dy)*(1.-dz)
c cu(i,n,m+1,l)=qci*(1.-dx)*dy*(1.-dz)
c cu(i,n+1,m+1,l)=qci*dx*dy*(1.-dz)
c cu(i,n,m,l+1)=qci*(1.-dx)*(1.-dy)*dz
c cu(i,n+1,m,l+1)=qci*dx*(1.-dy)*dz
c cu(i,n,m+1,l+1)=qci*(1.-dx)*dy*dz
c cu(i,n+1,m+1,l+1)=qci*dx*dy*dz
c where n,m,l = leftmost grid points and dx = x-n, dy = y-m, dz = z-l
c and qci = qm*vi, where i = x,y,z
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c ppart(4,n,m) = velocity vx of particle n in tile m
c ppart(5,n,m) = velocity vy of particle n in tile m
c ppart(6,n,m) = velocity vz of particle n in tile m
c cu(i,j,k,l) = ith component of current density at grid point j,k,l
c kpic = number of particles per tile
c qm = charge on particle, in units of e
c dt = time interval between successive calculations
c nppmx = maximum number of particles in tile
c idimp = size of phase space = 6
c nx/ny/nz = system length in x/y/z direction
c mx/my/mz = number of grids in sorting cell in x/y/z
c nxv = second dimension of current array, must be >= nx+1
c nyv = third dimension of current array, must be >= ny+1
c nzv = fourth dimension of current array, must be >= nz+1
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mxyz1 = mx1*my1*mz1,
c where mz1 = (system length in z direction - 1)/mz + 1
c ipbc = particle boundary condition = (0,1,2,3) =
c (none,3d periodic,3d reflecting,mixed 2d reflecting/1d periodic)
      implicit none
      integer nppmx, idimp, nx, ny, nz, mx, my, mz, nxv, nyv, nzv
      integer mx1, my1, mxyz1, ipbc
      real qm, dt
      real ppart, cu
      integer kpic
      dimension ppart(idimp,nppmx,mxyz1), cu(3,nxv,nyv,nzv)
      dimension kpic(mxyz1)
c local data
      integer MXV, MYV, MZV
      parameter(MXV=17,MYV=17,MZV=17)
      integer mxy1, noff, moff, loff, npp
      integer i, j, k, l, nn, mm, ll, nm, lm
      real edgelx, edgely, edgelz, edgerx, edgery, edgerz
      real dxp, dyp, dzp, amx, amy, amz, dx1, dx, dy, dz, vx, vy, vz
      real x, y, z
      real scu
      dimension scu(3,MXV,MYV,MZV)
c     dimension scu(3,mx+1,my+1,mz+1)
      mxy1 = mx1*my1
c set boundary values
      edgelx = 0.0
      edgely = 0.0
      edgelz = 0.0
      edgerx = real(nx)
      edgery = real(ny)
      edgerz = real(nz)
      if (ipbc.eq.2) then
         edgelx = 1.0
         edgely = 1.0
         edgelz = 1.0
         edgerx = real(nx-1)
         edgery = real(ny-1)
         edgerz = real(nz-1)
      else if (ipbc.eq.3) then
         edgelx = 1.0
         edgely = 1.0
         edgerx = real(nx-1)
         edgery = real(ny-1)
      endif
c error if local array is too small
c     if ((mx.ge.MXV).or.(my.ge.MYV).or.(mz.ge.MZV)) return
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,noff,moff,loff,npp,nn,mm,ll,nm,lm,x,y,z,dxp,dyp, 
!$OMP& dzp,amx,amy,amz,dx1,dx,dy,dz,vx,vy,vz,scu)
      do 150 l = 1, mxyz1
      loff = (l - 1)/mxy1
      k = l - mxy1*loff
      loff = mz*loff
      noff = (k - 1)/mx1
      moff = my*noff
      noff = mx*(k - mx1*noff - 1)
      npp = kpic(l)
c zero out local accumulator
      do 30 k = 1, mz+1
      do 20 j = 1, my+1
      do 10 i = 1, mx+1
      scu(1,i,j,k) = 0.0
      scu(2,i,j,k) = 0.0
      scu(3,i,j,k) = 0.0
   10 continue
   20 continue
   30 continue
c loop over particles in tile
      do 40 j = 1, npp
c find interpolation weights
      x = ppart(1,j,l)
      y = ppart(2,j,l)
      z = ppart(3,j,l)
      nn = x
      mm = y
      ll = z
      dxp = qm*(x - real(nn))
      dyp = y - real(mm)
      dzp = z - real(ll)
      nn = nn - noff + 1
      mm = mm - moff + 1
      ll = ll - loff + 1
      amx = qm - dxp
      amy = 1.0 - dyp
      dx1 = dxp*dyp
      dyp = amx*dyp
      amx = amx*amy
      amz = 1.0 - dzp
      amy = dxp*amy
c deposit current within tile to local accumulator
      dx = amx*amz
      dy = amy*amz
      vx = ppart(4,j,l)
      vy = ppart(5,j,l)
      vz = ppart(6,j,l)
      scu(1,nn,mm,ll) = scu(1,nn,mm,ll) + vx*dx
      scu(2,nn,mm,ll) = scu(2,nn,mm,ll) + vy*dx
      scu(3,nn,mm,ll) = scu(3,nn,mm,ll) + vz*dx
      dx = dyp*amz
      scu(1,nn+1,mm,ll) = scu(1,nn+1,mm,ll) + vx*dy
      scu(2,nn+1,mm,ll) = scu(2,nn+1,mm,ll) + vy*dy
      scu(3,nn+1,mm,ll) = scu(3,nn+1,mm,ll) + vz*dy
      dy = dx1*amz
      scu(1,nn,mm+1,ll) = scu(1,nn,mm+1,ll) + vx*dx
      scu(2,nn,mm+1,ll) = scu(2,nn,mm+1,ll) + vy*dx
      scu(3,nn,mm+1,ll) = scu(3,nn,mm+1,ll) + vz*dx
      dx = amx*dzp
      scu(1,nn+1,mm+1,ll) = scu(1,nn+1,mm+1,ll) + vx*dy
      scu(2,nn+1,mm+1,ll) = scu(2,nn+1,mm+1,ll) + vy*dy
      scu(3,nn+1,mm+1,ll) = scu(3,nn+1,mm+1,ll) + vz*dy
      dy = amy*dzp
      scu(1,nn,mm,ll+1) = scu(1,nn,mm,ll+1) + vx*dx
      scu(2,nn,mm,ll+1) = scu(2,nn,mm,ll+1) + vy*dx
      scu(3,nn,mm,ll+1) = scu(3,nn,mm,ll+1) + vz*dx
      dx = dyp*dzp
      scu(1,nn+1,mm,ll+1) = scu(1,nn+1,mm,ll+1) + vx*dy
      scu(2,nn+1,mm,ll+1) = scu(2,nn+1,mm,ll+1) + vy*dy
      scu(3,nn+1,mm,ll+1) = scu(3,nn+1,mm,ll+1) + vz*dy
      dy = dx1*dzp
      scu(1,nn,mm+1,ll+1) = scu(1,nn,mm+1,ll+1) + vx*dx
      scu(2,nn,mm+1,ll+1) = scu(2,nn,mm+1,ll+1) + vy*dx
      scu(3,nn,mm+1,ll+1) = scu(3,nn,mm+1,ll+1) + vz*dx
      scu(1,nn+1,mm+1,ll+1) = scu(1,nn+1,mm+1,ll+1) + vx*dy
      scu(2,nn+1,mm+1,ll+1) = scu(2,nn+1,mm+1,ll+1) + vy*dy
      scu(3,nn+1,mm+1,ll+1) = scu(3,nn+1,mm+1,ll+1) + vz*dy
c advance position half a time-step
      dx = x + vx*dt
      dy = y + vy*dt
      dz = z + vz*dt
c reflecting boundary conditions
      if (ipbc.eq.2) then
         if ((dx.lt.edgelx).or.(dx.ge.edgerx)) then
            dx = x
            ppart(4,j,l) = -vx
         endif
         if ((dy.lt.edgely).or.(dy.ge.edgery)) then
            dy = y
            ppart(5,j,l) = -vy
         endif
         if ((dz.lt.edgelz).or.(dz.ge.edgerz)) then
            dz = z
            ppart(6,j,l) = -vz
         endif
c mixed reflecting/periodic boundary conditions
      else if (ipbc.eq.3) then
         if ((dx.lt.edgelx).or.(dx.ge.edgerx)) then
            dx = x
            ppart(4,j,l) = -vx
         endif
         if ((dy.lt.edgely).or.(dy.ge.edgery)) then
            dy = y
            ppart(5,j,l) = -vy
         endif
      endif
c set new position
      ppart(1,j,l) = dx
      ppart(2,j,l) = dy
      ppart(3,j,l) = dz
   40 continue
c deposit current to interior points in global array
      nn = min(mx,nxv-noff)
      mm = min(my,nyv-moff)
      ll = min(mz,nzv-loff)
      do 70 k = 2, ll
      do 60 j = 2, mm
      do 50 i = 2, nn
      cu(1,i+noff,j+moff,k+loff) = cu(1,i+noff,j+moff,k+loff)           
     1+ scu(1,i,j,k)
      cu(2,i+noff,j+moff,k+loff) = cu(2,i+noff,j+moff,k+loff)           
     1+ scu(2,i,j,k)
      cu(3,i+noff,j+moff,k+loff) = cu(3,i+noff,j+moff,k+loff)           
     1+ scu(3,i,j,k)
   50 continue
   60 continue
   70 continue
c deposit current to edge points in global array
      lm = min(mz+1,nzv-loff)
      do 90 j = 2, mm
      do 80 i = 2, nn
!$OMP ATOMIC
      cu(1,i+noff,j+moff,1+loff) = cu(1,i+noff,j+moff,1+loff)           
     1+ scu(1,i,j,1)
!$OMP ATOMIC
      cu(2,i+noff,j+moff,1+loff) = cu(2,i+noff,j+moff,1+loff)           
     1+ scu(2,i,j,1)
!$OMP ATOMIC
      cu(3,i+noff,j+moff,1+loff) = cu(3,i+noff,j+moff,1+loff)           
     1+ scu(3,i,j,1)
      if (lm > mz) then
!$OMP ATOMIC
         cu(1,i+noff,j+moff,lm+loff) = cu(1,i+noff,j+moff,lm+loff)      
     1   + scu(1,i,j,lm)
!$OMP ATOMIC
         cu(2,i+noff,j+moff,lm+loff) = cu(2,i+noff,j+moff,lm+loff)      
     1   + scu(2,i,j,lm)
!$OMP ATOMIC
         cu(3,i+noff,j+moff,lm+loff) = cu(3,i+noff,j+moff,lm+loff)      
     1   + scu(3,i,j,lm)
      endif
   80 continue
   90 continue
      nm = min(mx+1,nxv-noff)
      mm = min(my+1,nyv-moff)
      do 120 k = 1, ll
      do 100 i = 2, nn
!$OMP ATOMIC
      cu(1,i+noff,1+moff,k+loff) = cu(1,i+noff,1+moff,k+loff)           
     1+ scu(1,i,1,k)
!$OMP ATOMIC
      cu(2,i+noff,1+moff,k+loff) = cu(2,i+noff,1+moff,k+loff)           
     1+ scu(2,i,1,k)
!$OMP ATOMIC
      cu(3,i+noff,1+moff,k+loff) = cu(3,i+noff,1+moff,k+loff)           
     1+ scu(3,i,1,k)
      if (mm > my) then
!$OMP ATOMIC
         cu(1,i+noff,mm+moff,k+loff) = cu(1,i+noff,mm+moff,k+loff)      
     1   + scu(1,i,mm,k)
!$OMP ATOMIC
         cu(2,i+noff,mm+moff,k+loff) = cu(2,i+noff,mm+moff,k+loff)      
     1   + scu(2,i,mm,k)
!$OMP ATOMIC
         cu(3,i+noff,mm+moff,k+loff) = cu(3,i+noff,mm+moff,k+loff)      
     1   + scu(3,i,mm,k)
      endif
  100 continue
      do 110 j = 1, mm
!$OMP ATOMIC
      cu(1,1+noff,j+moff,k+loff) = cu(1,1+noff,j+moff,k+loff)           
     1+ scu(1,1,j,k)
!$OMP ATOMIC
      cu(2,1+noff,j+moff,k+loff) = cu(2,1+noff,j+moff,k+loff)           
     1+ scu(2,1,j,k)
!$OMP ATOMIC
      cu(3,1+noff,j+moff,k+loff) = cu(3,1+noff,j+moff,k+loff)           
     1+ scu(3,1,j,k)
      if (nm > mx) then
!$OMP ATOMIC
         cu(1,nm+noff,j+moff,k+loff) = cu(1,nm+noff,j+moff,k+loff)      
     1   + scu(1,nm,j,k)
!$OMP ATOMIC
         cu(2,nm+noff,j+moff,k+loff) = cu(2,nm+noff,j+moff,k+loff)      
     1   + scu(2,nm,j,k)
!$OMP ATOMIC
         cu(3,nm+noff,j+moff,k+loff) = cu(3,nm+noff,j+moff,k+loff)      
     1   + scu(3,nm,j,k)
      endif
  110 continue
  120 continue
      if (lm > mz) then
         do 130 i = 2, nn
!$OMP ATOMIC
         cu(1,i+noff,1+moff,lm+loff) = cu(1,i+noff,1+moff,lm+loff)      
     1   + scu(1,i,1,lm)
!$OMP ATOMIC
         cu(2,i+noff,1+moff,lm+loff) = cu(2,i+noff,1+moff,lm+loff)      
     1   + scu(2,i,1,lm)
!$OMP ATOMIC
         cu(3,i+noff,1+moff,lm+loff) = cu(3,i+noff,1+moff,lm+loff)      
     1   + scu(3,i,1,lm)
         if (mm > my) then
!$OMP ATOMIC
            cu(1,i+noff,mm+moff,lm+loff) = cu(1,i+noff,mm+moff,lm+loff) 
     1      + scu(1,i,mm,lm)
!$OMP ATOMIC
            cu(2,i+noff,mm+moff,lm+loff) = cu(2,i+noff,mm+moff,lm+loff) 
     1      + scu(2,i,mm,lm)
!$OMP ATOMIC
            cu(3,i+noff,mm+moff,lm+loff) = cu(3,i+noff,mm+moff,lm+loff) 
     1      + scu(3,i,mm,lm)
         endif
  130    continue
         do 140 j = 1, mm
!$OMP ATOMIC
         cu(1,1+noff,j+moff,lm+loff) = cu(1,1+noff,j+moff,lm+loff)      
     1   + scu(1,1,j,lm)
!$OMP ATOMIC
         cu(2,1+noff,j+moff,lm+loff) = cu(2,1+noff,j+moff,lm+loff)      
     1   + scu(2,1,j,lm)
!$OMP ATOMIC
         cu(3,1+noff,j+moff,lm+loff) = cu(3,1+noff,j+moff,lm+loff)      
     1   + scu(3,1,j,lm)
         if (nm > mx) then
!$OMP ATOMIC
            cu(1,nm+noff,j+moff,lm+loff) = cu(1,nm+noff,j+moff,lm+loff) 
     1      + scu(1,nm,j,lm)
!$OMP ATOMIC
            cu(2,nm+noff,j+moff,lm+loff) = cu(2,nm+noff,j+moff,lm+loff) 
     1      + scu(2,nm,j,lm)
!$OMP ATOMIC
            cu(3,nm+noff,j+moff,lm+loff) = cu(3,nm+noff,j+moff,lm+loff) 
     1      + scu(3,nm,j,lm)
         endif
  140    continue
      endif
  150 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      subroutine GJPPOSTF3L(ppart,cu,kpic,ncl,ihole,qm,dt,nppmx,idimp,nx
     1,ny,nz,mx,my,mz,nxv,nyv,nzv,mx1,my1,mxyz1,ntmax,irc)
c for 3d code, this subroutine calculates particle current density
c using first-order linear interpolation
c in addition, particle positions are advanced a half time-step
c with periodic boundary conditions.
c also determines list of particles which are leaving this tile
c OpenMP version using guard cells
c data deposited in tiles
c particles stored segmented array
c 69 flops/particle, 30 loads, 27 stores
c input: all except ncl, ihole, irc,
c output: ppart, cu, ncl, ihole, irc
c current density is approximated by values at the nearest grid points
c cu(i,n,m,l)=qci*(1.-dx)*(1.-dy)*(1.-dz)
c cu(i,n+1,m,l)=qci*dx*(1.-dy)*(1.-dz)
c cu(i,n,m+1,l)=qci*(1.-dx)*dy*(1.-dz)
c cu(i,n+1,m+1,l)=qci*dx*dy*(1.-dz)
c cu(i,n,m,l+1)=qci*(1.-dx)*(1.-dy)*dz
c cu(i,n+1,m,l+1)=qci*dx*(1.-dy)*dz
c cu(i,n,m+1,l+1)=qci*(1.-dx)*dy*dz
c cu(i,n+1,m+1,l+1)=qci*dx*dy*dz
c where n,m,l = leftmost grid points and dx = x-n, dy = y-m, dz = z-l
c and qci = qm*vi, where i = x,y,z
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c ppart(4,n,m) = velocity vx of particle n in tile m
c ppart(5,n,m) = velocity vy of particle n in tile m
c ppart(6,n,m) = velocity vz of particle n in tile m
c cu(i,j,k,l) = ith component of current density at grid point j,k,l
c kpic(l) = number of particles in tile l
c ncl(i,l) = number of particles going to destination i, tile l
c ihole(1,:,l) = location of hole in array left by departing particle
c ihole(2,:,l) = direction destination of particle leaving hole
c all for tile l
c ihole(1,1,l) = ih, number of holes left (error, if negative)
c qm = charge on particle, in units of e
c dt = time interval between successive calculations
c nppmx = maximum number of particles in tile
c idimp = size of phase space = 6
c nx/ny/nz = system length in x/y/z direction
c mx/my/mz = number of grids in sorting cell in x/y/z
c nxv = second dimension of current array, must be >= nx+1
c nyv = third dimension of current array, must be >= ny+1
c nzv = fourth dimension of current array, must be >= nz+1
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mxyz1 = mx1*my1*mz1,
c where mz1 = (system length in z direction - 1)/mz + 1
c ntmax = size of hole array for particles leaving tiles
c irc = maximum overflow, returned only if error occurs, when irc > 0
c optimized version
      implicit none
      integer nppmx, idimp, nx, ny, nz, mx, my, mz, nxv, nyv, nzv
      integer mx1, my1, mxyz1, ntmax, irc
      real qm, dt
      real ppart, cu
      integer kpic, ncl, ihole
      dimension ppart(idimp,nppmx,mxyz1), cu(3,nxv,nyv,nzv)
      dimension kpic(mxyz1), ncl(26,mxyz1)
      dimension ihole(2,ntmax+1,mxyz1)
c local data
      integer MXV, MYV, MZV
      parameter(MXV=17,MYV=17,MZV=17)
      integer mxy1, noff, moff, loff, npp
      integer i, j, k, l, ih, nh, nn, mm, ll, nm, lm
      real anx, any, anz, edgelx, edgely, edgelz, edgerx, edgery, edgerz
      real dxp, dyp, dzp, amx, amy, amz, dx1, dx, dy, dz, vx, vy, vz
      real x, y, z
      real scu
      dimension scu(3,MXV,MYV,MZV)
c     dimension scu(3,mx+1,my+1,mz+1)
      mxy1 = mx1*my1
      anx = real(nx)
      any = real(ny)
      anz = real(nz)
c error if local array is too small
c     if ((mx.ge.MXV).or.(my.ge.MYV).or.(mz.ge.MZV)) return
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,noff,moff,loff,npp,nn,mm,ll,nm,lm,ih,nh,x,y,z,dxp
!$OMP& ,dyp,dzp,amx,amy,amz,dx1,dx,dy,dz,vx,vy,vz,edgelx,edgely,edgelz, 
!$OMP& edgerx,edgery,edgerz,scu)
      do 160 l = 1, mxyz1
      loff = (l - 1)/mxy1
      k = l - mxy1*loff
      loff = mz*loff
      noff = (k - 1)/mx1
      moff = my*noff
      noff = mx*(k - mx1*noff - 1)
      npp = kpic(l)
      nn = min(mx,nx-noff)
      mm = min(my,ny-moff)
      ll = min(mz,nz-loff)
      edgelx = noff
      edgerx = noff + nn
      edgely = moff
      edgery = moff + mm
      edgelz = loff
      edgerz = loff + ll
      ih = 0
      nh = 0
c zero out local accumulator
      do 30 k = 1, mz+1
      do 20 j = 1, my+1
      do 10 i = 1, mx+1
      scu(1,i,j,k) = 0.0
      scu(2,i,j,k) = 0.0
      scu(3,i,j,k) = 0.0
   10 continue
   20 continue
   30 continue
c clear counters
      do 40 j = 1, 26
      ncl(j,l) = 0
   40 continue
c loop over particles in tile
      do 50 j = 1, npp
c find interpolation weights
      x = ppart(1,j,l)
      y = ppart(2,j,l)
      z = ppart(3,j,l)
      nn = x
      mm = y
      ll = z
      dxp = qm*(x - real(nn))
      dyp = y - real(mm)
      dzp = z - real(ll)
      nn = nn - noff + 1
      mm = mm - moff + 1
      ll = ll - loff + 1
      amx = qm - dxp
      amy = 1.0 - dyp
      dx1 = dxp*dyp
      dyp = amx*dyp
      amx = amx*amy
      amz = 1.0 - dzp
      amy = dxp*amy
c deposit current within tile to local accumulator
      dx = amx*amz
      dy = amy*amz
      vx = ppart(4,j,l)
      vy = ppart(5,j,l)
      vz = ppart(6,j,l)
      scu(1,nn,mm,ll) = scu(1,nn,mm,ll) + vx*dx
      scu(2,nn,mm,ll) = scu(2,nn,mm,ll) + vy*dx
      scu(3,nn,mm,ll) = scu(3,nn,mm,ll) + vz*dx
      dx = dyp*amz
      scu(1,nn+1,mm,ll) = scu(1,nn+1,mm,ll) + vx*dy
      scu(2,nn+1,mm,ll) = scu(2,nn+1,mm,ll) + vy*dy
      scu(3,nn+1,mm,ll) = scu(3,nn+1,mm,ll) + vz*dy
      dy = dx1*amz
      scu(1,nn,mm+1,ll) = scu(1,nn,mm+1,ll) + vx*dx
      scu(2,nn,mm+1,ll) = scu(2,nn,mm+1,ll) + vy*dx
      scu(3,nn,mm+1,ll) = scu(3,nn,mm+1,ll) + vz*dx
      dx = amx*dzp
      scu(1,nn+1,mm+1,ll) = scu(1,nn+1,mm+1,ll) + vx*dy
      scu(2,nn+1,mm+1,ll) = scu(2,nn+1,mm+1,ll) + vy*dy
      scu(3,nn+1,mm+1,ll) = scu(3,nn+1,mm+1,ll) + vz*dy
      dy = amy*dzp
      scu(1,nn,mm,ll+1) = scu(1,nn,mm,ll+1) + vx*dx
      scu(2,nn,mm,ll+1) = scu(2,nn,mm,ll+1) + vy*dx
      scu(3,nn,mm,ll+1) = scu(3,nn,mm,ll+1) + vz*dx
      dx = dyp*dzp
      scu(1,nn+1,mm,ll+1) = scu(1,nn+1,mm,ll+1) + vx*dy
      scu(2,nn+1,mm,ll+1) = scu(2,nn+1,mm,ll+1) + vy*dy
      scu(3,nn+1,mm,ll+1) = scu(3,nn+1,mm,ll+1) + vz*dy
      dy = dx1*dzp
      scu(1,nn,mm+1,ll+1) = scu(1,nn,mm+1,ll+1) + vx*dx
      scu(2,nn,mm+1,ll+1) = scu(2,nn,mm+1,ll+1) + vy*dx
      scu(3,nn,mm+1,ll+1) = scu(3,nn,mm+1,ll+1) + vz*dx
      scu(1,nn+1,mm+1,ll+1) = scu(1,nn+1,mm+1,ll+1) + vx*dy
      scu(2,nn+1,mm+1,ll+1) = scu(2,nn+1,mm+1,ll+1) + vy*dy
      scu(3,nn+1,mm+1,ll+1) = scu(3,nn+1,mm+1,ll+1) + vz*dy
c advance position half a time-step
      dx = x + vx*dt
      dy = y + vy*dt
      dz = z + vz*dt
c find particles going out of bounds
      mm = 0
c count how many particles are going in each direction in ncl
c save their address and destination in ihole
c use periodic boundary conditions and check for roundoff error
c ist = direction particle is going
      if (dx.ge.edgerx) then
         if (dx.ge.anx) dx = dx - anx
         mm = 2
      else if (dx.lt.edgelx) then
         if (dx.lt.0.0) then
            dx = dx + anx
            if (dx.lt.anx) then
               mm = 1
            else
               dx = 0.0
            endif
         else
            mm = 1
         endif
      endif
      if (dy.ge.edgery) then
         if (dy.ge.any) dy = dy - any
         mm = mm + 6
      else if (dy.lt.edgely) then
         if (dy.lt.0.0) then
            dy = dy + any
            if (dy.lt.any) then
               mm = mm + 3
            else
               dy = 0.0
            endif
         else
            mm = mm + 3
         endif
      endif
      if (dz.ge.edgerz) then
         if (dz.ge.anz) dz = dz - anz
         mm = mm + 18
      else if (dz.lt.edgelz) then
         if (dz.lt.0.0) then
            dz = dz + anz
            if (dz.lt.anz) then
               mm = mm + 9
            else
               dz = 0.0
            endif
         else
            mm = mm + 9
         endif
      endif
c set new position
      ppart(1,j,l) = dx
      ppart(2,j,l) = dy
      ppart(3,j,l) = dz
c increment counters
      if (mm.gt.0) then
         ncl(mm,l) = ncl(mm,l) + 1
         ih = ih + 1
         if (ih.le.ntmax) then
            ihole(1,ih+1,l) = j
            ihole(2,ih+1,l) = mm
         else
            nh = 1
         endif
      endif
   50 continue
c deposit current to interior points in global array
      nn = min(mx,nxv-noff)
      mm = min(my,nyv-moff)
      ll = min(mz,nzv-loff)
      do 80 k = 2, ll
      do 70 j = 2, mm
      do 60 i = 2, nn
      cu(1,i+noff,j+moff,k+loff) = cu(1,i+noff,j+moff,k+loff)           
     1+ scu(1,i,j,k)
      cu(2,i+noff,j+moff,k+loff) = cu(2,i+noff,j+moff,k+loff)           
     1+ scu(2,i,j,k)
      cu(3,i+noff,j+moff,k+loff) = cu(3,i+noff,j+moff,k+loff)           
     1+ scu(3,i,j,k)
   60 continue
   70 continue
   80 continue
c deposit current to edge points in global array
      lm = min(mz+1,nzv-loff)
      do 100 j = 2, mm
      do 90 i = 2, nn
!$OMP ATOMIC
      cu(1,i+noff,j+moff,1+loff) = cu(1,i+noff,j+moff,1+loff)           
     1+ scu(1,i,j,1)
!$OMP ATOMIC
      cu(2,i+noff,j+moff,1+loff) = cu(2,i+noff,j+moff,1+loff)           
     1+ scu(2,i,j,1)
!$OMP ATOMIC
      cu(3,i+noff,j+moff,1+loff) = cu(3,i+noff,j+moff,1+loff)           
     1+ scu(3,i,j,1)
      if (lm > mz) then
!$OMP ATOMIC
         cu(1,i+noff,j+moff,lm+loff) = cu(1,i+noff,j+moff,lm+loff)      
     1   + scu(1,i,j,lm)
!$OMP ATOMIC
         cu(2,i+noff,j+moff,lm+loff) = cu(2,i+noff,j+moff,lm+loff)      
     1   + scu(2,i,j,lm)
!$OMP ATOMIC
         cu(3,i+noff,j+moff,lm+loff) = cu(3,i+noff,j+moff,lm+loff)      
     1   + scu(3,i,j,lm)
      endif
   90 continue
  100 continue
      nm = min(mx+1,nxv-noff)
      mm = min(my+1,nyv-moff)
      do 130 k = 1, ll
      do 110 i = 2, nn
!$OMP ATOMIC
      cu(1,i+noff,1+moff,k+loff) = cu(1,i+noff,1+moff,k+loff)           
     1+ scu(1,i,1,k)
!$OMP ATOMIC
      cu(2,i+noff,1+moff,k+loff) = cu(2,i+noff,1+moff,k+loff)           
     1+ scu(2,i,1,k)
!$OMP ATOMIC
      cu(3,i+noff,1+moff,k+loff) = cu(3,i+noff,1+moff,k+loff)           
     1+ scu(3,i,1,k)
      if (mm > my) then
!$OMP ATOMIC
         cu(1,i+noff,mm+moff,k+loff) = cu(1,i+noff,mm+moff,k+loff)      
     1   + scu(1,i,mm,k)
!$OMP ATOMIC
         cu(2,i+noff,mm+moff,k+loff) = cu(2,i+noff,mm+moff,k+loff)      
     1   + scu(2,i,mm,k)
!$OMP ATOMIC
         cu(3,i+noff,mm+moff,k+loff) = cu(3,i+noff,mm+moff,k+loff)      
     1   + scu(3,i,mm,k)
      endif
  110 continue
      do 120 j = 1, mm
!$OMP ATOMIC
      cu(1,1+noff,j+moff,k+loff) = cu(1,1+noff,j+moff,k+loff)           
     1+ scu(1,1,j,k)
!$OMP ATOMIC
      cu(2,1+noff,j+moff,k+loff) = cu(2,1+noff,j+moff,k+loff)           
     1+ scu(2,1,j,k)
!$OMP ATOMIC
      cu(3,1+noff,j+moff,k+loff) = cu(3,1+noff,j+moff,k+loff)           
     1+ scu(3,1,j,k)
      if (nm > mx) then
!$OMP ATOMIC
         cu(1,nm+noff,j+moff,k+loff) = cu(1,nm+noff,j+moff,k+loff)      
     1   + scu(1,nm,j,k)
!$OMP ATOMIC
         cu(2,nm+noff,j+moff,k+loff) = cu(2,nm+noff,j+moff,k+loff)      
     1   + scu(2,nm,j,k)
!$OMP ATOMIC
         cu(3,nm+noff,j+moff,k+loff) = cu(3,nm+noff,j+moff,k+loff)      
     1   + scu(3,nm,j,k)
      endif
  120 continue
  130 continue
      if (lm > mz) then
         do 140 i = 2, nn
!$OMP ATOMIC
         cu(1,i+noff,1+moff,lm+loff) = cu(1,i+noff,1+moff,lm+loff)      
     1   + scu(1,i,1,lm)
!$OMP ATOMIC
         cu(2,i+noff,1+moff,lm+loff) = cu(2,i+noff,1+moff,lm+loff)      
     1   + scu(2,i,1,lm)
!$OMP ATOMIC
         cu(3,i+noff,1+moff,lm+loff) = cu(3,i+noff,1+moff,lm+loff)      
     1   + scu(3,i,1,lm)
         if (mm > my) then
!$OMP ATOMIC
            cu(1,i+noff,mm+moff,lm+loff) = cu(1,i+noff,mm+moff,lm+loff) 
     1      + scu(1,i,mm,lm)
!$OMP ATOMIC
            cu(2,i+noff,mm+moff,lm+loff) = cu(2,i+noff,mm+moff,lm+loff) 
     1      + scu(2,i,mm,lm)
!$OMP ATOMIC
            cu(3,i+noff,mm+moff,lm+loff) = cu(3,i+noff,mm+moff,lm+loff) 
     1      + scu(3,i,mm,lm)
         endif
  140    continue
         do 150 j = 1, mm
!$OMP ATOMIC
         cu(1,1+noff,j+moff,lm+loff) = cu(1,1+noff,j+moff,lm+loff)      
     1   + scu(1,1,j,lm)
!$OMP ATOMIC
         cu(2,1+noff,j+moff,lm+loff) = cu(2,1+noff,j+moff,lm+loff)      
     1   + scu(2,1,j,lm)
!$OMP ATOMIC
         cu(3,1+noff,j+moff,lm+loff) = cu(3,1+noff,j+moff,lm+loff)      
     1   + scu(3,1,j,lm)
         if (nm > mx) then
!$OMP ATOMIC
            cu(1,nm+noff,j+moff,lm+loff) = cu(1,nm+noff,j+moff,lm+loff) 
     1      + scu(1,nm,j,lm)
!$OMP ATOMIC
            cu(2,nm+noff,j+moff,lm+loff) = cu(2,nm+noff,j+moff,lm+loff) 
     1      + scu(2,nm,j,lm)
!$OMP ATOMIC
            cu(3,nm+noff,j+moff,lm+loff) = cu(3,nm+noff,j+moff,lm+loff) 
     1      + scu(3,nm,j,lm)
         endif
  150    continue
      endif
c set error and end of file flag
      if (nh.gt.0) then
         irc = ih
         ih = -ih
      endif
      ihole(1,1,l) = ih
  160 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      subroutine GRJPPOST3L(ppart,cu,kpic,qm,dt,ci,nppmx,idimp,nx,ny,nz,
     1mx,my,mz,nxv,nyv,nzv,mx1,my1,mxyz1,ipbc)
c for 3d code, this subroutine calculates particle current density
c using first-order linear interpolation for relativistic particles
c in addition, particle positions are advanced a half time-step
c OpenMP version using guard cells
c data deposited in tiles
c particles stored segmented array
c 79 flops/particle, 1 divide, 1 sqrt, 30 loads, 27 stores
c input: all, output: ppart, cu
c current density is approximated by values at the nearest grid points
c cu(i,n,m,l)=qci*(1.-dx)*(1.-dy)*(1.-dz)
c cu(i,n+1,m,l)=qci*dx*(1.-dy)*(1.-dz)
c cu(i,n,m+1,l)=qci*(1.-dx)*dy*(1.-dz)
c cu(i,n+1,m+1,l)=qci*dx*dy*(1.-dz)
c cu(i,n,m,l+1)=qci*(1.-dx)*(1.-dy)*dz
c cu(i,n+1,m,l+1)=qci*dx*(1.-dy)*dz
c cu(i,n,m+1,l+1)=qci*(1.-dx)*dy*dz
c cu(i,n+1,m+1,l+1)=qci*dx*dy*dz
c where n,m,l = leftmost grid points and dx = x-n, dy = y-m, dz = z-l
c and qci = qm*pi*gami, where i = x,y,z
c where gami = 1./sqrt(1.+sum(pi**2)*ci*ci)
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c ppart(4,n,m) = x momentum of particle n in tile m
c ppart(5,n,m) = y momentum of particle n in tile m
c ppart(6,n,m) = z momentum of particle n in tile m
c cu(i,j,k,l) = ith component of current density at grid point j,k,l
c kpic = number of particles per tile
c qm = charge on particle, in units of e
c dt = time interval between successive calculations
c ci = reciprocal of velocity of light
c nppmx = maximum number of particles in tile
c idimp = size of phase space = 6
c nx/ny/nz = system length in x/y/z direction
c mx/my/mz = number of grids in sorting cell in x/y/z
c nxv = second dimension of current array, must be >= nx+1
c nyv = third dimension of current array, must be >= ny+1
c nzv = fourth dimension of current array, must be >= nz+1
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mxyz1 = mx1*my1*mz1,
c where mz1 = (system length in z direction - 1)/mz + 1
c ipbc = particle boundary condition = (0,1,2,3) =
c (none,3d periodic,3d reflecting,mixed 2d reflecting/1d periodic)
      implicit none
      integer nppmx, idimp, nx, ny, nz, mx, my, mz, nxv, nyv, nzv
      integer mx1, my1, mxyz1, ipbc
      real qm, dt, ci
      real ppart, cu
      integer kpic
      dimension ppart(idimp,nppmx,mxyz1), cu(3,nxv,nyv,nzv)
      dimension kpic(mxyz1)
c local data
      integer MXV, MYV, MZV
      parameter(MXV=17,MYV=17,MZV=17)
      integer mxy1, noff, moff, loff, npp
      integer i, j, k, l, nn, mm, ll, nm, lm
      real ci2, edgelx, edgely, edgelz, edgerx, edgery, edgerz
      real dxp, dyp, dzp, amx, amy, amz, dx1, dx, dy, dz, vx, vy, vz
      real x, y, z, p2, gami
      real scu
      dimension scu(3,MXV,MYV,MZV)
c     dimension scu(3,mx+1,my+1,mz+1)
      mxy1 = mx1*my1
      ci2 = ci*ci
c set boundary values
      edgelx = 0.0
      edgely = 0.0
      edgelz = 0.0
      edgerx = real(nx)
      edgery = real(ny)
      edgerz = real(nz)
      if (ipbc.eq.2) then
         edgelx = 1.0
         edgely = 1.0
         edgelz = 1.0
         edgerx = real(nx-1)
         edgery = real(ny-1)
         edgerz = real(nz-1)
      else if (ipbc.eq.3) then
         edgelx = 1.0
         edgely = 1.0
         edgerx = real(nx-1)
         edgery = real(ny-1)
      endif
c error if local array is too small
c     if ((mx.ge.MXV).or.(my.ge.MYV).or.(mz.ge.MZV)) return
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,noff,moff,loff,npp,nn,mm,ll,nm,lm,x,y,z,dxp,dyp, 
!$OMP& dzp,amx,amy,amz,dx1,dx,dy,dz,vx,vy,vz,p2,gami,scu)
      do 150 l = 1, mxyz1
      loff = (l - 1)/mxy1
      k = l - mxy1*loff
      loff = mz*loff
      noff = (k - 1)/mx1
      moff = my*noff
      noff = mx*(k - mx1*noff - 1)
      npp = kpic(l)
c zero out local accumulator
      do 30 k = 1, mz+1
      do 20 j = 1, my+1
      do 10 i = 1, mx+1
      scu(1,i,j,k) = 0.0
      scu(2,i,j,k) = 0.0
      scu(3,i,j,k) = 0.0
   10 continue
   20 continue
   30 continue
c loop over particles in tile
      do 40 j = 1, npp
c find interpolation weights
      x = ppart(1,j,l)
      y = ppart(2,j,l)
      z = ppart(3,j,l)
      nn = x
      mm = y
      ll = z
      dxp = qm*(x - real(nn))
      dyp = y - real(mm)
      dzp = z - real(ll)
c find inverse gamma
      vx = ppart(4,j,l)
      vy = ppart(5,j,l)
      vz = ppart(6,j,l)
      p2 = vx*vx + vy*vy + vz*vz
      gami = 1.0/sqrt(1.0 + p2*ci2)
c calculate weights
      nn = nn - noff + 1
      mm = mm - moff + 1
      ll = ll - loff + 1
      amx = qm - dxp
      amy = 1.0 - dyp
      dx1 = dxp*dyp
      dyp = amx*dyp
      amx = amx*amy
      amz = 1.0 - dzp
      amy = dxp*amy
c deposit current within tile to local accumulator
      dx = amx*amz
      dy = amy*amz
      vx = vx*gami
      vy = vy*gami
      vz = vz*gami
      scu(1,nn,mm,ll) = scu(1,nn,mm,ll) + vx*dx
      scu(2,nn,mm,ll) = scu(2,nn,mm,ll) + vy*dx
      scu(3,nn,mm,ll) = scu(3,nn,mm,ll) + vz*dx
      dx = dyp*amz
      scu(1,nn+1,mm,ll) = scu(1,nn+1,mm,ll) + vx*dy
      scu(2,nn+1,mm,ll) = scu(2,nn+1,mm,ll) + vy*dy
      scu(3,nn+1,mm,ll) = scu(3,nn+1,mm,ll) + vz*dy
      dy = dx1*amz
      scu(1,nn,mm+1,ll) = scu(1,nn,mm+1,ll) + vx*dx
      scu(2,nn,mm+1,ll) = scu(2,nn,mm+1,ll) + vy*dx
      scu(3,nn,mm+1,ll) = scu(3,nn,mm+1,ll) + vz*dx
      dx = amx*dzp
      scu(1,nn+1,mm+1,ll) = scu(1,nn+1,mm+1,ll) + vx*dy
      scu(2,nn+1,mm+1,ll) = scu(2,nn+1,mm+1,ll) + vy*dy
      scu(3,nn+1,mm+1,ll) = scu(3,nn+1,mm+1,ll) + vz*dy
      dy = amy*dzp
      scu(1,nn,mm,ll+1) = scu(1,nn,mm,ll+1) + vx*dx
      scu(2,nn,mm,ll+1) = scu(2,nn,mm,ll+1) + vy*dx
      scu(3,nn,mm,ll+1) = scu(3,nn,mm,ll+1) + vz*dx
      dx = dyp*dzp
      scu(1,nn+1,mm,ll+1) = scu(1,nn+1,mm,ll+1) + vx*dy
      scu(2,nn+1,mm,ll+1) = scu(2,nn+1,mm,ll+1) + vy*dy
      scu(3,nn+1,mm,ll+1) = scu(3,nn+1,mm,ll+1) + vz*dy
      dy = dx1*dzp
      scu(1,nn,mm+1,ll+1) = scu(1,nn,mm+1,ll+1) + vx*dx
      scu(2,nn,mm+1,ll+1) = scu(2,nn,mm+1,ll+1) + vy*dx
      scu(3,nn,mm+1,ll+1) = scu(3,nn,mm+1,ll+1) + vz*dx
      scu(1,nn+1,mm+1,ll+1) = scu(1,nn+1,mm+1,ll+1) + vx*dy
      scu(2,nn+1,mm+1,ll+1) = scu(2,nn+1,mm+1,ll+1) + vy*dy
      scu(3,nn+1,mm+1,ll+1) = scu(3,nn+1,mm+1,ll+1) + vz*dy
c advance position half a time-step
      dx = x + vx*dt
      dy = y + vy*dt
      dz = z + vz*dt
c reflecting boundary conditions
      if (ipbc.eq.2) then
         if ((dx.lt.edgelx).or.(dx.ge.edgerx)) then
            dx = x
            ppart(4,j,l) = -ppart(4,j,l)
         endif
         if ((dy.lt.edgely).or.(dy.ge.edgery)) then
            dy = y
            ppart(5,j,l) = -ppart(5,j,l)
         endif
         if ((dz.lt.edgelz).or.(dz.ge.edgerz)) then
            dz = z
            ppart(6,j,l) = -ppart(6,j,l)
         endif
c mixed reflecting/periodic boundary conditions
      else if (ipbc.eq.3) then
         if ((dx.lt.edgelx).or.(dx.ge.edgerx)) then
            dx = x
            ppart(4,j,l) = -ppart(4,j,l)
         endif
         if ((dy.lt.edgely).or.(dy.ge.edgery)) then
            dy = y
            ppart(5,j,l) = -ppart(5,j,l)
         endif
      endif
c set new position
      ppart(1,j,l) = dx
      ppart(2,j,l) = dy
      ppart(3,j,l) = dz
   40 continue
c deposit current to interior points in global array
      nn = min(mx,nxv-noff)
      mm = min(my,nyv-moff)
      ll = min(mz,nzv-loff)
      do 70 k = 2, ll
      do 60 j = 2, mm
      do 50 i = 2, nn
      cu(1,i+noff,j+moff,k+loff) = cu(1,i+noff,j+moff,k+loff)           
     1+ scu(1,i,j,k)
      cu(2,i+noff,j+moff,k+loff) = cu(2,i+noff,j+moff,k+loff)           
     1+ scu(2,i,j,k)
      cu(3,i+noff,j+moff,k+loff) = cu(3,i+noff,j+moff,k+loff)           
     1+ scu(3,i,j,k)
   50 continue
   60 continue
   70 continue
c deposit current to edge points in global array
      lm = min(mz+1,nzv-loff)
      do 90 j = 2, mm
      do 80 i = 2, nn
!$OMP ATOMIC
      cu(1,i+noff,j+moff,1+loff) = cu(1,i+noff,j+moff,1+loff)           
     1+ scu(1,i,j,1)
!$OMP ATOMIC
      cu(2,i+noff,j+moff,1+loff) = cu(2,i+noff,j+moff,1+loff)           
     1+ scu(2,i,j,1)
!$OMP ATOMIC
      cu(3,i+noff,j+moff,1+loff) = cu(3,i+noff,j+moff,1+loff)           
     1+ scu(3,i,j,1)
      if (lm > mz) then
!$OMP ATOMIC
         cu(1,i+noff,j+moff,lm+loff) = cu(1,i+noff,j+moff,lm+loff)      
     1   + scu(1,i,j,lm)
!$OMP ATOMIC
         cu(2,i+noff,j+moff,lm+loff) = cu(2,i+noff,j+moff,lm+loff)      
     1   + scu(2,i,j,lm)
!$OMP ATOMIC
         cu(3,i+noff,j+moff,lm+loff) = cu(3,i+noff,j+moff,lm+loff)      
     1   + scu(3,i,j,lm)
      endif
   80 continue
   90 continue
      nm = min(mx+1,nxv-noff)
      mm = min(my+1,nyv-moff)
      do 120 k = 1, ll
      do 100 i = 2, nn
!$OMP ATOMIC
      cu(1,i+noff,1+moff,k+loff) = cu(1,i+noff,1+moff,k+loff)           
     1+ scu(1,i,1,k)
!$OMP ATOMIC
      cu(2,i+noff,1+moff,k+loff) = cu(2,i+noff,1+moff,k+loff)           
     1+ scu(2,i,1,k)
!$OMP ATOMIC
      cu(3,i+noff,1+moff,k+loff) = cu(3,i+noff,1+moff,k+loff)           
     1+ scu(3,i,1,k)
      if (mm > my) then
!$OMP ATOMIC
         cu(1,i+noff,mm+moff,k+loff) = cu(1,i+noff,mm+moff,k+loff)      
     1   + scu(1,i,mm,k)
!$OMP ATOMIC
         cu(2,i+noff,mm+moff,k+loff) = cu(2,i+noff,mm+moff,k+loff)      
     1   + scu(2,i,mm,k)
!$OMP ATOMIC
         cu(3,i+noff,mm+moff,k+loff) = cu(3,i+noff,mm+moff,k+loff)      
     1   + scu(3,i,mm,k)
      endif
  100 continue
      do 110 j = 1, mm
!$OMP ATOMIC
      cu(1,1+noff,j+moff,k+loff) = cu(1,1+noff,j+moff,k+loff)           
     1+ scu(1,1,j,k)
!$OMP ATOMIC
      cu(2,1+noff,j+moff,k+loff) = cu(2,1+noff,j+moff,k+loff)           
     1+ scu(2,1,j,k)
!$OMP ATOMIC
      cu(3,1+noff,j+moff,k+loff) = cu(3,1+noff,j+moff,k+loff)           
     1+ scu(3,1,j,k)
      if (nm > mx) then
!$OMP ATOMIC
         cu(1,nm+noff,j+moff,k+loff) = cu(1,nm+noff,j+moff,k+loff)      
     1   + scu(1,nm,j,k)
!$OMP ATOMIC
         cu(2,nm+noff,j+moff,k+loff) = cu(2,nm+noff,j+moff,k+loff)      
     1   + scu(2,nm,j,k)
!$OMP ATOMIC
         cu(3,nm+noff,j+moff,k+loff) = cu(3,nm+noff,j+moff,k+loff)      
     1   + scu(3,nm,j,k)
      endif
  110 continue
  120 continue
      if (lm > mz) then
         do 130 i = 2, nn
!$OMP ATOMIC
         cu(1,i+noff,1+moff,lm+loff) = cu(1,i+noff,1+moff,lm+loff)      
     1   + scu(1,i,1,lm)
!$OMP ATOMIC
         cu(2,i+noff,1+moff,lm+loff) = cu(2,i+noff,1+moff,lm+loff)      
     1   + scu(2,i,1,lm)
!$OMP ATOMIC
         cu(3,i+noff,1+moff,lm+loff) = cu(3,i+noff,1+moff,lm+loff)      
     1   + scu(3,i,1,lm)
         if (mm > my) then
!$OMP ATOMIC
            cu(1,i+noff,mm+moff,lm+loff) = cu(1,i+noff,mm+moff,lm+loff) 
     1      + scu(1,i,mm,lm)
!$OMP ATOMIC
            cu(2,i+noff,mm+moff,lm+loff) = cu(2,i+noff,mm+moff,lm+loff) 
     1      + scu(2,i,mm,lm)
!$OMP ATOMIC
            cu(3,i+noff,mm+moff,lm+loff) = cu(3,i+noff,mm+moff,lm+loff) 
     1      + scu(3,i,mm,lm)
         endif
  130    continue
         do 140 j = 1, mm
!$OMP ATOMIC
         cu(1,1+noff,j+moff,lm+loff) = cu(1,1+noff,j+moff,lm+loff)      
     1   + scu(1,1,j,lm)
!$OMP ATOMIC
         cu(2,1+noff,j+moff,lm+loff) = cu(2,1+noff,j+moff,lm+loff)      
     1   + scu(2,1,j,lm)
!$OMP ATOMIC
         cu(3,1+noff,j+moff,lm+loff) = cu(3,1+noff,j+moff,lm+loff)      
     1   + scu(3,1,j,lm)
         if (nm > mx) then
!$OMP ATOMIC
            cu(1,nm+noff,j+moff,lm+loff) = cu(1,nm+noff,j+moff,lm+loff) 
     1      + scu(1,nm,j,lm)
!$OMP ATOMIC
            cu(2,nm+noff,j+moff,lm+loff) = cu(2,nm+noff,j+moff,lm+loff) 
     1      + scu(2,nm,j,lm)
!$OMP ATOMIC
            cu(3,nm+noff,j+moff,lm+loff) = cu(3,nm+noff,j+moff,lm+loff) 
     1      + scu(3,nm,j,lm)
         endif
  140    continue
      endif
  150 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      subroutine GRJPPOSTF3L(ppart,cu,kpic,ncl,ihole,qm,dt,ci,nppmx,    
     1idimp,nx,ny,nz,mx,my,mz,nxv,nyv,nzv,mx1,my1,mxyz1,ntmax,irc)
c for 3d code, this subroutine calculates particle current density
c using first-order linear interpolation for relativistic particles
c in addition, particle positions are advanced a half time-step
c with periodic boundary conditions.
c also determines list of particles which are leaving this tile
c OpenMP version using guard cells
c data deposited in tiles
c particles stored segmented array
c 79 flops/particle, 1 divide, 1 sqrt, 30 loads, 27 stores
c input: all except ncl, ihole, irc,
c output: ppart, cu, ncl, ihole, irc
c current density is approximated by values at the nearest grid points
c cu(i,n,m,l)=qci*(1.-dx)*(1.-dy)*(1.-dz)
c cu(i,n+1,m,l)=qci*dx*(1.-dy)*(1.-dz)
c cu(i,n,m+1,l)=qci*(1.-dx)*dy*(1.-dz)
c cu(i,n+1,m+1,l)=qci*dx*dy*(1.-dz)
c cu(i,n,m,l+1)=qci*(1.-dx)*(1.-dy)*dz
c cu(i,n+1,m,l+1)=qci*dx*(1.-dy)*dz
c cu(i,n,m+1,l+1)=qci*(1.-dx)*dy*dz
c cu(i,n+1,m+1,l+1)=qci*dx*dy*dz
c where n,m,l = leftmost grid points and dx = x-n, dy = y-m, dz = z-l
c and qci = qm*pi*gami, where i = x,y,z
c where gami = 1./sqrt(1.+sum(pi**2)*ci*ci)
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c ppart(4,n,m) = x momentum of particle n in tile m
c ppart(5,n,m) = y momentum of particle n in tile m
c ppart(6,n,m) = z momentum of particle n in tile m
c cu(i,j,k,l) = ith component of current density at grid point j,k,l
c kpic(l) = number of particles in tile l
c ncl(i,l) = number of particles going to destination i, tile l
c ihole(1,:,l) = location of hole in array left by departing particle
c ihole(2,:,l) = direction destination of particle leaving hole
c all for tile l
c ihole(1,1,l) = ih, number of holes left (error, if negative)
c qm = charge on particle, in units of e
c dt = time interval between successive calculations
c ci = reciprocal of velocity of light
c nppmx = maximum number of particles in tile
c idimp = size of phase space = 6
c nx/ny/nz = system length in x/y/z direction
c mx/my/mz = number of grids in sorting cell in x/y/z
c nxv = second dimension of current array, must be >= nx+1
c nyv = third dimension of current array, must be >= ny+1
c nzv = fourth dimension of current array, must be >= nz+1
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mxyz1 = mx1*my1*mz1,
c where mz1 = (system length in z direction - 1)/mz + 1
c ntmax = size of hole array for particles leaving tiles
c irc = maximum overflow, returned only if error occurs, when irc > 0
c optimized version
      implicit none
      integer nppmx, idimp, nx, ny, nz, mx, my, mz, nxv, nyv, nzv
      integer mx1, my1, mxyz1, ntmax, irc
      real qm, dt, ci
      real ppart, cu
      integer kpic, ncl, ihole
      dimension ppart(idimp,nppmx,mxyz1), cu(3,nxv,nyv,nzv)
      dimension kpic(mxyz1), ncl(26,mxyz1)
      dimension ihole(2,ntmax+1,mxyz1)
c local data
      integer MXV, MYV, MZV
      parameter(MXV=17,MYV=17,MZV=17)
      integer mxy1, noff, moff, loff, npp
      integer i, j, k, l, ih, nh, nn, mm, ll, nm, lm
      real anx, any, anz, edgelx, edgely, edgelz, edgerx, edgery, edgerz
      real dxp, dyp, dzp, amx, amy, amz, dx1, dx, dy, dz, vx, vy, vz
      real ci2, x, y, z, p2, gami
      real scu
      dimension scu(3,MXV,MYV,MZV)
c     dimension scu(3,mx+1,my+1,mz+1)
      mxy1 = mx1*my1
      ci2 = ci*ci
      anx = real(nx)
      any = real(ny)
      anz = real(nz)
c error if local array is too small
c     if ((mx.ge.MXV).or.(my.ge.MYV).or.(mz.ge.MZV)) return
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,noff,moff,loff,npp,nn,mm,ll,ih,nh,nm,lm,x,y,z,dxp
!$OMP& ,dyp,dzp,amx,amy,amz,dx1,dx,dy,dz,vx,vy,vz,p2,gami,edgelx,edgely,
!$OMP& edgelz,edgerx,edgery,edgerz,scu)
      do 160 l = 1, mxyz1
      loff = (l - 1)/mxy1
      k = l - mxy1*loff
      loff = mz*loff
      noff = (k - 1)/mx1
      moff = my*noff
      noff = mx*(k - mx1*noff - 1)
      npp = kpic(l)
      npp = kpic(l)
      nn = min(mx,nx-noff)
      mm = min(my,ny-moff)
      ll = min(mz,nz-loff)
      edgelx = noff
      edgerx = noff + nn
      edgely = moff
      edgery = moff + mm
      edgelz = loff
      edgerz = loff + ll
      ih = 0
      nh = 0
c zero out local accumulator
      do 30 k = 1, mz+1
      do 20 j = 1, my+1
      do 10 i = 1, mx+1
      scu(1,i,j,k) = 0.0
      scu(2,i,j,k) = 0.0
      scu(3,i,j,k) = 0.0
   10 continue
   20 continue
   30 continue
c clear counters
      do 40 j = 1, 26
      ncl(j,l) = 0
   40 continue
c loop over particles in tile
      do 50 j = 1, npp
c find interpolation weights
      x = ppart(1,j,l)
      y = ppart(2,j,l)
      z = ppart(3,j,l)
      nn = x
      mm = y
      ll = z
      dxp = qm*(x - real(nn))
      dyp = y - real(mm)
      dzp = z - real(ll)
c find inverse gamma
      vx = ppart(4,j,l)
      vy = ppart(5,j,l)
      vz = ppart(6,j,l)
      p2 = vx*vx + vy*vy + vz*vz
      gami = 1.0/sqrt(1.0 + p2*ci2)
c calculate weights
      nn = nn - noff + 1
      mm = mm - moff + 1
      ll = ll - loff + 1
      amx = qm - dxp
      amy = 1.0 - dyp
      dx1 = dxp*dyp
      dyp = amx*dyp
      amx = amx*amy
      amz = 1.0 - dzp
      amy = dxp*amy
c deposit current within tile to local accumulator
      dx = amx*amz
      dy = amy*amz
      vx = vx*gami
      vy = vy*gami
      vz = vz*gami
      scu(1,nn,mm,ll) = scu(1,nn,mm,ll) + vx*dx
      scu(2,nn,mm,ll) = scu(2,nn,mm,ll) + vy*dx
      scu(3,nn,mm,ll) = scu(3,nn,mm,ll) + vz*dx
      dx = dyp*amz
      scu(1,nn+1,mm,ll) = scu(1,nn+1,mm,ll) + vx*dy
      scu(2,nn+1,mm,ll) = scu(2,nn+1,mm,ll) + vy*dy
      scu(3,nn+1,mm,ll) = scu(3,nn+1,mm,ll) + vz*dy
      dy = dx1*amz
      scu(1,nn,mm+1,ll) = scu(1,nn,mm+1,ll) + vx*dx
      scu(2,nn,mm+1,ll) = scu(2,nn,mm+1,ll) + vy*dx
      scu(3,nn,mm+1,ll) = scu(3,nn,mm+1,ll) + vz*dx
      dx = amx*dzp
      scu(1,nn+1,mm+1,ll) = scu(1,nn+1,mm+1,ll) + vx*dy
      scu(2,nn+1,mm+1,ll) = scu(2,nn+1,mm+1,ll) + vy*dy
      scu(3,nn+1,mm+1,ll) = scu(3,nn+1,mm+1,ll) + vz*dy
      dy = amy*dzp
      scu(1,nn,mm,ll+1) = scu(1,nn,mm,ll+1) + vx*dx
      scu(2,nn,mm,ll+1) = scu(2,nn,mm,ll+1) + vy*dx
      scu(3,nn,mm,ll+1) = scu(3,nn,mm,ll+1) + vz*dx
      dx = dyp*dzp
      scu(1,nn+1,mm,ll+1) = scu(1,nn+1,mm,ll+1) + vx*dy
      scu(2,nn+1,mm,ll+1) = scu(2,nn+1,mm,ll+1) + vy*dy
      scu(3,nn+1,mm,ll+1) = scu(3,nn+1,mm,ll+1) + vz*dy
      dy = dx1*dzp
      scu(1,nn,mm+1,ll+1) = scu(1,nn,mm+1,ll+1) + vx*dx
      scu(2,nn,mm+1,ll+1) = scu(2,nn,mm+1,ll+1) + vy*dx
      scu(3,nn,mm+1,ll+1) = scu(3,nn,mm+1,ll+1) + vz*dx
      scu(1,nn+1,mm+1,ll+1) = scu(1,nn+1,mm+1,ll+1) + vx*dy
      scu(2,nn+1,mm+1,ll+1) = scu(2,nn+1,mm+1,ll+1) + vy*dy
      scu(3,nn+1,mm+1,ll+1) = scu(3,nn+1,mm+1,ll+1) + vz*dy
c advance position half a time-step
      dx = x + vx*dt
      dy = y + vy*dt
      dz = z + vz*dt
c find particles going out of bounds
      mm = 0
c count how many particles are going in each direction in ncl
c save their address and destination in ihole
c use periodic boundary conditions and check for roundoff error
c ist = direction particle is going
      if (dx.ge.edgerx) then
         if (dx.ge.anx) dx = dx - anx
         mm = 2
      else if (dx.lt.edgelx) then
         if (dx.lt.0.0) then
            dx = dx + anx
            if (dx.lt.anx) then
               mm = 1
            else
               dx = 0.0
            endif
         else
            mm = 1
         endif
      endif
      if (dy.ge.edgery) then
         if (dy.ge.any) dy = dy - any
         mm = mm + 6
      else if (dy.lt.edgely) then
         if (dy.lt.0.0) then
            dy = dy + any
            if (dy.lt.any) then
               mm = mm + 3
            else
               dy = 0.0
            endif
         else
            mm = mm + 3
         endif
      endif
      if (dz.ge.edgerz) then
         if (dz.ge.anz) dz = dz - anz
         mm = mm + 18
      else if (dz.lt.edgelz) then
         if (dz.lt.0.0) then
            dz = dz + anz
            if (dz.lt.anz) then
               mm = mm + 9
            else
               dz = 0.0
            endif
         else
            mm = mm + 9
         endif
      endif
c set new position
      ppart(1,j,l) = dx
      ppart(2,j,l) = dy
      ppart(3,j,l) = dz
c increment counters
      if (mm.gt.0) then
         ncl(mm,l) = ncl(mm,l) + 1
         ih = ih + 1
         if (ih.le.ntmax) then
            ihole(1,ih+1,l) = j
            ihole(2,ih+1,l) = mm
         else
            nh = 1
         endif
      endif
   50 continue
c deposit current to interior points in global array
      nn = min(mx,nxv-noff)
      mm = min(my,nyv-moff)
      ll = min(mz,nzv-loff)
      do 80 k = 2, ll
      do 70 j = 2, mm
      do 60 i = 2, nn
      cu(1,i+noff,j+moff,k+loff) = cu(1,i+noff,j+moff,k+loff)           
     1+ scu(1,i,j,k)
      cu(2,i+noff,j+moff,k+loff) = cu(2,i+noff,j+moff,k+loff)           
     1+ scu(2,i,j,k)
      cu(3,i+noff,j+moff,k+loff) = cu(3,i+noff,j+moff,k+loff)           
     1+ scu(3,i,j,k)
   60 continue
   70 continue
   80 continue
c deposit current to edge points in global array
      lm = min(mz+1,nzv-loff)
      do 100 j = 2, mm
      do 90 i = 2, nn
!$OMP ATOMIC
      cu(1,i+noff,j+moff,1+loff) = cu(1,i+noff,j+moff,1+loff)           
     1+ scu(1,i,j,1)
!$OMP ATOMIC
      cu(2,i+noff,j+moff,1+loff) = cu(2,i+noff,j+moff,1+loff)           
     1+ scu(2,i,j,1)
!$OMP ATOMIC
      cu(3,i+noff,j+moff,1+loff) = cu(3,i+noff,j+moff,1+loff)           
     1+ scu(3,i,j,1)
      if (lm > mz) then
!$OMP ATOMIC
         cu(1,i+noff,j+moff,lm+loff) = cu(1,i+noff,j+moff,lm+loff)      
     1   + scu(1,i,j,lm)
!$OMP ATOMIC
         cu(2,i+noff,j+moff,lm+loff) = cu(2,i+noff,j+moff,lm+loff)      
     1   + scu(2,i,j,lm)
!$OMP ATOMIC
         cu(3,i+noff,j+moff,lm+loff) = cu(3,i+noff,j+moff,lm+loff)      
     1   + scu(3,i,j,lm)
      endif
   90 continue
  100 continue
      nm = min(mx+1,nxv-noff)
      mm = min(my+1,nyv-moff)
      do 130 k = 1, ll
      do 110 i = 2, nn
!$OMP ATOMIC
      cu(1,i+noff,1+moff,k+loff) = cu(1,i+noff,1+moff,k+loff)           
     1+ scu(1,i,1,k)
!$OMP ATOMIC
      cu(2,i+noff,1+moff,k+loff) = cu(2,i+noff,1+moff,k+loff)           
     1+ scu(2,i,1,k)
!$OMP ATOMIC
      cu(3,i+noff,1+moff,k+loff) = cu(3,i+noff,1+moff,k+loff)           
     1+ scu(3,i,1,k)
      if (mm > my) then
!$OMP ATOMIC
         cu(1,i+noff,mm+moff,k+loff) = cu(1,i+noff,mm+moff,k+loff)      
     1   + scu(1,i,mm,k)
!$OMP ATOMIC
         cu(2,i+noff,mm+moff,k+loff) = cu(2,i+noff,mm+moff,k+loff)      
     1   + scu(2,i,mm,k)
!$OMP ATOMIC
         cu(3,i+noff,mm+moff,k+loff) = cu(3,i+noff,mm+moff,k+loff)      
     1   + scu(3,i,mm,k)
      endif
  110 continue
      do 120 j = 1, mm
!$OMP ATOMIC
      cu(1,1+noff,j+moff,k+loff) = cu(1,1+noff,j+moff,k+loff)           
     1+ scu(1,1,j,k)
!$OMP ATOMIC
      cu(2,1+noff,j+moff,k+loff) = cu(2,1+noff,j+moff,k+loff)           
     1+ scu(2,1,j,k)
!$OMP ATOMIC
      cu(3,1+noff,j+moff,k+loff) = cu(3,1+noff,j+moff,k+loff)           
     1+ scu(3,1,j,k)
      if (nm > mx) then
!$OMP ATOMIC
         cu(1,nm+noff,j+moff,k+loff) = cu(1,nm+noff,j+moff,k+loff)      
     1   + scu(1,nm,j,k)
!$OMP ATOMIC
         cu(2,nm+noff,j+moff,k+loff) = cu(2,nm+noff,j+moff,k+loff)      
     1   + scu(2,nm,j,k)
!$OMP ATOMIC
         cu(3,nm+noff,j+moff,k+loff) = cu(3,nm+noff,j+moff,k+loff)      
     1   + scu(3,nm,j,k)
      endif
  120 continue
  130 continue
      if (lm > mz) then
         do 140 i = 2, nn
!$OMP ATOMIC
         cu(1,i+noff,1+moff,lm+loff) = cu(1,i+noff,1+moff,lm+loff)      
     1   + scu(1,i,1,lm)
!$OMP ATOMIC
         cu(2,i+noff,1+moff,lm+loff) = cu(2,i+noff,1+moff,lm+loff)      
     1   + scu(2,i,1,lm)
!$OMP ATOMIC
         cu(3,i+noff,1+moff,lm+loff) = cu(3,i+noff,1+moff,lm+loff)      
     1   + scu(3,i,1,lm)
         if (mm > my) then
!$OMP ATOMIC
            cu(1,i+noff,mm+moff,lm+loff) = cu(1,i+noff,mm+moff,lm+loff) 
     1      + scu(1,i,mm,lm)
!$OMP ATOMIC
            cu(2,i+noff,mm+moff,lm+loff) = cu(2,i+noff,mm+moff,lm+loff) 
     1      + scu(2,i,mm,lm)
!$OMP ATOMIC
            cu(3,i+noff,mm+moff,lm+loff) = cu(3,i+noff,mm+moff,lm+loff) 
     1      + scu(3,i,mm,lm)
         endif
  140    continue
         do 150 j = 1, mm
!$OMP ATOMIC
         cu(1,1+noff,j+moff,lm+loff) = cu(1,1+noff,j+moff,lm+loff)      
     1   + scu(1,1,j,lm)
!$OMP ATOMIC
         cu(2,1+noff,j+moff,lm+loff) = cu(2,1+noff,j+moff,lm+loff)      
     1   + scu(2,1,j,lm)
!$OMP ATOMIC
         cu(3,1+noff,j+moff,lm+loff) = cu(3,1+noff,j+moff,lm+loff)      
     1   + scu(3,1,j,lm)
         if (nm > mx) then
!$OMP ATOMIC
            cu(1,nm+noff,j+moff,lm+loff) = cu(1,nm+noff,j+moff,lm+loff) 
     1      + scu(1,nm,j,lm)
!$OMP ATOMIC
            cu(2,nm+noff,j+moff,lm+loff) = cu(2,nm+noff,j+moff,lm+loff) 
     1      + scu(2,nm,j,lm)
!$OMP ATOMIC
            cu(3,nm+noff,j+moff,lm+loff) = cu(3,nm+noff,j+moff,lm+loff) 
     1      + scu(3,nm,j,lm)
         endif
  150    continue
      endif
c set error and end of file flag
      if (nh.gt.0) then
         irc = ih
         ih = -ih
      endif
      ihole(1,1,l) = ih
  160 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      subroutine PPORDER3L(ppart,ppbuff,kpic,ncl,ihole,idimp,nppmx,nx,ny
     1,nz,mx,my,mz,mx1,my1,mz1,npbmx,ntmax,irc)
c this subroutine sorts particles by x,y,z grid in tiles of mx, my, mz
c linear interpolation, with periodic boundary conditions
c tiles are assumed to be arranged in 3D linear memory
c algorithm has 3 steps.  first, one finds particles leaving tile and
c stores their number in each directon, location, and destination in ncl
c and ihole.  second, a prefix scan of ncl is performed and departing
c particles are buffered in ppbuff in direction order.  finally, we copy
c the incoming particles from other tiles into ppart.
c input: all except ppbuff, ncl, ihole, irc
c output: ppart, ppbuff, kpic, ncl, ihole, irc
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c ppbuff(i,n,l) = i co-ordinate of particle n in tile l
c kpic(l) = number of particles in tile l
c ncl(i,l) = number of particles going to destination i, tile l
c ihole(1,:,l) = location of hole in array left by departing particle
c ihole(2,:,l) = direction destination of particle leaving hole
c all for tile l
c ihole(1,1,l) = ih, number of holes left (error, if negative)
c idimp = size of phase space = 6
c nppmx = maximum number of particles in tile
c nx/ny/nz = system length in x/y/z direction
c mx/my/mz = number of grids in sorting cell in x/y/z
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mz1 = (system length in z direction - 1)/mz + 1
c npbmx = size of buffer array ppbuff
c ntmax = size of hole array for particles leaving tiles
c irc = maximum overflow, returned only if error occurs, when irc > 0
      implicit none
      integer idimp, nppmx, nx, ny, nz, mx, my, mz, mx1, my1, mz1
      integer npbmx, ntmax, irc
      real ppart, ppbuff
      integer kpic, ncl, ihole
      dimension ppart(idimp,nppmx,mx1*my1*mz1)
      dimension ppbuff(idimp,npbmx,mx1*my1*mz1)
      dimension kpic(mx1*my1*mz1), ncl(26,mx1*my1*mz1)
      dimension ihole(2,ntmax+1,mx1*my1*mz1)
c local data
      integer mxy1, mxyz1, noff, moff, loff, npp, ncoff
      integer i, j, k, l, ii, kx, ky, kz, ih, nh, ist, nn, mm, ll, isum
      integer ip, j1, j2, kxl, kxr, kk, kl, kr, lk, lr
      real anx, any, anz, edgelx, edgely, edgelz, edgerx, edgery, edgerz
      real dx, dy, dz
      integer ks
      dimension ks(26)
      mxy1 = mx1*my1
      mxyz1 = mxy1*mz1
      anx = real(nx)
      any = real(ny)
      anz = real(nz)
c find and count particles leaving tiles and determine destination
c update ppart, ihole, ncl
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(j,k,l,noff,moff,loff,npp,nn,mm,ll,ih,nh,ist,dx,dy,dz,    
!$OMP& edgelx,edgely,edgelz,edgerx,edgery,edgerz)
      do 30 l = 1, mxyz1
      loff = (l - 1)/mxy1
      k = l - mxy1*loff
      loff = mz*loff
      noff = (k - 1)/mx1
      moff = my*noff
      noff = mx*(k - mx1*noff - 1)
      npp = kpic(l)
      nn = min(mx,nx-noff)
      mm = min(my,ny-moff)
      ll = min(mz,nz-loff)
      ih = 0
      nh = 0
      edgelx = noff
      edgerx = noff + nn
      edgely = moff
      edgery = moff + mm
      edgelz = loff
      edgerz = loff + ll
c clear counters
      do 10 j = 1, 26
      ncl(j,l) = 0
   10 continue
c loop over particles in tile
      do 20 j = 1, npp
      dx = ppart(1,j,l)
      dy = ppart(2,j,l)
      dz = ppart(3,j,l)
c find particles going out of bounds
      ist = 0
c count how many particles are going in each direction in ncl
c save their address and destination in ihole
c use periodic boundary conditions and check for roundoff error
c ist = direction particle is going
      if (dx.ge.edgerx) then
         if (dx.ge.anx) ppart(1,j,l) = dx - anx
         ist = 2
      else if (dx.lt.edgelx) then
         if (dx.lt.0.0) then
            dx = dx + anx
            if (dx.lt.anx) then
               ist = 1
            else
               dx = 0.0
            endif
            ppart(1,j,l) = dx
         else
            ist = 1
         endif
      endif
      if (dy.ge.edgery) then
         if (dy.ge.any) ppart(2,j,l) = dy - any
         ist = ist + 6
      else if (dy.lt.edgely) then
         if (dy.lt.0.0) then
            dy = dy + any
            if (dy.lt.any) then
               ist = ist + 3
            else
               dy = 0.0
            endif
            ppart(2,j,l) = dy
         else
            ist = ist + 3
         endif
      endif
      if (dz.ge.edgerz) then
         if (dz.ge.anz) ppart(3,j,l) = dz - anz
         ist = ist + 18
      else if (dz.lt.edgelz) then
         if (dz.lt.0.0) then
            dz = dz + anz
            if (dz.lt.anz) then
               ist = ist + 9
            else
               dz = 0.0
            endif
            ppart(3,j,l) = dz
         else
            ist = ist + 9
         endif
      endif
      if (ist.gt.0) then
         ncl(ist,l) = ncl(ist,l) + 1
         ih = ih + 1
         if (ih.le.ntmax) then
            ihole(1,ih+1,l) = j
            ihole(2,ih+1,l) = ist
         else
            nh = 1
         endif
      endif
   20 continue
c set error and end of file flag
      if (nh.gt.0) then
         irc = ih
         ih = -ih
      endif
      ihole(1,1,l) = ih
   30 continue
!$OMP END PARALLEL DO
c ihole overflow
      if (irc.gt.0) return
c
c buffer particles that are leaving tile: update ppbuff, ncl
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,l,isum,ist,nh,ip,j1,ii)
      do 70 l = 1, mxyz1
c find address offset for ordered ppbuff array
      isum = 0
      do 40 j = 1, 26
      ist = ncl(j,l)
      ncl(j,l) = isum
      isum = isum + ist
   40 continue
      nh = ihole(1,1,l)
      ip = 0
c loop over particles leaving tile
      do 60 j = 1, nh
c buffer particles that are leaving tile, in direction order
      j1 = ihole(1,j+1,l)
      ist = ihole(2,j+1,l)
      ii = ncl(ist,l) + 1
      if (ii.le.npbmx) then
         do 50 i = 1, idimp
         ppbuff(i,ii,l) = ppart(i,j1,l)
   50    continue
      else
         ip = 1
      endif
      ncl(ist,l) = ii
   60 continue
c set error
      if (ip.gt.0) irc = ncl(26,l)
   70 continue
!$OMP END PARALLEL DO
c ppbuff overflow
      if (irc.gt.0) return
c
c copy incoming particles from buffer into ppart: update ppart, kpic
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,ii,kk,npp,kx,ky,kz,kl,kr,kxl,kxr,lk,ll,lr,ih,nh, 
!$OMP& ncoff,ist,j1,j2,ip,ks)
      do 130 l = 1, mxyz1
      npp = kpic(l)
      kz = (l - 1)/mxy1
      k = l - mxy1*kz
      kz = kz + 1
c loop over tiles in z, assume periodic boundary conditions
      lk = (kz - 1)*mxy1
c find tile behind
      ll = kz - 1 
      if (ll.lt.1) ll = ll + mz1
      ll = (ll - 1)*mxy1
c find tile in front
      lr = kz + 1
      if (lr.gt.mz1) lr = lr - mz1
      lr = (lr - 1)*mxy1
      ky = (k - 1)/mx1 + 1
c loop over tiles in y, assume periodic boundary conditions
      kk = (ky - 1)*mx1
c find tile above
      kl = ky - 1 
      if (kl.lt.1) kl = kl + my1
      kl = (kl - 1)*mx1
c find tile below
      kr = ky + 1
      if (kr.gt.my1) kr = kr - my1
      kr = (kr - 1)*mx1
c loop over tiles in x, assume periodic boundary conditions
      kx = k - (ky - 1)*mx1
      kxl = kx - 1 
      if (kxl.lt.1) kxl = kxl + mx1
      kxr = kx + 1
      if (kxr.gt.mx1) kxr = kxr - mx1
c find tile number for different directions
      ks(1) = kxr + kk + lk
      ks(2) = kxl + kk + lk
      ks(3) = kx + kr + lk
      ks(4) = kxr + kr + lk
      ks(5) = kxl + kr + lk
      ks(6) = kx + kl + lk
      ks(7) = kxr + kl + lk
      ks(8) = kxl + kl + lk
      ks(9) = kx + kk + lr
      ks(10) = kxr + kk + lr
      ks(11) = kxl + kk + lr
      ks(12) = kx + kr + lr
      ks(13) = kxr + kr + lr
      ks(14) = kxl + kr + lr
      ks(15) = kx + kl + lr
      ks(16) = kxr + kl + lr
      ks(17) = kxl + kl + lr
      ks(18) = kx + kk + ll
      ks(19) = kxr + kk + ll
      ks(20) = kxl + kk + ll
      ks(21) = kx + kr + ll
      ks(22) = kxr + kr + ll
      ks(23) = kxl + kr + ll
      ks(24) = kx + kl + ll
      ks(25) = kxr + kl + ll
      ks(26) = kxl + kl + ll
c loop over directions
      nh = ihole(1,1,l)
      ncoff = 0
      ih = 0
      ist = 0
      j1 = 0
      do 100 ii = 1, 26
      if (ii.gt.1) ncoff = ncl(ii-1,ks(ii))
c ip = number of particles coming from direction ii
      ip = ncl(ii,ks(ii)) - ncoff
      do 90 j = 1, ip
      ih = ih + 1
c insert incoming particles into holes
      if (ih.le.nh) then
         j1 = ihole(1,ih+1,l)
c place overflow at end of array
      else
         j1 = npp + 1
         npp = j1
      endif
      if (j1.le.nppmx) then
         do 80 i = 1, idimp
         ppart(i,j1,l) = ppbuff(i,j+ncoff,ks(ii))
   80    continue
      else
         ist = 1
      endif
   90 continue
  100 continue
c set error
      if (ist.gt.0) irc = j1
c fill up remaining holes in particle array with particles from bottom
      if (ih.lt.nh) then
         ip = nh - ih
         do 120 j = 1, ip
         j1 = npp - j + 1
         j2 = ihole(1,nh-j+2,l)
         if (j1.gt.j2) then
c move particle only if it is below current hole
            do 110 i = 1, idimp
            ppart(i,j2,l) = ppart(i,j1,l)
  110       continue
         endif
  120    continue
         npp = npp - ip
      endif
      kpic(l) = npp
  130 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      subroutine PPORDERF3L(ppart,ppbuff,kpic,ncl,ihole,idimp,nppmx,mx1,
     1my1,mz1,npbmx,ntmax,irc)
c this subroutine sorts particles by x,y,z grid in tiles of mx, my, mz
c linear interpolation, with periodic boundary conditions
c tiles are assumed to be arranged in 3D linear memory
c the algorithm has 2 steps.  first, a prefix scan of ncl is performed
c and departing particles are buffered in ppbuff in direction order.
c then we copy the incoming particles from other tiles into ppart.
c it assumes that the number, location, and destination of particles 
c leaving a tile have been previously stored in ncl and ihole by the
c GPPUSHF3L subroutine.
c input: all except ppbuff, irc
c output: ppart, ppbuff, kpic, ncl, irc
c ppart(1,n,m) = position x of particle n in tile m
c ppart(2,n,m) = position y of particle n in tile m
c ppart(3,n,m) = position z of particle n in tile m
c ppbuff(i,n,l) = i co-ordinate of particle n in tile l
c kpic(l) = number of particles in tile l
c ncl(i,l) = number of particles going to destination i, tile l
c ihole(1,:,l) = location of hole in array left by departing particle
c ihole(2,:,l) = direction destination of particle leaving hole
c all for tile l
c ihole(1,1,l) = ih, number of holes left (error, if negative)
c idimp = size of phase space = 6
c nppmx = maximum number of particles in tile
c mx1 = (system length in x direction - 1)/mx + 1
c my1 = (system length in y direction - 1)/my + 1
c mz1 = (system length in z direction - 1)/mz + 1
c npbmx = size of buffer array ppbuff
c ntmax = size of hole array for particles leaving tiles
c irc = maximum overflow, returned only if error occurs, when irc > 0
      implicit none
      integer idimp, nppmx, mx1, my1, mz1, npbmx, ntmax, irc
      real ppart, ppbuff
      integer kpic, ncl, ihole
      dimension ppart(idimp,nppmx,mx1*my1*mz1)
      dimension ppbuff(idimp,npbmx,mx1*my1*mz1)
      dimension kpic(mx1*my1*mz1), ncl(26,mx1*my1*mz1)
      dimension ihole(2,ntmax+1,mx1*my1*mz1)
c local data
      integer mxy1, mxyz1, npp, ncoff
      integer i, j, k, l, ii, kx, ky, kz, ih, nh, ist, ll, isum
      integer ip, j1, j2, kxl, kxr, kk, kl, kr, lk, lr
      integer ks
      dimension ks(26)
      mxy1 = mx1*my1
      mxyz1 = mxy1*mz1
c buffer particles that are leaving tile: update ppbuff, ncl
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,l,isum,ist,nh,ip,j1,ii)
      do 40 l = 1, mxyz1
c find address offset for ordered ppbuff array
      isum = 0
      do 10 j = 1, 26
      ist = ncl(j,l)
      ncl(j,l) = isum
      isum = isum + ist
   10 continue
      nh = ihole(1,1,l)
      ip = 0
c loop over particles leaving tile
      do 30 j = 1, nh
c buffer particles that are leaving tile, in direction order
      j1 = ihole(1,j+1,l)
      ist = ihole(2,j+1,l)
      ii = ncl(ist,l) + 1
      if (ii.le.npbmx) then
         do 20 i = 1, idimp
         ppbuff(i,ii,l) = ppart(i,j1,l)
   20    continue
      else
         ip = 1
      endif
      ncl(ist,l) = ii
   30 continue
c set error
      if (ip.gt.0) irc = ncl(26,l)
   40 continue
!$OMP END PARALLEL DO
c ppbuff overflow
      if (irc.gt.0) return
c
c copy incoming particles from buffer into ppart: update ppart, kpic
c loop over tiles
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,ii,kk,npp,kx,ky,kz,kl,kr,kxl,kxr,lk,ll,lr,ih,nh, 
!$OMP& ncoff,ist,j1,j2,ip,ks)
      do 100 l = 1, mxyz1
      npp = kpic(l)
      kz = (l - 1)/mxy1
      k = l - mxy1*kz
      kz = kz + 1
c loop over tiles in z, assume periodic boundary conditions
      lk = (kz - 1)*mxy1
c find tile behind
      ll = kz - 1 
      if (ll.lt.1) ll = ll + mz1
      ll = (ll - 1)*mxy1
c find tile in front
      lr = kz + 1
      if (lr.gt.mz1) lr = lr - mz1
      lr = (lr - 1)*mxy1
      ky = (k - 1)/mx1 + 1
c loop over tiles in y, assume periodic boundary conditions
      kk = (ky - 1)*mx1
c find tile above
      kl = ky - 1 
      if (kl.lt.1) kl = kl + my1
      kl = (kl - 1)*mx1
c find tile below
      kr = ky + 1
      if (kr.gt.my1) kr = kr - my1
      kr = (kr - 1)*mx1
c loop over tiles in x, assume periodic boundary conditions
      kx = k - (ky - 1)*mx1
      kxl = kx - 1 
      if (kxl.lt.1) kxl = kxl + mx1
      kxr = kx + 1
      if (kxr.gt.mx1) kxr = kxr - mx1
c find tile number for different directions
      ks(1) = kxr + kk + lk
      ks(2) = kxl + kk + lk
      ks(3) = kx + kr + lk
      ks(4) = kxr + kr + lk
      ks(5) = kxl + kr + lk
      ks(6) = kx + kl + lk
      ks(7) = kxr + kl + lk
      ks(8) = kxl + kl + lk
      ks(9) = kx + kk + lr
      ks(10) = kxr + kk + lr
      ks(11) = kxl + kk + lr
      ks(12) = kx + kr + lr
      ks(13) = kxr + kr + lr
      ks(14) = kxl + kr + lr
      ks(15) = kx + kl + lr
      ks(16) = kxr + kl + lr
      ks(17) = kxl + kl + lr
      ks(18) = kx + kk + ll
      ks(19) = kxr + kk + ll
      ks(20) = kxl + kk + ll
      ks(21) = kx + kr + ll
      ks(22) = kxr + kr + ll
      ks(23) = kxl + kr + ll
      ks(24) = kx + kl + ll
      ks(25) = kxr + kl + ll
      ks(26) = kxl + kl + ll
c loop over directions
      nh = ihole(1,1,l)
      ncoff = 0
      ih = 0
      ist = 0
      j1 = 0
      do 70 ii = 1, 26
      if (ii.gt.1) ncoff = ncl(ii-1,ks(ii))
c ip = number of particles coming from direction ii
      ip = ncl(ii,ks(ii)) - ncoff
      do 60 j = 1, ip
      ih = ih + 1
c insert incoming particles into holes
      if (ih.le.nh) then
         j1 = ihole(1,ih+1,l)
c place overflow at end of array
      else
         j1 = npp + 1
         npp = j1
      endif
      if (j1.le.nppmx) then
         do 50 i = 1, idimp
         ppart(i,j1,l) = ppbuff(i,j+ncoff,ks(ii))
   50    continue
      else
         ist = 1
      endif
   60 continue
   70 continue
c set error
      if (ist.gt.0) irc = j1
c fill up remaining holes in particle array with particles from bottom
      if (ih.lt.nh) then
         ip = nh - ih
         do 90 j = 1, ip
         j1 = npp - j + 1
         j2 = ihole(1,nh-j+2,l)
         if (j1.gt.j2) then
c move particle only if it is below current hole
            do 80 i = 1, idimp
            ppart(i,j2,l) = ppart(i,j1,l)
   80       continue
         endif
   90    continue
         npp = npp - ip
      endif
      kpic(l) = npp
  100 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      subroutine CGUARD3L(fxyz,nx,ny,nz,nxe,nye,nze)
c replicate extended periodic vector field fxyz
c linear interpolation
c nx/ny/nz = system length in x/y direction
c nxe = first dimension of field arrays, must be >= nx+1
c nye = second dimension of field arrays, must be >= ny+1
c nze = third dimension of field arrays, must be >= nz+1
      implicit none
      real fxyz
      integer nx, ny, nz, nxe, nye, nze
      dimension fxyz(3,nxe,nye,nze)
c local data
      integer j, k, l
c copy edges of extended field
!$OMP PARALLEL
!$OMP DO PRIVATE(j,k,l)
      do 30 l = 1, nz
      do 10 k = 1, ny
      fxyz(1,nx+1,k,l) = fxyz(1,1,k,l)
      fxyz(2,nx+1,k,l) = fxyz(2,1,k,l)
      fxyz(3,nx+1,k,l) = fxyz(3,1,k,l)
   10 continue
      do 20 j = 1, nx
      fxyz(1,j,ny+1,l) = fxyz(1,j,1,l)
      fxyz(2,j,ny+1,l) = fxyz(2,j,1,l)
      fxyz(3,j,ny+1,l) = fxyz(3,j,1,l)
   20 continue
      fxyz(1,nx+1,ny+1,l) = fxyz(1,1,1,l)
      fxyz(2,nx+1,ny+1,l) = fxyz(2,1,1,l)
      fxyz(3,nx+1,ny+1,l) = fxyz(3,1,1,l)
   30 continue
!$OMP END DO NOWAIT
!$OMP DO PRIVATE(j,k)
      do 50 k = 1, ny
      do 40 j = 1, nx
      fxyz(1,j,k,nz+1) = fxyz(1,j,k,1)
      fxyz(2,j,k,nz+1) = fxyz(2,j,k,1)
      fxyz(3,j,k,nz+1) = fxyz(3,j,k,1)
   40 continue
      fxyz(1,nx+1,k,nz+1) = fxyz(1,1,k,1)
      fxyz(2,nx+1,k,nz+1) = fxyz(2,1,k,1)
      fxyz(3,nx+1,k,nz+1) = fxyz(3,1,k,1)
   50 continue
!$OMP END DO
!$OMP END PARALLEL
      do 60 j = 1, nx
      fxyz(1,j,ny+1,nz+1) = fxyz(1,j,1,1)
      fxyz(2,j,ny+1,nz+1) = fxyz(2,j,1,1)
      fxyz(3,j,ny+1,nz+1) = fxyz(3,j,1,1)
   60 continue
      fxyz(1,nx+1,ny+1,nz+1) = fxyz(1,1,1,1)
      fxyz(2,nx+1,ny+1,nz+1) = fxyz(2,1,1,1)
      fxyz(3,nx+1,ny+1,nz+1) = fxyz(3,1,1,1)
      return
      end
c-----------------------------------------------------------------------
      subroutine ACGUARD3L(cu,nx,ny,nz,nxe,nye,nze)
c accumulate extended periodic vector field cu
c linear interpolation
c nx/ny/nz = system length in x/y direction
c nxe = first dimension of field arrays, must be >= nx+1
c nye = second dimension of field arrays, must be >= ny+1
c nze = third dimension of field arrays, must be >= nz+1
      implicit none
      integer nx, ny, nz, nxe, nye, nze
      real cu
      dimension cu(3,nxe,nye,nze)
c local data
      integer i, j, k, l
c accumulate edges of extended field
!$OMP PARALLEL
!$OMP DO PRIVATE(i,j,k,l)
      do 60 l = 1, nz
      do 20 k = 1, ny
      do 10 i = 1, 3
      cu(i,1,k,l) = cu(i,1,k,l) + cu(i,nx+1,k,l)
      cu(i,nx+1,k,l) = 0.0
   10 continue
   20 continue
      do 40 j = 1, nx
      do 30 i = 1, 3
      cu(i,j,1,l) = cu(i,j,1,l) + cu(i,j,ny+1,l)
      cu(i,j,ny+1,l) = 0.0
   30 continue
   40 continue
      do 50 i = 1, 3
      cu(i,1,1,l) = cu(i,1,1,l) + cu(i,nx+1,ny+1,l)
      cu(i,nx+1,ny+1,l) = 0.0
   50 continue
   60 continue
!$OMP END DO
!$OMP DO PRIVATE(i,j,k)
      do 100 k = 1, ny
      do 80 j = 1, nx
      do 70 i = 1, 3
      cu(i,j,k,1) = cu(i,j,k,1) + cu(i,j,k,nz+1)
      cu(i,j,k,nz+1) = 0.0
   70 continue
   80 continue
      do 90 i = 1, 3
      cu(i,1,k,1) = cu(i,1,k,1) + cu(i,nx+1,k,nz+1)
      cu(i,nx+1,k,nz+1) = 0.0
   90 continue
  100 continue
!$OMP END DO
!$OMP END PARALLEL
      do 120 j = 1, nx
      do 110 i = 1, 3
      cu(i,j,1,1) = cu(i,j,1,1) + cu(i,j,ny+1,nz+1)
      cu(i,j,ny+1,nz+1) = 0.0
  110 continue
  120 continue
      do 130 i = 1, 3
      cu(i,1,1,1) = cu(i,1,1,1) + cu(i,nx+1,ny+1,nz+1)
      cu(i,nx+1,ny+1,nz+1) = 0.0
  130 continue
      return
      end
c-----------------------------------------------------------------------
      subroutine AGUARD3L(q,nx,ny,nz,nxe,nye,nze)
c accumulate extended periodic scalar field q
c linear interpolation
c nx/ny/nz = system length in x/y direction
c nxe = first dimension of field arrays, must be >= nx+1
c nye = second dimension of field arrays, must be >= ny+1
c nze = third dimension of field arrays, must be >= nz+1
      implicit none
      real q
      integer nx, ny, nz, nxe, nye, nze
      dimension q(nxe,nye,nze)
      integer j, k, l
c accumulate edges of extended field
!$OMP PARALLEL
!$OMP DO PRIVATE(j,k,l)
      do 30 l = 1, nz
      do 10 k = 1, ny
      q(1,k,l) = q(1,k,l) + q(nx+1,k,l)
      q(nx+1,k,l) = 0.0
   10 continue
      do 20 j = 1, nx
      q(j,1,l) = q(j,1,l) + q(j,ny+1,l)
      q(j,ny+1,l) = 0.0
   20 continue
      q(1,1,l) = q(1,1,l) + q(nx+1,ny+1,l)
      q(nx+1,ny+1,l) = 0.0
   30 continue
!$OMP END DO
!$OMP DO PRIVATE(j,k)
      do 50 k = 1, ny
      do 40 j = 1, nx
      q(j,k,1) = q(j,k,1) + q(j,k,nz+1)
      q(j,k,nz+1) = 0.0
   40 continue
      q(1,k,1) = q(1,k,1) + q(nx+1,k,nz+1)
      q(nx+1,k,nz+1) = 0.0
   50 continue
!$OMP END DO
!$OMP END PARALLEL
      do 60 j = 1, nx
      q(j,1,1) = q(j,1,1) + q(j,ny+1,nz+1)
      q(j,ny+1,nz+1) = 0.0
   60 continue
      q(1,1,1) = q(1,1,1) + q(nx+1,ny+1,nz+1)
      q(nx+1,ny+1,nz+1) = 0.0
      return
      end
c-----------------------------------------------------------------------
      subroutine MPOIS33(q,fxyz,isign,ffc,ax,ay,az,affp,we,nx,ny,nz,nxvh
     1,nyv,nzv,nxhd,nyhd,nzhd)
c this subroutine solves 3d poisson's equation in fourier space for
c force/charge (or convolution of electric field over particle shape)
c with periodic boundary conditions.
c for isign = 0, output: ffc
c input: isign,ax,ay,az,affp,nx,ny,nz,nxvh,nyv,nzv,nxhd,nyhd,nzhd
c for isign = -1, output: fxyz, we
c input: q,ffc,isign,nx,ny,nz,nxvh,nyv,nzv,nxhd,nyhd,nzhd
c approximate flop count is:
c 59*nxc*nyc*nzc + 26*(nxc*nyc + nxc*nzc + nyc*nzc)
c where nxc = nx/2 - 1, nyc = ny/2 - 1, nzc = nz/2 - 1
c if isign = 0, form factor array is prepared
c if isign is not equal to 0, force/charge is calculated
c equation used is:
c fx(kx,ky,kz) = -sqrt(-1)*kx*g(kx,ky,kz)*s(kx,ky,kz),
c fy(kx,ky,kz) = -sqrt(-1)*ky*g(kx,ky,kz)*s(kx,ky,kz),
c fz(kx,ky,kz) = -sqrt(-1)*kz*g(kx,ky,kz)*s(kx,ky,kz),
c where kx = 2pi*j/nx, ky = 2pi*k/ny, kz = 2pi*l/nz, and
c j,k,l = fourier mode numbers,
c g(kx,ky,kz) = (affp/(kx**2+ky**2+kz**2))*s(kx,ky,kz),
c s(kx,ky,kz) = exp(-((kx*ax)**2+(ky*ay)**2+(kz*az)**2)/2), except for
c fx(kx=pi) = fy(kx=pi) = fz(kx=pi) = 0,
c fx(ky=pi) = fy(ky=pi) = fx(ky=pi) = 0,
c fx(kz=pi) = fy(kz=pi) = fz(kz=pi) = 0,
c fx(kx=0,ky=0,kz=0) = fy(kx=0,ky=0,kz=0) = fz(kx=0,ky=0,kz=0) = 0.
c q(j,k,l) = complex charge density for fourier mode (j-1,k-1,l-1)
c fxyz(1,j,k,l) = x component of complex force/charge
c fxyz(2,j,k,l) = y component of complex force/charge
c fxyz(3,j,k,l) = z component of complex force/charge
c all for fourier mode (j-1,k-1,l-1)
c aimag(ffc(j,k,l)) = finite-size particle shape factor s
c for fourier mode (j-1,k-1,l-1)
c real(ffc(j,k,l)) = potential green's function g
c for fourier mode (j-1,k-1,l-1)
c ax/ay/az = half-width of particle in x/y/z direction
c affp = normalization constant = nx*ny*nz/np,
c where np=number of particles
c electric field energy is also calculated, using
c we = nx*ny*nz*sum((affp/(kx**2+ky**2+kz**2))*
c    |q(kx,ky,kz)*s(kx,ky,kz)|**2)
c nx/ny/nz = system length in x/y/z direction
c nxvh = first dimension of field arrays, must be >= nxh
c nyv = second dimension of field arrays, must be >= ny
c nzv = third dimension of field arrays, must be >= nz
c nxhd = first dimension of form factor array, must be >= nxh
c nyhd = second dimension of form factor array, must be >= nyh
c nzhd = third dimension of form factor array, must be >= nzh
      implicit none
      integer isign, nx, ny, nz, nxvh, nyv, nzv, nxhd, nyhd, nzhd
      real ax, ay, az, affp, we
      complex q, fxyz, ffc
      dimension q(nxvh,nyv,nzv), fxyz(3,nxvh,nyv,nzv)
      dimension ffc(nxhd,nyhd,nzhd)
c local data
      integer nxh, nyh, nzh, ny2, nz2, j, k, l, k1, l1
      real dnx, dny, dnz, dkx, dky, dkz, at1, at2, at3, at4, at5, at6
      complex zero, zt1, zt2
      double precision wp, sum1, sum2
      nxh = nx/2
      nyh = max(1,ny/2)
      nzh = max(1,nz/2)
      ny2 = ny + 2
      nz2 = nz + 2
      dnx = 6.28318530717959/real(nx)
      dny = 6.28318530717959/real(ny)
      dnz = 6.28318530717959/real(nz)
      zero = cmplx(0.0,0.0)
      if (isign.ne.0) go to 40
c prepare form factor array
      do 30 l = 1, nzh
      dkz = dnz*real(l - 1)
      at1 = dkz*dkz
      at2 = (dkz*az)**2
      do 20 k = 1, nyh
      dky = dny*real(k - 1)
      at3 = dky*dky + at1
      at4 = (dky*ay)**2 + at2
      do 10 j = 1, nxh
      dkx = dnx*real(j - 1)
      at5 = dkx*dkx + at3
      at6 = exp(-.5*((dkx*ax)**2 + at4))
      if (at5.eq.0.) then
         ffc(j,k,l) = cmplx(affp,1.0)
      else
         ffc(j,k,l) = cmplx(affp*at6/at5,at6)
      endif
   10 continue
   20 continue
   30 continue
      return
c calculate force/charge and sum field energy
   40 sum1 = 0.0d0
c mode numbers 0 < kx < nx/2, 0 < ky < ny/2, and 0 < kz < nz/2
!$OMP PARALLEL
!$OMP DO PRIVATE(j,k,l,k1,l1,dky,dkz,at1,at2,at3,at4,zt1,zt2,wp)
!$OMP& REDUCTION(+:sum1)
      do 90 l = 2, nzh
      l1 = nz2 - l
      dkz = dnz*real(l - 1)
      wp = 0.0d0
      do 60 k = 2, nyh
      k1 = ny2 - k
      dky = dny*real(k - 1)
      do 50 j = 2, nxh
      at1 = real(ffc(j,k,l))*aimag(ffc(j,k,l))
      at2 = dnx*real(j - 1)*at1
      at3 = dky*at1
      at4 = dkz*at1
      zt1 = cmplx(aimag(q(j,k,l)),-real(q(j,k,l)))
      zt2 = cmplx(aimag(q(j,k1,l)),-real(q(j,k1,l)))
      fxyz(1,j,k,l) = at2*zt1
      fxyz(2,j,k,l) = at3*zt1
      fxyz(3,j,k,l) = at4*zt1
      fxyz(1,j,k1,l) = at2*zt2
      fxyz(2,j,k1,l) = -at3*zt2
      fxyz(3,j,k1,l) = at4*zt2
      zt1 = cmplx(aimag(q(j,k,l1)),-real(q(j,k,l1)))
      zt2 = cmplx(aimag(q(j,k1,l1)),-real(q(j,k1,l1)))
      fxyz(1,j,k,l1) = at2*zt1
      fxyz(2,j,k,l1) = at3*zt1
      fxyz(3,j,k,l1) = -at4*zt1
      fxyz(1,j,k1,l1) = at2*zt2
      fxyz(2,j,k1,l1) = -at3*zt2
      fxyz(3,j,k1,l1) = -at4*zt2
      wp = wp + at1*(q(j,k,l)*conjg(q(j,k,l))                           
     1   + q(j,k1,l)*conjg(q(j,k1,l)) + q(j,k,l1)*conjg(q(j,k,l1))      
     2   + q(j,k1,l1)*conjg(q(j,k1,l1)))
   50 continue
   60 continue
c mode numbers kx = 0, nx/2
      do 70 k = 2, nyh
      k1 = ny2 - k
      at1 = real(ffc(1,k,l))*aimag(ffc(1,k,l))
      at3 = dny*real(k - 1)*at1
      at4 = dkz*at1
      zt1 = cmplx(aimag(q(1,k,l)),-real(q(1,k,l)))
      zt2 = cmplx(aimag(q(1,k,l1)),-real(q(1,k,l1)))
      fxyz(1,1,k,l) = zero
      fxyz(2,1,k,l) = at3*zt1
      fxyz(3,1,k,l) = at4*zt1
      fxyz(1,1,k1,l) = zero
      fxyz(2,1,k1,l) = zero
      fxyz(3,1,k1,l) = zero
      fxyz(1,1,k,l1) = zero
      fxyz(2,1,k,l1) = at3*zt2
      fxyz(3,1,k,l1) = -at4*zt2
      fxyz(1,1,k1,l1) = zero
      fxyz(2,1,k1,l1) = zero
      fxyz(3,1,k1,l1) = zero
      wp = wp + at1*(q(1,k,l)*conjg(q(1,k,l))                           
     1   + q(1,k,l1)*conjg(q(1,k,l1)))
   70 continue
c mode numbers ky = 0, ny/2
      k1 = nyh + 1
      do 80 j = 2, nxh
      at1 = real(ffc(j,1,l))*aimag(ffc(j,1,l))
      at2 = dnx*real(j - 1)*at1
      at4 = dkz*at1
      zt1 = cmplx(aimag(q(j,1,l)),-real(q(j,1,l)))
      zt2 = cmplx(aimag(q(j,1,l1)),-real(q(j,1,l1)))
      fxyz(1,j,1,l) = at2*zt1
      fxyz(2,j,1,l) = zero
      fxyz(3,j,1,l) = at4*zt1
      fxyz(1,j,k1,l) = zero
      fxyz(2,j,k1,l) = zero
      fxyz(3,j,k1,l) = zero
      fxyz(1,j,1,l1) = at2*zt2
      fxyz(2,j,1,l1) = zero
      fxyz(3,j,1,l1) = -at4*zt2
      fxyz(1,j,k1,l1) = zero
      fxyz(2,j,k1,l1) = zero
      fxyz(3,j,k1,l1) = zero
      wp = wp + at1*(q(j,1,l)*conjg(q(j,1,l))                           
     1   + q(j,1,l1)*conjg(q(j,1,l1)))
   80 continue
c mode numbers kx = 0, nx/2
      at1 = real(ffc(1,1,l))*aimag(ffc(1,1,l))
      at4 = dkz*at1
      fxyz(1,1,1,l) = zero
      fxyz(2,1,1,l) = zero
      fxyz(3,1,1,l) = at4*cmplx(aimag(q(1,1,l)),-real(q(1,1,l)))
      fxyz(1,1,k1,l) = zero
      fxyz(2,1,k1,l) = zero
      fxyz(3,1,k1,l) = zero
      fxyz(1,1,1,l1) = zero
      fxyz(2,1,1,l1) = zero
      fxyz(3,1,1,l1) = zero
      fxyz(1,1,k1,l1) = zero
      fxyz(2,1,k1,l1) = zero
      fxyz(3,1,k1,l1) = zero
      wp = wp + at1*(q(1,1,l)*conjg(q(1,1,l)))
      sum1 = sum1 + wp
   90 continue
!$OMP END DO NOWAIT
!$OMP END PARALLEL
c mode numbers kz = 0, nz/2
      l1 = nzh + 1
      sum2 = 0.0d0
!$OMP PARALLEL DO PRIVATE(j,k,k1,dky,at1,at2,at3,zt1,zt2,wp)
!$OMP& REDUCTION(+:sum2)
      do 110 k = 2, nyh
      k1 = ny2 - k
      dky = dny*real(k - 1)
      wp = 0.0d0
      do 100 j = 2, nxh
      at1 = real(ffc(j,k,1))*aimag(ffc(j,k,1))
      at2 = dnx*real(j - 1)*at1
      at3 = dky*at1
      zt1 = cmplx(aimag(q(j,k,1)),-real(q(j,k,1)))
      zt2 = cmplx(aimag(q(j,k1,1)),-real(q(j,k1,1)))
      fxyz(1,j,k,1) = at2*zt1
      fxyz(2,j,k,1) = at3*zt1
      fxyz(3,j,k,1) = zero
      fxyz(1,j,k1,1) = at2*zt2
      fxyz(2,j,k1,1) = -at3*zt2
      fxyz(3,j,k1,1) = zero
      fxyz(1,j,k,l1) = zero
      fxyz(2,j,k,l1) = zero
      fxyz(3,j,k,l1) = zero
      fxyz(1,j,k1,l1) = zero
      fxyz(2,j,k1,l1) = zero
      fxyz(3,j,k1,l1) = zero
      wp = wp + at1*(q(j,k,1)*conjg(q(j,k,1))
     1   + q(j,k1,1)*conjg(q(j,k1,1)))
  100 continue
c mode numbers kx = 0, nx/2
      at1 = real(ffc(1,k,1))*aimag(ffc(1,k,1))
      at3 = dny*real(k - 1)*at1
      fxyz(1,1,k,1) = zero
      fxyz(2,1,k,1) = at3*cmplx(aimag(q(1,k,1)),-real(q(1,k,1)))
      fxyz(3,1,k,1) = zero
      fxyz(1,1,k1,1) = zero
      fxyz(2,1,k1,1) = zero
      fxyz(3,1,k1,1) = zero
      fxyz(1,1,k,l1) = zero
      fxyz(2,1,k,l1) = zero
      fxyz(3,1,k,l1) = zero
      fxyz(1,1,k1,l1) = zero
      fxyz(2,1,k1,l1) = zero
      fxyz(3,1,k1,l1) = zero
      wp = wp + at1*(q(1,k,1)*conjg(q(1,k,1)))
      sum2 = sum2 + wp
  110 continue
!$OMP END PARALLEL DO
      wp = 0.0d0
c mode numbers ky = 0, ny/2
      k1 = nyh + 1
      do 120 j = 2, nxh
      at1 = real(ffc(j,1,1))*aimag(ffc(j,1,1))
      at2 = dnx*real(j - 1)*at1
      fxyz(1,j,1,1) = at2*cmplx(aimag(q(j,1,1)),-real(q(j,1,1)))
      fxyz(2,j,1,1) = zero
      fxyz(3,j,1,1) = zero
      fxyz(1,j,k1,1) = zero
      fxyz(2,j,k1,1) = zero
      fxyz(3,j,k1,1) = zero
      fxyz(1,j,1,l1) = zero
      fxyz(2,j,1,l1) = zero
      fxyz(3,j,1,l1) = zero
      fxyz(1,j,k1,l1) = zero
      fxyz(2,j,k1,l1) = zero
      fxyz(3,j,k1,l1) = zero
      wp = wp + at1*(q(j,1,1)*conjg(q(j,1,1)))
  120 continue
      fxyz(1,1,1,1) = zero
      fxyz(2,1,1,1) = zero
      fxyz(3,1,1,1) = zero
      fxyz(1,1,k1,1) = zero
      fxyz(2,1,k1,1) = zero
      fxyz(3,1,k1,1) = zero
      fxyz(1,1,1,l1) = zero
      fxyz(2,1,1,l1) = zero
      fxyz(3,1,1,l1) = zero
      fxyz(1,1,k1,l1) = zero
      fxyz(2,1,k1,l1) = zero
      fxyz(3,1,k1,l1) = zero
      we = real(nx)*real(ny)*real(nz)*(sum1 + sum2 + wp)
      return
      end
c-----------------------------------------------------------------------
      subroutine MCUPERP3(cu,nx,ny,nz,nxvh,nyv,nzv)
c this subroutine calculates the transverse current in fourier space
c input: all, output: cu
c approximate flop count is:
c 100*nxc*nyc*nzc + 36*(nxc*nyc + nxc*nzc + nyc*nzc)
c and (nx/2)*nyc*nzc divides
c where nxc = nx/2 - 1, nyc = ny/2 - 1, nzc = nz/2 - 1
c the transverse current is calculated using the equation:
c cux(kx,ky,kz) = cux(kx,ky,kz) - kx*(kx*cux(kx,ky,kz)+ky*cuy(kx,ky,kz)+
c                                 kz*cuz(kx,ky,kz))/(kx*kx+ky*ky+kz*kz)
c cuy(kx,ky,kz) = cuy(kx,ky,kz) - ky*(kx*cux(kx,ky,kz)+ky*cuy(kx,ky,kz)+
c                                 kz*cuz(kx,ky,kz))/(kx*kx+ky*ky+kz*kz)
c cuz(kx,ky,kz) = cuz(kx,ky,kz) - kz*(kx*cux(kx,ky,kz)+ky*cuy(kx,ky,kz)+
c                                 kz*cuz(kx,ky,kz))/(kx*kx+ky*ky+kz*kz)
c where kx = 2pi*j/nx, ky = 2pi*k/ny, kz = 2pi*l/nz, and
c j,k,l = fourier mode numbers, except for
c cux(kx=pi) = cuy(kx=pi) = cuz(kx=pi) = 0,
c cux(ky=pi) = cuy(ky=pi) = cux(ky=pi) = 0,
c cux(kz=pi) = cuy(kz=pi) = cuz(kz=pi) = 0,
c cux(kx=0,ky=0,kz=0) = cuy(kx=0,ky=0,kz=0) = cuz(kx=0,ky=0,kz=0) = 0.
c cu(i,j,k,l) = complex current density for fourier mode (j-1,k-1,l-1)
c nx/ny/nz = system length in x/y/z direction
c nxvh = second dimension of field arrays, must be >= nxh
c nyv = third dimension of field arrays, must be >= ny
c nzv = fourth dimension of field arrays, must be >= nz
      implicit none
      integer nx, ny, nz, nxvh, nyv, nzv
      complex cu
      dimension cu(3,nxvh,nyv,nzv)
c local data
      integer nxh, nyh, nzh, ny2, nz2, j, k, l, k1, l1
      real dnx, dny, dnz, dkx, dky, dkz, dky2, dkz2, dkyz2, at1
      complex zero, zt1
      nxh = nx/2
      nyh = max(1,ny/2)
      nzh = max(1,nz/2)
      ny2 = ny + 2
      nz2 = nz + 2
      dnx = 6.28318530717959/real(nx)
      dny = 6.28318530717959/real(ny)
      dnz = 6.28318530717959/real(nz)
      zero = cmplx(0.0,0.0)
c calculate transverse part of current
c mode numbers 0 < kx < nx/2, 0 < ky < ny/2, and 0 < kz < nz/2
!$OMP PARALLEL
!$OMP DO PRIVATE(j,k,l,k1,l1,dkx,dky,dkz,dkz2,dkyz2,at1,zt1)
      do 50 l = 2, nzh
      l1 = nz2 - l
      dkz = dnz*real(l - 1)
      dkz2 = dkz*dkz
      do 20 k = 2, nyh
      k1 = ny2 - k
      dky = dny*real(k - 1)
      dkyz2 = dky*dky + dkz2
      do 10 j = 2, nxh
      dkx = dnx*real(j - 1)
      at1 = 1.0/(dkx*dkx + dkyz2)
      zt1 = at1*(dkx*cu(1,j,k,l) + dky*cu(2,j,k,l) + dkz*cu(3,j,k,l))
      cu(1,j,k,l) = cu(1,j,k,l) - dkx*zt1
      cu(2,j,k,l) = cu(2,j,k,l) - dky*zt1
      cu(3,j,k,l) = cu(3,j,k,l) - dkz*zt1
      zt1 = at1*(dkx*cu(1,j,k1,l) - dky*cu(2,j,k1,l) + dkz*cu(3,j,k1,l))
      cu(1,j,k1,l) = cu(1,j,k1,l) - dkx*zt1
      cu(2,j,k1,l) = cu(2,j,k1,l) + dky*zt1
      cu(3,j,k1,l) = cu(3,j,k1,l) - dkz*zt1
      zt1 = at1*(dkx*cu(1,j,k,l1) + dky*cu(2,j,k,l1) - dkz*cu(3,j,k,l1))
      cu(1,j,k,l1) = cu(1,j,k,l1) - dkx*zt1
      cu(2,j,k,l1) = cu(2,j,k,l1) - dky*zt1
      cu(3,j,k,l1) = cu(3,j,k,l1) + dkz*zt1
      zt1 = at1*(dkx*cu(1,j,k1,l1) - dky*cu(2,j,k1,l1)
     1    - dkz*cu(3,j,k1,l1))
      cu(1,j,k1,l1) = cu(1,j,k1,l1) - dkx*zt1
      cu(2,j,k1,l1) = cu(2,j,k1,l1) + dky*zt1
      cu(3,j,k1,l1) = cu(3,j,k1,l1) + dkz*zt1
   10 continue
   20 continue
c mode numbers kx = 0, nx/2
      do 30 k = 2, nyh
      k1 = ny2 - k
      dky = dny*real(k - 1)
      at1 = 1.0/(dky*dky + dkz2)
      zt1 = at1*(dky*cu(2,1,k,l) + dkz*cu(3,1,k,l))
      cu(2,1,k,l) = cu(2,1,k,l) - dky*zt1
      cu(3,1,k,l) = cu(3,1,k,l) - dkz*zt1
      cu(1,1,k1,l) = zero
      cu(2,1,k1,l) = zero
      cu(3,1,k1,l) = zero
      zt1 = at1*(dky*cu(2,1,k,l1) - dkz*cu(3,1,k,l1))
      cu(2,1,k,l1) = cu(2,1,k,l1) - dky*zt1
      cu(3,1,k,l1) = cu(3,1,k,l1) + dkz*zt1
      cu(1,1,k1,l1) = zero
      cu(2,1,k1,l1) = zero
      cu(3,1,k1,l1) = zero
   30 continue
c mode numbers ky = 0, ny/2
      k1 = nyh + 1
      do 40 j = 2, nxh
      dkx = dnx*real(j - 1)
      at1 = 1.0/(dkx*dkx + dkz2)
      zt1 = at1*(dkx*cu(1,j,1,l) + dkz*cu(3,j,1,l))
      cu(1,j,1,l) = cu(1,j,1,l) - dkx*zt1
      cu(3,j,1,l) = cu(3,j,1,l) - dkz*zt1
      cu(1,j,k1,l) = zero
      cu(2,j,k1,l) = zero
      cu(3,j,k1,l) = zero
      zt1 = at1*(dkx*cu(1,j,1,l1) - dkz*cu(3,j,1,l1))
      cu(1,j,1,l1) = cu(1,j,1,l1) - dkx*zt1
      cu(3,j,1,l1) = cu(3,j,1,l1) + dkz*zt1
      cu(1,j,k1,l1) = zero
      cu(2,j,k1,l1) = zero
      cu(3,j,k1,l1) = zero
   40 continue
c mode numbers kx = 0, nx/2
      cu(3,1,1,l) = zero
      cu(1,1,k1,l) = zero
      cu(2,1,k1,l) = zero
      cu(3,1,k1,l) = zero
      cu(1,1,1,l1) = zero
      cu(2,1,1,l1) = zero
      cu(3,1,1,l1) = zero
      cu(1,1,k1,l1) = zero
      cu(2,1,k1,l1) = zero
      cu(3,1,k1,l1) = zero
   50 continue
!$OMP END DO NOWAIT
!$OMP END PARALLEL
c mode numbers kz = 0, nz/2
      l1 = nzh + 1
!$OMP PARALLEL DO PRIVATE(j,k,k1,dky,dky2,dkx,at1,zt1)
      do 70 k = 2, nyh
      k1 = ny2 - k
      dky = dny*real(k - 1)
      dky2 = dky*dky
      do 60 j = 2, nxh
      dkx = dnx*real(j - 1)
      at1 = 1./(dkx*dkx + dky2)
      zt1 = at1*(dkx*cu(1,j,k,1) + dky*cu(2,j,k,1))
      cu(1,j,k,1) = cu(1,j,k,1) - dkx*zt1
      cu(2,j,k,1) = cu(2,j,k,1) - dky*zt1
      zt1 = at1*(dkx*cu(1,j,k1,1) - dky*cu(2,j,k1,1))
      cu(1,j,k1,1) = cu(1,j,k1,1) - dkx*zt1
      cu(2,j,k1,1) = cu(2,j,k1,1) + dky*zt1
      cu(1,j,k,l1) = zero
      cu(2,j,k,l1) = zero
      cu(3,j,k,l1) = zero
      cu(1,j,k1,l1) = zero
      cu(2,j,k1,l1) = zero
      cu(3,j,k1,l1) = zero
   60 continue
c mode numbers kx = 0, nx/2
      cu(2,1,k,1) = zero
      cu(1,1,k1,1) = zero
      cu(2,1,k1,1) = zero
      cu(3,1,k1,1) = zero
      cu(1,1,k,l1) = zero
      cu(2,1,k,l1) = zero
      cu(3,1,k,l1) = zero
      cu(1,1,k1,l1) = zero
      cu(2,1,k1,l1) = zero
      cu(3,1,k1,l1) = zero
   70 continue
!$OMP END PARALLEL DO
c mode numbers ky = 0, ny/2
      k1 = nyh + 1
      do 90 j = 2, nxh
      cu(1,j,1,1) = zero
      cu(1,j,k1,1) = zero
      cu(2,j,k1,1) = zero
      cu(3,j,k1,1) = zero
      cu(1,j,1,l1) = zero
      cu(2,j,1,l1) = zero
      cu(3,j,1,l1) = zero
      cu(1,j,k1,l1) = zero
      cu(2,j,k1,l1) = zero
      cu(3,j,k1,l1) = zero
   90 continue
      cu(1,1,1,1) = zero
      cu(2,1,1,1) = zero
      cu(3,1,1,1) = zero
      cu(1,1,k1,1) = zero
      cu(2,1,k1,1) = zero
      cu(3,1,k1,1) = zero
      cu(1,1,1,l1) = zero
      cu(2,1,1,l1) = zero
      cu(3,1,1,l1) = zero
      cu(1,1,k1,l1) = zero
      cu(2,1,k1,l1) = zero
      cu(3,1,k1,l1) = zero
      return
      end
c-----------------------------------------------------------------------
      subroutine MIBPOIS33(cu,bxyz,ffc,ci,wm,nx,ny,nz,nxvh,nyv,nzv,nxhd,
     1nyhd,nzhd)
c this subroutine solves 3d poisson's equation in fourier space for
c magnetic field with periodic boundary conditions.
c input: cu,ffc,ci,nx,ny,nz,nxvh,nyv,nzv,nxhd,nyhd,nzhd
c output: bxyz, wm
c approximate flop count is:
c 193*nxc*nyc*nzc + 84*(nxc*nyc + nxc*nzc + nyc*nzc)
c where nxc = nx/2 - 1, nyc = ny/2 - 1, nzc = nz/2 - 1
c the magnetic field is calculated using the equations:
c bx(kx,ky,kz) = ci*ci*sqrt(-1)*g(kx,ky,kz)*
c                (ky*cuz(kx,ky,kz)-kz*cuy(kx,ky,kz)),
c by(kx,ky,kz) = ci*ci*sqrt(-1)*g(kx,ky,kz)*
c                (kz*cux(kx,ky,kz)-kx*cuz(kx,ky,kz)),
c bz(kx,ky,kz) = ci*ci*sqrt(-1)*g(kx,ky,kz)*
c                (kx*cuy(kx,ky,kz)-ky*cux(kx,ky,kz)),
c where kx = 2pi*j/nx, ky = 2pi*k/ny, kz = 2pi*l/nz, and
c j,k,l = fourier mode numbers,
c g(kx,ky,kz) = (affp/(kx**2+ky**2+kz**2))*s(kx,ky,kz),
c s(kx,ky,kz) = exp(-((kx*ax)**2+(ky*ay)**2+(kz*az)**2)/2), except for
c bx(kx=pi) = by(kx=pi) = bz(kx=pi) = 0,
c bx(ky=pi) = by(ky=pi) = bx(ky=pi) = 0,
c bx(kz=pi) = by(kz=pi) = bz(kz=pi) = 0,
c bx(kx=0,ky=0,kz=0) = by(kx=0,ky=0,kz=0) = bz(kx=0,ky=0,kz=0) = 0.
c cu(i,j,k,l) = complex current density for fourier mode (j-1,k-1,l-1)
c bxyz(i,j,k,l) = i component of complex magnetic field
c all for fourier mode (j-1,k-1,l-1)
c aimag(ffc(j,k,l)) = finite-size particle shape factor s
c for fourier mode (j-1,k-1,l-1)
c real(ffc(j,k,l)) = potential green's function g
c for fourier mode (j-1,k-1,l-1)
c ci = reciprocal of velocity of light
c magnetic field energy is also calculated, using
c wm = nx*ny*nz*sum((affp/(kx**2+ky**2+kz**2))*ci*ci
c    |cu(kx,ky,kz)*s(kx,ky,kz)|**2)
c this expression is valid only if the current is divergence-free
c nx/ny/nz = system length in x/y/z direction
c nxvh = second dimension of field arrays, must be >= nxh
c nyv = third dimension of field arrays, must be >= ny
c nzv = fourth dimension of field arrays, must be >= nz
c nxhd = dimension of form factor array, must be >= nxh
c nyhd = second dimension of form factor array, must be >= nyh
c nzhd = third dimension of form factor array, must be >= nzh
      implicit none
      integer nx, ny, nz, nxvh, nyv, nzv, nxhd, nyhd, nzhd
      real ci, wm
      complex cu, bxyz, ffc
      dimension cu(3,nxvh,nyv,nzv), bxyz(3,nxvh,nyv,nzv)
      dimension ffc(nxhd,nyhd,nzhd)
c local data
      integer nxh, nyh, nzh, ny2, nz2, j, k, l, k1, l1
      real dnx, dny, dnz, dky, dkz, ci2, at1, at2, at3, at4
      complex zero, zt1, zt2, zt3
      double precision wp, sum1, sum2
      nxh = nx/2
      nyh = max(1,ny/2)
      nzh = max(1,nz/2)
      ny2 = ny + 2
      nz2 = nz + 2
      dnx = 6.28318530717959/real(nx)
      dny = 6.28318530717959/real(ny)
      dnz = 6.28318530717959/real(nz)
      zero = cmplx(0.0,0.0)
      ci2 = ci*ci
c calculate magnetic field and sum field energy
      sum1 = 0.0d0
c mode numbers 0 < kx < nx/2, 0 < ky < ny/2, and 0 < kz < nz/2
!$OMP PARALLEL
!$OMP DO PRIVATE(j,k,l,k1,l1,dky,dkz,at1,at2,at3,at4,zt1,zt2,zt3,wp)
!$OMP& REDUCTION(+:sum1)
      do 50 l = 2, nzh
      l1 = nz2 - l
      dkz = dnz*real(l - 1)
      wp = 0.0d0
      do 20 k = 2, nyh
      k1 = ny2 - k
      dky = dny*real(k - 1)
      do 10 j = 2, nxh
      at1 = ci2*real(ffc(j,k,l))
      at2 = dnx*real(j - 1)*at1
      at3 = dky*at1
      at4 = dkz*at1
      at1 = at1*aimag(ffc(j,k,l))
      zt1 = cmplx(-aimag(cu(3,j,k,l)),real(cu(3,j,k,l)))
      zt2 = cmplx(-aimag(cu(2,j,k,l)),real(cu(2,j,k,l)))
      zt3 = cmplx(-aimag(cu(1,j,k,l)),real(cu(1,j,k,l)))
      bxyz(1,j,k,l) = at3*zt1 - at4*zt2
      bxyz(2,j,k,l) = at4*zt3 - at2*zt1
      bxyz(3,j,k,l) = at2*zt2 - at3*zt3
      zt1 = cmplx(-aimag(cu(3,j,k1,l)),real(cu(3,j,k1,l)))
      zt2 = cmplx(-aimag(cu(2,j,k1,l)),real(cu(2,j,k1,l)))
      zt3 = cmplx(-aimag(cu(1,j,k1,l)),real(cu(1,j,k1,l)))
      bxyz(1,j,k1,l) = -at3*zt1 - at4*zt2
      bxyz(2,j,k1,l) = at4*zt3 - at2*zt1
      bxyz(3,j,k1,l) = at2*zt2 + at3*zt3
      zt1 = cmplx(-aimag(cu(3,j,k,l1)),real(cu(3,j,k,l1)))
      zt2 = cmplx(-aimag(cu(2,j,k,l1)),real(cu(2,j,k,l1)))
      zt3 = cmplx(-aimag(cu(1,j,k,l1)),real(cu(1,j,k,l1)))
      bxyz(1,j,k,l1) = at3*zt1 + at4*zt2
      bxyz(2,j,k,l1) = -at4*zt3 - at2*zt1
      bxyz(3,j,k,l1) = at2*zt2 - at3*zt3
      zt1 = cmplx(-aimag(cu(3,j,k1,l1)),real(cu(3,j,k1,l1)))
      zt2 = cmplx(-aimag(cu(2,j,k1,l1)),real(cu(2,j,k1,l1)))
      zt3 = cmplx(-aimag(cu(1,j,k1,l1)),real(cu(1,j,k1,l1)))
      bxyz(1,j,k1,l1) = -at3*zt1 + at4*zt2
      bxyz(2,j,k1,l1) = -at4*zt3 - at2*zt1
      bxyz(3,j,k1,l1) = at2*zt2 + at3*zt3
      wp = wp + at1*(cu(1,j,k,l)*conjg(cu(1,j,k,l))
     1   + cu(2,j,k,l)*conjg(cu(2,j,k,l))
     2   + cu(3,j,k,l)*conjg(cu(3,j,k,l))
     3   + cu(1,j,k1,l)*conjg(cu(1,j,k1,l))
     4   + cu(2,j,k1,l)*conjg(cu(2,j,k1,l))
     5   + cu(3,j,k1,l)*conjg(cu(3,j,k1,l))
     6   + cu(1,j,k,l1)*conjg(cu(1,j,k,l1))
     7   + cu(2,j,k,l1)*conjg(cu(2,j,k,l1))
     8   + cu(3,j,k,l1)*conjg(cu(3,j,k,l1))
     9   + cu(1,j,k1,l1)*conjg(cu(1,j,k1,l1))
     a   + cu(2,j,k1,l1)*conjg(cu(2,j,k1,l1))
     b   + cu(3,j,k1,l1)*conjg(cu(3,j,k1,l1)))
   10 continue
   20 continue
c mode numbers kx = 0, nx/2
      do 30 k = 2, nyh
      k1 = ny2 - k
      at1 = ci2*real(ffc(1,k,l))
      at3 = dny*real(k - 1)*at1
      at4 = dkz*at1
      at1 = at1*aimag(ffc(1,k,l))
      zt1 = cmplx(-aimag(cu(3,1,k,l)),real(cu(3,1,k,l)))
      zt2 = cmplx(-aimag(cu(2,1,k,l)),real(cu(2,1,k,l)))
      zt3 = cmplx(-aimag(cu(1,1,k,l)),real(cu(1,1,k,l)))
      bxyz(1,1,k,l) = at3*zt1 - at4*zt2
      bxyz(2,1,k,l) = at4*zt3
      bxyz(3,1,k,l) = -at3*zt3
      bxyz(1,1,k1,l) = zero
      bxyz(2,1,k1,l) = zero
      bxyz(3,1,k1,l) = zero
      zt1 = cmplx(-aimag(cu(3,1,k,l1)),real(cu(3,1,k,l1)))
      zt2 = cmplx(-aimag(cu(2,1,k,l1)),real(cu(2,1,k,l1)))
      zt3 = cmplx(-aimag(cu(1,1,k,l1)),real(cu(1,1,k,l1)))
      bxyz(1,1,k,l1) = at3*zt1 + at4*zt2
      bxyz(2,1,k,l1) = -at4*zt3
      bxyz(3,1,k,l1) = -at3*zt3
      bxyz(1,1,k1,l1) = zero
      bxyz(2,1,k1,l1) = zero
      bxyz(3,1,k1,l1) = zero
      wp = wp + at1*(cu(1,1,k,l)*conjg(cu(1,1,k,l))
     1   + cu(2,1,k,l)*conjg(cu(2,1,k,l))
     2   + cu(3,1,k,l)*conjg(cu(3,1,k,l))
     3   + cu(1,1,k,l1)*conjg(cu(1,1,k,l1))
     4   + cu(2,1,k,l1)*conjg(cu(2,1,k,l1))
     5   + cu(3,1,k,l1)*conjg(cu(3,1,k,l1)))
   30 continue
c mode numbers ky = 0, ny/2
      k1 = nyh + 1
      do 40 j = 2, nxh
      at1 = ci2*real(ffc(j,1,l))
      at2 = dnx*real(j - 1)*at1
      at4 = dkz*at1
      at1 = at1*aimag(ffc(j,1,l))
      zt1 = cmplx(-aimag(cu(3,j,1,l)),real(cu(3,j,1,l)))
      zt2 = cmplx(-aimag(cu(2,j,1,l)),real(cu(2,j,1,l)))
      zt3 = cmplx(-aimag(cu(1,j,1,l)),real(cu(1,j,1,l)))
      bxyz(1,j,1,l) = -at4*zt2
      bxyz(2,j,1,l) = at4*zt3 - at2*zt1
      bxyz(3,j,1,l) = at2*zt2
      bxyz(1,j,k1,l) = zero
      bxyz(2,j,k1,l) = zero
      bxyz(3,j,k1,l) = zero
      zt1 = cmplx(-aimag(cu(3,j,1,l1)),real(cu(3,j,1,l1)))
      zt2 = cmplx(-aimag(cu(2,j,1,l1)),real(cu(2,j,1,l1)))
      zt3 = cmplx(-aimag(cu(1,j,1,l1)),real(cu(1,j,1,l1)))
      bxyz(1,j,1,l1) = at4*zt2
      bxyz(2,j,1,l1) = -at4*zt3 - at2*zt1
      bxyz(3,j,1,l1) = at2*zt2
      bxyz(1,j,k1,l1) = zero
      bxyz(2,j,k1,l1) = zero
      bxyz(3,j,k1,l1) = zero
      wp = wp + at1*(cu(1,j,1,l)*conjg(cu(1,j,1,l))
     1   + cu(2,j,1,l)*conjg(cu(2,j,1,l))
     2   + cu(3,j,1,l)*conjg(cu(3,j,1,l))
     3   + cu(1,j,1,l1)*conjg(cu(1,j,1,l1))
     4   + cu(2,j,1,l1)*conjg(cu(2,j,1,l1))
     5   + cu(3,j,1,l1)*conjg(cu(3,j,1,l1)))
   40 continue
c mode numbers kx = 0, nx/2
      at1 = ci2*real(ffc(1,1,l))
      at4 = dkz*at1
      at1 = at1*aimag(ffc(1,1,l))
      zt2 = cmplx(-aimag(cu(2,1,1,l)),real(cu(2,1,1,l)))
      zt3 = cmplx(-aimag(cu(1,1,1,l)),real(cu(1,1,1,l)))
      bxyz(1,1,1,l) = -at4*zt2
      bxyz(2,1,1,l) = at4*zt3
      bxyz(3,1,1,l) = zero
      bxyz(1,1,k1,l) = zero
      bxyz(2,1,k1,l) = zero
      bxyz(3,1,k1,l) = zero
      bxyz(1,1,1,l1) = zero
      bxyz(2,1,1,l1) = zero
      bxyz(3,1,1,l1) = zero
      bxyz(1,1,k1,l1) = zero
      bxyz(2,1,k1,l1) = zero
      bxyz(3,1,k1,l1) = zero
      wp = wp + at1*(cu(1,1,1,l)*conjg(cu(1,1,1,l))
     1   + cu(2,1,1,l)*conjg(cu(2,1,1,l))
     2   + cu(3,1,1,l)*conjg(cu(3,1,1,l)))
      sum1 = sum1 + wp
   50 continue
!$OMP END DO NOWAIT
!$OMP END PARALLEL
c mode numbers kz = 0, nz/2
      l1 = nzh + 1
      sum2 = 0.0d0
!$OMP PARALLEL DO PRIVATE(j,k,k1,dky,at1,at2,at3,zt1,zt2,zt3,wp)
!$OMP& REDUCTION(+:sum2)
      do 70 k = 2, nyh
      k1 = ny2 - k
      dky = dny*real(k - 1)
      wp = 0.0d0
      do 60 j = 2, nxh
      at1 = ci2*real(ffc(j,k,1))
      at2 = dnx*real(j - 1)*at1
      at3 = dky*at1
      at1 = at1*aimag(ffc(j,k,1))
      zt1 = cmplx(-aimag(cu(3,j,k,1)),real(cu(3,j,k,1)))
      zt2 = cmplx(-aimag(cu(2,j,k,1)),real(cu(2,j,k,1)))
      zt3 = cmplx(-aimag(cu(1,j,k,1)),real(cu(1,j,k,1)))
      bxyz(1,j,k,1) = at3*zt1
      bxyz(2,j,k,1) = -at2*zt1
      bxyz(3,j,k,1) = at2*zt2 - at3*zt3
      zt1 = cmplx(-aimag(cu(3,j,k1,1)),real(cu(3,j,k1,1)))
      zt2 = cmplx(-aimag(cu(2,j,k1,1)),real(cu(2,j,k1,1)))
      zt3 = cmplx(-aimag(cu(1,j,k1,1)),real(cu(1,j,k1,1)))
      bxyz(1,j,k1,1) = -at3*zt1
      bxyz(2,j,k1,1) = -at2*zt1
      bxyz(3,j,k1,1) = at2*zt2 + at3*zt3
      bxyz(1,j,k,l1) = zero
      bxyz(2,j,k,l1) = zero
      bxyz(3,j,k,l1) = zero
      bxyz(1,j,k1,l1) = zero
      bxyz(2,j,k1,l1) = zero
      bxyz(3,j,k1,l1) = zero
      wp = wp + at1*(cu(1,j,k,1)*conjg(cu(1,j,k,1))
     1   + cu(2,j,k,1)*conjg(cu(2,j,k,1))
     2   + cu(3,j,k,1)*conjg(cu(3,j,k,1))
     3   + cu(1,j,k1,1)*conjg(cu(1,j,k1,1))
     4   + cu(2,j,k1,1)*conjg(cu(2,j,k1,1))
     5   + cu(3,j,k1,1)*conjg(cu(3,j,k1,1)))
   60 continue
c mode numbers kx = 0, nx/2
      at1 = ci2*real(ffc(1,k,1))
      at3 = dny*real(k - 1)*at1
      at1 = at1*aimag(ffc(1,k,1))
      zt1 = cmplx(-aimag(cu(3,1,k,1)),real(cu(3,1,k,1)))
      zt3 = cmplx(-aimag(cu(1,1,k,1)),real(cu(1,1,k,1)))
      bxyz(1,1,k,1) = at3*zt1
      bxyz(2,1,k,1) = zero
      bxyz(3,1,k,1) = -at3*zt3
      bxyz(1,1,k1,1) = zero
      bxyz(2,1,k1,1) = zero
      bxyz(3,1,k1,1) = zero
      bxyz(1,1,k,l1) = zero
      bxyz(2,1,k,l1) = zero
      bxyz(3,1,k,l1) = zero
      bxyz(1,1,k1,l1) = zero
      bxyz(2,1,k1,l1) = zero
      bxyz(3,1,k1,l1) = zero
      wp = wp + at1*(cu(1,1,k,1)*conjg(cu(1,1,k,1))
     1   + cu(2,1,k,1)*conjg(cu(2,1,k,1))
     2   + cu(3,1,k,1)*conjg(cu(3,1,k,1)))
      sum2 = sum2 + wp
   70 continue
!$OMP END PARALLEL DO
      wp = 0.0d0
c mode numbers ky = 0, ny/2
      k1 = nyh + 1
      do 80 j = 2, nxh
      at1 = ci2*real(ffc(j,1,1))
      at2 = dnx*real(j - 1)*at1
      at1 = at1*aimag(ffc(j,1,1))
      zt1 = cmplx(-aimag(cu(3,j,1,1)),real(cu(3,j,1,1)))
      zt2 = cmplx(-aimag(cu(2,j,1,1)),real(cu(2,j,1,1)))
      bxyz(1,j,1,1) = zero
      bxyz(2,j,1,1) = -at2*zt1
      bxyz(3,j,1,1) = at2*zt2
      bxyz(1,j,k1,1) = zero
      bxyz(2,j,k1,1) = zero
      bxyz(3,j,k1,1) = zero
      bxyz(1,j,1,l1) = zero
      bxyz(2,j,1,l1) = zero
      bxyz(3,j,1,l1) = zero
      bxyz(1,j,k1,l1) = zero
      bxyz(2,j,k1,l1) = zero
      bxyz(3,j,k1,l1) = zero
      wp = wp + at1*(cu(1,j,1,1)*conjg(cu(1,j,1,1))
     1   + cu(2,j,1,1)*conjg(cu(2,j,1,1))
     2   + cu(3,j,1,1)*conjg(cu(3,j,1,1)))
   80 continue
      bxyz(1,1,1,1) = zero
      bxyz(2,1,1,1) = zero
      bxyz(3,1,1,1) = zero
      bxyz(1,1,k1,1) = zero
      bxyz(2,1,k1,1) = zero
      bxyz(3,1,k1,1) = zero
      bxyz(1,1,1,l1) = zero
      bxyz(2,1,1,l1) = zero
      bxyz(3,1,1,l1) = zero
      bxyz(1,1,k1,l1) = zero
      bxyz(2,1,k1,l1) = zero
      bxyz(3,1,k1,l1) = zero
      wm = real(nx)*real(ny)*real(nz)*(sum1 + sum2 + wp)
      return
      end
c-----------------------------------------------------------------------
      subroutine MMAXWEL3(exyz,bxyz,cu,ffc,ci,dt,wf,wm,nx,ny,nz,nxvh,nyv
     1,nzv,nxhd,nyhd,nzhd)
c this subroutine solves 3d maxwell's equation in fourier space for
c transverse electric and magnetic fields with periodic boundary
c conditions.
c input: all, output: wf, wm, exyz, bxyz
c approximate flop count is:
c 680*nxc*nyc*nzc + 149*(nxc*nyc + nxc*nzc + nyc*nzc)
c plus nxc*nyc*nzc divides
c where nxc = nx/2 - 1, nyc = ny/2 - 1, nzc = nz/2 - 1
c the magnetic field is first updated half a step using the equations:
c bx(kx,ky,kz) = bx(kx,ky,kz) - .5*dt*sqrt(-1)*
c                (ky*ez(kx,ky,kz)-kz*ey(kx,ky,kz))
c by(kx,ky,kz) = by(kx,ky,kz) - .5*dt*sqrt(-1)*
c               (kz*ex(kx,ky,kz)-kx*ez(kx,ky,kz))
c bz(kx,ky,kz) = bz(kx,ky,kz) - .5*dt*sqrt(-1)*
c               (kx*ey(kx,ky,kz)-ky*ex(kx,ky,kz))
c the electric field is then updated a whole step using the equations:
c ex(kx,ky,kz) = ex(kx,ky,kz) + c2*dt*sqrt(-1)*
c  (ky*bz(kx,ky,kz)-kz*by(kx,ky,kz)) - affp*dt*cux(kx,ky,kz)*s(kx,ky,kz)
c ey(kx,ky,kz) = ey(kx,ky,kz) + c2*dt*sqrt(-1)*
c  (kz*bx(kx,ky,kz)-kx*bz(kx,ky,kz)) - affp*dt*cuy(kx,ky,kz)*s(kx,ky,kz)
c ez(kx,ky,kz) = ez(kx,ky,kz) + c2*dt*sqrt(-1)*
c  (kx*by(kx,ky,kz)-ky*bx(kx,ky,kz)) - affp*dt*cuz(kx,ky,kz)*s(kx,ky,kz)
c the magnetic field is finally updated the remaining half step with
c the new electric field and the previous magnetic field equations.
c where kx = 2pi*j/nx, ky = 2pi*k/ny, kz = 2pi*l/nz, c2 = 1./(ci*ci)
c and s(kx,ky,kz) = exp(-((kx*ax)**2+(ky*ay)**2+(kz*az)**2)
c j,k,l = fourier mode numbers, except for
c ex(kx=pi) = ey(kx=pi) = ez(kx=pi) = 0,
c ex(ky=pi) = ey(ky=pi) = ex(ky=pi) = 0,
c ex(kz=pi) = ey(kz=pi) = ez(kz=pi) = 0,
c ex(kx=0,ky=0,kz=0) = ey(kx=0,ky=0,kz=0) = ez(kx=0,ky=0,kz=0) = 0.
c and similarly for bx, by, bz.
c cu(i,j,k,l) = complex current density
c exyz(i,j,k,l) = complex transverse electric field
c bxyz(i,j,k,l) = complex magnetic field
c for component i, all for fourier mode (j-1,k-1,l-1)
c real(ffc(1,1,1)) = affp = normalization constant = nx*ny*nz/np,
c where np=number of particles
c aimag(ffc(j,k,l)) = finite-size particle shape factor s,
c s(kx,ky,kz) = exp(-((kx*ax)**2+(ky*ay)**2+(kz*az)**2)/2)
c for fourier mode (j-1,k-1,l-1)
c ci = reciprocal of velocity of light
c dt = time interval between successive calculations
c transverse electric field energy is also calculated, using
c wf = nx*ny*nz**sum((1/affp)*|exyz(kx,ky,kz)|**2)
c magnetic field energy is also calculated, using
c wm = nx*ny*nz**sum((c2/affp)*|bxyz(kx,ky,kz)|**2)
c nx/ny/nz = system length in x/y/z direction
c nxvh = second dimension of field arrays, must be >= nxh
c nyv = third dimension of field arrays, must be >= ny
c nzv = fourth dimension of field arrays, must be >= nz
c nxhd = second dimension of form factor array, must be >= nxh
c nyhd = third dimension of form factor array, must be >= nyh
c nzhd = fourth dimension of form factor array, must be >= nzh
      implicit none
      integer nx, ny, nz, nxvh, nyv, nzv, nxhd, nyhd, nzhd
      real ci, dt, wf, wm
      complex exyz, bxyz, cu, ffc
      dimension exyz(3,nxvh,nyv,nzv), bxyz(3,nxvh,nyv,nzv)
      dimension cu(3,nxvh,nyv,nzv)
      dimension ffc(nxhd,nyhd,nzhd)
c local data
      integer nxh, nyh, nzh, ny2, nz2, j, k, l, k1, l1
      real dnx, dny, dnz, dth, c2, cdt, affp, anorm, dkx, dky, dkz
      real adt, afdt
      complex zero, zt1, zt2, zt3, zt4, zt5, zt6, zt7, zt8, zt9
      double precision wp, ws, sum1, sum2, sum3, sum4
      if (ci.le.0.0) return
      nxh = nx/2
      nyh = max(1,ny/2)
      nzh = max(1,nz/2)
      ny2 = ny + 2
      nz2 = nz + 2
      dnx = 6.28318530717959/real(nx)
      dny = 6.28318530717959/real(ny)
      dnz = 6.28318530717959/real(nz)
      dth = .5*dt
      c2 = 1.0/(ci*ci)
      cdt = c2*dt
      affp = real(ffc(1,1,1))
      adt = affp*dt
      zero = cmplx(0.0,0.0)
      anorm = 1.0/affp
c update electromagnetic field and sum field energies
      sum1 = 0.0d0
      sum2 = 0.0d0
c calculate the electromagnetic fields
c mode numbers 0 < kx < nx/2, 0 < ky < ny/2, and 0 < kz < nz/2
!$OMP PARALLEL
!$OMP DO PRIVATE(j,k,l,k1,l1,dkz,dky,dkx,afdt,zt1,zt2,zt3,zt4,zt5,zt6,  
!$OMP& zt7,zt8,zt9,ws,wp)
!$OMP& REDUCTION(+:sum1,sum2)
      do 50 l = 2, nzh
      l1 = nz2 - l
      dkz = dnz*real(l - 1)
      ws = 0.0d0
      wp = 0.0d0
      do 20 k = 2, nyh
      k1 = ny2 - k
      dky = dny*real(k - 1)
      do 10 j = 2, nxh
      dkx = dnx*real(j - 1)
      afdt = adt*aimag(ffc(j,k,l))
c update magnetic field half time step, ky > 0, kz > 0
      zt1 = cmplx(-aimag(exyz(3,j,k,l)),real(exyz(3,j,k,l)))
      zt2 = cmplx(-aimag(exyz(2,j,k,l)),real(exyz(2,j,k,l)))
      zt3 = cmplx(-aimag(exyz(1,j,k,l)),real(exyz(1,j,k,l)))
      zt4 = bxyz(1,j,k,l) - dth*(dky*zt1 - dkz*zt2)
      zt5 = bxyz(2,j,k,l) - dth*(dkz*zt3 - dkx*zt1)
      zt6 = bxyz(3,j,k,l) - dth*(dkx*zt2 - dky*zt3)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,j,k,l) + cdt*(dky*zt1 - dkz*zt2) - afdt*cu(1,j,k,l)
      zt8 = exyz(2,j,k,l) + cdt*(dkz*zt3 - dkx*zt1) - afdt*cu(2,j,k,l)
      zt9 = exyz(3,j,k,l) + cdt*(dkx*zt2 - dky*zt3) - afdt*cu(3,j,k,l)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt2 = cmplx(-aimag(zt8),real(zt8))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,j,k,l) = zt7
      exyz(2,j,k,l) = zt8
      exyz(3,j,k,l) = zt9
      ws = ws + anorm*(zt7*conjg(zt7) + zt8*conjg(zt8) + zt9*conjg(zt9))
      zt4 = zt4 - dth*(dky*zt1 - dkz*zt2)
      zt5 = zt5 - dth*(dkz*zt3 - dkx*zt1)
      zt6 = zt6 - dth*(dkx*zt2 - dky*zt3)
      bxyz(1,j,k,l) = zt4
      bxyz(2,j,k,l) = zt5
      bxyz(3,j,k,l) = zt6
      wp = wp + anorm*(zt4*conjg(zt4) + zt5*conjg(zt5) + zt6*conjg(zt6))
c update magnetic field half time step, ky < 0, kz > 0
      zt1 = cmplx(-aimag(exyz(3,j,k1,l)),real(exyz(3,j,k1,l)))
      zt2 = cmplx(-aimag(exyz(2,j,k1,l)),real(exyz(2,j,k1,l)))
      zt3 = cmplx(-aimag(exyz(1,j,k1,l)),real(exyz(1,j,k1,l)))
      zt4 = bxyz(1,j,k1,l) + dth*(dky*zt1 + dkz*zt2)
      zt5 = bxyz(2,j,k1,l) - dth*(dkz*zt3 - dkx*zt1)
      zt6 = bxyz(3,j,k1,l) - dth*(dkx*zt2 + dky*zt3)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,j,k1,l) - cdt*(dky*zt1 + dkz*zt2) - afdt*cu(1,j,k1,l)
      zt8 = exyz(2,j,k1,l) + cdt*(dkz*zt3 - dkx*zt1) - afdt*cu(2,j,k1,l)
      zt9 = exyz(3,j,k1,l) + cdt*(dkx*zt2 + dky*zt3) - afdt*cu(3,j,k1,l)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt2 = cmplx(-aimag(zt8),real(zt8))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,j,k1,l) = zt7
      exyz(2,j,k1,l) = zt8
      exyz(3,j,k1,l) = zt9
      ws = ws + anorm*(zt7*conjg(zt7) + zt8*conjg(zt8) + zt9*conjg(zt9))
      zt4 = zt4 + dth*(dky*zt1 + dkz*zt2)
      zt5 = zt5 - dth*(dkz*zt3 - dkx*zt1)
      zt6 = zt6 - dth*(dkx*zt2 + dky*zt3)
      bxyz(1,j,k1,l) = zt4
      bxyz(2,j,k1,l) = zt5
      bxyz(3,j,k1,l) = zt6
      wp = wp + anorm*(zt4*conjg(zt4) + zt5*conjg(zt5) + zt6*conjg(zt6))
c update magnetic field half time step, ky > 0, kz < 0
      zt1 = cmplx(-aimag(exyz(3,j,k,l1)),real(exyz(3,j,k,l1)))
      zt2 = cmplx(-aimag(exyz(2,j,k,l1)),real(exyz(2,j,k,l1)))
      zt3 = cmplx(-aimag(exyz(1,j,k,l1)),real(exyz(1,j,k,l1)))
      zt4 = bxyz(1,j,k,l1) - dth*(dky*zt1 + dkz*zt2)
      zt5 = bxyz(2,j,k,l1) + dth*(dkz*zt3 + dkx*zt1)
      zt6 = bxyz(3,j,k,l1) - dth*(dkx*zt2 - dky*zt3)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,j,k,l1) + cdt*(dky*zt1 + dkz*zt2) - afdt*cu(1,j,k,l1)
      zt8 = exyz(2,j,k,l1) - cdt*(dkz*zt3 + dkx*zt1) - afdt*cu(2,j,k,l1)
      zt9 = exyz(3,j,k,l1) + cdt*(dkx*zt2 - dky*zt3) - afdt*cu(3,j,k,l1)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt2 = cmplx(-aimag(zt8),real(zt8))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,j,k,l1) = zt7
      exyz(2,j,k,l1) = zt8
      exyz(3,j,k,l1) = zt9
      ws = ws + anorm*(zt7*conjg(zt7) + zt8*conjg(zt8) + zt9*conjg(zt9))
      zt4 = zt4 - dth*(dky*zt1 + dkz*zt2)
      zt5 = zt5 + dth*(dkz*zt3 + dkx*zt1)
      zt6 = zt6 - dth*(dkx*zt2 - dky*zt3)
      bxyz(1,j,k,l1) = zt4
      bxyz(2,j,k,l1) = zt5
      bxyz(3,j,k,l1) = zt6
      wp = wp + anorm*(zt4*conjg(zt4) + zt5*conjg(zt5) + zt6*conjg(zt6))
c update magnetic field half time step, ky < 0, kz < 0
      zt1 = cmplx(-aimag(exyz(3,j,k1,l1)),real(exyz(3,j,k1,l1)))
      zt2 = cmplx(-aimag(exyz(2,j,k1,l1)),real(exyz(2,j,k1,l1)))
      zt3 = cmplx(-aimag(exyz(1,j,k1,l1)),real(exyz(1,j,k1,l1)))
      zt4 = bxyz(1,j,k1,l1) + dth*(dky*zt1 - dkz*zt2)
      zt5 = bxyz(2,j,k1,l1) + dth*(dkz*zt3 + dkx*zt1)
      zt6 = bxyz(3,j,k1,l1) - dth*(dkx*zt2 + dky*zt3)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,j,k1,l1) - cdt*(dky*zt1 - dkz*zt2)
     1    - afdt*cu(1,j,k1,l1)
      zt8 = exyz(2,j,k1,l1) - cdt*(dkz*zt3 + dkx*zt1)
     1    - afdt*cu(2,j,k1,l1)
      zt9 = exyz(3,j,k1,l1) + cdt*(dkx*zt2 + dky*zt3)
     1    - afdt*cu(3,j,k1,l1)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt2 = cmplx(-aimag(zt8),real(zt8))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,j,k1,l1) = zt7
      exyz(2,j,k1,l1) = zt8
      exyz(3,j,k1,l1) = zt9
      ws = ws + anorm*(zt7*conjg(zt7) + zt8*conjg(zt8) + zt9*conjg(zt9))
      zt4 = zt4 + dth*(dky*zt1 - dkz*zt2)
      zt5 = zt5 + dth*(dkz*zt3 + dkx*zt1)
      zt6 = zt6 - dth*(dkx*zt2 + dky*zt3)
      bxyz(1,j,k1,l1) = zt4
      bxyz(2,j,k1,l1) = zt5
      bxyz(3,j,k1,l1) = zt6
      wp = wp + anorm*(zt4*conjg(zt4) + zt5*conjg(zt5) + zt6*conjg(zt6))
   10 continue
   20 continue
c mode numbers kx = 0, nx/2
      do 30 k = 2, nyh
      k1 = ny2 - k
      dky = dny*real(k - 1)
      afdt = adt*aimag(ffc(1,k,l))
c update magnetic field half time step, kz > 0
      zt1 = cmplx(-aimag(exyz(3,1,k,l)),real(exyz(3,1,k,l)))
      zt2 = cmplx(-aimag(exyz(2,1,k,l)),real(exyz(2,1,k,l)))
      zt3 = cmplx(-aimag(exyz(1,1,k,l)),real(exyz(1,1,k,l)))
      zt4 = bxyz(1,1,k,l) - dth*(dky*zt1 - dkz*zt2)
      zt5 = bxyz(2,1,k,l) - dth*(dkz*zt3)
      zt6 = bxyz(3,1,k,l) + dth*(dky*zt3)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,1,k,l) + cdt*(dky*zt1 - dkz*zt2) - afdt*cu(1,1,k,l)
      zt8 = exyz(2,1,k,l) + cdt*(dkz*zt3) - afdt*cu(2,1,k,l)
      zt9 = exyz(3,1,k,l) - cdt*(dky*zt3) - afdt*cu(3,1,k,l)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt2 = cmplx(-aimag(zt8),real(zt8))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,1,k,l) = zt7
      exyz(2,1,k,l) = zt8
      exyz(3,1,k,l) = zt9  
      ws = ws + anorm*(zt7*conjg(zt7) + zt8*conjg(zt8) + zt9*conjg(zt9))
      zt4 = zt4 - dth*(dky*zt1 - dkz*zt2)
      zt5 = zt5 - dth*(dkz*zt3)
      zt6 = zt6 + dth*(dky*zt3) 
      bxyz(1,1,k,l) = zt4
      bxyz(2,1,k,l) = zt5
      bxyz(3,1,k,l) = zt6
      wp = wp + anorm*(zt4*conjg(zt4) + zt5*conjg(zt5) + zt6*conjg(zt6))
      bxyz(1,1,k1,l) = zero
      bxyz(2,1,k1,l) = zero
      bxyz(3,1,k1,l) = zero
      exyz(1,1,k1,l) = zero
      exyz(2,1,k1,l) = zero
      exyz(3,1,k1,l) = zero
c update magnetic field half time step, kz < 0
      zt1 = cmplx(-aimag(exyz(3,1,k,l1)),real(exyz(3,1,k,l1)))
      zt2 = cmplx(-aimag(exyz(2,1,k,l1)),real(exyz(2,1,k,l1)))
      zt3 = cmplx(-aimag(exyz(1,1,k,l1)),real(exyz(1,1,k,l1)))
      zt4 = bxyz(1,1,k,l1) - dth*(dky*zt1 + dkz*zt2)
      zt5 = bxyz(2,1,k,l1) + dth*(dkz*zt3)
      zt6 = bxyz(3,1,k,l1) + dth*(dky*zt3)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,1,k,l1) + cdt*(dky*zt1 + dkz*zt2) - afdt*cu(1,1,k,l1)
      zt8 = exyz(2,1,k,l1) - cdt*(dkz*zt3) - afdt*cu(2,1,k,l1)
      zt9 = exyz(3,1,k,l1) - cdt*(dky*zt3) - afdt*cu(3,1,k,l1)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt2 = cmplx(-aimag(zt8),real(zt8))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,1,k,l1) = zt7
      exyz(2,1,k,l1) = zt8
      exyz(3,1,k,l1) = zt9
      ws = ws + anorm*(zt7*conjg(zt7) + zt8*conjg(zt8) + zt9*conjg(zt9))
      zt4 = zt4 - dth*(dky*zt1 + dkz*zt2)
      zt5 = zt5 + dth*(dkz*zt3)
      zt6 = zt6 + dth*(dky*zt3)
      bxyz(1,1,k,l1) = zt4
      bxyz(2,1,k,l1) = zt5
      bxyz(3,1,k,l1) = zt6
      wp = wp + anorm*(zt4*conjg(zt4) + zt5*conjg(zt5) + zt6*conjg(zt6))
      bxyz(1,1,k1,l1) = zero
      bxyz(2,1,k1,l1) = zero
      bxyz(3,1,k1,l1) = zero
      exyz(1,1,k1,l1) = zero
      exyz(2,1,k1,l1) = zero
      exyz(3,1,k1,l1) = zero
   30 continue
c mode numbers ky = 0, ny/2
      k1 = nyh + 1
      do 40 j = 2, nxh
      dkx = dnx*real(j - 1)
      afdt = adt*aimag(ffc(j,1,l))
c update magnetic field half time step, kz > 0
      zt1 = cmplx(-aimag(exyz(3,j,1,l)),real(exyz(3,j,1,l)))
      zt2 = cmplx(-aimag(exyz(2,j,1,l)),real(exyz(2,j,1,l)))
      zt3 = cmplx(-aimag(exyz(1,j,1,l)),real(exyz(1,j,1,l)))
      zt4 = bxyz(1,j,1,l) + dth*(dkz*zt2)
      zt5 = bxyz(2,j,1,l) - dth*(dkz*zt3 - dkx*zt1)
      zt6 = bxyz(3,j,1,l) - dth*(dkx*zt2)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,j,1,l) - cdt*(dkz*zt2) - afdt*cu(1,j,1,l)
      zt8 = exyz(2,j,1,l) + cdt*(dkz*zt3 - dkx*zt1) - afdt*cu(2,j,1,l)
      zt9 = exyz(3,j,1,l) + cdt*(dkx*zt2) - afdt*cu(3,j,1,l)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt2 = cmplx(-aimag(zt8),real(zt8))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,j,1,l) = zt7
      exyz(2,j,1,l) = zt8
      exyz(3,j,1,l) = zt9
      ws = ws + anorm*(zt7*conjg(zt7) + zt8*conjg(zt8) + zt9*conjg(zt9))
      zt4 = zt4 + dth*(dkz*zt2)
      zt5 = zt5 - dth*(dkz*zt3 - dkx*zt1)
      zt6 = zt6 - dth*(dkx*zt2)
      bxyz(1,j,1,l) = zt4
      bxyz(2,j,1,l) = zt5
      bxyz(3,j,1,l) = zt6
      wp = wp + anorm*(zt4*conjg(zt4) + zt5*conjg(zt5) + zt6*conjg(zt6))
      bxyz(1,j,k1,l) = zero
      bxyz(2,j,k1,l) = zero
      bxyz(3,j,k1,l) = zero
      exyz(1,j,k1,l) = zero
      exyz(2,j,k1,l) = zero
      exyz(3,j,k1,l) = zero
c update magnetic field half time step, kz > 0
      zt1 = cmplx(-aimag(exyz(3,j,1,l1)),real(exyz(3,j,1,l1)))
      zt2 = cmplx(-aimag(exyz(2,j,1,l1)),real(exyz(2,j,1,l1)))
      zt3 = cmplx(-aimag(exyz(1,j,1,l1)),real(exyz(1,j,1,l1)))
      zt4 = bxyz(1,j,1,l1) - dth*(dkz*zt2)
      zt5 = bxyz(2,j,1,l1) + dth*(dkz*zt3 + dkx*zt1)
      zt6 = bxyz(3,j,1,l1) - dth*(dkx*zt2)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,j,1,l1) + cdt*(dkz*zt2) - afdt*cu(1,j,1,l1)
      zt8 = exyz(2,j,1,l1) - cdt*(dkz*zt3 + dkx*zt1) - afdt*cu(2,j,1,l1)
      zt9 = exyz(3,j,1,l1) + cdt*(dkx*zt2) - afdt*cu(3,j,1,l1)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt2 = cmplx(-aimag(zt8),real(zt8))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,j,1,l1) = zt7
      exyz(2,j,1,l1) = zt8
      exyz(3,j,1,l1) = zt9
      ws = ws + anorm*(zt7*conjg(zt7) + zt8*conjg(zt8) + zt9*conjg(zt9))
      zt4 = zt4 - dth*(dkz*zt2)
      zt5 = zt5 + dth*(dkz*zt3 + dkx*zt1)
      zt6 = zt6 - dth*(dkx*zt2)
      bxyz(1,j,1,l1) = zt4
      bxyz(2,j,1,l1) = zt5
      bxyz(3,j,1,l1) = zt6
      wp = wp + anorm*(zt4*conjg(zt4) + zt5*conjg(zt5) + zt6*conjg(zt6))
      bxyz(1,j,k1,l1) = zero
      bxyz(2,j,k1,l1) = zero
      bxyz(3,j,k1,l1) = zero
      exyz(1,j,k1,l1) = zero
      exyz(2,j,k1,l1) = zero
      exyz(3,j,k1,l1) = zero
   40 continue
c mode numbers kx = 0, nx/2
      afdt = adt*aimag(ffc(1,1,l))
c update magnetic field half time step
      zt2 = cmplx(-aimag(exyz(2,1,1,l)),real(exyz(2,1,1,l)))
      zt3 = cmplx(-aimag(exyz(1,1,1,l)),real(exyz(1,1,1,l)))
      zt4 = bxyz(1,1,1,l) + dth*(dkz*zt2)
      zt5 = bxyz(2,1,1,l) - dth*(dkz*zt3)
c update electric field whole time step
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,1,1,l) - cdt*(dkz*zt2) - afdt*cu(1,1,1,l)
      zt8 = exyz(2,1,1,l) + cdt*(dkz*zt3) - afdt*cu(2,1,1,l)
c update magnetic field half time step and store electric field
      zt2 = cmplx(-aimag(zt8),real(zt8))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,1,1,l) = zt7
      exyz(2,1,1,l) = zt8
      exyz(3,1,1,l) = zero
      ws = ws + anorm*(zt7*conjg(zt7) + zt8*conjg(zt8))
      zt4 = zt4 + dth*(dkz*zt2)
      zt5 = zt5 - dth*(dkz*zt3)
      bxyz(1,1,1,l) = zt4
      bxyz(2,1,1,l) = zt5
      bxyz(3,1,1,l) = zero
      wp = wp + anorm*(zt4*conjg(zt4) + zt5*conjg(zt5))
      bxyz(1,1,k1,l) = zero
      bxyz(2,1,k1,l) = zero
      bxyz(3,1,k1,l) = zero
      exyz(1,1,k1,l) = zero
      exyz(2,1,k1,l) = zero
      exyz(3,1,k1,l) = zero
      bxyz(1,1,1,l1) = zero
      bxyz(2,1,1,l1) = zero
      bxyz(3,1,1,l1) = zero
      exyz(1,1,1,l1) = zero
      exyz(2,1,1,l1) = zero
      exyz(3,1,1,l1) = zero
      bxyz(1,1,k1,l1) = zero
      bxyz(2,1,k1,l1) = zero
      bxyz(3,1,k1,l1) = zero
      exyz(1,1,k1,l1) = zero
      exyz(2,1,k1,l1) = zero
      exyz(3,1,k1,l1) = zero
      sum1 = sum1 + ws
      sum2 = sum2 + wp
   50 continue
!$OMP END DO NOWAIT
!$OMP END PARALLEL
      l1 = nzh + 1
      sum3 = 0.0d0
      sum4 = 0.0d0
c mode numbers kz = 0, nz/2
!$OMP PARALLEL DO PRIVATE(j,k,k1,dky,dkx,afdt,zt1,zt2,zt3,zt4,zt5,zt6,  
!$OMP& zt7,zt8,zt9,ws,wp)
!$OMP& REDUCTION(+:sum3,sum4)
      do 70 k = 2, nyh
      k1 = ny2 - k
      dky = dny*real(k - 1)
      ws = 0.0d0
      wp = 0.0d0
      do 60 j = 2, nxh
      dkx = dnx*real(j - 1)
      afdt = adt*aimag(ffc(j,k,1))
c update magnetic field half time step, ky > 0
      zt1 = cmplx(-aimag(exyz(3,j,k,1)),real(exyz(3,j,k,1)))
      zt2 = cmplx(-aimag(exyz(2,j,k,1)),real(exyz(2,j,k,1)))
      zt3 = cmplx(-aimag(exyz(1,j,k,1)),real(exyz(1,j,k,1)))
      zt4 = bxyz(1,j,k,1) - dth*(dky*zt1)
      zt5 = bxyz(2,j,k,1) + dth*(dkx*zt1)
      zt6 = bxyz(3,j,k,1) - dth*(dkx*zt2 - dky*zt3)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,j,k,1) + cdt*(dky*zt1) - afdt*cu(1,j,k,1)
      zt8 = exyz(2,j,k,1) - cdt*(dkx*zt1) - afdt*cu(2,j,k,1)
      zt9 = exyz(3,j,k,1) + cdt*(dkx*zt2 - dky*zt3) - afdt*cu(3,j,k,1)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt2 = cmplx(-aimag(zt8),real(zt8))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,j,k,1) = zt7
      exyz(2,j,k,1) = zt8
      exyz(3,j,k,1) = zt9
      ws = ws + anorm*(zt7*conjg(zt7) + zt8*conjg(zt8) + zt9*conjg(zt9))
      zt4 = zt4 - dth*(dky*zt1)
      zt5 = zt5 + dth*(dkx*zt1)
      zt6 = zt6 - dth*(dkx*zt2 - dky*zt3)
      bxyz(1,j,k,1) = zt4
      bxyz(2,j,k,1) = zt5
      bxyz(3,j,k,1) = zt6
      wp = wp + anorm*(zt4*conjg(zt4) + zt5*conjg(zt5) + zt6*conjg(zt6))
c update magnetic field half time step, ky < 0
      zt1 = cmplx(-aimag(exyz(3,j,k1,1)),real(exyz(3,j,k1,1)))
      zt2 = cmplx(-aimag(exyz(2,j,k1,1)),real(exyz(2,j,k1,1)))
      zt3 = cmplx(-aimag(exyz(1,j,k1,1)),real(exyz(1,j,k1,1)))
      zt4 = bxyz(1,j,k1,1) + dth*(dky*zt1)
      zt5 = bxyz(2,j,k1,1) + dth*(dkx*zt1)
      zt6 = bxyz(3,j,k1,1) - dth*(dkx*zt2 + dky*zt3)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,j,k1,1) - cdt*(dky*zt1) - afdt*cu(1,j,k1,1)
      zt8 = exyz(2,j,k1,1) - cdt*(dkx*zt1) - afdt*cu(2,j,k1,1)
      zt9 = exyz(3,j,k1,1) + cdt*(dkx*zt2 + dky*zt3) - afdt*cu(3,j,k1,1)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt2 = cmplx(-aimag(zt8),real(zt8))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,j,k1,1) = zt7
      exyz(2,j,k1,1) = zt8
      exyz(3,j,k1,1) = zt9
      ws = ws + anorm*(zt7*conjg(zt7) + zt8*conjg(zt8) + zt9*conjg(zt9))
      zt4 = zt4 + dth*(dky*zt1)
      zt5 = zt5 + dth*(dkx*zt1)
      zt6 = zt6 - dth*(dkx*zt2 + dky*zt3)
      bxyz(1,j,k1,1) = zt4
      bxyz(2,j,k1,1) = zt5
      bxyz(3,j,k1,1) = zt6
      wp = wp + anorm*(zt4*conjg(zt4) + zt5*conjg(zt5) + zt6*conjg(zt6))
      bxyz(1,j,k,l1) = zero
      bxyz(2,j,k,l1) = zero
      bxyz(3,j,k,l1) = zero
      exyz(1,j,k,l1) = zero
      exyz(2,j,k,l1) = zero
      exyz(3,j,k,l1) = zero
      bxyz(1,j,k1,l1) = zero
      bxyz(2,j,k1,l1) = zero
      bxyz(3,j,k1,l1) = zero
      exyz(1,j,k1,l1) = zero
      exyz(2,j,k1,l1) = zero
      exyz(3,j,k1,l1) = zero
   60 continue
c mode numbers kx = 0, nx/2
      dky = dny*real(k - 1)
      afdt = adt*aimag(ffc(1,k,1))
c update magnetic field half time step
      zt1 = cmplx(-aimag(exyz(3,1,k,1)),real(exyz(3,1,k,1)))
      zt3 = cmplx(-aimag(exyz(1,1,k,1)),real(exyz(1,1,k,1)))
      zt4 = bxyz(1,1,k,1) - dth*(dky*zt1)
      zt6 = bxyz(3,1,k,1) + dth*(dky*zt3)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt3 = cmplx(-aimag(zt4),real(zt4))
      zt7 = exyz(1,1,k,1) + cdt*(dky*zt1) - afdt*cu(1,1,k,1)
      zt9 = exyz(3,1,k,1) - cdt*(dky*zt3) - afdt*cu(3,1,k,1)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt3 = cmplx(-aimag(zt7),real(zt7))
      exyz(1,1,k,1) = zt7
      exyz(2,1,k,1) = zero
      exyz(3,1,k,1) = zt9
      ws = ws + anorm*(zt7*conjg(zt7) + zt9*conjg(zt9))
      zt4 = zt4 - dth*(dky*zt1)
      zt6 = zt6 + dth*(dky*zt3)
      bxyz(1,1,k,1) = zt4
      bxyz(2,1,k,1) = zero
      bxyz(3,1,k,1) = zt6
      wp = wp + anorm*(zt4*conjg(zt4) + zt6*conjg(zt6))
      bxyz(1,1,k1,1) = zero
      bxyz(2,1,k1,1) = zero
      bxyz(3,1,k1,1) = zero
      exyz(1,1,k1,1) = zero
      exyz(2,1,k1,1) = zero
      exyz(3,1,k1,1) = zero
      bxyz(1,1,k,l1) = zero
      bxyz(2,1,k,l1) = zero
      bxyz(3,1,k,l1) = zero
      exyz(1,1,k,l1) = zero
      exyz(2,1,k,l1) = zero
      exyz(3,1,k,l1) = zero
      bxyz(1,1,k1,l1) = zero
      bxyz(2,1,k1,l1) = zero
      bxyz(3,1,k1,l1) = zero
      exyz(1,1,k1,l1) = zero
      exyz(2,1,k1,l1) = zero
      exyz(3,1,k1,l1) = zero
      sum3 = sum3 + ws
      sum4 = sum4 + wp
   70 continue
!$OMP END PARALLEL DO
      ws = 0.0d0
      wp = 0.0d0
c mode numbers ky = 0, ny/2
      k1 = nyh + 1
      do 80 j = 2, nxh
      dkx = dnx*real(j - 1)
      afdt = adt*aimag(ffc(j,1,1))
c update magnetic field half time step
      zt1 = cmplx(-aimag(exyz(3,j,1,1)),real(exyz(3,j,1,1)))
      zt2 = cmplx(-aimag(exyz(2,j,1,1)),real(exyz(2,j,1,1)))
      zt5 = bxyz(2,j,1,1) + dth*(dkx*zt1)
      zt6 = bxyz(3,j,1,1) - dth*(dkx*zt2)
c update electric field whole time step
      zt1 = cmplx(-aimag(zt6),real(zt6))
      zt2 = cmplx(-aimag(zt5),real(zt5))
      zt8 = exyz(2,j,1,1) - cdt*(dkx*zt1) - afdt*cu(2,j,1,1)
      zt9 = exyz(3,j,1,1) + cdt*(dkx*zt2) - afdt*cu(3,j,1,1)
c update magnetic field half time step and store electric field
      zt1 = cmplx(-aimag(zt9),real(zt9))
      zt2 = cmplx(-aimag(zt8),real(zt8))
      exyz(1,j,1,1) = zero
      exyz(2,j,1,1) = zt8
      exyz(3,j,1,1) = zt9
      ws = ws + anorm*(zt8*conjg(zt8) + zt9*conjg(zt9))
      zt5 = zt5 + dth*(dkx*zt1)
      zt6 = zt6 - dth*(dkx*zt2)
      bxyz(1,j,1,1) = zero
      bxyz(2,j,1,1) = zt5
      bxyz(3,j,1,1) = zt6
      wp = wp + anorm*(zt5*conjg(zt5) + zt6*conjg(zt6))
      bxyz(1,j,k1,1) = zero
      bxyz(2,j,k1,1) = zero
      bxyz(3,j,k1,1) = zero
      exyz(1,j,k1,1) = zero
      exyz(2,j,k1,1) = zero
      exyz(3,j,k1,1) = zero
      bxyz(1,j,1,l1) = zero
      bxyz(2,j,1,l1) = zero
      bxyz(3,j,1,l1) = zero
      exyz(1,j,1,l1) = zero
      exyz(2,j,1,l1) = zero
      exyz(3,j,1,l1) = zero
      bxyz(1,j,k1,l1) = zero
      bxyz(2,j,k1,l1) = zero
      bxyz(3,j,k1,l1) = zero
      exyz(1,j,k1,l1) = zero
      exyz(2,j,k1,l1) = zero
      exyz(3,j,k1,l1) = zero
   80 continue
      bxyz(1,1,1,1) = zero
      bxyz(2,1,1,1) = zero
      bxyz(3,1,1,1) = zero
      exyz(1,1,1,1) = zero
      exyz(2,1,1,1) = zero
      exyz(3,1,1,1) = zero
      bxyz(1,1,k1,1) = zero
      bxyz(2,1,k1,1) = zero
      bxyz(3,1,k1,1) = zero
      exyz(1,1,k1,1) = zero
      exyz(2,1,k1,1) = zero
      exyz(3,1,k1,1) = zero
      bxyz(1,1,1,l1) = zero
      bxyz(2,1,1,l1) = zero
      bxyz(3,1,1,l1) = zero
      exyz(1,1,1,l1) = zero
      exyz(2,1,1,l1) = zero
      exyz(3,1,1,l1) = zero
      bxyz(1,1,k1,l1) = zero
      bxyz(2,1,k1,l1) = zero
      bxyz(3,1,k1,l1) = zero
      exyz(1,1,k1,l1) = zero
      exyz(2,1,k1,l1) = zero
      exyz(3,1,k1,l1) = zero
      wf = real(nx)*real(ny)*real(nz)*(sum1 + sum3 + ws)
      wm = real(nx)*real(ny)*real(nz)*c2*(sum2 + sum4 + wp)
      return
      end
c-----------------------------------------------------------------------
      subroutine MEMFIELD3(fxyz,exyz,ffc,isign,nx,ny,nz,nxvh,nyv,nzv,   
     1nxhd,nyhd,nzhd)
c this subroutine either adds complex vector fields if isign > 0
c or copies complex vector fields if isign < 0
c includes additional smoothing
      implicit none
      integer isign, nx, ny, nz, nxvh, nyv, nzv, nxhd, nyhd, nzhd
      complex fxyz, exyz, ffc
      dimension fxyz(3,nxvh,nyv,nzv), exyz(3,nxvh,nyv,nzv)
      dimension ffc(nxhd,nyhd,nzhd)
c local data
      integer i, j, k, l, nxh, nyh, nzh, ny2, nz2, k1, l1
      real at1
      nxh = nx/2
      nyh = max(1,ny/2)
      nzh = max(1,nz/2)
      ny2 = ny + 2
      nz2 = nz + 2
c add the fields
      if (isign.gt.0) then
!$OMP PARALLEL
!$OMP DO PRIVATE(i,j,k,l,k1,l1,at1)
         do 60 l = 2, nzh
         l1 = nz2 - l
         do 30 k = 2, nyh
         k1 = ny2 - k
         do 20 j = 1, nxh
         at1 = aimag(ffc(j,k,l))
         do 10 i = 1, 3
         fxyz(i,j,k,l) = fxyz(i,j,k,l) + exyz(i,j,k,l)*at1
         fxyz(i,j,k1,l) = fxyz(i,j,k1,l) + exyz(i,j,k1,l)*at1
         fxyz(i,j,k,l1) = fxyz(i,j,k,l1) + exyz(i,j,k,l1)*at1
         fxyz(i,j,k1,l1) = fxyz(i,j,k1,l1) + exyz(i,j,k1,l1)*at1
   10    continue
   20    continue
   30    continue
         k1 = nyh + 1
         do 50 j = 1, nxh
         at1 = aimag(ffc(j,1,l))
         do 40 i = 1, 3
         fxyz(i,j,1,l) = fxyz(i,j,1,l) + exyz(i,j,1,l)*at1
         fxyz(i,j,k1,l) = fxyz(i,j,k1,l) + exyz(i,j,k1,l)*at1
         fxyz(i,j,1,l1) = fxyz(i,j,1,l1) + exyz(i,j,1,l1)*at1
         fxyz(i,j,k1,l1) = fxyz(i,j,k1,l1) + exyz(i,j,k1,l1)*at1
   40    continue
   50    continue
   60    continue
!$OMP END DO NOWAIT
!$OMP END PARALLEL
         l1 = nzh + 1
!$OMP PARALLEL DO PRIVATE(i,j,k,k1,at1)
         do 90 k = 2, nyh
         k1 = ny2 - k
         do 80 j = 1, nxh
         at1 = aimag(ffc(j,k,1))
         do 70 i = 1, 3
         fxyz(i,j,k,1) = fxyz(i,j,k,1) + exyz(i,j,k,1)*at1
         fxyz(i,j,k1,1) = fxyz(i,j,k1,1) + exyz(i,j,k1,1)*at1
         fxyz(i,j,k,l1) = fxyz(i,j,k,l1) + exyz(i,j,k,l1)*at1
         fxyz(i,j,k1,l1) = fxyz(i,j,k1,l1) + exyz(i,j,k1,l1)*at1
   70    continue
   80    continue
   90    continue
!$OMP END PARALLEL DO
         k1 = nyh + 1
         do 110 j = 1, nxh
         at1 = aimag(ffc(j,1,1))
         do 100 i = 1, 3
         fxyz(i,j,1,1) = fxyz(i,j,1,1) + exyz(i,j,1,1)*at1
         fxyz(i,j,k1,1) = fxyz(i,j,k1,1) + exyz(i,j,k1,1)*at1
         fxyz(i,j,1,l1) = fxyz(i,j,1,l1) + exyz(i,j,1,l1)*at1
         fxyz(i,j,k1,l1) = fxyz(i,j,k1,l1) + exyz(i,j,k1,l1)*at1
  100    continue
  110    continue
c copy the fields
      else if (isign.lt.0) then
!$OMP PARALLEL
!$OMP DO PRIVATE(i,j,k,l,k1,l1,at1)
         do 170 l = 2, nzh
         l1 = nz2 - l
         do 140 k = 2, nyh
         k1 = ny2 - k
         do 130 j = 1, nxh
         at1 = aimag(ffc(j,k,l))
         do 120 i = 1, 3
         fxyz(i,j,k,l) = exyz(i,j,k,l)*at1
         fxyz(i,j,k1,l) = exyz(i,j,k1,l)*at1
         fxyz(i,j,k,l1) = exyz(i,j,k,l1)*at1
         fxyz(i,j,k1,l1) = exyz(i,j,k1,l1)*at1
  120    continue
  130    continue
  140    continue
         k1 = nyh + 1
         do 160 j = 1, nxh
         at1 = aimag(ffc(j,1,l))
         do 150 i = 1, 3
         fxyz(i,j,1,l) = exyz(i,j,1,l)*at1
         fxyz(i,j,k1,l) = exyz(i,j,k1,l)*at1
         fxyz(i,j,1,l1) = exyz(i,j,1,l1)*at1
         fxyz(i,j,k1,l1) = exyz(i,j,k1,l1)*at1
  150    continue
  160    continue
  170    continue
!$OMP END DO NOWAIT
!$OMP END PARALLEL
         l1 = nzh + 1
!$OMP PARALLEL DO PRIVATE(i,j,k,k1,at1)
         do 200 k = 2, nyh
         k1 = ny2 - k
         do 190 j = 1, nxh
         at1 = aimag(ffc(j,k,1))
         do 180 i = 1, 3
         fxyz(i,j,k,1) = exyz(i,j,k,1)*at1
         fxyz(i,j,k1,1) = exyz(i,j,k1,1)*at1
         fxyz(i,j,k,l1) = exyz(i,j,k,l1)*at1
         fxyz(i,j,k1,l1) = exyz(i,j,k1,l1)*at1
  180    continue
  190    continue
  200    continue
!$OMP END PARALLEL DO
         k1 = nyh + 1
         do 220 j = 1, nxh
         at1 = aimag(ffc(j,1,1))
         do 210 i = 1, 3
         fxyz(i,j,1,1) = exyz(i,j,1,1)*at1
         fxyz(i,j,k1,1) = exyz(i,j,k1,1)*at1
         fxyz(i,j,1,l1) = exyz(i,j,1,l1)*at1
         fxyz(i,j,k1,l1) = exyz(i,j,k1,l1)*at1
  210    continue
  220    continue
      endif
      return
      end
c-----------------------------------------------------------------------
      subroutine WFFT3RINIT(mixup,sct,indx,indy,indz,nxhyzd,nxyzhd)
c this subroutine calculates tables needed by a three dimensional
c real to complex fast fourier transform and its inverse.
c input: indx, indy, indz, nxhyzd, nxyzhd
c output: mixup, sct
c mixup = array of bit reversed addresses
c sct = sine/cosine table
c indx/indy/indz = exponent which determines length in x/y/z direction,
c where nx=2**indx, ny=2**indy, nz=2**indz
c nxhyzd = maximum of (nx/2,ny,nz)
c nxyzhd = one half of maximum of (nx,ny,nz)
c written by viktor k. decyk, ucla
      implicit none
      integer indx, indy, indz, nxhyzd, nxyzhd
      integer mixup
      complex sct
      dimension mixup(nxhyzd), sct(nxyzhd)
c local data
      integer indx1, ndx1yz, nx, ny, nz, nxyz, nxhyz, nxyzh
      integer j, k, lb, ll, jb, it
      real dnxyz, arg
      indx1 = indx - 1
      ndx1yz = max0(indx1,indy,indz)
      nx = 2**indx
      ny = 2**indy
      nz = 2**indz
      nxyz = max0(nx,ny,nz)
      nxhyz = 2**ndx1yz
c bit-reverse index table: mixup(j) = 1 + reversed bits of (j - 1)
      do 20 j = 1, nxhyz
      lb = j - 1
      ll = 0
      do 10 k = 1, ndx1yz
      jb = lb/2
      it = lb - 2*jb
      lb = jb
      ll = 2*ll + it
   10 continue
      mixup(j) = ll + 1
   20 continue
c sine/cosine table for the angles 2*n*pi/nxyz
      nxyzh = nxyz/2
      dnxyz = 6.28318530717959/real(nxyz)
      do 30 j = 1, nxyzh
      arg = dnxyz*real(j - 1)
      sct(j) = cmplx(cos(arg),-sin(arg))
   30 continue
      return
      end
c-----------------------------------------------------------------------
      subroutine WFFT3RMX(f,isign,mixup,sct,indx,indy,indz,nxhd,nyd,nzd,
     1nxhyzd,nxyzhd)
c wrapper function for real to complex fft, with packed data
c parallelized with OpenMP
      implicit none
      complex f, sct
      integer mixup
      integer isign, indx, indy, indz, nxhd, nyd, nzd, nxhyzd, nxyzhd
      dimension f(nxhd,nyd,nzd), mixup(nxhyzd), sct(nxyzhd)
c local data
      integer ny, nz, nyi, nzi
      data nyi, nzi /1,1/
c calculate range of indices
      ny = 2**indy
      nz = 2**indz
c inverse fourier transform
      if (isign.lt.0) then
c perform xy fft
         call FFT3RMXY(f,isign,mixup,sct,indx,indy,indz,nzi,nz,nxhd,nyd,
     1nzd,nxhyzd,nxyzhd)
c perform z fft
         call FFT3RMXZ(f,isign,mixup,sct,indx,indy,indz,nyi,ny,nxhd,nyd,
     1nzd,nxhyzd,nxyzhd)
c forward fourier transform
      else if (isign.gt.0) then
c perform z fft
         call FFT3RMXZ(f,isign,mixup,sct,indx,indy,indz,nyi,ny,nxhd,nyd,
     1nzd,nxhyzd,nxyzhd)
c perform xy fft
         call FFT3RMXY(f,isign,mixup,sct,indx,indy,indz,nzi,nz,nxhd,nyd,
     1nzd,nxhyzd,nxyzhd)
      endif
      return
      end
c-----------------------------------------------------------------------
      subroutine WFFT3RM3(f,isign,mixup,sct,indx,indy,indz,nxhd,nyd,nzd,
     1nxhyzd,nxyzhd)
c wrapper function for 3 2d real to complex ffts, with packed data
c parallelized with OpenMP
      implicit none
      complex f, sct
      integer mixup
      integer isign, indx, indy, indz, nxhd, nyd, nzd, nxhyzd, nxyzhd
      dimension f(3,nxhd,nyd,nzd), mixup(nxhyzd), sct(nxyzhd)
c local data
      integer ny, nz, nyi, nzi
      data nyi, nzi /1,1/
c calculate range of indices
      ny = 2**indy
      nz = 2**indz
c inverse fourier transform
      if (isign.lt.0) then
c perform xy fft
         call FFT3RM3XY(f,isign,mixup,sct,indx,indy,indz,nzi,nz,nxhd,nyd
     1,nzd,nxhyzd,nxyzhd)
c perform z fft
         call FFT3RM3Z(f,isign,mixup,sct,indx,indy,indz,nyi,ny,nxhd,nyd,
     1nzd,nxhyzd,nxyzhd)
c forward fourier transform
      else if (isign.gt.0) then
c perform z fft
         call FFT3RM3Z(f,isign,mixup,sct,indx,indy,indz,nyi,ny,nxhd,nyd,
     1nzd,nxhyzd,nxyzhd)
c perform xy fft
         call FFT3RM3XY(f,isign,mixup,sct,indx,indy,indz,nzi,nz,nxhd,nyd
     1,nzd,nxhyzd,nxyzhd)
      endif
      return
      end
c-----------------------------------------------------------------------
      subroutine FFT3RMXY(f,isign,mixup,sct,indx,indy,indz,nzi,nzp,nxhd,
     1nyd,nzd,nxhyzd,nxyzhd)
c this subroutine performs the x-y part of a three dimensional real to
c complex fast fourier transform and its inverse, for a subset of z,
c using complex arithmetic, with OpenMP
c for isign = (-1,1), input: all, output: f
c for isign = -1, approximate flop count: N*(5*log2(N) + 19/2)
c for isign = 1,  approximate flop count: N*(5*log2(N) + 15/2)
c where N = (nx/2)*ny*nz
c indx/indy/indz = exponent which determines length in x/y/z direction,
c where nx=2**indx, ny=2**indy, nz=2**indz
c if isign = -1, an inverse fourier transform in x and y is performed
c f(n,m,i) = (1/nx*ny*nz)*sum(f(j,k,i)*exp(-sqrt(-1)*2pi*n*j/nx)*
c       exp(-sqrt(-1)*2pi*m*k/ny))
c if isign = 1, a forward fourier transform in x and y is performed
c f(j,k,l) = sum(f(n,m,l)*exp(sqrt(-1)*2pi*n*j/nx)*
c       exp(sqrt(-1)*2pi*m*k/ny))
c mixup = array of bit reversed addresses
c sct = sine/cosine table
c nzi = initial z index used
c nzp = number of z indices used
c nxhd = first dimension of f
c nyd,nzd = second and third dimensions of f
c nxhyzd = maximum of (nx/2,ny,nz)
c nxyzhd = maximum of (nx,ny,nz)/2
c fourier coefficients are stored as follows:
c f(j,k,l) = real, imaginary part of mode j-1,k-1,l-1
c where 1 <= j <= nx/2, 1 <= k <= ny, 1 <= l <= nz, except for
c f(1,k,l) = real, imaginary part of mode nx/2,k-1,l-1,
c where ny/2+2 <= k <= ny and 1 <= l <= nz, and
c f(1,1,l) = real, imaginary part of mode nx/2,0,l-1,
c f(1,ny/2+1,l) = real, imaginary part mode nx/2,ny/2,l-1,
c where nz/2+2 <= l <= nz, and
c imag(f(1,1,1)) = real part of mode nx/2,0,0
c imag(f(1,ny/2+1,1)) = real part of mode nx/2,ny/2,0
c imag(f(1,1,nz/2+1)) = real part of mode nx/2,0,nz/2
c imag(f(1,ny/2+1,nz/2+1)) = real part of mode nx/2,ny/2,nz/2
c using jpl storage convention, as described in:
c E. Huang, P. C. Liewer, V. K. Decyk, and R. D. Ferraro, "Concurrent
c Three-Dimensional Fast Fourier Transform Algorithms for Coarse-Grained
c Distributed Memory Parallel Computers," Caltech CRPC Report 217-50,
c December 1993.
c written by viktor k. decyk, ucla
      implicit none
      integer isign, indx, indy, indz, nzi, nzp, nxhd, nyd, nzd
      integer nxhyzd, nxyzhd
      complex f, sct
      integer mixup
      dimension f(nxhd,nyd,nzd), mixup(nxhyzd), sct(nxyzhd)
c local data
      integer indx1, ndx1yz, nx, nxh, nxhh, nxh2, ny, nyh, ny2
      integer nz, nzh, nz2, nxyz, nxhyz, nzt, nrx, nry, nrxb, nryb
      integer i, j, k, l, n, j1, j2, k1, k2, ns, ns2, km, kmr
      real ani
      complex t1, t2, t3
      if (isign.eq.0) return
      indx1 = indx - 1
      ndx1yz = max0(indx1,indy,indz)
      nx = 2**indx
      nxh = nx/2
      nxhh = nx/4
      nxh2 = nxh + 2
      ny = 2**indy
      nyh = ny/2
      ny2 = ny + 2
      nz = 2**indz
      nzh = nz/2
      nz2 = nz + 2
      nxyz = max0(nx,ny,nz)
      nxhyz = 2**ndx1yz
      nzt = nzi + nzp - 1
      if (isign.gt.0) go to 180
c inverse fourier transform
      nrxb = nxhyz/nxh
      nrx = nxyz/nxh
      nryb = nxhyz/ny
      nry = nxyz/ny
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,n,ns,ns2,km,kmr,k1,k2,j1,j2,ani,t1,t2,t3)
      do 170 n = nzi, nzt
c bit-reverse array elements in x
      do 20 j = 1, nxh
      j1 = (mixup(j) - 1)/nrxb + 1
      if (j.lt.j1) then
         do 10 i = 1, ny
         t1 = f(j1,i,n)
         f(j1,i,n) = f(j,i,n)
         f(j,i,n) = t1
   10    continue
      endif
   20 continue
c first transform in x
      do 60 l = 1, indx1
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nxhh/ns
      kmr = km*nrx
      do 50 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 40 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = sct(1+kmr*(j-1))
      do 30 i = 1, ny
      t2 = t1*f(j2,i,n)
      f(j2,i,n) = f(j1,i,n) - t2
      f(j1,i,n) = f(j1,i,n) + t2
   30 continue
   40 continue
   50 continue
   60 continue
c unscramble coefficients and normalize
      kmr = nxyz/nx
      ani = 0.5/(real(nx)*real(ny)*real(nz))
      do 80 j = 2, nxhh
      t3 = cmplx(aimag(sct(1+kmr*(j-1))),-real(sct(1+kmr*(j-1))))
      do 70 k = 1, ny
      t2 = conjg(f(nxh2-j,k,n))
      t1 = f(j,k,n) + t2
      t2 = (f(j,k,n) - t2)*t3
      f(j,k,n) = ani*(t1 + t2)
      f(nxh2-j,k,n) = ani*conjg(t1 - t2)
   70 continue
   80 continue
      ani = 2.0*ani
      do 90 k = 1, ny
      f(nxhh+1,k,n) = ani*conjg(f(nxhh+1,k,n))
      f(1,k,n) = ani*cmplx(real(f(1,k,n)) + aimag(f(1,k,n)),
     1                     real(f(1,k,n)) - aimag(f(1,k,n)))
   90 continue
c bit-reverse array elements in y
      do 110 k = 1, ny
      k1 = (mixup(k) - 1)/nryb + 1
      if (k.lt.k1) then
         do 100 i = 1, nxh
         t1 = f(i,k1,n)
         f(i,k1,n) = f(i,k,n)
         f(i,k,n) = t1
  100    continue
      endif
  110 continue
c then transform in y
      do 150 l = 1, indy
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nyh/ns
      kmr = km*nry
      do 140 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 130 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = sct(1+kmr*(j-1))
      do 120 i = 1, nxh
      t2 = t1*f(i,j2,n)
      f(i,j2,n) = f(i,j1,n) - t2
      f(i,j1,n) = f(i,j1,n) + t2
  120 continue
  130 continue
  140 continue
  150 continue
c unscramble modes kx = 0, nx/2
      do 160 k = 2, nyh
      t1 = f(1,ny2-k,n)
      f(1,ny2-k,n) = 0.5*cmplx(aimag(f(1,k,n) + t1),real(f(1,k,n) - t1))
      f(1,k,n) = 0.5*cmplx(real(f(1,k,n) + t1),aimag(f(1,k,n) - t1))
  160 continue
  170 continue
!$OMP END PARALLEL DO
      return
c forward fourier transform
  180 nryb = nxhyz/ny
      nry = nxyz/ny
      nrxb = nxhyz/nxh
      nrx = nxyz/nxh
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,n,ns,ns2,km,kmr,k1,k2,j1,j2,t1,t2,t3)
      do 350 n = nzi, nzt
c scramble modes kx = 0, nx/2
      do 190 k = 2, nyh
      t1 = cmplx(aimag(f(1,ny2-k,n)),real(f(1,ny2-k,n)))
      f(1,ny2-k,n) = conjg(f(1,k,n) - t1)
      f(1,k,n) = f(1,k,n) + t1
  190 continue
c bit-reverse array elements in y
      do 210 k = 1, ny
      k1 = (mixup(k) - 1)/nryb + 1
      if (k.lt.k1) then
         do 200 i = 1, nxh
         t1 = f(i,k1,n)
         f(i,k1,n) = f(i,k,n)
         f(i,k,n) = t1
  200    continue
      endif
  210 continue
c then transform in y
      do 250 l = 1, indy
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nyh/ns
      kmr = km*nry
      do 240 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 230 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = conjg(sct(1+kmr*(j-1)))
      do 220 i = 1, nxh
      t2 = t1*f(i,j2,n)
      f(i,j2,n) = f(i,j1,n) - t2
      f(i,j1,n) = f(i,j1,n) + t2
  220 continue
  230 continue
  240 continue
  250 continue
c scramble coefficients
      kmr = nxyz/nx
      do 270 j = 2, nxhh
      t3 = cmplx(aimag(sct(1+kmr*(j-1))),real(sct(1+kmr*(j-1))))
      do 260 k = 1, ny
      t2 = conjg(f(nxh2-j,k,n))
      t1 = f(j,k,n) + t2
      t2 = (f(j,k,n) - t2)*t3
      f(j,k,n) = t1 + t2
      f(nxh2-j,k,n) = conjg(t1 - t2)
  260 continue
  270 continue
      do 280 k = 1, ny
      f(nxhh+1,k,n) = 2.0*conjg(f(nxhh+1,k,n))
      f(1,k,n) = cmplx(real(f(1,k,n)) + aimag(f(1,k,n)),
     1                 real(f(1,k,n)) - aimag(f(1,k,n)))
  280 continue
c bit-reverse array elements in x
      do 300 j = 1, nxh
      j1 = (mixup(j) - 1)/nrxb + 1
      if (j.lt.j1) then
         do 290 i = 1, ny
         t1 = f(j1,i,n)
         f(j1,i,n) = f(j,i,n)
         f(j,i,n) = t1
  290    continue
      endif
  300 continue
c finally transform in x
      do 340 l = 1, indx1
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nxhh/ns
      kmr = km*nrx
      do 330 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 320 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = conjg(sct(1+kmr*(j-1)))
      do 310 i = 1, ny
      t2 = t1*f(j2,i,n)
      f(j2,i,n) = f(j1,i,n) - t2
      f(j1,i,n) = f(j1,i,n) + t2
  310 continue
  320 continue
  330 continue
  340 continue
  350 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      subroutine FFT3RMXZ(f,isign,mixup,sct,indx,indy,indz,nyi,nyp,nxhd,
     1nyd,nzd,nxhyzd,nxyzhd)
c this subroutine performs the z part of a three dimensional real to
c complex fast fourier transform and its inverse, for a subset of y,
c using complex arithmetic, with OpenMP
c for isign = (-1,1), input: all, output: f
c for isign = -1, approximate flop count: N*(5*log2(N) + 19/2)
c for isign = 1,  approximate flop count: N*(5*log2(N) + 15/2)
c where N = (nx/2)*ny*nz
c indx/indy/indz = exponent which determines length in x/y/z direction,
c where nx=2**indx, ny=2**indy, nz=2**indz
c if isign = -1, an inverse fourier transform in z is performed
c f(j,k,l) = sum(f(j,k,i)*exp(-sqrt(-1)*2pi*l*i/nz))
c if isign = 1, a forward fourier transform in z is performed
c f(n,m,i) = sum(f(n,m,l)*exp(sqrt(-1)*2pi*l*i/nz))
c mixup = array of bit reversed addresses
c sct = sine/cosine table
c nyi = initial y index used
c nyp = number of y indices used
c nxhd = first dimension of f
c nyd,nzd = second and third dimensions of f
c nxhyzd = maximum of (nx/2,ny,nz)
c nxyzhd = maximum of (nx,ny,nz)/2
c fourier coefficients are stored as follows:
c f(j,k,l) = real, imaginary part of mode j-1,k-1,l-1
c where 1 <= j <= nx/2, 1 <= k <= ny, 1 <= l <= nz, except for
c f(1,k,l), = real, imaginary part of mode nx/2,k-1,l-1,
c where ny/2+2 <= k <= ny and 1 <= l <= nz, and
c f(1,1,l) = real, imaginary part of mode nx/2,0,l-1,
c f(1,ny/2+1,l) = real, imaginary part mode nx/2,ny/2,l-1,
c where nz/2+2 <= l <= nz, and
c imag(f(1,1,1)) = real part of mode nx/2,0,0
c imag(f(1,ny/2+1,1)) = real part of mode nx/2,ny/2,0
c imag(f(1,1,nz/2+1)) = real part of mode nx/2,0,nz/2
c imag(f(1,ny/2+1,nz/2+1)) = real part of mode nx/2,ny/2,nz/2
c using jpl storage convention, as described in:
c E. Huang, P. C. Liewer, V. K. Decyk, and R. D. Ferraro, "Concurrent
c Three-Dimensional Fast Fourier Transform Algorithms for Coarse-Grained
c Distributed Memory Parallel Computers," Caltech CRPC Report 217-50,
c December 1993.
c written by viktor k. decyk, ucla
      implicit none
      integer isign, indx, indy, indz, nyi, nyp, nxhd, nyd, nzd
      integer nxhyzd, nxyzhd
      complex f, sct
      integer mixup
      dimension f(nxhd,nyd,nzd), mixup(nxhyzd), sct(nxyzhd)
c local data
      integer indx1, ndx1yz, nx, nxh, nxhh, nxh2, ny, nyh, ny2
      integer nz, nzh, nz2, nxyz, nxhyz, nyt, nrz, nrzb
      integer i, j, k, l, n, j1, j2, k1, k2, l1, ns, ns2, km, kmr
      complex t1, t2
      if (isign.eq.0) return
      indx1 = indx - 1
      ndx1yz = max0(indx1,indy,indz)
      nx = 2**indx
      nxh = nx/2
      nxhh = nx/4
      nxh2 = nxh + 2
      ny = 2**indy
      nyh = ny/2
      ny2 = ny + 2
      nz = 2**indz
      nzh = nz/2
      nz2 = nz + 2
      nxyz = max0(nx,ny,nz)
      nxhyz = 2**ndx1yz
      nyt = nyi + nyp - 1
      if (isign.gt.0) go to 90
c inverse fourier transform
      nrzb = nxhyz/nz
      nrz = nxyz/nz
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,n,ns,ns2,km,kmr,k1,k2,j1,j2,l1,t1,t2)
      do 70 n = nyi, nyt
c bit-reverse array elements in z
      do 20 l = 1, nz
      l1 = (mixup(l) - 1)/nrzb + 1
      if (l.lt.l1) then
         do 10 i = 1, nxh
         t1 = f(i,n,l1)
         f(i,n,l1) = f(i,n,l)
         f(i,n,l) = t1
   10    continue
      endif
   20 continue
c finally transform in z
      do 60 l = 1, indz
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nzh/ns
      kmr = km*nrz
      do 50 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 40 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = sct(1+kmr*(j-1))
      do 30 i = 1, nxh
      t2 = t1*f(i,n,j2)
      f(i,n,j2) = f(i,n,j1) - t2
      f(i,n,j1) = f(i,n,j1) + t2
   30 continue
   40 continue
   50 continue
   60 continue
   70 continue
!$OMP END PARALLEL DO
c unscramble modes kx = 0, nx/2
      do 80 n = 2, nzh
      if (nyi.eq.1) then
         t1 = f(1,1,nz2-n)
         f(1,1,nz2-n) = 0.5*cmplx(aimag(f(1,1,n) + t1),
     1                            real(f(1,1,n) - t1))
         f(1,1,n) = 0.5*cmplx(real(f(1,1,n) + t1),aimag(f(1,1,n) - t1))
      endif
      if ((nyi.le.nyh+1).and.(nyt.ge.nyh+1)) then
         t1 = f(1,nyh+1,nz2-n)
         f(1,nyh+1,nz2-n) = 0.5*cmplx(aimag(f(1,nyh+1,n) + t1),
     1                                real(f(1,nyh+1,n) - t1))
         f(1,nyh+1,n) = 0.5*cmplx(real(f(1,nyh+1,n) + t1),
     1                            aimag(f(1,nyh+1,n) - t1))
      endif
   80 continue
      return
c forward fourier transform
   90 nrzb = nxhyz/nz
      nrz = nxyz/nz
c scramble modes kx = 0, nx/2
      do 100 n = 2, nzh
      if (nyi.eq.1) then
         t1 = cmplx(aimag(f(1,1,nz2-n)),real(f(1,1,nz2-n)))
         f(1,1,nz2-n) = conjg(f(1,1,n) - t1)
         f(1,1,n) = f(1,1,n) + t1
      endif
      if ((nyi.le.nyh+1).and.(nyt.ge.nyh+1)) then
         t1 = cmplx(aimag(f(1,nyh+1,nz2-n)),real(f(1,nyh+1,nz2-n)))
         f(1,nyh+1,nz2-n) = conjg(f(1,nyh+1,n) - t1)
         f(1,nyh+1,n) = f(1,nyh+1,n) + t1
      endif
  100 continue
c bit-reverse array elements in z
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,n,ns,ns2,km,kmr,k1,k2,j1,j2,l1,t1,t2)
      do 170 n = nyi, nyt
      do 120 l = 1, nz
      l1 = (mixup(l) - 1)/nrzb + 1
      if (l.lt.l1) then
         do 110 i = 1, nxh
         t1 = f(i,n,l1)
         f(i,n,l1) = f(i,n,l)
         f(i,n,l) = t1
  110    continue
      endif
  120 continue
c first transform in z
      do 160 l = 1, indz
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nzh/ns
      kmr = km*nrz
      do 150 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 140 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = conjg(sct(1+kmr*(j-1)))
      do 130 i = 1, nxh
      t2 = t1*f(i,n,j2)
      f(i,n,j2) = f(i,n,j1) - t2
      f(i,n,j1) = f(i,n,j1) + t2
  130 continue
  140 continue
  150 continue
  160 continue
  170 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      subroutine FFT3RM3XY(f,isign,mixup,sct,indx,indy,indz,nzi,nzp,nxhd
     1,nyd,nzd,nxhyzd,nxyzhd)
c this subroutine performs the x-y part of 3 three dimensional complex
c to real fast fourier transforms and their inverses, for a subset of z,
c using complex arithmetic, with OpenMP
c for isign = (-1,1), input: all, output: f
c for isign = -1, approximate flop count: N*(5*log2(N) + 19/2)
c for isign = 1,  approximate flop count: N*(5*log2(N) + 15/2)
c where N = (nx/2)*ny*nz
c indx/indy/indz = exponent which determines length in x/y/z direction,
c where nx=2**indx, ny=2**indy, nz=2**indz
c if isign = -1, three inverse fourier transforms in x and y are
c performed
c f(1:3,n,m,i) = (1/nx*ny*nz)*sum(f(1:3,j,k,i)*exp(-sqrt(-1)*2pi*n*j/nx)
c       *exp(-sqrt(-1)*2pi*m*k/ny))
c if isign = 1, three forward fourier transforms in x and y are
c performed
c f(1:3,j,k,l) = sum(f(1:3,n,m,l)*exp(sqrt(-1)*2pi*n*j/nx)*
c       exp(sqrt(-1)*2pi*m*k/ny))
c mixup = array of bit reversed addresses
c sct = sine/cosine table
c nzi = initial z index used
c nzp = number of z indices used
c nxhd = second dimension of f
c nyd,nzd = third and fourth dimensions of f
c nxhyzd = maximum of (nx/2,ny,nz)
c nxyzhd = maximum of (nx,ny,nz)/2
c fourier coefficients are stored as follows:
c f(1:3,j,k,l) = real, imaginary part of mode j-1,k-1,l-1
c where 1 <= j <= nx/2, 1 <= k <= ny, 1 <= l <= nz, except for
c f(1:3,1,k,l) = real, imaginary part of mode nx/2,k-1,l-1,
c where ny/2+2 <= k <= ny and 1 <= l <= nz, and
c f(1:3,1,1,l) = real, imaginary part of mode nx/2,0,l-1,
c f(1:3,1,ny/2+1,l) = real, imaginary part mode nx/2,ny/2,l-1,
c where nz/2+2 <= l <= nz, and
c imag(f(1:3,1,1,1)) = real part of mode nx/2,0,0
c imag(f(1:3,1,ny/2+1,1)) = real part of mode nx/2,ny/2,0
c imag(f(1:3,1,1,nz/2+1)) = real part of mode nx/2,0,nz/2
c imag(f(1:3,1,ny/2+1,nz/2+1)) = real part of mode nx/2,ny/2,nz/2
c using jpl storage convention, as described in:
c E. Huang, P. C. Liewer, V. K. Decyk, and R. D. Ferraro, "Concurrent
c Three-Dimensional Fast Fourier Transform Algorithms for Coarse-Grained
c Distributed Memory Parallel Computers," Caltech CRPC Report 217-50,
c December 1993.
c written by viktor k. decyk, ucla
      implicit none
      integer isign, indx, indy, indz, nzi, nzp, nxhd, nyd, nzd
      integer nxhyzd,nxyzhd
      complex f, sct
      integer mixup
      dimension f(3,nxhd,nyd,nzd), mixup(nxhyzd), sct(nxyzhd)
c local data
      integer indx1, ndx1yz, nx, nxh, nxhh, nxh2, ny, nyh, ny2
      integer nz, nzh, nz2, nxyz, nxhyz, nzt, nrx, nry, nrxb, nryb
      integer i, j, k, l, n, jj, j1, j2, k1, k2, ns, ns2, km, kmr
      real at1, at2, ani
      complex t1, t2, t3, t4
      if (isign.eq.0) return
      indx1 = indx - 1
      ndx1yz = max0(indx1,indy,indz)
      nx = 2**indx
      nxh = nx/2
      nxhh = nx/4
      nxh2 = nxh + 2
      ny = 2**indy
      nyh = ny/2
      ny2 = ny + 2
      nz = 2**indz
      nzh = nz/2
      nz2 = nz + 2
      nxyz = max0(nx,ny,nz)
      nxhyz = 2**ndx1yz
      nzt = nzi + nzp - 1
      if (isign.gt.0) go to 230
c inverse fourier transform
      nrxb = nxhyz/nxh
      nrx = nxyz/nxh
      nryb = nxhyz/ny
      nry = nxyz/ny
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,n,ns,ns2,km,kmr,k1,k2,jj,j1,j2,at1,at2,ani,t1,t2,
!$OMP& t3,t4)
      do 220 n = nzi, nzt
c swap complex components
      do 20 i = 1, ny
      do 10 j = 1, nxh
      at1 = real(f(3,j,i,n))
      f(3,j,i,n) = cmplx(real(f(2,j,i,n)),aimag(f(3,j,i,n)))
      at2 = aimag(f(2,j,i,n))
      f(2,j,i,n) = cmplx(aimag(f(1,j,i,n)),at1)
      f(1,j,i,n) = cmplx(real(f(1,j,i,n)),at2)
   10 continue
   20 continue
c bit-reverse array elements in x
      do 40 j = 1, nxh
      j1 = (mixup(j) - 1)/nrxb + 1
      if (j.lt.j1) then
      do 30 i = 1, ny
         t1 = f(1,j1,i,n)
         t2 = f(2,j1,i,n)
         t3 = f(3,j1,i,n)
         f(1,j1,i,n) = f(1,j,i,n)
         f(2,j1,i,n) = f(2,j,i,n)
         f(3,j1,i,n) = f(3,j,i,n)
         f(1,j,i,n) = t1
         f(2,j,i,n) = t2
         f(3,j,i,n) = t3
   30    continue
      endif
   40 continue
c first transform in x
      do 80 l = 1, indx1
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nxhh/ns
      kmr = km*nrx
      do 70 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 60 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = sct(1+kmr*(j-1))
      do 50 i = 1, ny
      t2 = t1*f(1,j2,i,n)
      t3 = t1*f(2,j2,i,n)
      t4 = t1*f(3,j2,i,n)
      f(1,j2,i,n) = f(1,j1,i,n) - t2
      f(2,j2,i,n) = f(2,j1,i,n) - t3
      f(3,j2,i,n) = f(3,j1,i,n) - t4
      f(1,j1,i,n) = f(1,j1,i,n) + t2
      f(2,j1,i,n) = f(2,j1,i,n) + t3
      f(3,j1,i,n) = f(3,j1,i,n) + t4
   50 continue
   60 continue
   70 continue
   80 continue
c unscramble coefficients and normalize
      kmr = nxyz/nx
      ani = 0.5/(real(nx)*real(ny)*real(nz))
      do 110 j = 2, nxhh
      t3 = cmplx(aimag(sct(1+kmr*(j-1))),-real(sct(1+kmr*(j-1))))
      do 100 k = 1, ny
      do 90 jj = 1, 3
      t2 = conjg(f(jj,nxh2-j,k,n))
      t1 = f(jj,j,k,n) + t2
      t2 = (f(jj,j,k,n) - t2)*t3
      f(jj,j,k,n) = ani*(t1 + t2)
      f(jj,nxh2-j,k,n) = ani*conjg(t1 - t2)
   90 continue
  100 continue
  110 continue
      ani = 2.0*ani
      do 130 k = 1, ny
      do 120 jj = 1, 3
      f(jj,nxhh+1,k,n) = ani*conjg(f(jj,nxhh+1,k,n))
      f(jj,1,k,n) = ani*cmplx(real(f(jj,1,k,n)) + aimag(f(jj,1,k,n)),
     1                        real(f(jj,1,k,n)) - aimag(f(jj,1,k,n)))
  120 continue
  130 continue
c bit-reverse array elements in y
      do 150 k = 1, ny
      k1 = (mixup(k) - 1)/nryb + 1
      if (k.lt.k1) then
         do 140 i = 1, nxh
         t1 = f(1,i,k1,n)
         t2 = f(2,i,k1,n)
         t3 = f(3,i,k1,n)
         f(1,i,k1,n) = f(1,i,k,n)
         f(2,i,k1,n) = f(2,i,k,n)
         f(3,i,k1,n) = f(3,i,k,n)
         f(1,i,k,n) = t1
         f(2,i,k,n) = t2
         f(3,i,k,n) = t3
  140    continue
      endif
  150 continue
c then transform in y
      do 190 l = 1, indy
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nyh/ns
      kmr = km*nry
      do 180 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 170 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = sct(1+kmr*(j-1))
      do 160 i = 1, nxh
      t2 = t1*f(1,i,j2,n)
      t3 = t1*f(2,i,j2,n)
      t4 = t1*f(3,i,j2,n)
      f(1,i,j2,n) = f(1,i,j1,n) - t2
      f(2,i,j2,n) = f(2,i,j1,n) - t3
      f(3,i,j2,n) = f(3,i,j1,n) - t4
      f(1,i,j1,n) = f(1,i,j1,n) + t2
      f(2,i,j1,n) = f(2,i,j1,n) + t3
      f(3,i,j1,n) = f(3,i,j1,n) + t4
  160 continue
  170 continue
  180 continue
  190 continue
c unscramble modes kx = 0, nx/2
      do 210 k = 2, nyh
      do 200 jj = 1, 3
      t1 = f(jj,1,ny2-k,n)
      f(jj,1,ny2-k,n) = 0.5*cmplx(aimag(f(jj,1,k,n) + t1),
     1                            real(f(jj,1,k,n) - t1))
      f(jj,1,k,n) = 0.5*cmplx(real(f(jj,1,k,n) + t1),
     1                        aimag(f(jj,1,k,n) - t1))
  200 continue
  210 continue
  220 continue
!$OMP END PARALLEL DO
      return
c forward fourier transform
  230 nryb = nxhyz/ny
      nry = nxyz/ny
      nrxb = nxhyz/nxh
      nrx = nxyz/nxh
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,n,ns,ns2,km,kmr,k1,k2,jj,j1,j2,at1,at2,t1,t2,t3,
!$OMP& t4)
      do 450 n = nzi, nzt
c scramble modes kx = 0, nx/2
      do 250 k = 2, nyh
      do 240 jj = 1, 3
      t1 = cmplx(aimag(f(jj,1,ny2-k,n)),real(f(jj,1,ny2-k,n)))
      f(jj,1,ny2-k,n) = conjg(f(jj,1,k,n) - t1)
      f(jj,1,k,n) = f(jj,1,k,n) + t1
  240 continue
  250 continue
c bit-reverse array elements in y
      do 270 k = 1, ny
      k1 = (mixup(k) - 1)/nryb + 1
      if (k.lt.k1) then
         do 260 i = 1, nxh
         t1 = f(1,i,k1,n)
         t2 = f(2,i,k1,n)
         t3 = f(3,i,k1,n)
         f(1,i,k1,n) = f(1,i,k,n)
         f(2,i,k1,n) = f(2,i,k,n)
         f(3,i,k1,n) = f(3,i,k,n)
         f(1,i,k,n) = t1
         f(2,i,k,n) = t2
         f(3,i,k,n) = t3
  260 continue
      endif
  270 continue
c then transform in y
      do 310 l = 1, indy
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nyh/ns
      kmr = km*nry
      do 300 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 290 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = conjg(sct(1+kmr*(j-1)))
      do 280 i = 1, nxh
      t2 = t1*f(1,i,j2,n)
      t3 = t1*f(2,i,j2,n)
      t4 = t1*f(3,i,j2,n)
      f(1,i,j2,n) = f(1,i,j1,n) - t2
      f(2,i,j2,n) = f(2,i,j1,n) - t3
      f(3,i,j2,n) = f(3,i,j1,n) - t4
      f(1,i,j1,n) = f(1,i,j1,n) + t2
      f(2,i,j1,n) = f(2,i,j1,n) + t3
      f(3,i,j1,n) = f(3,i,j1,n) + t4
  280 continue
  290 continue
  300 continue
  310 continue
c scramble coefficients
      kmr = nxyz/nx
      do 340 j = 2, nxhh
      t3 = cmplx(aimag(sct(1+kmr*(j-1))),real(sct(1+kmr*(j-1))))
      do 330 k = 1, ny
      do 320 jj = 1, 3
      t2 = conjg(f(jj,nxh2-j,k,n))
      t1 = f(jj,j,k,n) + t2
      t2 = (f(jj,j,k,n) - t2)*t3
      f(jj,j,k,n) = t1 + t2
      f(jj,nxh2-j,k,n) = conjg(t1 - t2)
  320 continue
  330 continue
  340 continue
      do 360 k = 1, ny
      do 350 jj = 1, 3
      f(jj,nxhh+1,k,n) = 2.0*conjg(f(jj,nxhh+1,k,n))
      f(jj,1,k,n) = cmplx(real(f(jj,1,k,n)) + aimag(f(jj,1,k,n)),
     1                    real(f(jj,1,k,n)) - aimag(f(jj,1,k,n)))
  350 continue
  360 continue
c bit-reverse array elements in x
      do 380 j = 1, nxh
      j1 = (mixup(j) - 1)/nrxb + 1
      if (j.lt.j1) then
      do 370 i = 1, ny
         t1 = f(1,j1,i,n)
         t2 = f(2,j1,i,n)
         t3 = f(3,j1,i,n)
         f(1,j1,i,n) = f(1,j,i,n)
         f(2,j1,i,n) = f(2,j,i,n)
         f(3,j1,i,n) = f(3,j,i,n)
         f(1,j,i,n) = t1
         f(2,j,i,n) = t2
         f(3,j,i,n) = t3
  370 continue
      endif
  380 continue
c finally transform in x
      do 420 l = 1, indx1
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nxhh/ns
      kmr = km*nrx
      do 410 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 400 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = conjg(sct(1+kmr*(j-1)))
      do 390 i = 1, ny
      t2 = t1*f(1,j2,i,n)
      t3 = t1*f(2,j2,i,n)
      t4 = t1*f(3,j2,i,n)
      f(1,j2,i,n) = f(1,j1,i,n) - t2
      f(2,j2,i,n) = f(2,j1,i,n) - t3
      f(3,j2,i,n) = f(3,j1,i,n) - t4
      f(1,j1,i,n) = f(1,j1,i,n) + t2
      f(2,j1,i,n) = f(2,j1,i,n) + t3
      f(3,j1,i,n) = f(3,j1,i,n) + t4
  390 continue
  400 continue
  410 continue
  420 continue
c swap complex components
      do 440 i = 1, ny
      do 430 j = 1, nxh
      at1 = real(f(3,j,i,n))
      f(3,j,i,n) = cmplx(aimag(f(2,j,i,n)),aimag(f(3,j,i,n)))
      at2 = real(f(2,j,i,n))
      f(2,j,i,n) = cmplx(at1,aimag(f(1,j,i,n)))
      f(1,j,i,n) = cmplx(real(f(1,j,i,n)),at2)
  430 continue
  440 continue
  450 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      subroutine FFT3RM3Z(f,isign,mixup,sct,indx,indy,indz,nyi,nyp,nxhd,
     1nyd,nzd,nxhyzd,nxyzhd)
c this subroutine performs the z part of 3 three dimensional complex to
c real fast fourier transforms and their inverses, for a subset of y,
c using complex arithmetic, with OpenMP
c for isign = (-1,1), input: all, output: f
c for isign = -1, approximate flop count: N*(5*log2(N) + 19/2)
c for isign = 1,  approximate flop count: N*(5*log2(N) + 15/2)
c where N = (nx/2)*ny*nz
c indx/indy/indz = exponent which determines length in x/y/z direction,
c where nx=2**indx, ny=2**indy, nz=2**indz
c if isign = -1, three inverse fourier transforms in z are performed
c f(1:3,j,k,l) = sum(f(1:3,j,k,i)*exp(-sqrt(-1)*2pi*l*i/nz))
c if isign = 1, three forward fourier transforms in z are performed
c f(1:3,n,m,i) = sum(f(1:3,n,m,l)*exp(sqrt(-1)*2pi*l*i/nz))
c mixup = array of bit reversed addresses
c sct = sine/cosine table
c nyi = initial y index used
c nyp = number of y indices used
c nxhd = second dimension of f
c nyd,nzd = third and fourth dimensions of f
c nxhyzd = maximum of (nx/2,ny,nz)
c nxyzhd = maximum of (nx,ny,nz)/2
c fourier coefficients are stored as follows:
c f(1:3,2*j-1,k,l),f(2*j,k,l) = real, imaginary part of mode j-1,k-1,l-1
c where 1 <= j <= nx/2, 1 <= k <= ny, 1 <= l <= nz, except for
c f(1:3,1,k,l) = real, imaginary part of mode nx/2,k-1,l-1,
c where ny/2+2 <= k <= ny and 1 <= l <= nz, and
c f(1:3,1,1,l) = real, imaginary part of mode nx/2,0,l-1,
c f(1:3,1,ny/2+1,l) = real, imaginary part mode nx/2,ny/2,l-1,
c where nz/2+2 <= l <= nz, and
c imag(f(1:3,1,1,1)) = real part of mode nx/2,0,0
c imag(f(1:3,1,ny/2+1,1)) = real part of mode nx/2,ny/2,0
c imag(f(1:3,1,1,nz/2+1)) = real part of mode nx/2,0,nz/2
c imag(f(1:3,1,ny/2+1,nz/2+1)) = real part of mode nx/2,ny/2,nz/2
c using jpl storage convention, as described in:
c E. Huang, P. C. Liewer, V. K. Decyk, and R. D. Ferraro, "Concurrent
c Three-Dimensional Fast Fourier Transform Algorithms for Coarse-Grained
c Distributed Memory Parallel Computers," Caltech CRPC Report 217-50,
c December 1993.
c written by viktor k. decyk, ucla
      implicit none
      integer isign, indx, indy, indz, nyi, nyp, nxhd, nyd, nzd
      integer nxhyzd, nxyzhd
      complex f, sct
      integer mixup
      dimension f(3,nxhd,nyd,nzd), mixup(nxhyzd), sct(nxyzhd)
c local data
      integer indx1, ndx1yz, nx, nxh, nxhh, nxh2, ny, nyh, ny2
      integer nz, nzh, nz2, nxyz, nxhyz, nyt, nrz, nrzb
      integer i, j, k, l, n, jj, j1, j2, k1, k2, l1, ns, ns2, km, kmr
      complex t1, t2, t3, t4
      if (isign.eq.0) return
      indx1 = indx - 1
      ndx1yz = max0(indx1,indy,indz)
      nx = 2**indx
      nxh = nx/2
      nxhh = nx/4
      nxh2 = nxh + 2
      ny = 2**indy
      nyh = ny/2
      ny2 = ny + 2
      nz = 2**indz
      nzh = nz/2
      nz2 = nz + 2
      nxyz = max0(nx,ny,nz)
      nxhyz = 2**ndx1yz
      nyt = nyi + nyp - 1
      if (isign.gt.0) go to 110
c inverse fourier transform
      nrzb = nxhyz/nz
      nrz = nxyz/nz
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,n,ns,ns2,km,kmr,k1,k2,j1,j2,l1,t1,t2,t3,t4)
      do 70 n = nyi, nyt
c bit-reverse array elements in z
      do 20 l = 1, nz
      l1 = (mixup(l) - 1)/nrzb + 1
      if (l.lt.l1) then
      do 10 i = 1, nxh
         t1 = f(1,i,n,l1)
         t2 = f(2,i,n,l1)
         t3 = f(3,i,n,l1)
         f(1,i,n,l1) = f(1,i,n,l)
         f(2,i,n,l1) = f(2,i,n,l)
         f(3,i,n,l1) = f(3,i,n,l)
         f(1,i,n,l) = t1
         f(2,i,n,l) = t2
         f(3,i,n,l) = t3
   10 continue
      endif
   20 continue
c finally transform in z
      do 60 l = 1, indz
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nzh/ns
      kmr = km*nrz
      do 50 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 40 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = sct(1+kmr*(j-1))
      do 30 i = 1, nxh
      t2 = t1*f(1,i,n,j2)
      t3 = t1*f(2,i,n,j2)
      t4 = t1*f(3,i,n,j2)
      f(1,i,n,j2) = f(1,i,n,j1) - t2
      f(2,i,n,j2) = f(2,i,n,j1) - t3
      f(3,i,n,j2) = f(3,i,n,j1) - t4
      f(1,i,n,j1) = f(1,i,n,j1) + t2
      f(2,i,n,j1) = f(2,i,n,j1) + t3
      f(3,i,n,j1) = f(3,i,n,j1) + t4
   30 continue
   40 continue
   50 continue
   60 continue
   70 continue
!$OMP END PARALLEL DO
c unscramble modes kx = 0, nx/2
      do 100 n = 2, nzh
      if (nyi.eq.1) then
         do 80 jj = 1, 3
         t1 = f(jj,1,1,nz2-n)
         f(jj,1,1,nz2-n) = 0.5*cmplx(aimag(f(jj,1,1,n) + t1),
     1                               real(f(jj,1,1,n) - t1))
         f(jj,1,1,n) = 0.5*cmplx(real(f(jj,1,1,n) + t1),
     1                           aimag(f(jj,1,1,n) - t1))
   80    continue
      endif
      if ((nyi.le.nyh+1).and.(nyt.ge.nyh+1)) then
         do 90 jj = 1, 3
         t1 = f(jj,1,nyh+1,nz2-n)
         f(jj,1,nyh+1,nz2-n) = 0.5*cmplx(aimag(f(jj,1,nyh+1,n) + t1),
     1                                  real(f(jj,1,nyh+1,n) - t1))
         f(jj,1,nyh+1,n) = 0.5*cmplx(real(f(jj,1,nyh+1,n) + t1),
     1                              aimag(f(jj,1,nyh+1,n) - t1))
   90    continue
      endif
  100 continue
      return
c forward fourier transform
  110 nrzb = nxhyz/nz
      nrz = nxyz/nz
c scramble modes kx = 0, nx/2
      do 140 n = 2, nzh
      if (nyi.eq.1) then
         do 120 jj = 1, 3
         t1 = cmplx(aimag(f(jj,1,1,nz2-n)),real(f(jj,1,1,nz2-n)))
         f(jj,1,1,nz2-n) = conjg(f(jj,1,1,n) - t1)
         f(jj,1,1,n) = f(jj,1,1,n) + t1
  120    continue
      endif
      if ((nyi.le.nyh+1).and.(nyt.ge.nyh+1)) then
         do 130 jj = 1, 3
         t1 = cmplx(aimag(f(jj,1,nyh+1,nz2-n)),
     1              real(f(jj,1,nyh+1,nz2-n)))
         f(jj,1,nyh+1,nz2-n) = conjg(f(jj,1,nyh+1,n) - t1)
         f(jj,1,nyh+1,n) = f(jj,1,nyh+1,n) + t1
  130    continue
      endif
  140 continue
c bit-reverse array elements in z
!$OMP PARALLEL DO
!$OMP& PRIVATE(i,j,k,l,n,ns,ns2,km,kmr,k1,k2,j1,j2,l1,t1,t2,t3,t4)
      do 210 n = nyi, nyt
      do 160 l = 1, nz
      l1 = (mixup(l) - 1)/nrzb + 1
      if (l.lt.l1) then
         do 150 i = 1, nxh
         t1 = f(1,i,n,l1)
         t2 = f(2,i,n,l1)
         t3 = f(3,i,n,l1)
         f(1,i,n,l1) = f(1,i,n,l)
         f(2,i,n,l1) = f(2,i,n,l)
         f(3,i,n,l1) = f(3,i,n,l)
         f(1,i,n,l) = t1
         f(2,i,n,l) = t2
         f(3,i,n,l) = t3
  150    continue
      endif
  160 continue
c first transform in z
      do 200 l = 1, indz
      ns = 2**(l - 1)
      ns2 = ns + ns
      km = nzh/ns
      kmr = km*nrz
      do 190 k = 1, km
      k1 = ns2*(k - 1)
      k2 = k1 + ns
      do 180 j = 1, ns
      j1 = j + k1
      j2 = j + k2
      t1 = conjg(sct(1+kmr*(j-1)))
      do 170 i = 1, nxh
      t2 = t1*f(1,i,n,j2)
      t3 = t1*f(2,i,n,j2)
      t4 = t1*f(3,i,n,j2)
      f(1,i,n,j2) = f(1,i,n,j1) - t2
      f(2,i,n,j2) = f(2,i,n,j1) - t3
      f(3,i,n,j2) = f(3,i,n,j1) - t4
      f(1,i,n,j1) = f(1,i,n,j1) + t2
      f(2,i,n,j1) = f(2,i,n,j1) + t3
      f(3,i,n,j1) = f(3,i,n,j1) + t4
  170 continue
  180 continue
  190 continue
  200 continue
  210 continue
!$OMP END PARALLEL DO
      return
      end
c-----------------------------------------------------------------------
      function ranorm()
c this program calculates a random number y from a gaussian distribution
c with zero mean and unit variance, according to the method of
c mueller and box:
c    y(k) = (-2*ln(x(k)))**1/2*sin(2*pi*x(k+1))
c    y(k+1) = (-2*ln(x(k)))**1/2*cos(2*pi*x(k+1)),
c where x is a random number uniformly distributed on (0,1).
c written for the ibm by viktor k. decyk, ucla
      implicit none
      integer iflg,isc,i1,r1,r2,r4,r5
      double precision ranorm,h1l,h1u,h2l,r0,r3,asc,bsc,temp
      save iflg,r1,r2,r4,r5,h1l,h1u,h2l,r0
      data r1,r2,r4,r5 /885098780,1824280461,1396483093,55318673/
      data h1l,h1u,h2l /65531.0d0,32767.0d0,65525.0d0/
      data iflg,r0 /0,0.0d0/
      if (iflg.eq.0) go to 10
      ranorm = r0
      r0 = 0.0d0
      iflg = 0
      return
   10 isc = 65536
      asc = dble(isc)
      bsc = asc*asc
      i1 = r1 - (r1/isc)*isc
      r3 = h1l*dble(r1) + asc*h1u*dble(i1)
      i1 = r3/bsc
      r3 = r3 - dble(i1)*bsc
      bsc = 0.5d0*bsc
      i1 = r2/isc
      isc = r2 - i1*isc
      r0 = h1l*dble(r2) + asc*h1u*dble(isc)
      asc = 1.0d0/bsc
      isc = r0*asc
      r2 = r0 - dble(isc)*bsc
      r3 = r3 + (dble(isc) + 2.0d0*h1u*dble(i1))
      isc = r3*asc
      r1 = r3 - dble(isc)*bsc
      temp = dsqrt(-2.0d0*dlog((dble(r1) + dble(r2)*asc)*asc))
      isc = 65536
      asc = dble(isc)
      bsc = asc*asc
      i1 = r4 - (r4/isc)*isc
      r3 = h2l*dble(r4) + asc*h1u*dble(i1)
      i1 = r3/bsc
      r3 = r3 - dble(i1)*bsc
      bsc = 0.5d0*bsc
      i1 = r5/isc
      isc = r5 - i1*isc
      r0 = h2l*dble(r5) + asc*h1u*dble(isc)
      asc = 1.0d0/bsc
      isc = r0*asc
      r5 = r0 - dble(isc)*bsc
      r3 = r3 + (dble(isc) + 2.0d0*h1u*dble(i1))
      isc = r3*asc
      r4 = r3 - dble(isc)*bsc
      r0 = 6.28318530717959d0*((dble(r4) + dble(r5)*asc)*asc)
      ranorm = temp*dsin(r0)
      r0 = temp*dcos(r0)
      iflg = 1
      return
      end
c-----------------------------------------------------------------------
      subroutine PPCOPYOUT(part,ppart,kpic,nop,nppmx,idimp,mxyz1,irc)
c for 3d code, this subroutine copies segmented particle data ppart to
c the array part with original tiled layout
c input: all except part, output: part
c part(i,j) = i-th coordinate for particle j
c ppart(i,j,k) = i-th coordinate for particle j in tile k
c kpic = number of particles per tile
c nop = number of particles
c nppmx = maximum number of particles in tile
c idimp = size of phase space = 6
c mxyz1 = total number of tiles
c irc = maximum overflow, returned only if error occurs, when irc > 0
      implicit none
      integer nop, nppmx, idimp, mxyz1, irc
      real part, ppart
      integer kpic
      dimension part(idimp,nop), ppart(idimp,nppmx,mxyz1)
      dimension kpic(mxyz1)
c local data
      integer i, j, k, npoff, npp, ne, ierr
      npoff = 0
      ierr = 0
c loop over tiles
      do 30 k = 1, mxyz1
      npp = kpic(k)
      ne = npp + npoff
      if (ne.gt.nop) ierr = max(ierr,ne-nop)
      if (ierr.gt.0) npp = 0
c loop over particles in tile
      do 20 j = 1, npp
      do 10 i = 1, idimp
      part(i,j+npoff) = ppart(i,j,k)
   10 continue
   20 continue
      npoff = npoff + npp
   30 continue
      if (ierr.gt.0) irc = ierr
      return
      end
