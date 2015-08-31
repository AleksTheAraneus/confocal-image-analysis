pth <- commandArgs(trailingOnly = TRUE)

### READ IN AND PREPROCESS DATA
file_list_coloc <- list.files(paste0(pth, "/colocalisation"), pattern=".tsv")
file_count <- list.files(paste0(pth, "/count"), pattern=".tsv")[1]

coloc_data <- matrix(NA)
for(file in file_list_coloc) {
  Label <- c(gsub("C1-", "", gsub(".tif_coloc.tsv", "", as.character(file))))
  new <- cbind(read.csv(paste0(pth, "/colocalisation/", file), header=T, sep="\t"), Label)
  coloc_data <- merge(coloc_data, new, all=T)
}
coloc <- coloc_data[coloc_data$parameter == "area fraction",]

#
count_data <- read.csv(paste0(pth, "/count/", file_count), header=T, sep="\t")

count <- count_data[count_data$Area > 99,]
count <- as.data.frame(xtabs(~Label, count))
count$Label <- unlist(lapply(as.character(count$Label), function(x) { gsub(".tif", "", gsub("C3-", "", x))} ))

### MERGE TABLES
res <- merge(coloc, count)

res <- res[, c(1,3,4,5,7)]
names(res) <- c("image", "red", "green", "red_AND_green", "cell_count")

res$green_per_cell <- round(res$green / res$cell_count, 5)
res$red_AND_green_per_cell <- round(res$red_AND_green / res$cell_count, 5)


### STATISTICS
res$green_per_cell_norm <- scale(as.numeric(res$green_per_cell))
res$red_AND_green_per_cell <- scale(as.numeric(res$red_AND_green_per_cell))


### SAVE AWAY
system("mkdir output")
write.csv(res, "output/measurements.csv")

print(paste0("Saved to: ", pth, "output/measurements.csv"))