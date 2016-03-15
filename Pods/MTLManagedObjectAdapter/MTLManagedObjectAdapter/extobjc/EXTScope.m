//
//  EXTScope.m
//  extobjc
//
//  Created by Justin Spahr-Summers on 2011-05-04.
//  Copyright (C) 2012 Justin Spahr-Summers.
//  Released under the MIT license.
//

#import "mtl_moa_EXTScope.h"

void mtl_moa_executeCleanupBlock (__strong mtl_moa_cleanupBlock_t *block) {
    (*block)();
}

