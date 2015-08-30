// macro converts each .lsm file in given directory to three .tif files representing channels and saves them into an output directory

args = getArgument();
input = substring(args, 0, lastIndexOf(args, "/__SEPARATOR__/"));
output = substring(args, lastIndexOf(args, "/__SEPARATOR__/")+15);

print("Input: "+input);
print("Output: "+output);

//input = getDirectory("Input directory");
//output = getDirectory("Output directory");

suffix = ".lsm";

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
	run("Split Channels");
		while (nImages>0) {	
		selectImage(nImages);
		file_path = output + replace(getTitle(), ".lsm", ".tif");
		run("Save", "save=file_path");
		close();
	}
}
print("Saved to: " + output);
