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
	
 	run("Arrange Channels...", "new=132");

  save(replace(args, ".lsm", ".tif"));
  
}

run("Quit");


