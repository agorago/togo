
pwd=$(pwd)
dirlast=${pwd##*/}
dirlast=$(echo $dirlast | tr -d "-" )
dependencies_file="dependencies.go"
{
    echo "package ${dirlast}" 
    echo "import ("
} > ${dependencies_file}

while IFS="," read module module_path url test_present
do
    echo "_ \"$url\""
done < dependencies.txt >>  ${dependencies_file}

echo ")" >> ${dependencies_file}