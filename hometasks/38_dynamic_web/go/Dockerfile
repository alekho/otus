FROM golang:1.15.3-alpine3.12
WORKDIR /app
COPY myapp.go /app
RUN go build -o myapp
ENTRYPOINT ["./myapp"]