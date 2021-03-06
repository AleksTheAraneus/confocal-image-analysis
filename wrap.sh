#!/usr/bin/env bash

# rename all files so that it makes sense
function rename_files {
    if [ -d "$RAW_DIR" ]; then
        if [ ! -d $1 ]; then
            mkdir $1
        fi

        cd $RAW_DIR
        rename_files_indir $1 #pass the $RAW_DIR/input further
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
            rename_files_indir $1
            cd ..
        else
            prefix=$(pwd)
            prefix=${prefix//'/'/_}_
            mv "$i" "$where_is_input$1$prefix$i"
        fi
    done
}

function swap_channels {
  for file in $( ls $1 | grep '.lsm' ); do 
    $where_is_script/ImageJ -macro $where_is_script/arrange_channels.ijm "$where_is_input$1$file"
    done
}

function lsm_to_tif {
  $where_is_script/ImageJ -macro $where_is_script/lsm_to_tif.ijm $where_is_input$1
}

# also for tiff files; measures RGB for each .lsm image
function measure_channels {
  for file in $( ls $1 | grep -v '.lsm\|.tsv' ); do #measure for tiffs only
    $where_is_script/ImageJ -macro $where_is_script/measure_channels.ijm $where_is_input$1$file
  done
}

# macro splits each .lsm file in given directory to three .tif files representing channels and saves them into an output directory
function split_channels {
    if [ ! -d "split" ]; then
        mkdir split
    fi
    $where_is_script/ImageJ -macro $where_is_script/split.ijm $where_is_input$1/__SEPARATOR__/$where_is_input"split/"
}


# macro takes in channel 1 and 2 and returns image of colocalised stain and mesurement of total colocalised area per as many pixels / um
function colocalisation {
    if [ ! -d "colocalisation" ]; then
        mkdir colocalisation
    fi

    for file in $( ls -d split/* | grep 'C2-\|C1-' ); do
        cp $file $where_is_input"colocalisation/"
    done

    for file in $( ls colocalisation | grep -v '.tsv\|C1-' ); do
        timeout 10s $where_is_script/ImageJ -macro $where_is_script/coloc.ijm $where_is_input"colocalisation/"$file
    done
}


# macro takes in stained nuclei .tif file from directory and returns number of cells (nuclei); also saves processed image to specified directory
function count_nuclei {
    if [ ! -d "count" ]; then
        mkdir count
    fi

    for file in $(ls -d split/* | grep C2-); do #ATT
        cp $file $where_is_input"count/"
    done
     
    for file in $( ls count | grep -v '_coloc.tsv' ); do
        $where_is_script/ImageJ -macro $where_is_script/count.ijm $where_is_input"count/"$file
    done
  
}


# 
function in_nuclei {
#   channelNuclei=C3
#   channelColoc=C2
    if [ ! -d "in_nuclei" ]; then
        mkdir in_nuclei
    fi

    for file in $( ls -d split/* | grep 'C2-\|C1-' ); do #ATT (also in make_results.R)
        cp $file in_nuclei
    done

    for file in $( ls in_nuclei | grep -v '.tsv\|C1-' ); do #ATT (also in make_results.R)
            timeout 10s $where_is_script/ImageJ -macro $where_is_script/in_nuclei.ijm $where_is_input$1$file
    done
}


function make_results {
    Rscript make_results.R $where_is_input$1
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

# options: --path to the analysis folder --procedure (incl. swap channels)
while getopts "hd:p:" OPTION
do
    case $OPTION in
    h)  echo "TODO: Add a usage file."
        exit 1
        ;;
    d)  RAW_DIR=$OPTARG
        ;;
    p)  PROCEDURE=$OPTARG
        ;;
    ?)  exit
    esac
done

# echo "Something wrong with the options you did (not?) specify. Check out the help file."
where_is_script="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/ # path to bin
where_is_input=$(pwd)/

#

case $PROCEDURE in
    rename_files)
        rename_files input/ # dirty; only perform once 
        echo $RAW_DIR
        echo "Rename OK"
        ;;
    swap_channels)
        echo "---swapping channels 132"
        swap_channels input/
        echo "Swap OK"
        echo "Not validated"
        ;;
    lsm_to_tiff)
        lsm_to_tif input/
        echo "To tiff OK"
        ;;
    measure_channels)
        measure_channels input/
        echo "Measure OK"
        ;;
    split_channels)
        split_channels input/
        echo "Split OK"
        ;;
    measure_colocalisation)
        colocalisation split/
        echo "Colocalisation OK"
        ;;
    count_nuclei)
        count_nuclei count/ #ATT for some .lsm images there are no 3 channels; point ot which is with nucl
        echo "Count OK"
        ;;
    measure_in_nuclei)
        in_nuclei in_nuclei/ #ATT same here
        echo "In nuclei OK"
        ;;
    make_results)
        make_results #TODO ARG # need to change stuff for differnet runs in make_results.R
        echo "Results OK"
        ;;
    *)
        echo "No valid precedure specified (?)."
        ;;
esac

        #clean_up #TODO dont get rid of things, put them in output!


