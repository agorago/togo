# Executes all the test scripts for all the dependencies if they exist
function executeTests(){
  dir=$1
  if [[ -d $dir ]]
    then
        ls $dir |
          while read filename
          do
             echo "Executing script $dir/$filename"
             bash $dir/$filename
          done
	  fi
}
echo "Executing the test scripts for all dependencies"

while IFS="," read module module_path url test_present
do
    path_to_file=$module_path/internal/scripts/test
    executeTests $path_to_file
done < dependencies.txt

executeTests internal/scripts/test
exit 0