// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>
#import <Foundation/Foundation.h>

// libillium_crypto.a rust symbols
extern void generate_secret_key(uint8_t* out);
extern void secret_key_from_seed(const uint8_t* seed, uint8_t* out);
extern void priv_to_pub(const uint8_t* bytes, uint8_t* out);
extern void compressed_to_full(const uint8_t* bytes, uint8_t* out_x, uint8_t* out_y);
extern void sign(const uint8_t* privkey, const uint8_t* message_digest, uint8_t* out);
extern bool verify(const uint8_t* pub_bytes, const uint8_t* digest_bytes, const uint8_t* sig_r, const uint8_t* sig_s);