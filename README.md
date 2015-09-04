## confocal-image-analysis

This readme is extremely informative. The script takes .lsm confocal microscopy images as an input. It allows for the quantification of dyes and of the colocalised region of two of them. Also counts the cells and returns the mean per cell value for the dye intesity.

# Files
"exploratory.R" is a mess. Not pipeline... able.

# Output
The output file is a .csv matrix:

 variable | description 
 --- | ---| ---
 file | name of the .lsm file from the 'input' folder 
 date | date when data was recorded, i.e. when the picure was taken 
 cell_line | cell line 
 treatment | whether Control, Zinc treated or Zna/Zinc treated 
 image | name of original image 
 green_area_fraction | fraction of image area that shows any green (Fluozin showing free intracellular zinc) 
 yellow_area_fraction | fraction of image area that shows any yellow (region where green colocalises with red stain, which is a lysotracker) 
 green_mean | mean intensity of green on image 
 yellow_mean | mean intensity of the colocalisation region 
 green_stdev | intensity standard deviation of the green region 
 yellow_stdev | intensity standard deviation of the yellow region 
 cell_count | number of cells on image 
 green_mean_per_cell | mean intensity of green divided by the number of cells 
 yellow_mean_per_cell | mean intensity of colocalisation region divided by the number of cells 