FROM alpine:3.17.1

RUN apk update
RUN apk add gnu-libiconv 
RUN apk add curl
RUN apk add head 

WORKDIR /dmr_users

CMD ["./script.sh"]


