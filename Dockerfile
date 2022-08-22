# syntax=docker/dockerfile:latest

ARG version=2.4.0
FROM dcr.bndigital.dev/library/yarn:${version} AS build
COPY .yarn .yarn
COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn
COPY packages/cms/package.json packages/cms/package.json
COPY packages/website/package.json packages/website/package.json
RUN yarn
COPY packages packages
RUN yarn build

ARG version=2.4.0
FROM dcr.bndigital.dev/library/yarn:${version} AS test
COPY --from=build --chown=node /usr/local/src .
ENV APP_ENV=$APP_ENV \
    APP_NAME=$APP_NAME
RUN yarn test


FROM dcr.bndigital.dev/library/nodejs:${version} AS website
COPY --from=build --chown=node /usr/local/src/packages/website/build .


FROM dcr.bndigital.dev/library/nodejs:${version} AS cms
COPY --from=build --chown=node /usr/local/src/packages/cms .
ENTRYPOINT ["yarn"]
CMD ["strapi", "start"]
