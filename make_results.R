# ctrl+f: ROUND ONE

pth <- commandArgs(trailingOnly = TRUE)
#pth <- "/mnt/DATAPART1/Sasi"


### READ IN AND PREPROCESS DATA
file_list_coloc <- list.files(paste0(pth, "/colocalisation"), pattern=".tsv")
file_list_count <- list.files(paste0(pth, "/count"), pattern=".tsv") 
file_list_measure_lsm <- list.files(paste0(pth, "/input"), pattern=".tsv")
file_list_in_nuclei <- list.files(paste0(pth, "/in_nuclei"), pattern=".tsv")


# measure RGB channels on converted .lsm images
measure_lsm_data <- matrix(NA)
for( file in file_list_measure_lsm) {
  Label <- c(gsub(".lsm_measure_lsm.tsv", "", as.character(file)))
  new <- cbind(read.csv(paste0(pth, "/input/", file), header=T, sep="\t"), Label)
  measure_lsm_data <- merge(measure_lsm_data, new, all=T)
}

measure_lsm_data <- measure_lsm_data[,-6]
measure_lsm_data$parameter <- as.character(measure_lsm_data$parameter)

measure_lsm <- matrix(NA)
for( i in unique(measure_lsm_data$parameter)) {
  new <- measure_lsm_data[measure_lsm_data$parameter == i,]
  new <- new[,-1]
  names(new) <- c(paste0("red_", i), paste0("green_", i), paste0("blue_", i), "Label") #blue = yellow
  measure_lsm <- merge(measure_lsm, new)
}
measure_lsm <- measure_lsm[,-2]

# colocalisation data; only measure yellow, which is blue. Put 0's where no measurement available
coloc_data <- matrix(NA)
for(file in file_list_coloc) {
  Label <- c(gsub("C1-", "", gsub(".tif_coloc.tsv", "", as.character(file))))
  new <- cbind(read.csv(paste0(pth, "/colocalisation/", file), header=T, sep="\t"), Label)
  coloc_data <- merge(coloc_data, new, all=T)
}

coloc_data <- coloc_data[,-6]
coloc_data$parameter <- as.character(coloc_data$parameter)

coloc <- matrix(NA)
for( i in unique(coloc_data$parameter)) {
  new <- coloc_data[coloc_data$parameter == i,]
  new <- new[,-1]
  names(new) <- c(paste0("red_", i), paste0("green_", i), paste0("blue_", i), "Label") #blue = yellow
  coloc <- merge(coloc, new)
}
coloc <- coloc[,c(1,5,8,11)]
names(coloc)[1] <- "Label"

# 
count_data <- matrix(NA, 0, 13)
for ( file in file_list_count) {
  new <-read.csv(paste0(pth, "/count/", file), header=T, sep="\t")
  count_data <- rbind(count_data, new)
}

count <- count_data[count_data$Area > 99,]
count <- as.data.frame(xtabs(~Label, count))
count$Label <- unlist(lapply(as.character(count$Label), function(x) { gsub(".tif", "", gsub("C3-", "", x))} ))


# green in nuclei
if (!is.na(file_list_in_nuclei[1])) {
  print("Green in nuclei data detected, adding...")
  in_nuclei_data <- matrix(NA)
  for (file in file_list_in_nuclei) {
    Label <- c(gsub("C3-", "", gsub(".tif_in_nuc.tsv", "", as.character(file))))
    new <- cbind(read.csv(paste0(pth, "/in_nuclei/", file), header=T, sep="\t"), Label)
    in_nuclei_data <- merge(in_nuclei_data, new, all=T)
  }

  in_nuclei <- matrix(NA)
  for( i in unique(in_nuclei_data$parameter)) {
    new <- in_nuclei_data[in_nuclei_data$parameter == i,]
    new <- new[,-1]
    names(new) <- c(paste0("red_", i), paste0("green_", i), paste0("blue_", i), "Label") #blue = yellow
    in_nuclei <- merge(in_nuclei, new)
  }
  in_nuclei <- in_nuclei[,c(1,6,9,12)]
  names(in_nuclei) <- c("file", "green_in_nuclei_area_fraction", "green_in_nuclei_mean", "green_in_nuclei_stdev")
  
} else {
  print("No green in nuclei data detected.")
}

### MERGE TABLES
res <- merge(measure_lsm, count, all=T)
res <- merge(res, coloc, by="Label", all=T)

names(res) <- c("file", "red_area_fraction", "green_area_fraction", "blue_area_fraction", "red_mean", "green_mean", "blue_mean", "red_stdev","green_stdev",
                "blue_stdev", "cell_count", "yellow_area_fraction", "yellow_mean", "yellow_stdev")


res$red_mean_per_cell <- round(res$red_mean / res$cell_count, 5)
res$green_mean_per_cell <- round(res$green_mean / res$cell_count, 5)
res$yellow_mean_per_cell <- round(res$yellow_mean / res$cell_count, 5)



### LABELS: LYSO
meta <- cbind(t(as.data.frame(strsplit(as.character(res$file), "_"))), as.data.frame(res$file))
meta <- meta[, -(1:5)] 
names(meta) <- c("date", "cell_line", "treatment", "image", "file")

# ### LABELS: mitochondria:
# meta <- cbind(t(as.data.frame(strsplit(as.character(res$file), "_"))), as.data.frame(res$file))
# meta <- meta[, -(1:5)] 
# names(meta) <- c("date", "cell_line", "image", "file")

res <- merge(meta,res)

levels(res$cell_line)[levels(res$cell_line)=="231"] <- "MDAMB231"
res$cell_line <- droplevels(res$cell_line)

### rearrange
#LYSO
res <- res[,c(1:5,15,6:14,16:21)]

#MITO
#res <- res[,c(1,2,3,4,14,5:13,15:20)]


### add green in nuclei,if exists
if (!is.na(file_list_in_nuclei[1])) {
  res <- merge(res, in_nuclei, all.x=T)
  }

res$file <- gsub("_", "/", res$file)

### SUMMARY
agg1 <- aggregate(res, by=list(res$cell_line, res$treatment, res$date), FUN=mean, na.rm=T)
agg2 <- aggregate(res, by=list(res$cell_line, res$treatment), FUN=mean, na.rm=T)

### SAVE AWAY
system("mkdir output")
write.csv(res, "output/measurements.csv", row.names=F)
write.csv(agg1, "output/summary1.csv", row.names=F)
write.csv(agg2, "output/summary2.csv", row.names=F)

print(paste0("Saved to: ", pth, "/output"))
