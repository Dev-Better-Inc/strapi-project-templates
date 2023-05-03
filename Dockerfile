# syntax=docker/dockerfile:latest
ARG version=3.5.0
FROM dcr.bndigital.dev/library/yarn:${version} AS build
COPY .yarn .yarn
COPY package.json yarn.lock .yarnrc.yml ./
COPY packages/cms/package.json packages/cms/package.json
COPY packages/website/package.json packages/website/package.json
RUN yarn
COPY packages packages
RUN --mount=type=cache,target=/var/cache/yarn \
    yarn build \
 && rm -rf packages/cms/tsconfig.json \
 && rm -rf packages/cms/src/* \
 && rm -rf packages/cms/config \
 && rm -rf packages/cms/public \
 && mv -v packages/cms/dist/* packages/cms \
 && yarn workspaces focus --production --all

FROM dcr.bndigital.dev/library/nodejs:${version}
LABEL org.opencontainers.image.source=https://github.com/bn-digital/project-templates \
      org.opencontainers.image.authors="BN Digital <dev@bndigital.co>"
USER node
WORKDIR /usr/local/src
COPY --from=build --chown=node /usr/local/src/node_modules /usr/local/src/node_modules
COPY --from=build --chown=node /usr/local/src/packages/cms .
COPY --from=build --chown=node /usr/local/src/packages/website/build public
COPY --from=busybox /bin/wget /bin/wget
ENV NODE_ENV=production \
    HOST=0.0.0.0 \
    PORT=5000
EXPOSE $PORT
ENTRYPOINT ["npx"]
CMD ["strapi", "start"]
HEALTHCHECK --interval=10s --timeout=10s --start-period=10s --retries=3 \
        CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:$PORT || exit 1
