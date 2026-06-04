# Verify a_unident_dim == r in the non-degenerate regime, across many seeds and
# (m, r). Identify the exact saturation boundary where it stops equaling r.
source_funcs <- new.env()
Ja_offdiag <- function(a) {
  m <- length(a); pr <- which(upper.tri(matrix(0,m,m)), arr.ind=TRUE)
  J <- matrix(0, nrow(pr), m)
  for (i in seq_len(nrow(pr))) { j<-pr[i,1]; k<-pr[i,2]; J[i,j]<-J[i,j]+a[k]; J[i,k]<-J[i,k]+a[j] }
  J
}
JV_offdiag <- function(V) {
  m <- nrow(V); r <- ncol(V); pr <- which(upper.tri(matrix(0,m,m)), arr.ind=TRUE)
  M <- nrow(pr); J <- matrix(0, M, m*r); ci <- function(p,t) (t-1)*m + p
  for (i in seq_len(M)) { j<-pr[i,1]; k<-pr[i,2]
    for (t in seq_len(r)) { J[i,ci(j,t)]<-J[i,ci(j,t)]+V[k,t]; J[i,ci(k,t)]<-J[i,ci(k,t)]+V[j,t] } }
  J
}
rk <- function(X, tol=1e-8){ if(length(X)==0||nrow(X)==0||ncol(X)==0) return(0L); s<-svd(X)$d; sum(s>tol*max(1,s[1])) }
a_unident <- function(m, r, seed) {
  set.seed(seed); a<-runif(m,0.3,0.9); V<-matrix(rnorm(m*r),m,r)
  Ja<-Ja_offdiag(a); JV<-JV_offdiag(V); ident<-rk(cbind(Ja,JV))-rk(JV); m-ident
}
cat("Checking a_unident_dim == r, 20 seeds each. PASS if all equal r.\n")
cat(sprintf("%4s %4s %8s %8s %8s\n","m","r","min","max","==r?"))
for (m in c(6,8,10,12,16,20,30)) {
  for (r in 0:(m)) {
    vals <- sapply(1:20, function(s) a_unident(m,r,s+100*m+7*r))
    eqr <- all(vals==r)
    if (r<=min(m,12) || !eqr) # print interesting rows
      cat(sprintf("%4d %4d %8d %8d %8s\n", m, r, min(vals), max(vals), ifelse(eqr,"YES",paste0("NO(",paste(unique(vals),collapse=","),")"))))
  }
  cat("  ---\n")
}
# Theoretical saturation: a_unident < r once the rank-r symmetric off-diag
# variety dimension r*m - r(r-1)/2 (minus what?) exceeds M=m(m-1)/2 region.
# Report the largest r with a_unident==r for each m.
cat("\nLargest r with a_unident==r (the 'clean regime' boundary):\n")
for (m in c(6,8,10,12,16,20,30,40)) {
  best <- -1
  for (r in 0:m) { if (all(sapply(1:8,function(s) a_unident(m,r,s+9*m+3*r))==r)) best<-r else break }
  cat(sprintf("  m=%2d : r up to %2d  (M=%d, m=%d)\n", m, best, m*(m-1)/2, m))
}
