//
//  jailbreak.h
//  yalu102
//
//  Created by hongs on 2/21/19.
//  Copyright © 2019 kimjongcracks. All rights reserved.
//

#ifndef jailbreak_h
#define jailbreak_h

void jailbreak(mach_port_t pt, uint64_t kernbase, uint64_t allprocs);
kern_return_t remount_rw(uint64_t kernbase);
kern_return_t load_payload();
#endif /* jailbreak_h */

