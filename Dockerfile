FROM node:15.11.0-alpine AS client_builder

WORKDIR /app

COPY ./web/client .
RUN yarn install --immutable
RUN yarn build
RUN yarn cache clean

FROM golang:1.17.8-alpine AS go_builder

WORKDIR /app

RUN apk add --update --no-cache git make bash build-base
COPY . .
COPY --from=client_builder /app/dist ./web/client/dist
RUN go get -v -t -d ./...
RUN make install-tools
RUN make build
COPY --from=go_builder /app/bin/phoneinfoga /app/phoneinfoga
EXPOSE 5000
ENTRYPOINT ["/app/phoneinfoga"]
CMD ["--help"]
