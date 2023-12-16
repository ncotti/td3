#include "main.h"

int main(void) {
    HttpServer server(SERVER_IP, SERVER_PORT, CONFIG_FILE);
    server.start();
    return 0;
}
