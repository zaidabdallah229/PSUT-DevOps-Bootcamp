# Keep the provided course routing configuration
FROM alpine:3.21 AS config
WORKDIR /config
COPY nginx.conf ./nginx.conf

FROM nginx:1.27-alpine
COPY --from=config /config/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
