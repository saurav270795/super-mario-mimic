#This stage installs dependencies and compiles the TypeScript code.
FROM node:18-alpine AS builder

#Set the working directory inside the container.
WORKDIR /app

#Copy package.json and package-lock.json to the working directory.
COPY package*.json ./

#Install application dependencies.
#This includes both development and production dependencies.
RUN npm install

#Copy all the remaining files from your current directory into the container.
COPY . .

#Run the TypeScript build. This assumes your package.json has a "build" script that compiles your .ts files into a directory like 'dist'.
RUN npm run build

#This stage creates the final, lean production image.
FROM node:18-alpine

#Set the working directory in the container.
WORKDIR /app

#Copy only the compiled application and production dependencies from the builder stage.
#This keeps the final image size small.
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

#Install only the production dependencies.
RUN npm install -g serve

#Expose the port that your application will listen on.
EXPOSE 3200

#Define the command that will run when the container starts.It directly executes the compiled JavaScript file.
#Make sure the path 'dist/index.js' matches your build output.
CMD [ "serve", "-p", "3200", "dist" ]
