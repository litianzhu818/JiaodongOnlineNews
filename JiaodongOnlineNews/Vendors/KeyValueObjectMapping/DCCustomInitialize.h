//
//  DCCustomInitialize.h
//  KeyValueObjectMapping
//
//  Created by Diego Chohfi on 8/21/12.
//  Copyright (c) 2012 dchohfi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^DCCustomInitializeBlock)(Class classOfObjectToGenerate, NSDictionary *values, id parentObject);

@interface DCCustomInitialize : NSObject

@property(nonatomic, readonly) DCCustomInitializeBlock blockInitialize;
@property(nonatomic, readonly) Class classOfObjectToGenerate;

- (id) initWithBlockInitialize: (DCCustomInitializeBlock) blockInitialize
                      forClass: (Class) classOfObjectToGenerate;
- (BOOL) isValidToPerformBlock: (Class) classOfObjectToGenerate;
@end
