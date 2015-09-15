#!/usr/bin/env bash


# rename all files so that it makes sense
function rename_files {
	mkdir input

	cd raw
	rename_files_indir
	cd ..

	cd input
	ls | grep -v .lsm | xargs rm
	cd ..
}

function rename_files_indir {

	for i in * ; do 
		if [ "$i" != ${i//[[:space:]]} ] ; then
			mv "$i" "${i//[[:space:]]}"
		fi
	done

	for i in * ; do
		if [ -d $i ]; then
			cd $i

			rename_files_indir
			cd ..
		else
			prefix=$(pwd)
			prefix=${prefix//'/'/_}_
			mv "$i" "$pthInput$prefix$i"
		fi
	done
}


# measures RGB for each .lsm image
function measure_lsm {
  for file in $( ls $1 | grep -v '.tsv' ); do
    ./ImageJ -macro measure_lsm.ijm $1$file
  done
}

# macro converts each .lsm file in given directory to three .tif files representing channels and saves them into an output directory
function conversion {
	if [ ! -d "convert" ]; then
		mkdir convert
	fi
	./ImageJ -macro convert.ijm $1
}


# macro takes in channel 1 and 2 and returns image of colocalised stain and mesurement of total colocalised area per as many pixels / um
function colocalisation {
	if [ ! -d "colocalisation" ]; then
		mkdir colocalisation
	fi

	for file in $( ls -d convert/* | grep 'C1-\|C2-' ); do
		cp $file colocalisation
	done

	for file in $( ls colocalisation | grep -v '.tsv\|C2-' ); do
			./ImageJ -macro coloc.ijm $1$file
	done
}


# macro takes in stained nuclei .tif file from directory and returns number of cells (nuclei); also saves processed image to specified directory
function count_nuclei {
	if [ ! -d "count" ]; then
		mkdir count
	fi

	for file in $(ls -d convert/* | grep C3-); do
		cp $file count
	done
	 
	for file in $( ls count | grep .tif ); do
  	./ImageJ -macro count.ijm $1$file
  done
  
}


# 
function in_nuclei {
  if [ ! -d "in_nuclei" ]; then
		mkdir in_nuclei
	fi

	for file in $( ls -d convert/* | grep 'C3-\|C2-' ); do
		cp $file in_nuclei
	done

	for file in $( ls in_nuclei | grep -v '.tsv\|C2-' ); do
			timeout 10s ./ImageJ -macro in_nuclei.ijm $1$file
	done
}


function make_results {
	Rscript make_results.R $1
}

function clean_up {
	cd $pthColoc
	ls | grep C2- | xargs rm
	rm *.tsv

  #rm 

	cd $pthCount
	rm *.tsv
}

function exploratory {
  Rscript exploratory.R $1
}


###

# suffix to add to folder names

pth=$1
#pth_return=pwd


pthInput=$pth/input/
pthConv=$pth/convert/
pthColoc=$pth/colocalisation/
pthCount=$pth/count/
pthIn_nuclei=$pth/in_nuclei/

argsRename=$pth/raw
argsConv=$pthInput/__SEPARATOR__/$pthConv
argsColoc=$pthConv
argsCount=$pthCount
argsIn_nuclei=$pthIn_nuclei

#rename_files # dirty; only perform once 
measure_lsm $pthInput
conversion $argsConv
colocalisation $argsColoc
count_nuclei $argsCount
in_nuclei $argsIn_nuclei
#make_results $pth # need to change stuff for differnet runs
#clean_up #TODO dont get rid of things, put them in output!
