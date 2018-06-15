/*
 * set.h - High-level handler to set boot nonce
 *
 * Copyright (c) 2017 Siguza & tihmstar
 */

#ifndef SET_H
#define SET_H

#include <stdbool.h>
#include "common.h"


int unlock_nvram(task_t *tfp0, kptr_t *kslide);
bool set_generator(const char *gen);
bool get_generator(void);
bool dump_apticket(const char *to);

#endif
