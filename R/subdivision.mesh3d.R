# 
# subdivision.mesh3d
#
# an *efficient* algorithm for subdivision of mesh3d objects
# using addition operations and homogenous coordinates 
# by Daniel Adler 
#
# 

edgemap <- function( size ) {
  data<-vector( mode="numeric", length=( size*(size+1) )/2 )
  data[] <- -1
  return(data)
}

edgeindex <- function( from, to, size, row=min(from,to), col=max(from,to) )
  return( row*size - ( row*(row+1) )/2 - (size-col) )

divide.mesh3d <- function (mesh,vb=mesh$vb, ib=mesh$ib, it=mesh$it ) {
  nv    <- dim(vb)[2]
  inds <- seq_len(nv)
  nq <- if (is.null(ib)) 0 else dim(ib)[2]
  nt <- if (is.null(it)) 0 else dim(it)[2]
  primout <- c()
  nvmax <- nv + nq + ( nv*(nv+1) )/2
  outvb <- matrix(data=0,nrow=4,ncol=nvmax)  
  # copy old points
  outvb[,seq_len(nv)] <- vb  
  vcnt <- nv
  em    <- edgemap( nv )
  
  if (!is.null(mesh$normals)) {
    if (NROW(mesh$normals) == 4)
      mesh$normals <- t(asEuclidean(t(mesh$normals)))
    newnormals <- matrix(data=0,nrow=3,ncol=nvmax)
    newnormals[,inds] <- mesh$normals
  } else newnormals <- NULL
  
  if (!is.null(mesh$texcoords)) {
    newtexcoords <- matrix(data=0,nrow=2,ncol=nvmax)
    newtexcoords[,inds] <- mesh$texcoords
  } else newtexcoords <- NULL
  
  if (!is.null(newnormals) || !is.null(newtexcoords)) {
    newcount <- rep(0, nvmax)
    newcount[inds] <- 1
  }
  
  result <- structure(list(material=mesh$material), class="mesh3d")
  
  if (nq) {
    newnq <- nq*4

    outib <- matrix(nrow=4,ncol=newnq)
    vcnt  <- vcnt + nq
  
    for (i in 1:nq ) {
      isurf <- nv + i
      for (j in 1:4 ) {
      
        iprev <- ib[((j+2)%%4) + 1, i]
        ithis <- ib[j,i]
        inext <- ib[ (j%%4)    + 1, i]
      
        # get or alloc edge-point this->next
        mindex <- edgeindex(ithis, inext, nv)
        enext <- em[mindex]
        if (enext == -1) {
          vcnt       <- vcnt + 1
          enext      <- vcnt
          em[mindex] <- enext
        }

        # get or alloc edge-point prev->this
        mindex <- edgeindex(iprev, ithis, nv)
        eprev <- em[mindex]
        if (eprev == -1) {
          vcnt       <- vcnt + 1
          eprev      <- vcnt
          em[mindex] <- eprev
        }

        # gen grid      
        outib[, (i-1)*4+j ] <- c( ithis, enext, isurf, eprev )

        # calculate surface point
        outvb[,isurf] <- outvb[,isurf] + vb[,ithis]
      
        # calculate edge point
        outvb[,enext] <- outvb[,enext] + vb[,ithis] 
        outvb[,eprev] <- outvb[,eprev] + vb[,ithis] 
        
        if (!is.null(newnormals)) {
          thisnorm <- mesh$normals[,ithis]
          newnormals[,isurf] <- newnormals[,isurf] + thisnorm
          newnormals[,enext] <- newnormals[,enext] + thisnorm
          newnormals[,eprev] <- newnormals[,eprev] + thisnorm
        }
        
        if (!is.null(newtexcoords)) {
          thistexcoord <- mesh$texcoords[,ithis]
          newtexcoords[,isurf] <- newtexcoords[,isurf] + thistexcoord
          newtexcoords[,enext] <- newtexcoords[,enext] + thistexcoord
          newtexcoords[,eprev] <- newtexcoords[,eprev] + thistexcoord
        }
        
        if (!is.null(newnormals) || !is.null(newtexcoords)) {
          newcount[isurf] <- newcount[isurf] + 1
          newcount[enext] <- newcount[enext] + 1
          newcount[eprev] <- newcount[eprev] + 1
        }
      }
    }
    primout <- "quad"
    result$ib <- outib
  }
  if (nt) {
    newnt <- nt*4
    outit <- matrix(nrow=3,ncol=newnt)
  
    for (i in 1:nt ) {
      for (j in 1:3 ) {
      
        iprev <- it[((j+1)%%3) + 1, i]
        ithis <- it[j,i]
        inext <- it[ (j%%3)    + 1, i]
        
        # get or alloc edge-point this->next
        mindex <- edgeindex(ithis, inext, nv)
        enext <- em[mindex]
        if (enext == -1) {
          vcnt       <- vcnt + 1
          enext      <- vcnt
          em[mindex] <- enext
        }

        # get or alloc edge-point prev->this
        mindex <- edgeindex(iprev, ithis, nv)
        eprev <- em[mindex]
        if (eprev == -1) {
          vcnt       <- vcnt + 1
          eprev      <- vcnt
          em[mindex] <- eprev
        }

        # gen grid      
        outit[, (i-1)*4+j ] <- c( ithis, enext, eprev )
      
        # calculate edge point
        outvb[,enext] <- outvb[,enext] + vb[,ithis] 
        outvb[,eprev] <- outvb[,eprev] + vb[,ithis] 
        
        if (!is.null(newnormals)) {
          thisnorm <- mesh$normals[,ithis]
          newnormals[,enext] <- newnormals[,enext] + thisnorm
          newnormals[,eprev] <- newnormals[,eprev] + thisnorm
        }
        
        if (!is.null(newtexcoords)) {
          thistexcoord <- mesh$texcoords[,ithis]
          newtexcoords[,enext] <- newtexcoords[,enext] + thistexcoord
          newtexcoords[,eprev] <- newtexcoords[,eprev] + thistexcoord
        }
        
        if (!is.null(newnormals) || !is.null(newtexcoords)) {
          newcount[enext] <- newcount[enext] + 1
          newcount[eprev] <- newcount[eprev] + 1
        }        

      }
      # Now central triangle
      
      outit[, (i-1)*4+4 ] <- c( em[edgeindex(ithis, inext, nv)],
                                em[edgeindex(inext, iprev, nv)],
                                em[edgeindex(iprev, ithis, nv)] )
    }
    primout <- c(primout, "triangle")
    result$it <- outit
  }
  
  if (!is.null(newnormals) || !is.null(newtexcoords)) 
    newcount <- newcount[seq_len(vcnt)]
    
  if (!is.null(newnormals)) 
    newnormals <- newnormals[, seq_len(vcnt)]/rep(newcount, each=3)
    
  if (!is.null(newtexcoords))
    newtexcoords <- newtexcoords[, seq_len(vcnt)]/rep(newcount, each=2)
    
  result$vb <- outvb[,seq_len(vcnt)]
  result$normals <- newnormals
  result$texcoords <- newtexcoords
  
  return ( result )
}

normalize.mesh3d <- function (mesh) {
  mesh$vb[1,] <- mesh$vb[1,]/mesh$vb[4,]
  mesh$vb[2,] <- mesh$vb[2,]/mesh$vb[4,]
  mesh$vb[3,] <- mesh$vb[3,]/mesh$vb[4,]
  mesh$vb[4,] <- 1
  return (mesh)
}

deform.mesh3d <- function( mesh, vb=mesh$vb, ib=mesh$ib, it=mesh$it )
{
  nv <- dim(vb)[2]
  nq <- if (is.null(ib)) 0 else dim(ib)[2]
  nt <- if (is.null(it)) 0 else dim(it)[2]
  out <- matrix(0, nrow=4, ncol=nv )
  if (nq) {
    for ( i in 1:nq ) {
      for (j in 1:4 ) {
        iprev <- ib[((j+2)%%4) + 1, i]
        ithis <- ib[j,i]
        inext <- ib[ (j%%4)    + 1, i]
        out[ ,ithis ] <- out[ , ithis ] + vb[,iprev] + vb[,ithis] + vb[,inext]
      }
    }
    mesh$vb <- out
  }
  if (nt) {
    for ( i in 1:nt ) {
      for (j in 1:3 ) {
        iprev <- it[((j+1)%%3) + 1, i]
        ithis <- it[j,i]
        inext <- it[ (j%%3)    + 1, i]
        out[ ,ithis ] <- out[ , ithis ] + vb[,iprev] + vb[,ithis] + vb[,inext]
      }
    }
    mesh$vb <- out
  }  
  return(mesh)
}

subdivision3d.mesh3d <- function(x,depth=1,normalize=FALSE,deform=TRUE,...) {
  mesh <- x
  if (depth) {
    mesh <- divide.mesh3d(mesh)
    if (normalize)
      mesh <- normalize.mesh3d(mesh)
    if (deform)
      mesh <- deform.mesh3d(mesh)      
    mesh<-subdivision3d.mesh3d(mesh,depth-1,normalize,deform)
  }
  return(mesh)  
}

