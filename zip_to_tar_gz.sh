#!/bin/sh

ARCHIVE_PATH="$1"

function is_empty {
    local dir="$1"
    shopt -s nullglob
    local files=( "$dir"/* "$dir"/.* )
    [[ ${#files[@]} -eq 2 ]]
}

# setup tmp unzip folder
tempzipdir=/private/tmp/unzipped
if [ -d "$tempzipdir" ]; then
    echo "$tempzipdir is a directory, erasing and creating new directory"
    rm -r $tempzipdir
    mkdir $tempzipdir
else
	mkdir $tempzipdir
	echo "$tempzipdir is now a new directory"
fi

# check if passed file exists, if it does unzip it.
if [[ (-f "$ARCHIVE_PATH") && (${ARCHIVE_PATH: -4} == ".zip") ]]; then
	echo "@ARCHIVE_PATH is a .zip file"
	unzip "$ARCHIVE_PATH" -d $tempzipdir
	echo "unzip complete"
else
	echo "File does not exist, or is not a .zip file!"
    rm -r $tempzipdir
	exit
fi

# check if unzip produced any files.
if is_empty "$tempzipdir"; then 
	echo "Nothing to extract from .zip"
    rm -r $tempzipdir
	exit
else
	# convert to tar gz and drop in Downloads folder
	cd /Users/"$USER"/Downloads
	echo "moved to $PWD for conversion"
	if [ -f /Users/"$USER"/Downloads/temp.tar.gz ]; then
		rm temp.tar.gz
	fi
	FILE_NAME=$(basename "$ARCHIVE_PATH" ".zip")
	tar czvf "$FILE_NAME.tar.gz" $tempzipdir
	echo "file converted to Downloads folder."
	cd $OLDPWD
	echo "moved back to $PWD"
fi

# cleanup private unzipp
rm -r $tempzipdir
if [ -d "$tempzipdir" ]; then
    rm -r $tempzipdir
    echo "$tempzipdir removed"
fi

echo "Conversion complete!"