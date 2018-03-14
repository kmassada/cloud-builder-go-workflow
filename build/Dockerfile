FROM golang:latest  
WORKDIR /workspace
RUN ls -lrt 
ENV CGO_ENABLED 0
ENV GOOS linux
CMD ["go", "build", "-a", "-installsuffix", "cgo", "-o", "main", "./test-go"]