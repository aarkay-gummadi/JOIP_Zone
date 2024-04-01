FROM ubuntu:22.04
LABEL author="srikanth" org="qt" project="LAMP"
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && \
    apt install nginx -y && \
    apt install  php php-fpm -y 
COPY /info.php /var/www/html/info.php
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]