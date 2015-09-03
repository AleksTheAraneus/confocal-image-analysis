pth <- getwd()
#pth <- "/mnt/DATAPART1/Sasi"
setwd(pth)

### TOYS
library(ggplot2)
library(Hmisc)
#se <- function(x) sqrt(var(x)/length(x))

###
data <- read.csv(paste0(pth, "/output/measurements.csv"), row.names = NULL)

title <- function(x) {
  res <- NULL
  for (i in 1:length(x)) {
    res <- paste(res, x[i], sep="_")
  }
  res
}

### SUMMARY
#agg1 <- aggregate(data, by=list(data$cell_line, data$treatment, data$date), FUN=mean)
#agg2 <- aggregate(data, by=list(data$cell_line, data$treatment), FUN=mean)

data1 <- data[data$date=="8515",]
data2 <- data[data$date=="81015",]
data3 <- data[data$date=="81515",]

### PLOTS

#plot each cell line facets, each treatment x and yellow mena per cell y 
p1.1 <- ggplot(data_in, aes(treatment, yellow_mean_per_cell)) + 
  geom_bar(stat="identity") +
  facet_wrap(~cell_line) +
  labs(title=title(unique(data_in$date)))

p1.2 <- ggplot(data_in, aes(treatment, green_mean_per_cell)) + 
  geom_bar(stat="identity") +
  facet_wrap(~cell_line) +
  labs(title=title(unique(data_in$date)))



#plot each treatment facets and each cell line x and yellow_mean_per_cell y
p2.1 <- ggplot(data_in, aes(cell_line, yellow_mean_per_cell)) +
  geom_bar(stat="identity") +
  facet_wrap(~treatment) + 
  labs(title=title(unique(data_in$date))) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

p2.2 <- ggplot(data_in, aes(cell_line, green_mean_per_cell)) +
  geom_bar(stat="identity") +
  facet_wrap(~treatment) +
  labs(title=title(unique(data_in$date))) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


# plot area fraction just for all

#p1.3 <- ggplot(data, aes(treatment, yellow_area_fraction_per_cell)) + 
#  geom_bar(stat="identity") +
#  facet_wrap(~cell_line)


## SAVE AWAY
#system("mkdir plots")
#setwd(paste0(pth, '/plots'))
#plots <- list(p1.1, p1.2, p2.1, p2.2) #ls() 

graphics.off()

png(paste0(title(unique(data_in$date)), "_1.png"))
p1.1
dev.off()
png(paste0(title(unique(data_in$date)), "_2.png"))
p1.2
dev.off()
png(paste0(title(unique(data_in$date)), "_3.png"))
p2.1
dev.off()
png(paste0(title(unique(data_in$date)), "_4.png"))
p2.2
dev.off()

# 
# i=0
# for (plt in ls()) {
#   png(paste0(i, ".png"))
#   plt
#   dev.off()
#   i=i+1
# }


### SMIETNICZEK

# data$ympl_sd <- c(NA)
# data$gmpl_sd <- c(NA)
# 
# for (line in levels(data$cell_line)) {
#     for (trt in levels(data$treatment)) {
#     y_sd <- sd(data$yellow_mean_per_cell[(data$cell_line==line & data$treatment==trt)])
#     g_sd <- sd(data$green_mean_per_cell[(data$cell_line==line & data$treatment==trt)]) 
#     data[(data$cell_line==line & data$treatment==trt),]$ympl_sd <- c(y_sd)
#     data[(data$cell_line==line & data$treatment==trt),]$gmpl_sd <- c(g_sd)
#   }
# }
# 

# 
# ## PLOTS
# for (line in agg1$Group.1) {
#   dat <- agg2[agg2$Group.1==line,]
#   
#   p1.1 <- ggplot(dat, aes(Group.2, yellow_mean_per_cell)) +
#     geom_bar(stat="identity") +
#     geom_errorbar(aes(ymax=yellow_mean_per_cell+ympl_sd, ymin=yellow_mean_per_cell-ympl_sd), colour="black", width=.1, position="dodge") +
#     labs(title)
# }
# 
# p1.1 <- ggplot(agg2, aes(Group.2, yellow_mean_per_cell)) +
#   geom_bar(stat="identity") +
#   facet_wrap(~Group.1) +
#   geom_errorbar(aes(ymax=yellow_mean_per_cell+ympl_sd, ymin=yellow_mean_per_cell-ympl_sd), colour="black", width=.1, position="dodge") +
#   labs(title)
# 

