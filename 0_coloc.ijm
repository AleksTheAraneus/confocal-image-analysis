// macro takes in channel 1 and 2 and returns image of colocalised stain and mesurement of total colocalised area per as many pixels / um

args = getArgument();

processFile(args);

function processFile(args) {
	file1 = substring(args, 0, lastIndexOf(args, "/__SEPARATOR__/"));
	file2 = substring(args, lastIndexOf(args, "/__SEPARATOR__/")+15);

	open(file1);
	open(file2);

	// only colocalised
	run("Colocalization Threshold", "channel_1=file1 channel_2=file2 use=None channel=[Red : Green] show use");
	setThreshold(255, 255);
	run("Convert to Mask");
	run("Make Binary");	

	// measure
	run("Save", "save=file_path");
	run("Measure");
	saveAs("Results"+file1, input+"colocalisation.tsv");
}
