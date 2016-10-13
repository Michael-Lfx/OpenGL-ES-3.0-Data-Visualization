//
//  MyView.m
//  ES3_0_ClearColor
//
//  Created by michael on 13/10/2016.
//  Copyright © 2016 jlai. All rights reserved.
//

#import "MyView.h"
#import <OpenGLES/ES3/gl.h>

#define ARRAY_SIZE(array)       (sizeof(array) / sizeof(array[0]))

@interface MyView () {
    EAGLContext *context;
}

@end

@implementation MyView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupGL];
}

- (void)setupGL {
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!context) {
        NSLog(@"create EAGLContext failed.");
        return;
    }
    if (![EAGLContext setCurrentContext:context]) {
        NSLog(@"set EAGLContext failed.");
        return;
    }
    
    CAEAGLLayer *layer = (CAEAGLLayer *)self.layer;
    layer.opaque = YES;
    layer.contentsScale = [UIScreen mainScreen].scale;
    
    GLuint renderbuffer[1];
    glGenRenderbuffers(ARRAY_SIZE(renderbuffer), renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer[0]);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    
    GLuint framebuffer[1];
    glGenFramebuffers(ARRAY_SIZE(framebuffer), framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer[0]);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer[0]);
    
    glClearColor(1.0, 0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)dealloc {
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext: nil];
    }
}

@end
