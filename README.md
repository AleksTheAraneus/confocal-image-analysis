## TODO
- rename "wrap.sh" - more informative name (confoc_metrics or ...)
- use command line arguments for each of the pepeline modules and make them comprehensible (AND add description)
- how to make it a whole? (Fiji problematic)

## confocal-image-analysis

The script takes .lsm confocal microscopy images as an input. It allows for the quantification of dyes and of the colocalised region of two of them. Also counts the cells and returns the mean per cell value for the dye intesity.
Run wrap.sh with the full path to the directory with ImageJ and the directory named "input"

# Use
Make sure the channels of your .lsm picture are in follwing order: 1 - red, 2 - green, 3 - blue.
Make sure there is a directory 'raw' in the dir passed as an arg to wrap
Please put all the pictures in the "raw" folder according to the scheme: "raw/date/staining/treatment/cell.line/treatment.or.control/image.name.lsm" ?

To use a certain step in pipeline, comment/uncomment wrap.sh lines near the end.
Can give it a -swap_channels option
Example:
./wrap.sh /mnt/DATAPART1/Sasi --swap-channels

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
