// macro takes in stained nuclei .tif file from directory and returns number of cells (nuclei); also saves processed image to specified directory

args = getArgument();
//folder = substring(args, 0, lastIndexOf(args, "/__SEPARATOR__/"));
//file = substring(args, lastIndexOf(args, "/__SEPARATOR__/")+15);
//suffix = ".tif";

processFile(args);


//processFolder(input);

//function processFolder(input) {
//	list = getFileList(input);
//	for (i = 0; i < list.length; i++) {
//		if(File.isDirectory(input + list[i]))
//			processFolder("" + input + list[i]);
//		if(endsWith(list[i], suffix))
//			processFile(input, output, list[i]);
//	}
//}

function processFile(args) {
	open(args);
	
	run("Multiply...", "value=99.000");
	run("Make Binary");
	run("Dilate");
	run("Close-");
	run("Fill Holes");

	run("Remove Outliers...", "radius=20 threshold=50 which=Dark");
	run("Watershed");

	run("Analyze Particles...", "size=99-Infinity show=Outlines display exclude add in_situ");
	run("Save", "save=file_path");

  saveAs("Results", args+"_count.tsv");
  
}

run("Quit");
