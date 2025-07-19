Restinio-C: A C Wrapper for the Restinio C++ HTTP Framework

Overview

Restinio-C is a lightweight C wrapper for the Restinio C++ HTTP framework, designed to make it easier for C applications to build HTTP servers. It simplifies HTTP request handling, response generation, and integration with Swagger UI for API documentation.

This library provides:
	1.	A minimalistic interface for defining server options and handling HTTP requests.
	2.	A flexible callback-based mechanism for request routing.
	3.	Built-in support for serving Swagger UI and swagger.json for API documentation.

Features
	•	HTTP and HTTP/2 Support: Build HTTP or HTTP/2 servers with keep-alive and thread pooling.
	•	Callback-Based Request Handling: Define custom request handlers with support for fallback behavior.
	•	Swagger Integration: Serve Swagger UI files and a swagger.json file for API documentation.
	•	Resource Management: Automatic cleanup of responses using user-defined destroy functions.
	•	Lightweight API: Designed to expose the core features of Restinio while abstracting the complexities of C++.

Installation

To use Restinio-C, clone the repository and include the restinio-c headers in your project. You will also need to link against Restinio and its dependencies.

## Dependencies

### asio (1.30.2)
```bash
git clone --branch asio-1-30-2 --single-branch https://github.com/chriskohlhoff/asio.git
cd asio/asio
./autogen.sh
cd ../..
mkdir -p build/asio
cd build/asio
../../asio/asio/configure --prefix=/usr/local
make -j$(nproc)
sudo make install
cd -
rm -rf asio
```

### restinio
```bash
git clone --branch v.0.7.3-fork --single-branch https://github.com/andycurtis-public/restinio.git
mkdir -p build/fmt
mkdir -p build/expected-lite
mkdir -p build/restinio
cd build/fmt
cmake ../../restinio/fmt
make -j$(nproc) && sudo make install
cd ../expected-lite
cmake ../../restinio/expected-lite
make -j$(nproc) && sudo make install
cd ../restinio
cmake ../../restinio/dev \
  -DRESTINIO_SAMPLE=OFF \
  -DRESTINIO_TEST=OFF \
  -DRESTINIO_DEP_FMT=system \
  -DRESTINIO_DEP_EXPECTED_LITE=system
make -j$(nproc) && sudo make install
cd -
rm -rf restinio
```

## Build restinio_c library
```bash
mkdir -p build/restinio-c
cd build/restinio-c
cmake ../..
make -j$(nproc)
sudo make install
cd -
```

## Getting Started

1. Defining a Request Handler

Implement a function to handle incoming HTTP requests. This function must return a restinio_response_t object.

restinio_response_t *handle_request(
    void *arg,
    const char *method,
    const char *uri,
    const char *body,
    size_t body_length)
{
    printf("[user] %s %s %.*s\n", method, uri, (int)body_length, body);

    // Allocate and populate the response object
    restinio_response_t *response = (restinio_response_t *)malloc(sizeof(restinio_response_t));
    const char *response_text = "Hello from Restinio!";
    response->response = strdup(response_text);
    response->response_length = strlen(response_text);
    response->error_code = 0;
    response->error_message = NULL;

    // Add a Content-Type header
    response->headers = (restinio_header_t *)malloc(sizeof(restinio_header_t));
    response->headers->key = strdup("Content-Type");
    response->headers->value = strdup("text/plain");
    response->headers->next = NULL;

    // Set the destroy function
    response->destroy = destroy_response;

    return response;
}

2. Configuring the Server

Define server options in a restinio_options_t structure.

restinio_options_t options = {
    .enable_http2 = true,
    .enable_keepalive = true,
    .enable_thread_pool = true,
    .thread_pool_size = 4,
    .port = 8080,
    .address = "0.0.0.0"
};

3. Initializing the Server with Swagger Support

Use restinio_swagger_handler_arg to integrate Swagger with your server. Pass a fallback handler for custom routes.

restinio_swagger_handler_arg_t *swagger_arg = restinio_swagger_handler_arg(
    NULL,                     // No custom user data
    handle_request,           // Fallback handler
    "path/to/swagger.json",   // Path to swagger.json
    "path/to/swagger_ui/dist" // Path to Swagger UI files
);

restinio_init(&options, restinio_swagger_handler, swagger_arg);

API Reference

1. Server Options (restinio_options_t)

This structure configures the server’s runtime behavior.

Field	Type	Description
enable_ssl	bool	Enable SSL (default: false).
cert_file	char*	Path to the SSL certificate file.
key_file	char*	Path to the SSL private key file.
enable_http2	bool	Enable HTTP/2 support.
enable_keepalive	bool	Enable keep-alive connections.
enable_thread_pool	bool	Use a thread pool for handling requests.
thread_pool_size	int	Number of worker threads (if enabled).
port	unsigned short	Port to bind the server.
address	char*	Address to bind the server (e.g., 0.0.0.0).

2. Request Handler (restinio_handle_request_cb)

typedef restinio_response_t *(*restinio_handle_request_cb)(
    void *arg,
    const char *method,
    const char *uri,
    const char *body,
    size_t body_length
);

A callback function for handling HTTP requests. Returns a dynamically allocated restinio_response_t.

3. Response Object (restinio_response_t)

Represents an HTTP response.

Field	Type	Description
response	char*	Response body.
response_length	size_t	Length of the response body.
error_code	int	HTTP status code (0 for success).
error_message	char*	Error message (if applicable).
headers	restinio_header_t*	Linked list of HTTP headers.
destroy	restinio_destroy_cb	Callback to clean up response resources.

4. Swagger Integration

Use the Swagger handler to serve API documentation.

Factory Function

restinio_swagger_handler_arg_t *restinio_swagger_handler_arg(
    void *user_data,
    restinio_handle_request_cb user_callback,
    const char *swagger_json_path,
    const char *swagger_ui_dist);

Handler Function

restinio_response_t *restinio_swagger_handler(
    void *arg,
    const char *method,
    const char *uri,
    const char *body,
    size_t body_length);

Example: Full Implementation

#include "restinio-c/restinio_c.h"
#include "restinio-c/handlers/restinio_swagger.h"

int main() {
    restinio_options_t options = {
        .enable_http2 = true,
        .enable_keepalive = true,
        .enable_thread_pool = true,
        .thread_pool_size = 4,
        .port = 8080,
        .address = "0.0.0.0"
    };

    restinio_swagger_handler_arg_t *swagger_arg = restinio_swagger_handler_arg(
        NULL,
        handle_request,
        "swagger_ui/swagger.json",
        "swagger_ui/dist"
    );

    restinio_init(&options, restinio_swagger_handler, swagger_arg);

    printf("Server running at http://%s:%d\n", options.address, options.port);
    getchar();

    restinio_destroy();
    free(swagger_arg);

    return 0;
}
