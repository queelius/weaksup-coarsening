# Push r larger to confirm slope -> 1 (rule out genuine super-linearity).
# Use the exact Gaussian reduction (fast) AND the median-chi2 correction to show
# the apparent slope>1 at small r is exactly the median(chi2_r)/r factor.
source("/home/spinoza/github/papers/weaksup-coarsening/scripts/sim.R")
set.seed(99)
make_sim <- function(n,K,gap,n_anchor=6,dep=0.5){m<-2*K+n_anchor;acc<-rep(0.5+gap/2,m);
  dp<-if(K>0)lapply(seq_len(K),function(t)c(2*t-1,2*t))else list();
  list(sim=sim_ws(n,0.5,rep(0.8,m),acc,dep_pairs=dp,dep_strength=dep),m=m,K=K,a=2*acc-1)}
gold_deg_error<-function(obj,n_g){s<-obj$sim;idx<-sample.int(nrow(s$L),n_g);
  Lg<-s$L[idx,,drop=FALSE];Yg<-s$Y[idx];m<-obj$m;
  ah<-sapply(seq_len(m),function(j){x<-(Lg[,j]==Yg);if(all(is.na(x)))return(NA);2*mean(x,na.rm=TRUE)-1});
  ah[is.na(ah)]<-obj$a[is.na(ah)];errs<-numeric(obj$K);
  for(t in seq_len(obj$K)){j<-2*t-1;k<-2*t;u<-c(1,1)/sqrt(2);
    errs[t]<-sum(u*c(ah[j]-obj$a[j],ah[k]-obj$a[k]))};sqrt(sum(errs^2))}
smallest_ng<-function(grid,nrep,obj,thr){for(ng in grid){v<-replicate(nrep,gold_deg_error(obj,ng));if(median(v)<=thr)return(ng)};NA}
ng_grid<-unique(round(exp(seq(log(2),log(8e4),length.out=80))));nrep<-61;gap0<-0.20
K_grid<-c(2,4,8,16,24,32)
res<-data.frame(r=K_grid,ng=NA_real_)
for(i in seq_along(K_grid)){obj<-make_sim(50000,K_grid[i],gap0);res$ng[i]<-smallest_ng(ng_grid,nrep,obj,1.0*gap0);
  cat(sprintf("  r=%2d ng=%6.0f ng/r=%.2f\n",K_grid[i],res$ng[i],res$ng[i]/K_grid[i]))}
cat(sprintf("full-range slope=%.3f ; r>=8 slope=%.3f\n",
  coef(lm(log(ng)~log(r),res))[2], coef(lm(log(ng)~log(r),res[res$r>=8,]))[2]))
# correction-factor demonstration: predicted ng = v*median(chi2_r)/gap^2
v<-1-gap0^2; pred<-v*qchisq(0.5,K_grid)/gap0^2
cat("predicted (v*med chi2_r/gap^2):", paste(sprintf("%.0f",pred),collapse=" "),"\n")
cat("ratio observed/predicted:", paste(sprintf("%.2f",res$ng/pred),collapse=" "),"\n")
