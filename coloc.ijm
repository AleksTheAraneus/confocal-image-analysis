// macro takes in channel 1 and 2 and returns image of colocalised stain and mesurement of total colocalised area per as many pixels / um

args = getArgument();

processFile(args);

function processFile(args) {
	file1 = args;
	file2 = replace(args, "C2-", "C1-");
	print(file1);
	print(file2);

	open(file1);
	open(file2);

	run("Colocalization Threshold", "channel_1=file1 channel_2=file2 use=None channel=[Red : Green] show include");
	selectWindow("Results");
	close();
	selectWindow("Colocalized Pixel Map RGB Image");
	run("RGB Measure Plus", "red_threshold_min=1 red_threshold_max=255 green_threshold_min=1 green_threshold_max=255 blue_threshold_min=1 blue_threshold_max=255");
	
	//new_path=replace(file1, "input", "colocalisation");
    new_path=file1;
    print(new_path)
	run("Save", "save=new_path");
	saveAs("Results", replace(new_path, ".tif", "_coloc.tsv"));
	

}
run("Quit");

