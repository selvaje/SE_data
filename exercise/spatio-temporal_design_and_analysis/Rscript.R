#
# empty workspace (OPTIONAL!)
#
rm(list=ls())
##############################################
# Reading and plotting geostatistical data
#############################################
library(PrevMap); library(splancs)
data<-read.csv("galicia.csv",header=TRUE)
names(data)
# file contains data on lead conentrations in
# moss samples from two surveys, conducted 
# three years apart 
table(data$survey)
# extract data-locations and lead concentrations
# from year 2000 survey
lead2000<-data[which(data$survey==2000),1:3]
# map the data
point.map(lead2000,var.name=~lead,coords=~x+y)
# map the data again, with some optional arguments
# (the map will look nicer if you use the "zoom" facility)
point.map(lead2000,var.name=~lead,coords=~x+y,
          pt.div="quintiles",cex.min=0.5,cex.max=1)
bound<-read.csv("galicia_bndrs.csv",header=TRUE)
lines(bound)
###############################################
#Exploring spatial correlation: the variogram
###############################################
vario1<-variogram(lead2000,var.name=~lead,coords=~x+y)
plot(vario1)
?variogram
names(vario1)
vario1$u
# I prefer to choose my own distance bins
u<-5000*(1:20) 
vario2<-variogram(lead2000,var.name=~lead,coords=~x+y,
                  uvec=u)
plot(vario2$u,vario2$v,type="l",xlim=c(0,100000),
     xlab="u",ylab="V(u)") 
# if you choose narrow bins, the result can look noisy,
# so I'll try again with wider bins
u<-10000*(1:10)
vario3<-variogram(lead2000,var.name=~lead,coords=~x+y,
                  uvec=u)
plot(vario3$u,vario3$v,type="l",xlim=c(0,100000),
     ylim=c(0.5,max(vario3$v)),xlab="u",ylab="V(u)")
####################################################
# a (weak) diagnostic test for spatial correlation
####################################################
spat.corr.diagnostic(lead~1,coords=~x+y,data=lead2000,
                     likelihood="Gaussian",uvec=u)
# try a log-transformation...often a good idea
# for positive-real-valued data
lead2000$loglead<-log(lead2000$lead)
# plot two diagrams per screen
par(mfrow=c(1,2))
# histograms before and after log-transformation
# of lead concentration
hist(lead2000$lead); hist(lead2000$loglead)
# histogram looks more symmetric for the log-transformed
# data...not essential, but usually leads to better
# statistical behaviour
#
# revert to one diagram per screen
par(mfrow=c(1,1))
spat.corr.diagnostic(loglead~1,coords=~x+y,
                           data=lead2000,
                           likelihood="Gaussian",uvec=u)
# evidence for spatial correlaiton is now strong
#######################################################
# Parameter estimation for the linear Gaussian model
######################################################
vario4<-variogram(lead2000,var.name=~loglead,
                  coords=~x+y,uvec=u)
plot(vario4$u,vario4$v,pch=19,xlim=c(0,100000),
     ylim=c(0,0.25))
# I use the variogram to choose initial values for
# numerical optimisation of the likelihood function
# (the statistically efficient method of estmating
# model parameters)
fit.MLE <- linear.model.MLE(loglead~1,coords=~x+y,
                            start.cov.pars = c(15000,0.1),
                            data=lead2000,kappa=0.5)
# setting the myterious parameter kappa=0.5
# specifies an exponentially decaying spatial
# correlation
summary(fit.MLE)
# parameter beta is the overall mean of log-transformed
# lead concentration
# notice that the remaining parameters are returned on
# the log-scale, fot technical reasons that are NOT
# connected to the use of a log-transformation of the
# lead concentrations
fit.MLE$estimate
# notice that nu^2 = exp(-8.86) = 0 (approximately),
# so we could ignore it, but I'll keep it in the
# model for illustration
#
theta<-exp(fit.MLE$estimate[2:4])
u<-1000*(0:100)
v<-theta[1]*(theta[3]+1-exp(-u/theta[2]))
lines(u,v,col="red")
diagnostic<-variog.diagnostic.lm(fit.MLE)
# model fits data well...but remember it's not a very
# powerful test (note the width of the confidence region
# in the left-hand panel)
#################################################
# geostatistical prediction
##################################################
# R functions can sometimes be fussy about whether their
# arguments are matrices or data-frames
galicia.grid <- gridpts(as.matrix(bound),xs=5000,ys=5000)
pred.MLE <- spatial.pred.linear.MLE(fit.MLE,
                  grid.pred = galicia.grid,
                  type="joint",
                  n.sim.prev = 1000,
                  standard.errors = TRUE)
# put predictions back onto the unlogged scale
lead.samples <- exp(pred.MLE$samples)
# calculate mean of predictions at each location
lead.estim <- apply(lead.samples,1,mean)
range(lead.estim)
range(lead2000$lead)
# because predictions are smoothed versions of the data,
# their ranges are often narrower
#
# in general, we make inferences by drawing samples
# from the predictive distribution of the underlying
# spatial surface
pred.MLE$samples<-lead.samples
# I fttd the model to log-transformed lead concentrations,
# but I want to map the results as lead concentrations
pred.MLE$prevalence$predictions <- lead.estim
plot(pred.MLE,type="prevalence")
# 
# predictions are for untransformed lead-concentrations,
# the reference to "prevalence" is a consequence of the
# package having been designed with prevalence data in
# mind as its primary area of application
#
# if you want to predict particular properties of the
# lead-concentration surface, you need to post-process
# the samples from its predictive distribution
#
# for example, what cane we say about the maximum
# value of lead concentraton across the whole of Galicia?
predict.max<-NULL
for (sim in 1:1000) {
  predict.max<-c(predict.max,max(pred.MLE$samples[,sim]))
}
hist(predict.max,main="predicted maximum")
# notice how the predictive distribution extends 
# beyond the range of the data (as it must, if you
# think about it)
###################################################
# Another example: analysis of data on onchocerciasis 
# (river blindness) prevalence in Liberia
####################################################
#
# I use these packages for reading shape-files,
# you probably have your own preferred way of
# working with shape-files
library(rgdal); library(maptools); library(fields)
library(sf); library(dplyr)
Africa<-readOGR(dsn="Africa","africa")
data<-read.csv("LiberiaRemoData.csv")
names(data)
# for exploratory analysis of prevalence data, it's
# usually a good idea to work with so-called "empirical
# logits"
data$el<-log((data$npos+0.5)/(data$ntest-data$npos+0.5))
point.map(data,var.name=~el,coords=~long+lat)
point.map(data,var.name=~el,coords=~long+lat,
          pt.div="quintiles",cex.min=0.6,cex.max=1.2)
plot(Africa,add=TRUE)
# you can use the variogram function to calculate
# the variogram of the data after removing a linear
# (or quadratic if you prefer) trend-surface
vario.el<-variogram(data,var.name=~el,
          coords=~long+lat,trend="1st")
plot(vario.el$u,vario.el$v,type="l",lwd=2,ylim=c(0,0.6),
     xlab="u (degrees)",ylab="V(u)")
response<-cbind(data$npos,data$ntest-data$npos)
# first fit classical logistic regression model,
# ignoring spatial correlation, to get initial
# estimates of linear trend surface
fit.glm<-glm(response~long+lat,
             data=data,family=binomial)
summary(fit.glm)
beta<-fit.glm$coef
# I usually just guess initial values for the covariance 
# parameters by visual inspection of the variogram
sigmasq<-0.3; phi<-0.7;tausq<-0.1
# now you can set up the Monte Carlo maximum likleihood 
# estimation of the model parameters
par0<-c(beta,sigmasq,phi,tausq)
# the next line controls the details of the Markov chain
# Monte Carlo algorithm...you have to tune this yourself
# until you are happy with the result
#
mcmc<-control.mcmc.MCML(n.sim=20000,burnin=10000,thin=10,
                        h=1.65/(nrow(data)**(1/6)))
# the next line may take some time to run
fit.bl<-binomial.logistic.MCML(npos~long+lat,
          units.m=~ntest,coords=~long+lat,
          data=data,par0=par0,control.mcmc=mcmc,
          kappa=0.5,
          start.cov.pars=c(par0[5],par0[6]/par0[4]))
names(fit.bl)
fit.bl$log.lik # you want this value to be close to zero,
               # I usually settle for it being less than 1
               # (it can never be negative)
# to get a better result, I'll run the fitting algorithm
# again from new starting values. 
fit.bl$estimate
# I'll also set tausq to zero, since its estimate
# is approximately zero, suggesting that I don't
# need it in the model
beta<-fit.bl$estimate[1:3]
sigmasq<-exp(fit.bl$estimate[4])
phi<-exp(fit.bl$estimate[5])
par0<-c(beta,sigmasq,phi)
fit.bl<-binomial.logistic.MCML(npos~long+lat,
            units.m=~ntest,coords=~long+lat,
            data=data,par0=par0,control.mcmc=mcmc,kappa=0.5,
            fixed.rel.nugget=0, # this fixes tausq=0
            start.cov.pars=par0[4])
fit.bl$log.lik # now I'm happy
# the following command creates a two-column array
# with (transformed) parameter estimates in the first
# column and their standard errors in the second column
MLE<-cbind(fit.bl$estimate,sqrt(diag(fit.bl$covariance)))
#
# now I'll just extract the untransformed 
# covariance parameter estimates
sigmasq<-exp(MLE[4,1]); phi<-exp(MLE[5,1])
point.estimates<-c(sigmasq,phi)
names(point.estimates)<-c("sigmasq","phi")
round(point.estimates,4)
################################################
# prediction of the prevalence throughout Liberia
###################################################
# the following command reads an approximate boundary
# for Liberia ... you can probablydo a better job 
# using shape-files
Liberia.poly<-read.csv("Liberia_boundary.csv")
grid<-gridpts(as.matrix(Liberia.poly),xs=0.1,ys=0.1)
grid.predict<-as.data.frame(pip(grid,Liberia.poly))
# the spatial prediction function in PrevMap requires
# the prediction locations ot have the same names as
# the original data-locations...in this case 
# "long" and "lat"
names(grid.predict)<-c("long","lat")
predict.MCML<-spatial.pred.binomial.MCML(fit.bl,
                  grid.pred=grid.predict,predictors=grid.predict,
                  control.mcmc=mcmc,scale.predictions="prevalence",
                  standard.errors=TRUE,thresholds=0.2,type="joint",
                  scale.thresholds="prevalence")
#
# I'm going to send my predictive map to a .jpg file 
# rather than to the screen
jpeg("Liberia_results.jpg",height=500,width=1000)
plot(predict.MCML,type="prevalence")
point.map(data,var.name=~el,coords=~long+lat,add=TRUE,
          pt.div="quintiles",cex.min=0.7,cex.max=1.4)
plot(Africa,add=TRUE)
dev.off()
###################################################

