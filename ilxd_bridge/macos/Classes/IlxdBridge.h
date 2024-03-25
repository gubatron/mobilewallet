// Copyright (c) 2024 Project Illium
// This work is licensed under the terms of the MIT License
// For a copy, see <https://github.com/project-illium/mobilewallet/blob/main/LICENSE>
#import <Foundation/Foundation.h>

@interface IlxdBridge : NSObject

+ (int)lurkCommit:(NSString *)expr output:(uint8_t *)out;
+ (void)loadPublicParams;
+ (int)createProofFFI:(NSString *)lurkProgram
         privateParams:(NSString *)privateParams
          publicParams:(NSString *)publicParams
              maxSteps:(NSUInteger)maxSteps
                 proof:(uint8_t *)proof
             proofLen:(NSUInteger *)proofLen
            outputTag:(uint8_t *)outputTag
            outputVal:(uint8_t *)outputVal;
+ (int)verifyProofFFI:(NSString *)lurkProgram
          publicParams:(NSString *)publicParams
           packedProof:(const uint8_t *)packedProof
             proofSize:(NSUInteger)proofSize
           expectedTag:(const uint8_t *)expectedTag
        expectedOutput:(const uint8_t *)expectedOutput;
+ (int)evalFFI:(NSString *)lurkProgram
    privateParams:(NSString *)privateParams
     publicParams:(NSString *)publicParams
         maxSteps:(NSUInteger)maxSteps
        outputTag:(uint8_t *)outputTag
        outputVal:(uint8_t *)outputVal
       iterations:(NSUInteger *)iterations
            debug:(BOOL)debug;

@end
