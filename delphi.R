#!/usr/bin/env Rscript
# call this script with full path: 
#Rscript --no-save --no-restore --verbose ~/Copy/projects/delphi/z/code/delphi/delphi.R > out.txt 2>&1

rm(list=ls())
library(nls2)
library(nlstools)
library(ggplot2)

initial.options <- commandArgs(trailingOnly = FALSE)
file.arg.name <- "--file="
script_file <- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
base_dir <- dirname(script_file)
delphi_func <- paste0(base_dir, "/delphi_functions.R")
print(script_file)
print(delphi_func)

##############################
source(delphi_func)
container_id <- tail(strsplit(getwd(),split='/')[[1]],n=1)  
vid_list=read.csv('vid_list.csv',header=T,stringsAsFactors=T)
vid_list_detail=read.csv('vid_list_detail.csv',header=T,stringsAsFactors=T)
dat=read.csv('data.csv',header=T,stringsAsFactors=T)
dat <- subset(dat, dat$sum>0)
dat["dd"] <- NA
dat$dd <- as.Date(dat$date_d)
#df<-dat
#summary(dat)
mod <<- NA
val_bau <- vector()
val_avg <- vector()
val_id <- vector()
avg_sum <- 0
bau_sum <- 0
bau_df <<- lm_denom(dat)
avg_df <<- avg_denom(dat)
max_y <<- vector()
max_normal <<- 1.6
cut_off <<- 10 #used to be 25 for korean shows, set to a reasonable number

for (i in 1:nrow(vid_list)){
	this_id = vid_list$id[i]
	this_detail = vid_list_detail[i,]
	print(paste('detail: ',this_detail))
	val_id <- c(val_id,as.character(this_id))
	this<-subset(dat,video_id==as.character(this_id))
	this_firstday=subset(this,this$sum>cut_off) 
	firstday = min(this_firstday$dd)
	print(paste('min date: ',firstday))
	print(paste('index 1: ',this$dd[1]))
	print(paste('vid starts: ',this$sum[1]))
	#stop('end')
	#readline()
	more_months=T
	thismonth = firstday
	if (nrow(this)>0){ # video_id must have at least 1 row of data
		count = 1
		pred <- data.frame(mo=integer(36), vs=integer(36), denom=integer(36), normal=numeric(36))
		while (more_months){
			if(max(this$dd) < thismonth+30){ 
				more_months=F
				print('exiting')
			} else {
				temp = subset(this,(dd>=thismonth & dd<thismonth+30))
				pred$mo[count] <- count
				pred$vs[count] <- sum(temp$sum)
				pred$denom[count] <- sum(temp$denom)
				pred$normal[count] <- 1.0 * pred$vs[count] / pred$denom[count] 
				thismonth = thismonth+30
				print(thismonth)
				count = count + 1
			}
		}
		max_y <- c(max_y, max(pred$normal)*100)
		model_this <- subset(pred,mo>0)
		#if (nrow(model_this)>0){ # video_id must have at least 1 row of data
print(model_this)
print(this_id)
			prediction <- model_video(model_this,this_id,this_detail,max_normal)
			pred_avg <- prediction
			pred_bau <- prediction
			for (i in count:36){
				temp = subset(avg_df,(dd>=thismonth & dd<thismonth+30))
				pred_avg$denom[i] <- sum(temp$denom)
				temp = subset(bau_df,(dd>=thismonth & dd<thismonth+30))
				pred_bau$denom[i] <- sum(temp$denom)
			}
			for (i in which(prediction$vs==0)){
				pred_avg$vs[i] <- 1.0 * pred_avg$denom[i] * pred_avg$normal[i]
				pred_bau$vs[i] <- 1.0 * pred_bau$denom[i] * pred_bau$normal[i]
			}
			avg_sum <- sum(pred_avg$vs)
			bau_sum <- sum(pred_bau$vs)
			val_bau <- c(val_bau,bau_sum)
			val_avg <- c(val_avg,avg_sum)
		#} else { 
		#	nodata=T 
		#	print('######################################################')
		#	val_bau <- c(val_bau,0)
		#	val_avg <- c(val_avg,0)
		#}
	} else { print('=====================================================') }
}
#final_bau = sum(val_bau)
#final_avg = sum(val_avg)
### fix NAs hopefully
print(val_avg)
val_bau[is.na(val_bau)] <- mean(val_bau,na.rm=TRUE)
val_avg[is.na(val_avg)]<- mean(val_avg,na.rm=TRUE)
print(val_avg)
final_bau = sum(val_bau)
final_avg = sum(val_avg)
###
print(max(max_y))
print(paste0('BAU = ',format(final_bau, big.mark=',')))
print(paste0('AVG = ',format(final_avg, big.mark=',')))
final <- data.frame(id=val_id,bau=val_bau,avg=val_avg)

sink(paste0(getwd(),'/',container_id,'.txt'))
print(max(max_y))
print(paste0('max_y = ',max(max_y)))
print(paste0('BAU = ',format(final_bau, big.mark=',')))
print(paste0('AVG = ',format(final_avg, big.mark=',')))
sink()

this_entry <- paste(container_id,min(dat$dd),this_detail$origin_language,max(vid_list_detail$number),round(final_bau),round(final_avg),sep=',')
final_csv <- file(paste0(getwd(),"/projections.csv"), "a")
writeLines(this_entry,con=final_csv,sep='\n')
close(final_csv)

#again <- file(paste0(getwd(),'/projections_',container_id,'.csv'),open="a")
outer_dir <- paste(strsplit(getwd(),'/')[[1]][1:7],collapse='/')
again <- file(paste0(outer_dir,'/projections_',container_id,'.csv'),open="a")
print(outer_dir)
print(again)
writeLines(this_entry,con=again,sep='\n')
close(again)
