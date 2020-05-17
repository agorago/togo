cwd=$(pwd)
dirname=${cwd##*/}
tempdir=/tmp/${dirname}.$$

mkdir $tempdir
cd ..
cp -r $dirname $tempdir
cd $cwd

while IFS="," read module module_path url test_present
do
    echo "Copying $module_path"
    cp -r $module_path $tempdir
done < dependencies.txt
cp -r $CONFIGPATH $tempdir
docker build -t ${dirname} -f ${TOGODIR}/scripts/docker-deploy/Dockerfile $tempdir

rm -rf $tempdir
exit 0
