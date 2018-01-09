#include <stdio.h>
#include <stdint.h>

typedef enum {
    SOBA_BOOL,
    SOBA_STRING,
    SOBA_DOUBLE,
    SOBA_INTEGER,
} soba_value_type;

typedef intptr_t soba_id;
typedef double soba_double;
typedef char* soba_string;

typedef struct {
    soba_value_type t;
    union {
        int b;
        int i;
        double d;
        char *s;
        void *p;
        soba_id id;
    } v;
} soba_value;
