# Builder
FROM golang:1.10.3 as builder

WORKDIR /go/src/github.com/WhoMeNope/renderer

RUN go get -d -v golang.org/x/image/font \
 && go get -d -v golang.org/x/image/math/fixed \
 && go get -d -v github.com/golang/freetype \
 && go get -d -v github.com/golang/freetype/truetype \
 && go get -d -v github.com/valyala/fasthttp

COPY render ./render
RUN GOPATH=/go GOOS=linux CGO_ENABLED=0 go install -a -installsuffix cgo ./render

COPY serve ./serve
RUN GOPATH=/go GOOS=linux CGO_ENABLED=0 go build -a -installsuffix cgo -o app ./serve

# Deploy
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/
COPY --from=builder /go/src/github.com/WhoMeNope/renderer/serve/fonts ./fonts
COPY --from=builder /go/src/github.com/WhoMeNope/renderer/app .

EXPOSE 3000
ENTRYPOINT ["./app"]
