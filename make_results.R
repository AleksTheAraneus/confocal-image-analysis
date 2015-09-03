pth <- commandArgs(trailingOnly = TRUE)
#pth <- "/mnt/DATAPART1/Sasi"


### READ IN AND PREPROCESS DATA
file_list_coloc <- list.files(paste0(pth, "/colocalisation"), pattern=".tsv")
file_list_count <- list.files(paste0(pth, "/count"), pattern=".tsv") 

#
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
  names(new) <- c(paste0("red_", i), paste0("green_", i), paste0("blue_", i), "Label")
  coloc <- merge(coloc, new)
}
coloc <- coloc[,c(1,4,5,7,8,10,11)]

# 
count_data <- matrix(NA, 0, 13)
for ( file in file_list_count) {
  new <-read.csv(paste0(pth, "/count/", file), header=T, sep="\t")
  count_data <- rbind(count_data, new)
}

count <- count_data[count_data$Area > 99,]
count <- as.data.frame(xtabs(~Label, count))
count$Label <- unlist(lapply(as.character(count$Label), function(x) { gsub(".tif", "", gsub("C3-", "", x))} ))


### MERGE TABLES
res <- merge(coloc, count)

names(res) <- c("file", "green_area_fraction", "yellow_area_fraction", "green_mean", "yellow_mean", "green_stdev", "yellow_stdev", "cell_count")

res$green_mean_per_cell <- round(res$green_mean / res$cell_count, 5)
res$yellow_mean_per_cell <- round(res$yellow_mean / res$cell_count, 5)


### LABELS
meta <- cbind(t(as.data.frame(strsplit(as.character(res$file), "_"))), as.data.frame(res$file))
meta <- meta[, 6:10]
names(meta) <- c("date", "cell_line", "treatment", "image", "file")

res <- merge(res, meta)
res <- res[, c(1,11,12,13,14,2,3,4,5,6,7,8,9,10)]
res$file <- gsub("_", "/", res$file)

res$cell_line[res$cell_line=="231"] <- c("MDAMB231")
res$cell_line <- droplevels(res$cell_line)

### SAVE AWAY
system("mkdir output")
write.csv(res, "output/measurements.csv")

print(paste0("Saved to: ", pth, "/output/measurements.csv"))
