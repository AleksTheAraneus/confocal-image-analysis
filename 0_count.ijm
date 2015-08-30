// macro takes in stained nuclei .tif file from directory and returns number of cells (nuclei); also saves processed image to specified directory

input = getArgument();
output = input;
suffix = ".tif";

processFolder(input);

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + list[i]))
			processFolder("" + input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	open(input+file);
	
	run("Multiply...", "value=99.000");
	run("Make Binary");
	run("Dilate");
	run("Dilate");
	run("Close-");
	run("Fill Holes");

	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	run("Despeckle");
	
	run("Remove Outliers...", "radius=20 threshold=50 which=Dark");
	run("Watershed");

	run("Analyze Particles...", "size=50-Infinity show=Outlines display exclude add in_situ");
	run("Save", "save=file_path");
}

saveAs("Results", input+"count.tsv");
print("Saved to: " + output);
