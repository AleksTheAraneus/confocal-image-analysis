#!/bin/bash


function conversion {
	argsConv=$1
	if [ ! -d "convert" ]; then
		mkdir convert
	fi

	#./ImageJ -macro 0_convert.ijm $argsConv

	#TODO measure
}


function colocalisation {
	argsColoc=$1

	if [ ! -d "colocalisation" ]; then
		mkdir colocalisation
	fi

	for file in $( ls -d convert/* | grep (C1-|C2-) ); do
		cp $file colocalisation
	done

	cd colocalisation
	for file in $( ls colocalisation | grep C1- ); do 
		./ImageJ -macro 0_coloc $argsColoc
	done
	cd ..
}


function count_nuclei {
	argsCount=$1
	
	if [ ! -d "count" ]; then
		mkdir count
	fi

	for file in $(ls -d convert/* | grep C3-); do
		cp $file count
	done
	#./ImageJ -macro 0Count.ijm $argsCount

	#TODO drop measurements which have $Area < 500
}


###

pth=$1
pthInput=$pth/input/
pthConv=$pth/convert/
pthColoc=$pth/colocalisation/
pthCount=$pth/count/

argsConv="$pthInput/__SEPARATOR__/$pthConv"
argsColoc=$pthColoc
argsCount=$pthConv

conversion $argsConv
colocalisation $argsColoc
count_nuclei $argsCount










