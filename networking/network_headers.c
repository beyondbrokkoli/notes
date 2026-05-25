#include <stdint.h> // REQUIRED: Defines uint8_t, uint16_t, etc.

// REQUIRED: Tell the compiler NOT to add padding between struct members.
// For GCC/Clang in Arch Linux, we use __attribute__((packed)).
#pragma pack(push, 1)

struct UDP_Header {
    uint16_t src_port;
    uint16_t dest_port;
    uint16_t length;
    uint16_t checksum;

    // The data sits contiguously right after the header
    uint8_t payload[];
} __attribute__((packed));

struct TCP_Header {
    uint16_t src_port;
    uint16_t dest_port;
    uint32_t seq_num;
    uint32_t ack_num;

    uint16_t data_offset:4;
    uint16_t reserved:6;
    uint16_t flags:6;

    uint16_t window_size;
    uint16_t checksum;
    uint16_t urgent_ptr;

    uint8_t payload[];
} __attribute__((packed));

struct IPv4_Header {
    uint8_t  version:4;
    uint8_t  ihl:4;
    uint8_t  tos;
    uint16_t total_len;

    uint16_t id;
    uint16_t frag_off;

    uint8_t  ttl;
    uint8_t  protocol;
    uint16_t checksum;

    uint32_t src_ip;
    uint32_t dest_ip;

    // The inner header sits sequentially in memory right here
    union {
        struct TCP_Header tcp;
        struct UDP_Header udp;
    } next_header;
} __attribute__((packed));

struct Ethernet_Frame {
    uint8_t  preamble[7];
    uint8_t  sfd;

    uint8_t  dest_mac[6];
    uint8_t  src_mac[6];
    uint16_t eth_type;

    struct IPv4_Header payload;

    // Note: In real C implementations, the FCS trailer is often omitted
    // from the struct because the payload size is variable, making the
    // exact memory offset of the FCS dynamic.
} __attribute__((packed));

#pragma pack(pop)
