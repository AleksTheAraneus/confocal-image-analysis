// meaure RGB on an .lsm image or tif

args = getArgument();
processFile(args);

function processFile(file) {
	open(file);
	
	run("Make Composite");
	run("RGB Color");
	run("RGB Measure Plus", "red_threshold_min=1 red_threshold_max=255 green_threshold_min=1 green_threshold_max=255 blue_threshold_min=1 blue_threshold_max=255");
	saveAs("Results", file+"_measure_tif.tsv");
}
run("Quit");


