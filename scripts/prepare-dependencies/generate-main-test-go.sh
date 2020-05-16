function makeVar(){
    echo $1 | tr '-' '_' 
}

pwd=$(pwd)
dirlast=${pwd##*/}
dirlast=$(echo $dirlast | tr -d "-" )
maintest_file="test/main_test.go"
{
    echo "package test" 
    echo "import ("
    echo '  "testing"'

	echo '  "github.com/DATA-DOG/godog"'
    echo '  bplustest "github.com/MenaEnergyVentures/bplus/test"'
} > ${maintest_file}

while IFS="," read module module_path url test_present
do
    if [[ $test_present == 'true' ]] 
    then
        echo "  $(makeVar $module)test \"$url/test\""
    fi
done < dependencies.txt >>  ${maintest_file}

cat <<! >> ${maintest_file}
)
    
func TestMain(m *testing.M) {
	bplustest.BDD(m, FeatureContext)
}

func FeatureContext(s *godog.Suite) {
!

while IFS="," read module module_path url test_present
do
    if [[ $test_present == 'true' ]] 
    then
        echo "  $(makeVar $module)test.FeatureContext(s)"
    fi
done < dependencies.txt >>  ${maintest_file}

echo "}" >> ${maintest_file}
