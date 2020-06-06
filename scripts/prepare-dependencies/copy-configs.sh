
echo "Populating the configs in $CONFIGPATH"
rm -rf $CONFIGPATH
mkdir $CONFIGPATH
while IFS="," read module module_path url test_present
do
    path_to_file=$module_path/configs
    if [[ -d $path_to_file ]]
    then
        echo "Copying configs from $path_to_file"
        rsync -r  "$path_to_file" "$CONFIGPATH" 
	  fi

	
done < dependencies.txt