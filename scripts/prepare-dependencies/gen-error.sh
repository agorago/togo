
# Generates the error codes in all the modules
errpath="internal/err/codes.go"

while IFS="," read module module_path url test_present
do
    path_to_file=$module_path/$errpath
    if [[ -f $path_to_file ]]
    then
        echo "Generating error codes for $path_to_file"
        go generate $path_to_file
    fi
done < dependencies.txt