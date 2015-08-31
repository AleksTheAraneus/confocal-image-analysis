#!/bin/bash

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
	./ImageJ -macro count.ijm $1
}

function make_results {
	Rscript make_results.R $1
}

function clean_up {
	cd $pthColoc
	ls | grep C2- | xargs rm
	rm *.tsv

	cd $pthCount
	rm *.tsv
}

###

pth=$1
#pth_return=pwd

pthInput=$pth/input/
pthConv=$pth/convert/
pthColoc=$pth/colocalisation/
pthCount=$pth/count/

argsConv=$pthInput/__SEPARATOR__/$pthConv
argsColoc=$pthConv
argsCount=$pthCount

conversion $argsConv
colocalisation $argsColoc
count_nuclei $argsCount
make_results $pth
clean_up








