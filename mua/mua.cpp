#include "cxxopts.h"
#include <stdio.h>
#include <WinSock2.h>



std::string com_name;
FILE* file_read;
FILE* logger;
bool verbose = false;
int uart_fd;


std::vector<char> data;

void run();
int main(int argc, char** argv) {
    cxxopts::Options option("mua", "UART com writer for minisys1a.");
    option.add_options()("v,verbose", "Verbose mode")(
        "d,device", "Device to write",
        cxxopts::value<std::string>()->default_value("COM5"))("f,file", "0 for stdin, filename for file.",
                cxxopts::value<std::string>()->default_value("0"));
    auto opt = option.parse(argc, argv);
    logger = stderr;
    verbose = opt["v"].as<bool>();
    if (opt["f"].as<std::string>() == "0") {
        file_read = stdin;
    }
    else {
        auto fname = opt["f"].as<std::string>();
        auto er = fopen_s(&file_read, fname.c_str(), "r");
        
    }
    com_name = opt["device"].as<std::string>();
    run();

    fprintf(logger, "Done\n");
    return 0;
}

HANDLE open_port() {
    HANDLE port = CreateFileA(
        com_name.c_str(),
        GENERIC_READ | GENERIC_WRITE,
        0,
        NULL,
        OPEN_EXISTING,
        0,
        NULL
    );

    if (port == (HANDLE)-1) {
        fprintf(logger, "Error: cannot open com %s\n", com_name.c_str());
        exit(-1);
    }

    if (!SetupComm(port, 10240, 1024000)) {
        fprintf(logger, "Error: cannot set buffer.\n");
        exit(-1);
    }
    
    DCB p;
    // 写死参数
    memset(&p, 0, sizeof(p));
    p.DCBlength = sizeof(p);
    p.BaudRate = 128000;
    p.ByteSize = 8;
    p.Parity = NOPARITY;
    p.StopBits = ONESTOPBIT;

    if (!SetCommState(port, &p)) {
        fprintf(logger, "Error: cannot set comm state.\n");
        exit(-1);
    }

    COMMTIMEOUTS timeouts;
    timeouts.ReadIntervalTimeout = 1000;
    timeouts.ReadTotalTimeoutMultiplier = 500;
    timeouts.ReadTotalTimeoutConstant = 2000;
    timeouts.WriteTotalTimeoutMultiplier = 500;
    timeouts.WriteTotalTimeoutConstant = 2000;
    SetCommTimeouts(port, &timeouts);
    PurgeComm(port, PURGE_TXCLEAR | PURGE_RXCLEAR);
    fprintf(logger, "Success to open port!\n");
    return port;
}

inline char process_ch(char c) {
    if (c >= '0' && c <= '9') {
        return c - '0';
    }
    else if ('a' <= c && c <= 'z') {
        return c - 'a' + 10;
    }
    else if ('A' <= c && c <= 'Z') {
        return c - 'A' + 10;
    }
    return 0;
}

std::vector<char> load_data() {
    std::vector<char> data;
    while (!feof(file_read)) {
        auto c = fgetc(file_read);
        if (feof(file_read)) {
            fprintf(logger, "Warning: Input file should be aligned 2. ingore last...");
            break;
        }

        auto c2 = fgetc(file_read);
        c = process_ch(c);
        c2 = process_ch(c2);
        data.push_back(c << 4 | c2);
    }
    return data;
}

void write_port(HANDLE port) {
    constexpr size_t length = 32768;
    size_t written = 0;
   while (written < data.size()) {
        DWORD bw;
        DWORD expect_written = min(data.size() - written, length);
        BOOL write_stat = WriteFile(port, data.data() + written, expect_written * sizeof(char), &bw, NULL);

        if (!write_stat) {
            fprintf(logger, "Error: Write Port error %d\n", (int)write_stat);
            exit(-1);
        }

        if (bw != expect_written * sizeof(char)) {
            fprintf(logger, "Error: written %d, expect %d\n", (int) bw, static_cast<int>(data.size() * sizeof(char)));
            exit(-1);
        }
        fprintf(logger, "Success: Write %d bytes.\n", (int) bw);
        written += expect_written;
    }
}

void recv_response(HANDLE port) {
    constexpr int maxlen = 1024;
    std::vector<char> recv;
    recv.reserve(maxlen);
    DWORD rd;
    BOOL read_stat = ReadFile(port, recv.data(), maxlen, &rd, NULL);

    if (!read_stat) {
        fprintf(logger, "Error: Read Port error %d\n", (int)read_stat);
        exit(-1);
    }
    std::string str(recv.data(), (size_t) rd);
    fprintf(logger, "Resp: %s", str.c_str());
}

void run() {
    data = load_data();
    fprintf(logger, "Data Size = %llu\n", data.size());
    auto port = open_port();
    // system("pause");
    write_port(port);
    // system("pause");
    recv_response(port);
    CloseHandle(port);
}