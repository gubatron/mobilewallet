// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>
#include <cstdint> 
// Declare the Rust functions that are defined in the Rust library
extern "C" {
    int lurk_commit(const char* expr, uint8_t* out);
    void load_public_params();
    int create_proof_ffi(const char* lurk_program, const char* private_params, const char* public_params, size_t max_steps, uint8_t* proof, size_t* proof_len, uint8_t* output_tag, uint8_t* output_val);
    int verify_proof_ffi(const char* lurk_program, const char* public_params, const uint8_t* packed_proof, size_t proof_size, const uint8_t* expected_tag, const uint8_t* expected_output);
    int eval_ffi(const char* lurk_program, const char* private_params, const char* public_params, size_t max_steps, uint8_t* output_tag, uint8_t* output_val, size_t* iterations, bool debug);
}
