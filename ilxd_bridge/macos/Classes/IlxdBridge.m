// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>
#import "IlxdBridge.h"

extern int lurk_commit(const char* expr, uint8_t* out);
extern void load_public_params();
extern int create_proof_ffi(const char* lurk_program, const char* private_params, const char* public_params, size_t max_steps, uint8_t* proof, size_t* proof_len, uint8_t* output_tag, uint8_t* output_val);
extern int verify_proof_ffi(const char* lurk_program, const char* public_params, const uint8_t* packed_proof, size_t proof_size, const uint8_t* expected_tag, const uint8_t* expected_output);
extern int eval_ffi(const char* lurk_program, const char* private_params, const char* public_params, size_t max_steps, uint8_t* output_tag, uint8_t* output_val, size_t* iterations, bool debug);

@implementation IlxdBridge

+ (int)lurkCommit:(NSString *)expr output:(uint8_t *)out {
    const char* cExpr = [expr UTF8String];
    return lurk_commit(cExpr, out);
}

+ (void)loadPublicParams {
    load_public_params();
}

+ (int)createProofFFI:(NSString *)lurkProgram
         privateParams:(NSString *)privateParams
          publicParams:(NSString *)publicParams
              maxSteps:(NSUInteger)maxSteps
                 proof:(uint8_t *)proof
             proofLen:(NSUInteger *)proofLen
            outputTag:(uint8_t *)outputTag
            outputVal:(uint8_t *)outputVal {
    const char* cLurkProgram = [lurkProgram UTF8String];
    const char* cPrivateParams = [privateParams UTF8String];
    const char* cPublicParams = [publicParams UTF8String];
    return create_proof_ffi(cLurkProgram, cPrivateParams, cPublicParams, maxSteps, proof, proofLen, outputTag, outputVal);
}

+ (int)verifyProofFFI:(NSString *)lurkProgram
          publicParams:(NSString *)publicParams
           packedProof:(const uint8_t *)packedProof
             proofSize:(NSUInteger)proofSize
           expectedTag:(const uint8_t *)expectedTag
        expectedOutput:(const uint8_t *)expectedOutput {
    const char* cLurkProgram = [lurkProgram UTF8String];
    const char* cPublicParams = [publicParams UTF8String];
    return verify_proof_ffi(cLurkProgram, cPublicParams, packedProof, proofSize, expectedTag, expectedOutput);
}

+ (int)evalFFI:(NSString *)lurkProgram
    privateParams:(NSString *)privateParams
     publicParams:(NSString *)publicParams
         maxSteps:(NSUInteger)maxSteps
        outputTag:(uint8_t *)outputTag
        outputVal:(uint8_t *)outputVal
       iterations:(NSUInteger *)iterations
            debug:(BOOL)debug {
    const char* cLurkProgram = [lurkProgram UTF8String];
    const char* cPrivateParams = [privateParams UTF8String];
    const char* cPublicParams = [publicParams UTF8String];
    return eval_ffi(cLurkProgram, cPrivateParams, cPublicParams, maxSteps, outputTag, outputVal, iterations, debug);
}

@end
