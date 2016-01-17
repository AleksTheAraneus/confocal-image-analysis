// macro converts each .tif from .lsm file in given directory to three .tif files representing channels and saves them into an output directory

args = getArgument();
input = substring(args, 0, lastIndexOf(args, "/__SEPARATOR__/"));
output = substring(args, lastIndexOf(args, "/__SEPARATOR__/")+15);

print("Input: "+input);
print("Output: "+output);

//input = getDirectory("Input directory");
//output = getDirectory("Output directory");

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
    getDimensions(d,d,channels,d,d);

    if (channels<2) {
        file_path = output + "C1-" + getTitle();
        saveAs("Tiff", file_path);
        close();
    } else {
        run("Split Channels");
        while (nImages>0) {	
            selectImage(nImages);
            file_path = output + getTitle();
            saveAs("Tiff", file_path);
            close();
        }
    }
}

print("Saved to: " + output);
run("Quit");
