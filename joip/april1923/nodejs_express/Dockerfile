FROM node:16-alpine
LABEL authour="srikanth" project="nodejs" org="qtdevops"
RUN apk add git 
RUN apk add npm
RUN git clone https://github.com/expressjs/express.git 
RUN cd express && npm install express && \
npm install -g express-generator@4 && \
express /tmp/foo && cd /tmp/foo && npm install 
EXPOSE 3000
WORKDIR /tmp/foo
CMD [ "npm", "start" ]