
# Generates swagger based documentation for the project based on the BPLUS configurations

rm -rf internal/docs
mkdir internal/docs

bin/swagger-gen ${1} ${TOGODIR}/scripts/swagger/templates/header.gohtml internal/docs/swagger-service.go
bin/swagger-gen ${1} ${TOGODIR}/scripts/swagger/templates/op.gohtml internal/docs/swagger-ops.go