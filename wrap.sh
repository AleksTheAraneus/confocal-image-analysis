#!/usr/bin/env bash

# TODO: make conversion.ijm create dummy channels and the rest to check if the channel exists before proceeding
# use: ./wrap.sh /path/to/folder/with/scripts/
# optionally set ./wrap.sh /path/ --swap-channels

# rename all files so that it makes sense
function rename_files {
    if [ -d "raw" ]; then
        mkdir input

        cd raw
        rename_files_indir
        cd ..

        cd input
#       ls | grep -v .lsm | xargs rm
#       ls | grep -v .avi | xargs rm # -v ?
#       ls | grep -v .mov | xargs rm
#       ls | grep -v .czi | xargs rm
        cd ..
    fi
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

function swap_channels {
  echo "swapping channels 132"
  for file in $( ls $1 | grep '.lsm' ); do 
    ./ImageJ -macro arrange_channels.ijm $1$file
    done
}

function lsm_to_tif {
  ./ImageJ -macro lsm_to_tif.ijm $1
}

# also for tiff files; measures RGB for each .lsm image
function measure_lsm {
  for file in $( ls $1 | grep -v '.lsm\|.tsv' ); do #measure for tiffs only
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

    for file in $( ls -d convert/* | grep 'C2-\|C1-' ); do
        cp $file colocalisation
    done

    for file in $( ls colocalisation | grep -v '.tsv\|C1-' ); do
        timeout 10s ./ImageJ -macro coloc.ijm $1$file
    done
}


# macro takes in stained nuclei .tif file from directory and returns number of cells (nuclei); also saves processed image to specified directory
function count_nuclei {
    if [ ! -d "count" ]; then
        mkdir count
    fi

    for file in $(ls -d convert/* | grep C2-); do #ATT
        cp $file count
    done
     
    for file in $( ls count | grep .tif ); do
    ./ImageJ -macro count.ijm $1$file
  done
  
}


# 
function in_nuclei {
#	channelNuclei=C3
#	channelColoc=C2
    if [ ! -d "in_nuclei" ]; then
        mkdir in_nuclei
    fi

    for file in $( ls -d convert/* | grep 'C2-\|C1-' ); do #ATT (also in make_results.R)
        cp $file in_nuclei
    done

    for file in $( ls in_nuclei | grep -v '.tsv\|C1-' ); do #ATT (also in make_results.R)
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

    cd $pthCount
    rm *.tsv
}

function exploratory {
  Rscript exploratory.R $1
}


###

# suffix to add to folder names
#pth_return=pwd

pth=$1
swap_channels=$2

# folders
pthInput=$pth/input/
pthConv=$pth/convert/
pthColoc=$pth/colocalisation/
pthCount=$pth/count/
pthIn_nuclei=$pth/in_nuclei/

# arguments for each function
argsRename=$pth/raw
argsLsm_tif=$pthInput
argsConv=$pthInput/__SEPARATOR__/$pthConv
argsColoc=$pthConv
argsCount=$pthCount
argsIn_nuclei=$pthIn_nuclei

#rename_files # dirty; only perform once 
#if [ -n "$swap_channels" ]; then
#  swap_channels $pthInput
#fi

#lsm_to_tif $pthInput
#measure_lsm $pthInput
#conversion $pthInput/__SEPARATOR__/$pthConv
colocalisation $pthConv
#count_nuclei $pthCount #ATT for some .lsm images there are no 3 channels; point ot which is with nucl
#in_nuclei $pthIn_nuclei #ATT same here
#make_results $pth # need to change stuff for differnet runs in make_results.R
#clean_up #TODO dont get rid of things, put them in output!
