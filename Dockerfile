FROM node:20-alpine

EXPOSE 8061

WORKDIR /iframely

# Create new non-root user
RUN addgroup -S iframelygroup && adduser -S iframely -G iframelygroup
RUN apk add g++ make python3

# This will change the config to `config.<VALUE>.js` and the express server to change its behaviour.
# You should overwrite this on the CLI with `-e NODE_ENV=production`.
ENV NODE_ENV=local

## Utilize docker layer cache
COPY package.json /iframely/
RUN yarn install --pure-lockfile --production

COPY . /iframely

# Check if the file exists before changing ownership
RUN [ -f /iframely/config.local.js ] && chown -R iframely /iframely/config.local.js || echo "File /iframely/config.local.js does not exist"

RUN chmod +x /iframely/docker/entrypoint.sh

USER iframely

ENTRYPOINT [ "/iframely/docker/entrypoint.sh" ]