
# Enable Artifact Registry API for the project https://console.developers.google.com/apis/api/artifactregistry.googleapis.com/overview?project=1064159726085

# Line below tags the image and points to the Google Cloud Artifact Registry
# docker tag SOURCE-IMAGE LOCATION    -docker.pkg.dev/PROJECT-ID          /REPOSITORY/IMAGE:TAG
# the url for pusing to the repo is best copied from the repository page itself
# docker tag 019a0b88fbbb europe-west2-docker.pkg.dev/nextjs-deployment-test-408815/nextjs-dasboard-repo/nextjs-dashboard:init

# To push
# docker push LOCATION-docker.pkg.dev/PROJECT-ID/REPOSITORY/IMAGE:TAG



# Get NPM packages
FROM andrewcochrane24/alpine-node18-npm AS dependencies
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

# Rebuild the source code only when needed
FROM andrewcochrane24/alpine-node18-npm AS builder
WORKDIR /app
COPY . .
COPY --from=dependencies /app/node_modules ./node_modules
RUN npm run build

# Production image, copy all the files and run next
FROM andrewcochrane24/alpine-node18-npm AS runner
WORKDIR /app

ENV NODE_ENV production

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

USER nextjs
EXPOSE 3000

CMD ["npm", "start"]