// macro takes in channel 3 (nuclei; converted to binary mask) and returns image of colocalised stain between channel 3 and channel 2 and mesurement of total colocalised area per as many pixels / um

args = getArgument();
processFile(args);

function processFile(args) {
	file1 = args;
	file2 = replace(args, "C3-", "C2-");

	open(file1);
	// make nuclei mask
	//run("Multiply...", "value=99.000");
	run("Make Binary");
	run("Dilate");
	run("Close-");
	run("Fill Holes");
	run("Remove Outliers...", "radius=20 threshold=50 which=Dark");
	
	
	open(file2);
  run("Colocalization Threshold", "channel_1=file1 channel_2=file2 use=None channel=[Red : Green] show include");

	selectWindow("Results");
	close();
	selectWindow("Colocalized Pixel Map RGB Image");
	run("RGB Measure Plus", "red_threshold_min=1 red_threshold_max=255 green_threshold_min=1 green_threshold_max=255 blue_threshold_min=1 blue_threshold_max=255");
	
	run("Split Channels");
	selectWindow("Colocalized Pixel Map RGB Image (blue)");
	run("Save", "save=file1");
	saveAs("Results", file1+"_in_nuc.tsv");
	
}
run("Quit");
