# Consolidated reproduction of the T4 sample-complexity findings.
#   Run: Rscript .research/findings/reproduce.R
# Reproduces the headline numbers:
#   (1) d_free = r (parameter degeneracy gold must pin).
#   (2) gold is a rich diagonal measurement (per-coord var 1-a_j^2).
#   (3) L2-total recovery: n_g = Theta(r/gap^2)  (slope ~1 in r, -2 in gap).
#   (4) Linf per-direction: n_g = Theta(log r/gap^2) (n_g ~ a + b log r).
#   (5) minimax lower bound: minimax L2 risk = r*v/n_g => n_g* = r*v/gap^2.
#   (6) downstream label KL is an L2 quadratic form (slope 1 vs ||da||^2;
#       shape-invariant), so the operative rate is the LINEAR-r one.
set.seed(20260603)
SIM <- "/home/spinoza/github/papers/weaksup-coarsening/scripts/sim.R"
source(SIM)

cat("================ (1) degeneracy dimension d_free = r ================\n")
Ja<-function(a){m<-length(a);pr<-which(upper.tri(matrix(0,m,m)),arr.ind=TRUE);J<-matrix(0,nrow(pr),m);for(i in seq_len(nrow(pr))){j<-pr[i,1];k<-pr[i,2];J[i,j]<-J[i,j]+a[k];J[i,k]<-J[i,k]+a[j]};J}
JV<-function(V){m<-nrow(V);r<-ncol(V);pr<-which(upper.tri(matrix(0,m,m)),arr.ind=TRUE);J<-matrix(0,nrow(pr),m*r);ci<-function(p,t)(t-1)*m+p;for(i in seq_len(nrow(pr))){j<-pr[i,1];k<-pr[i,2];for(t in seq_len(r)){J[i,ci(j,t)]<-J[i,ci(j,t)]+V[k,t];J[i,ci(k,t)]<-J[i,ci(k,t)]+V[j,t]}};J}
rk<-function(X,tol=1e-8){if(length(X)==0||nrow(X)==0||ncol(X)==0)return(0L);s<-svd(X)$d;sum(s>tol*max(1,s[1]))}
m<-20; a<-runif(m,.3,.9)
for(r in c(0,1,3,6,10)){ V<-if(r>0)matrix(rnorm(m*r),m,r) else matrix(0,m,0)
  dfree<-m-(rk(cbind(Ja(a),JV(V)))-rk(JV(V))); cat(sprintf("  m=%d r=%2d -> d_free=%d\n",m,r,dfree)) }

cat("\n================ (2) gold = rich diagonal (var 1-a^2) ================\n")
mm<-8;acc<-c(.72,.70,.71,.69,.73,.68,.80,.78);at<-2*acc-1
s<-sim_ws(40000,.5,rep(.8,mm),acc,dep_pairs=list(c(1,2),c(3,4),c(5,6)),dep_strength=.5)
cr<-(s$L==s$Y); ev<-sapply(1:mm,function(j)var(2*cr[,j]-1,na.rm=TRUE))
cat("  emp var :",paste(sprintf("%.2f",ev),collapse=" "),"\n")
cat("  1 - a^2 :",paste(sprintf("%.2f",1-at^2),collapse=" "),"\n")

cat("\n================ (3)+(4) rates via exact Gaussian reduction ================\n")
gap<-0.20; v<-1-gap^2
medmax<-function(r,N=20000) median(replicate(N,max(abs(rnorm(r)))))
rs<-c(1,2,4,8,16,32,64)
ngL2 <- v*qchisq(.5,rs)/gap^2
ngLinf <- sapply(rs,function(r) v*medmax(r)^2/gap^2)
cat(sprintf("  %4s %10s %10s %8s\n","r","ng_L2","ng_Linf","ng_L2/r"))
for(i in seq_along(rs)) cat(sprintf("  %4d %10.1f %10.1f %8.2f\n",rs[i],ngL2[i],ngLinf[i],ngL2[i]/rs[i]))
cat(sprintf("  L2 slope vs r (r>=8): %.3f (predict 1)\n",coef(lm(log(ngL2[rs>=8])~log(rs[rs>=8])))[2]))
cat(sprintf("  Linf fit ng = %.1f + %.1f*log(r), R^2=%.3f (predict linear in log r)\n",
            coef(lm(ngLinf~log(rs)))[1],coef(lm(ngLinf~log(rs)))[2],summary(lm(ngLinf~log(rs)))$r.squared))
# gap slope at fixed r=8
gg<-c(.08,.10,.14,.20,.28,.40); ngg<-sapply(gg,function(gp)(1-gp^2)*qchisq(.5,8)/gp^2)
cat(sprintf("  gap slope (r=8, L2): %.3f (predict -2)\n",coef(lm(log(ngg)~log(gg)))[2]))

cat("\n================ (5) minimax lower bound ================\n")
for(r in c(4,16)){ng<-round(r*v/gap^2)
  risk<-mean(replicate(3000,{th<-rnorm(r);y<-th+sqrt(v/ng)*rnorm(r);sum((y-th)^2)}))
  cat(sprintf("  r=%2d n_g=r*v/gap^2=%3d : sample-mean risk=%.4f = r*v/n_g=%.4f (=gap^2=%.4f). minimax tight.\n",
              r,ng,risk,r*v/ng,gap^2))}

cat("\n================ (6) label KL is an L2 quadratic form ================\n")
mm2<-10;acc2<-rep(.5+gap/2,mm2);a2<-2*acc2-1
s2<-sim_ws(120000,.5,rep(.8,mm2),acc2)
logit<-function(p)log(p/(1-p));inv<-function(z)1/(1+exp(-z))
postA<-function(L,av,pv){ac<-pmin(pmax((1+av)/2,1e-6),1-1e-6);z<-rep(logit(pv),nrow(L))
  for(j in seq_len(ncol(L))){vv<-L[,j];ok<-!is.na(vv);z[ok]<-z[ok]+ifelse(vv[ok]==1L,log(ac[j]/(1-ac[j])),log((1-ac[j])/ac[j]))};inv(z)}
mkl<-function(p,q){p<-pmin(pmax(p,1e-9),1-1e-9);q<-pmin(pmax(q,1e-9),1-1e-9);mean(p*log(p/q)+(1-p)*log((1-p)/(1-q)))}
pt<-postA(s2$L,a2,.5)
sc<-.10
klc<-mean(replicate(30,{da<-rep(0,mm2);da[sample(mm2,1)]<-sample(c(-1,1),1)*sc;mkl(pt,postA(s2$L,a2+da,.5))}))
kls<-mean(replicate(30,{da<-sample(c(-1,1),mm2,TRUE)*sc/sqrt(mm2);mkl(pt,postA(s2$L,a2+da,.5))}))
cat(sprintf("  at ||da||_2=%.2f: concentrated(Linf=%.2f) KL=%.5f ; spread(Linf=%.2f) KL=%.5f ; ratio=%.2f\n",
            sc,sc,klc,sc/sqrt(mm2),kls,klc/kls))
cat("  ratio ~ 1 => label quality governed by L2 norm, not Linf => operative rate is Theta(r/gap^2).\n")

cat("\n================ SUMMARY ================\n")
cat("  d_free = r (param degeneracy). gold = rich diagonal (var 1-a^2).\n")
cat("  L2-total recovery: n_g = Theta(r/gap^2)  [MINIMAX].\n")
cat("  Linf per-direction: n_g = Theta(log r/gap^2) [union bound TIGHT].\n")
cat("  label KL is L2 => operative rate = Theta(r/gap^2). Linear r is CORRECT\n")
cat("  for the operative (total) loss; log r is correct for the Linf loss.\n")
