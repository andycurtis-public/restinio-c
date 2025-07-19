// SPDX-FileCopyrightText: 2024-2025 Knode.ai
// SPDX-License-Identifier: Apache-2.0
// Maintainer: Andy Curtis <contactandyc@gmail.com>
#ifndef _RESTINIO_PATH_HANDLER_H
#define _RESTINIO_PATH_HANDLER_H

#include "restinio-c/restinio_c.h"

typedef struct restinio_path_handler_s restinio_path_handler_t;

restinio_path_handler_t *restinio_path_handler(
    const char *source_path,
    const char *uri_path,
    bool directory);

restinio_response_t *restinio_path_handler_cb(
    void *arg,
    const char *method,
    const char *uri,
    const char *body,
    size_t body_length);

#endif