
echo $CONFIGPATH
while IFS="," read module module_path url test_present
do
    path_to_file=$module_path/configs/bundles
    if [[ -d $path_to_file ]]
    then
        echo "Copying resource bundles from $path_to_file"
        rsync -r  "$path_to_file" "$CONFIGPATH" 
	fi
	
done < dependencies.txt