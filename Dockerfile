FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy your site files to nginx's web root
COPY . /usr/share/nginx/html

# Expose default HTTP port
EXPOSE 80
