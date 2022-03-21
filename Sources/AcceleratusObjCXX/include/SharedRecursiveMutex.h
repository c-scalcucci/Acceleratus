//
//  SharedRecursiveMutex.h
//  
//  Created by Chris Scalcucci on 10/18/21.
//

#import <Foundation/Foundation.h>

@interface SharedRecursiveMutex : NSObject

- (void)lock;
- (void)lock_shared;

- (void)try_lock;
- (void)try_lock_shared;

- (void)unlock;
- (void)unlock_shared;

@end

