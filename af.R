
lm_denom <- function(df){ 
denom_df <- data.frame(dd=integer(2000), denom=integer(2000), counter=integer(2000))
max_num = as.numeric(max(df$dd) - min(df$dd))
for (i in 1:2000){
	if (i<=max_num){
		denom_df$dd[i] <- as.Date(min(df$dd) + i)
		denom_df$denom[i] <- max(dat$denom[dat$dd==denom_df$dd[i]])
		denom_df$counter[i] <- i
	}
}
mod <<- subset(denom_df, denom_df$counter>0)
mod <<- na.omit(mod)
#mod <<- subset(mod, mod$denom>(mean(mod$denom)-(3*sd(mod$denom))))
mod <<- subset(mod, mod$denom>500000)
xhat <- seq(1,max_num)
fit <- lm(denom~counter, data=mod)
yhat <- predict(fit,list(counter=xhat))
print(paste0(length(xhat),',',length(yhat)))
hat <- data.frame(x=xhat, y=yhat)
p <- ggplot(data=mod, aes(mod$counter,mod$denom)) + geom_point(color="red") + ylab("Total Daily Video Starts") + xlab('Days') + ggtitle('BAU Daily Video Starts')
p <- p + geom_line(data=hat, aes(x,y), color="blue", size=1.5, alpha=.5) 
print(p)
ggsave(filename = 'bau_dvs.jpg', plot = last_plot())
yhat <- predict(fit,list(counter=seq(1,2000)))
start_adding = max(denom_df$counter)+1
for (i in start_adding:2000){
	denom_df$dd[i] <- denom_df$dd[i-1]+1
	denom_df$denom[i] <- yhat[i]
	denom_df$counter[i] <- i 
}
return(denom_df)
}

################################################################

avg_denom <- function(df){ 
denom_df <- data.frame(dd=integer(2000), denom=integer(2000), counter=integer(2000))
max_num = as.numeric(max(df$dd) - min(df$dd))
for (i in 1:2000){
	if (i<=max_num){
		denom_df$dd[i] <- as.Date(min(df$dd) + i)
		denom_df$denom[i] <- max(dat$denom[dat$dd==denom_df$dd[i]])
		denom_df$counter[i] <- i
	}
}
mod <<- subset(denom_df, denom_df$counter>0)
mod <<- na.omit(mod)
mod <<- subset(mod, mod$denom>500000)
xhat <- seq(1,as.numeric(max_num))
yhat <- rep(mean(mod$denom),as.numeric(max_num))
print(paste0(length(xhat),',',length(yhat)))
hat <- data.frame(x=xhat, y=yhat)
p <- ggplot(data=mod, aes(mod$counter,mod$denom)) + geom_point(color="red") + ylab("Total Daily Video Starts") + xlab('Days') + ggtitle('AVG Daily Video Starts')
p <- p + geom_line(data=hat, aes(x,y), color="blue", size=1.5, alpha=.5) 
print(p)
ggsave(filename = 'avg_dvs.jpg', plot = last_plot())
start_adding = max(denom_df$counter)+1
for (i in start_adding:2000){
	denom_df$dd[i] <- denom_df$dd[i-1]+1
	denom_df$denom[i] <- mean(mod$denom)
	denom_df$counter[i] <- i 
}
return(denom_df)
}

##################################################################

model_video <- function(model_this,this_id,this_detail,max_normal){ 
mod = model_this
mod['x'] <- mod$mo - 1
mod['y'] <- mod$normal * 100
qplot(x,y,data=mod,size=10)
ggsave(filename = paste0(container_id,'.jpg'), plot = last_plot())
ratio_1_4 = 1.0 * mod$y[1] / mod$y[4]
#if (ratio_1_4 > 1){
#print('model type is exponential, see ratio of first to fourth month:')
#print(ratio_1_4)
xhat <- seq(0,35)
yhat <- rep(mean(mod$y),36)
	result <- try({
		print('trying exponential now...')
		f <- function(x,a,b,c) {a * exp(b * x) + c} 
		fit <- nls(y ~ f(x, a, b, c), mod, start = c(a = mod$y[1], b = -2.5, c=0.01))
	})
	if(class(result) == "try-error") {
		print('exponential model failed, reverting to long-term average')
	} else { yhat <- predict(fit,list(x=xhat)) }
hat <- data.frame(x=xhat, y=yhat)

#} else {
#	print('model type is linear, see ratio of first to fourth month:')
#	print(ratio_1_4)
#	xhat <- seq(0,35)
#	fit <- lm(y~x, data=mod)
#	yhat <- predict(fit,list(counter=xhat))
#	print(paste0(length(xhat),',',length(yhat)))
#	hat <- data.frame(x=xhat, y=yhat)
#}
print('mod')
print(mod)
print('hat')
print(hat)
#p <- ggplot(mod, aes(x,y)) + geom_point(color="red") + ylim(0,0.5) + ylab("Normalised Video Starts (x 100)") + xlab('Months') + ggtitle(paste0('Normalised Daily Video Starts: ',this_id))
p <- ggplot(data=hat, aes(x,y)) + geom_line(color="blue", size=1.5, alpha=.5) + ylim(0,max_normal) + ylab("Normalised Video Starts (x 100)") + xlab('Months') + ggtitle(this_detail$title_detailed)
p <- p + geom_point(data=mod, aes(x,y), color="red")
#p <- p + geom_line(data=hat, color="blue", size=1.5, alpha=.5)
print(p)
ggsave(filename = paste0(this_detail$number,'.jpg'), plot = last_plot())
start_adding = max(pred$mo)+1
for (i in start_adding:36){
	pred$mo[i] <- i
	pred$normal[i] <- yhat[i-1]/100
	print(pred)
}
return(pred)
}

