/*
 * set.m - High-level handler to set boot nonce
 *
 * Copyright (c) 2017 Siguza & tihmstar
 */

#include <errno.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <mach/mach.h>
#include "IOKit/IOKitLib.h"
#include <CoreFoundation/CoreFoundation.h>

#include "arch.h"
//#include "v0rtex.h"
#include "nvpatch.h"
#include "set.h"
#include "common.h"

int unlock_nvram(task_t *tfp0, kptr_t *kslide)
{
    int ret = 0;
    return nvpatch(tfp0, 0xfffffff007004000 + kslide, "com.apple.System.boot-nonce");
}

bool set_generator(const char *gen)
{
    bool ret = false;

    CFStringRef str = CFStringCreateWithCStringNoCopy(NULL, gen, kCFStringEncodingUTF8, kCFAllocatorNull);
    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL, 0, &kCFCopyStringDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    if(!str || !dict)
    {
        LOG("Failed to allocate CF objects");
    }
    else
    {
        CFDictionarySetValue(dict, CFSTR("com.apple.System.boot-nonce"), str);
        CFRelease(str);

        io_service_t nvram = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IODTNVRAM"));
        if(!MACH_PORT_VALID(nvram))
        {
            LOG("Failed to get IODTNVRAM service");
        }
        else
        {
            if(1)
            {
                kern_return_t kret = IORegistryEntrySetCFProperties(nvram, dict);
                LOG("IORegistryEntrySetCFProperties: %s", mach_error_string(kret));
                if(kret == KERN_SUCCESS)
                {
                    ret = true;
                    LOG("generator set");
                }
            }
        }

        CFRelease(dict);
    }

    return ret;
}

bool get_generator(void)
{
  NSString *bootNonce = [[NSMutableString alloc] initWithString:@""];
  CFMutableDictionaryRef bdict = IOServiceMatching("IODTNVRAM");
  io_service_t nvservice = IOServiceGetMatchingService(kIOMasterPortDefault, bdict);
  
  if(MACH_PORT_VALID(nvservice))
  {
    io_string_t buffer;
    unsigned int len = 256;
    kern_return_t kret = IORegistryEntryGetProperty(nvservice, "com.apple.System.boot-nonce", buffer, &len);
    if(kret == KERN_SUCCESS)
    {
      bootNonce = [NSString stringWithFormat:@"%s", (char *) buffer];
    }
    else
    {
      LOG("Reading var failed");
    }
  }
  else
  {
    LOG("Failed to get IODTNVRAM");
  }
  LOG("current generator: %@", bootNonce);
  return 0;
}


bool dump_apticket(const char *to)
{
    bool ret = false;
    if(1)
    {
        const char *from = "/System/Library/Caches/apticket.der";
        struct stat s;
        if(stat(from, &s) != 0)
        {
            LOG("stat failed: %s", strerror(errno));
        }
        else
        {
            FILE *in  = fopen(from, "rb");
            if(in == NULL)
            {
                LOG("failed to open src: %s", strerror(errno));
            }
            else
            {
                FILE *out = fopen(to, "wb");
                if(out == NULL)
                {
                    LOG("failed to open dst: %s", strerror(errno));
                }
                else
                {
                    char *buf = malloc(s.st_size);
                    if(buf == NULL)
                    {
                        LOG("failed to alloc buf: %s", strerror(errno));
                    }
                    else
                    {
                        fread(buf, s.st_size, 1, in);
                        fwrite(buf, s.st_size, 1, out);
                        free(buf);
                        ret = true;
                    }
                    fclose(out);
                }
                fclose(in);
            }
        }
    }
    return ret;
}
