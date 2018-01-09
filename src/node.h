typedef enum {
  NODE_VALUE,
  NODE_BLOCK,
  NODE_OP,
  NODE_LET,
  NODE_VAR,
} node_type;

typedef struct {
  node_type type;
  value val;
} node;

typedef struct {
  node* l;
  node* r;
} node_let;

typedef struct {
  node* l;
  char* op;
  node* r;
} node_op;

typedef {
  node* args;
  node* compstmt;
} node_block;

