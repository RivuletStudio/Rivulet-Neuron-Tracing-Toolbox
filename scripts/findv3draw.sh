#!bin/bash
# Script to find all .v3draw files in a folder and save to ../All-V3DRAW/1-N.v3draw

DATAPATH=$1;
GTPATH=$1;

TARGETFOLDER=$DATAPATH/../All-V3DRAW;
mkdir $TARGETFOLDER;

arr=( $(find $DATAPATH -name '*.v3draw') );

for((i=0;i<${#arr[@]};i++))
do
    filename=${arr[${i}]};
    echo "Processing $filename"
    BASEDIR=$(dirname $filename);

    swcarr=( $(find $BASEDIR -name '*.swc') );
    if [ ${#swcarr[@]} -ne 1 ]; then
        >&2 echo "More than 1 swc found in $BASEDIR";
        exit 42;
    else
        swcfile=${swcarr[0]};
        echo "Copying $swcfile to $TARGETFOLDER/$i.swc";
        cp $swcfile $TARGETFOLDER/$i.swc;
    fi

    echo "Copying $filename to $TARGETFOLDER/$i.v3draw";
    cp $filename $TARGETFOLDER/$i.v3draw;
done

