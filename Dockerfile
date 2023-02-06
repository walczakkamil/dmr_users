FROM alpine:3.17.1

RUN apk update
RUN apk add gnu-libiconv curl 

WORKDIR /dmr_users

CMD ["./script.sh"]


