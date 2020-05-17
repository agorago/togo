FROM golang:alpine as builder
# Install make and certificates
#RUN apk --no-cache add tzdata zip ca-certificates make git
# Make repository path
RUN mkdir -p /tmp/target
WORKDIR  /tmp/target
# Copy Makefile first, it will save time during development.
# COPY Makefile ./Makefile
# Copy all project files
ADD . .
WORKDIR sample-deploy

# Generate a binary
# RUN go get -d -v
RUN apk add make
RUN make build
# Second (final) stage, base image is scratch
FROM alpine
ENV CONFIGPATH=/configs
# Copy statically linked binary
COPY --from=builder /tmp/target/sample-deploy/bin/main /main
COPY --from=builder /tmp/target/configs /configs
# Copy SSL certificates, eventhough we don't need it for this example
# but if you decide to talk to HTTPS sites, you'll need this.
#COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# Notice "CMD", we don't use "Entrypoint" because there is no OS
EXPOSE 8080
CMD ["/main" ]