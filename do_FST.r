WC84<-function(x,pop){
  #number ind each population
  n<-table(pop)
  ###number of populations
  npop<-nrow(n)
  ###average sample size of each population
  n_avg<-mean(n)
  ###total number of samples
  N<-length(pop)
  ###frequency in samples
  p<-apply(x,2,function(x,pop){tapply(x,pop,mean)/2},pop=pop)
  ###average frequency in all samples (apply(x,2,mean)/2)
  p_avg<-as.vector(n%*%p/N )
  ###the sample variance of allele 1 over populations
  s2<-1/(npop-1)*(apply(p,1,function(x){((x-p_avg)^2)})%*%n)/n_avg
  ###average heterozygotes
  # h<-apply(x==1,2,function(x,pop)tapply(x,pop,mean),pop=pop)
  #average heterozygote frequency for allele 1
  # h_avg<-as.vector(n%*%h/N)
  #faster version than above:
  h_avg<-apply(x==1,2,sum)/N
  ###nc (see page 1360 in wier and cockerhamm, 1984)
  n_c<-1/(npop-1)*(N-sum(n^2)/N)
  ###variance betwen populations
  a <-n_avg/n_c*(s2-(p_avg*(1-p_avg)-(npop-1)*s2/npop-h_avg/4)/(n_avg-1))
  ###variance between individuals within populations
  b <- n_avg/(n_avg-1)*(p_avg*(1-p_avg)-(npop-1)*s2/npop-(2*n_avg-1)*h_avg/(4*n_avg))
  ###variance within individuals
  c <- h_avg/2
  ###inbreedning (F_it)
  F <- 1-c/(a+b+c)
  ###(F_st)
  theta <- a/(a+b+c)
  ###(F_is)
  f <- 1-c(b+c)
  ###weigted average of theta
  theta_w<-sum(a)/sum(a+b+c)
  list(F=F,theta=theta,f=f,theta_w=theta_w,a=a,b=b,c=c,total=c+b+a)
}

library(snpMatrix)
data <- read.plink("../admixture/prunedData")
geno <- matrix(as.integer(data@.Data),nrow=nrow(data@.Data))
geno <- t(geno)
geno[geno==0]<- NA
geno<-geno-1
g<-geno[complete.cases(geno),]
pop<-c(rep(1,7),rep(2,9),rep(3,1),rep(4,27))
### COMPARISONS in 4 
pop12<-pop[ifelse(pop==1,TRUE,ifelse(pop==2,TRUE,FALSE))]
pop13<-pop[ifelse(pop==1,TRUE,ifelse(pop==3,TRUE,FALSE))]
pop14<-pop[ifelse(pop==1,TRUE,ifelse(pop==4,TRUE,FALSE))]
pop23<-pop[ifelse(pop==2,TRUE,ifelse(pop==3,TRUE,FALSE))]
pop24<-pop[ifelse(pop==2,TRUE,ifelse(pop==4,TRUE,FALSE))]
pop34<-pop[ifelse(pop==3,TRUE,ifelse(pop==4,TRUE,FALSE))]
g12<-g[,ifelse(pop==1,TRUE,ifelse(pop==2,TRUE,FALSE))]
g13<-g[,ifelse(pop==1,TRUE,ifelse(pop==3,TRUE,FALSE))]
g14<-g[,ifelse(pop==1,TRUE,ifelse(pop==4,TRUE,FALSE))]
g23<-g[,ifelse(pop==2,TRUE,ifelse(pop==3,TRUE,FALSE))]
g24<-g[,ifelse(pop==2,TRUE,ifelse(pop==4,TRUE,FALSE))]
g34<-g[,ifelse(pop==3,TRUE,ifelse(pop==4,TRUE,FALSE))]
result12<-WC84(t(g12),pop12)
result13<-WC84(t(g13),pop13)
result14<-WC84(t(g14),pop14)
result23<-WC84(t(g23),pop23)
result24<-WC84(t(g24),pop24)
result34<-WC84(t(g34),pop34)

#esat vs west 
pop_ew<-c(rep(1,16),rep(2,28))
pop_evsw<-pop_ew[ifelse(pop_ew==1,TRUE,ifelse(pop_ew==2,TRUE,FALSE))]
g_evsw<-g[,ifelse(pop_ew==1,TRUE,ifelse(pop_ew==2,TRUE,FALSE))]
result_evsw<-WC84(t(g_evsw),pop_evsw)

FST <- data.frame(FST=c(mean(result12$theta,na.rm=T), mean(result13$theta,na.rm=T), mean(result14$theta,na.rm=T), 
                       mean(result23$theta,na.rm=T), mean(result24$theta,na.rm=T), mean(result34$theta,na.rm=T),
                        mean(result_evsw$theta,na.rm=T)), 
                 row.names = c('Gbb-Gbg', 'Gbb-Ggd', 'Gbb-Ggg', 'Gbg-Ggd', 'Gbg-Ggg', 'Ggd-Ggg',"East-West")
print(FST)
print('Done FST')


##test
a=a[!is.na(a)]
a[a>=0]                  
               
                  
                  
                  
#！！！###########no########################################################################
# 4 vs total
gg<-cbind(g,g)
pop_t<-c(rep(1,7),rep(2,9),rep(3,1),rep(4,27),rep(5,44))
pop15<-pop_t[ifelse(pop_t==1,TRUE,ifelse(pop_t==5,TRUE,FALSE))]
pop25<-pop_t[ifelse(pop_t==2,TRUE,ifelse(pop_t==5,TRUE,FALSE))]
pop35<-pop_t[ifelse(pop_t==3,TRUE,ifelse(pop_t==5,TRUE,FALSE))]
pop45<-pop_t[ifelse(pop_t==4,TRUE,ifelse(pop_t==5,TRUE,FALSE))]
g15<-gg[,ifelse(pop_t==1,TRUE,ifelse(pop_t==5,TRUE,FALSE))]
g25<-gg[,ifelse(pop_t==2,TRUE,ifelse(pop_t==5,TRUE,FALSE))]
g35<-gg[,ifelse(pop_t==3,TRUE,ifelse(pop_t==5,TRUE,FALSE))]
g45<-gg[,ifelse(pop_t==4,TRUE,ifelse(pop_t==5,TRUE,FALSE))]
result15<-WC84(t(g15),pop15)
result25<-WC84(t(g25),pop25)
result35<-WC84(t(g35),pop35)
result45<-WC84(t(g45),pop45)


FST <- data.frame(FST=c(mean(result12$theta,na.rm=T), mean(result13$theta,na.rm=T), mean(result14$theta,na.rm=T), 
                       mean(result23$theta,na.rm=T), mean(result24$theta,na.rm=T), mean(result34$theta,na.rm=T),
                        mean(result_evsw$theta,na.rm=T),mean(result15$theta,na.rm=T), mean(result25$theta,na.rm=T),
                        mean(result35$theta,na.rm=T), mean(result45$theta,na.rm=T)), 
                 row.names = c('Gbb-Gbg', 'Gbb-Ggd', 'Gbb-Ggg', 'Gbg-Ggd', 'Gbg-Ggg', 'Ggd-Ggg',"East-West",
                              "Gbb-total","Gbg-total","Ggd-total","Ggg-total"))
print(FST)
print('Done FST')
