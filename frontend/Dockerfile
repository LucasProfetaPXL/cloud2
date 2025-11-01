FROM node:16-alpine AS build
WORKDIR /usr/src/app
COPY . .
RUN npm ci || npm i
RUN npm run build --configuration=production
FROM nginx:alpine
COPY --from=build /usr/src/app/dist/frontend/ /usr/share/nginx/html
COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["/start.sh"]