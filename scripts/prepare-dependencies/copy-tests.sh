
while IFS="," read module module_path url test_present
do
    path_to_file=$module_path/test/features
    if [[ $test_present == 'true' ]] &&  [[ -d $path_to_file ]]
    then
        echo "Copying resource bundles from $path_to_file"
        rsync -r  "$path_to_file" test 
	fi
	
done < dependencies.txt